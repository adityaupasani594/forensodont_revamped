import uuid
from fastapi import APIRouter, Depends, UploadFile, File, Request, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.models.opg_image import OPGImage
from app.core.audit import log_audit_event
from app.worker import preprocess_task

router = APIRouter()

@router.post("/cases/{case_id}/opg")
async def upload_opg(
    request: Request,
    case_id: uuid.UUID,
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    # Mocking upload logic
    s3_key = f"original_{uuid.uuid4()}_{file.filename}"
    
    opg = OPGImage(
        case_id=case_id,
        image_type="post_mortem",
        s3_key=s3_key,
        original_filename=file.filename,
        file_format=file.content_type
    )
    db.add(opg)
    await log_audit_event(db, action="opg_uploaded", case_id=case_id, request=request)
    await db.commit()
    await db.refresh(opg)
    
    return opg

@router.post("/convert-dicom")
async def convert_dicom(file: UploadFile = File(...)):
    # Mock DICOM to PNG conversion
    return {"status": "success", "png_url": "mock_png_url"}

@router.post("/preprocess")
async def preprocess(
    opg_image_id: str
):
    job_id = str(uuid.uuid4())
    # Trigger celery task
    preprocess_task.delay(opg_image_id, job_id)
    return {
        "job_id": job_id,
        "websocket_url": f"ws://localhost:8000/api/v1/opg/preprocess/progress/{job_id}"
    }
