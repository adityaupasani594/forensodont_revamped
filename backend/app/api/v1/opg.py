import uuid
import json
from pathlib import Path
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, UploadFile, File, Request, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.config import settings
from app.core.database import get_db
from app.models.opg_image import OPGImage
from app.core.audit import log_audit_event

router = APIRouter()


def _register_case_asset(case_id: uuid.UUID, asset_type: str, local_path: Path, original_filename: str | None):
    registry_dir = Path(settings.UPLOAD_DIR) / "case_assets"
    registry_dir.mkdir(parents=True, exist_ok=True)
    registry_path = registry_dir / f"{case_id}.json"

    if registry_path.exists():
        registry = json.loads(registry_path.read_text(encoding="utf-8"))
    else:
        registry = {"case_id": str(case_id), "assets": []}

    asset = {
        "id": str(uuid.uuid4()),
        "type": asset_type,
        "path": str(local_path),
        "original_filename": original_filename,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    registry["assets"].append(asset)
    registry_path.write_text(json.dumps(registry, indent=2), encoding="utf-8")
    return asset

@router.post("/cases/{case_id}/opg")
async def upload_opg(
    request: Request,
    case_id: uuid.UUID,
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    upload_dir = Path(settings.UPLOAD_DIR)
    upload_dir.mkdir(parents=True, exist_ok=True)

    safe_name = Path(file.filename or "upload.png").name
    local_key = f"original_{uuid.uuid4()}_{safe_name}"
    local_path = upload_dir / local_key

    content = await file.read()
    if not content:
        raise HTTPException(status_code=400, detail="Uploaded file is empty")

    local_path.write_bytes(content)
    _register_case_asset(case_id, "opg", local_path, file.filename)
    
    opg = OPGImage(
        case_id=case_id,
        image_type="post_mortem",
        s3_key=str(local_path),
        original_filename=file.filename,
        file_format=file.content_type
    )
    db.add(opg)
    await log_audit_event(db, action="opg_uploaded", case_id=case_id, request=request)
    await db.commit()
    await db.refresh(opg)
    
    return opg


@router.post("/cases/{case_id}/audio")
async def upload_audio(
    request: Request,
    case_id: uuid.UUID,
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
):
    upload_dir = Path(settings.UPLOAD_DIR)
    upload_dir.mkdir(parents=True, exist_ok=True)

    safe_name = Path(file.filename or "note.wav").name
    local_key = f"audio_{uuid.uuid4()}_{safe_name}"
    local_path = upload_dir / local_key

    content = await file.read()
    if not content:
        raise HTTPException(status_code=400, detail="Uploaded audio file is empty")

    local_path.write_bytes(content)
    asset = _register_case_asset(case_id, "audio", local_path, file.filename)
    await log_audit_event(db, action="audio_uploaded", case_id=case_id, request=request)
    await db.commit()

    return {"status": "success", "asset": asset}


@router.post("/cases/{case_id}/video")
async def upload_video(
    request: Request,
    case_id: uuid.UUID,
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
):
    upload_dir = Path(settings.UPLOAD_DIR)
    upload_dir.mkdir(parents=True, exist_ok=True)

    safe_name = Path(file.filename or "clip.mp4").name
    local_key = f"video_{uuid.uuid4()}_{safe_name}"
    local_path = upload_dir / local_key

    content = await file.read()
    if not content:
        raise HTTPException(status_code=400, detail="Uploaded video file is empty")

    local_path.write_bytes(content)
    asset = _register_case_asset(case_id, "video", local_path, file.filename)
    await log_audit_event(db, action="video_uploaded", case_id=case_id, request=request)
    await db.commit()

    return {"status": "success", "asset": asset}


@router.get("/cases/{case_id}/assets")
async def list_case_assets(case_id: uuid.UUID):
    registry_path = Path(settings.UPLOAD_DIR) / "case_assets" / f"{case_id}.json"
    if not registry_path.exists():
        return {"case_id": str(case_id), "assets": []}

    return json.loads(registry_path.read_text(encoding="utf-8"))

@router.post("/convert-dicom")
async def convert_dicom(file: UploadFile = File(...)):
    # Mock DICOM to PNG conversion
    return {"status": "success", "png_url": "mock_png_url"}

@router.post("/preprocess")
async def preprocess(
    opg_image_id: str
):
    from app.worker import preprocess_task

    job_id = str(uuid.uuid4())
    # Trigger celery task
    preprocess_task.delay(opg_image_id, job_id)
    return {
        "job_id": job_id,
        "websocket_url": f"ws://localhost:8000/api/v1/opg/preprocess/progress/{job_id}"
    }
