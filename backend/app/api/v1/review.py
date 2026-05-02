import uuid
from fastapi import APIRouter, Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.models.expert_review import ExpertReview
from app.core.audit import log_audit_event

router = APIRouter()

@router.post("/cases/{case_id}/submit")
async def submit_for_review(
    request: Request,
    case_id: uuid.UUID,
    data: dict, # candidate_id
    db: AsyncSession = Depends(get_db)
):
    # Sends case to odontologist queue
    await log_audit_event(db, action="submitted_for_review", case_id=case_id, request=request)
    await db.commit()
    return {"status": "success"}

@router.post("/cases/{case_id}/decision")
async def review_decision(
    request: Request,
    case_id: uuid.UUID,
    data: dict, # candidate_id, decision, comment, annotations, interpol_dvi_ref
    db: AsyncSession = Depends(get_db)
):
    review = ExpertReview(
        case_id=case_id,
        candidate_id=uuid.UUID(data.get("candidate_id")),
        decision=data.get("decision"),
        comment=data.get("comment"),
        annotations=data.get("annotations"),
        interpol_dvi_ref=data.get("interpol_dvi_ref")
    )
    # Note: missing odontologist_id, would normally come from current_user
    db.add(review)
    
    await log_audit_event(db, action="review_decision", case_id=case_id, request=request)
    await db.commit()
    return review

@router.get("/queue")
async def get_queue():
    # Returns list of cases awaiting review
    return []
