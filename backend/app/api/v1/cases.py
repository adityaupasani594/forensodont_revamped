import uuid
from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.core.database import get_db
from app.models.case import Case
from app.core.audit import log_audit_event

router = APIRouter()

@router.post("/")
async def create_case(
    request: Request,
    case_data: dict,
    db: AsyncSession = Depends(get_db)
):
    new_case = Case(**case_data)
    db.add(new_case)
    await log_audit_event(db, action="case_created", case_id=new_case.id, request=request)
    await db.commit()
    await db.refresh(new_case)
    return new_case

@router.get("/")
async def list_cases(
    db: AsyncSession = Depends(get_db),
    status: str = Query(None),
    limit: int = 10,
    page: int = 1
):
    query = select(Case)
    if status:
        query = query.where(Case.status == status)
    query = query.limit(limit).offset((page - 1) * limit)
    result = await db.execute(query)
    return result.scalars().all()

@router.get("/{case_id}")
async def get_case(case_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Case).where(Case.id == case_id))
    return result.scalars().first()

@router.patch("/{case_id}")
async def update_case(case_id: uuid.UUID, case_data: dict, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Case).where(Case.id == case_id))
    case = result.scalars().first()
    if case:
        for key, value in case_data.items():
            setattr(case, key, value)
        await db.commit()
    return case

@router.delete("/{case_id}")
async def delete_case(case_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Case).where(Case.id == case_id))
    case = result.scalars().first()
    if case:
        case.status = 'deleted'
        await db.commit()
    return {"status": "success"}
@router.post("/{case_id}/promote-unidentified")
async def promote_case(
    request: Request,
    case_id: uuid.UUID, 
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(Case).where(Case.id == case_id))
    case = result.scalars().first()
    if not case:
        return {"error": "Case not found"}
    
    case.status = 'unidentified'
    await log_audit_event(db, action="promoted_to_unidentified", case_id=case_id, request=request)
    await db.commit()
    return {"status": "success"}
