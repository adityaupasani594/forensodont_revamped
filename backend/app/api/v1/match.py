import uuid
import json
import asyncio
from fastapi import APIRouter, Depends, Request, WebSocket, WebSocketDisconnect
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.models.match_job import MatchJob
from app.models.match_candidate import MatchCandidate
from app.core.audit import log_audit_event
from app.worker import match_task, redis_client
from app.core.config import settings

router = APIRouter()

@router.post("/")
async def run_match(
    request: Request,
    data: dict, # case_id, opg_image_id, filters
    db: AsyncSession = Depends(get_db)
):
    case_id = uuid.UUID(data.get("case_id"))
    job_id = str(uuid.uuid4())
    
    job = MatchJob(
        id=uuid.UUID(job_id),
        case_id=case_id,
        filters=data.get("filters", {})
    )
    db.add(job)
    await log_audit_event(db, action="match_started", case_id=case_id, request=request)
    await db.commit()
    
    match_task.delay(str(case_id), data.get("opg_image_id"), data.get("filters", {}), job_id)
    
    return {
        "job_id": job_id,
        "websocket_url": f"ws://{request.url.hostname}:{request.url.port}{settings.API_V1_STR}/match/progress/{job_id}"
    }

@router.websocket("/progress/{job_id}")
async def match_progress_websocket(websocket: WebSocket, job_id: str):
    await websocket.accept()
    pubsub = redis_client.pubsub()
    await pubsub.subscribe(f"job_progress:{job_id}")
    
    try:
        while True:
            message = await pubsub.get_message(ignore_subscribe_messages=True)
            if message:
                data = json.loads(message["data"])
                await websocket.send_json(data)
                if data.get("stage") == "complete":
                    break
            await asyncio.sleep(0.1)
    except WebSocketDisconnect:
        pass
    finally:
        await pubsub.unsubscribe(f"job_progress:{job_id}")

@router.get("/{job_id}/results")
async def get_match_results(job_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    # Fetch results from database
    result = await db.execute(
        select(MatchCandidate).where(MatchCandidate.job_id == job_id).order_by(MatchCandidate.rank)
    )
    candidates = result.scalars().all()
    
    return {
        "status": "success",
        "job_id": str(job_id),
        "candidates": [
            {
                "id": str(c.id),
                "rank": c.rank,
                "confidence": c.overall_confidence,
                "morphology": c.morphology_confidence,
                "restoration": c.restoration_confidence,
                "spatial": c.spatial_confidence,
                "age": c.age_alignment_confidence,
                "record_id": f"REC-{str(c.population_record_id)[:8]}",
                "features": c.per_tooth_matches.get("highlights", []) if c.per_tooth_matches else []
            } for c in candidates
        ]
    }

@router.get("/{job_id}/results/{candidate_id}")
async def get_candidate_detail(
    job_id: uuid.UUID, 
    candidate_id: uuid.UUID, 
    db: AsyncSession = Depends(get_db)
):
    # Fetch candidate
    result = await db.execute(
        select(MatchCandidate).where(MatchCandidate.id == candidate_id)
    )
    candidate = result.scalar_one_or_none()
    
    if not candidate:
        return {"error": "Candidate not found"}
    
    # Fetch population record for demographic info
    from app.models.population_record import PopulationRecord
    pop_result = await db.execute(
        select(PopulationRecord).where(PopulationRecord.id == candidate.population_record_id)
    )
    pop_record = pop_result.scalar_one_or_none()
    
    return {
        "id": str(candidate.id),
        "rank": candidate.rank,
        "confidence": candidate.overall_confidence,
        "morphology": candidate.morphology_confidence,
        "restoration": candidate.restoration_confidence,
        "spatial": candidate.spatial_confidence,
        "age": candidate.age_alignment_confidence,
        "subject_name": pop_record.subject_name if pop_record else "Unknown",
        "dob": str(pop_record.date_of_birth) if pop_record else "Unknown",
        "nationality": pop_record.nationality if pop_record else "Unknown",
        "last_seen": pop_record.last_seen_location if pop_record else "Unknown",
        "record_source": pop_record.record_source if pop_record else "Unknown",
        "features": candidate.per_tooth_matches if candidate.per_tooth_matches else {}
    }

