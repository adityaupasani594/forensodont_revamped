import asyncio
from celery import Celery
import redis
import json
from app.core.config import settings

celery = Celery(
    __name__,
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND
)

celery.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='UTC',
    enable_utc=True,
)

redis_client = redis.Redis.from_url(settings.REDIS_URL, decode_responses=True)

def publish_progress(job_id: str, stage: str, status: str, detail: str = None, **kwargs):
    message = {
        "stage": stage,
        "status": status,
        "detail": detail,
        **kwargs
    }
    redis_client.publish(f"job_progress:{job_id}", json.dumps(message))

import logging

# Masking utility for logs
def mask_pii(data: dict) -> dict:
    masked = data.copy()
    for key in ["subject_name", "date_of_birth", "record_id", "email"]:
        if key in masked:
            masked[key] = "***MASKED***"
    return masked

@celery.task(bind=True, max_retries=2, queue='preprocessing')
def preprocess_task(self, opg_image_id: str, job_id: str):
    logging.info(f"Starting preprocessing for OPG: {opg_image_id}")
    publish_progress(job_id, "preprocessing", "running", detail="Starting preprocessing pipeline")
    
    # ... logic ...
    import time
    time.sleep(2)
    
    publish_progress(job_id, "complete", "complete", quality_score=0.87)
    return {"status": "success", "job_id": job_id}

import uuid
from datetime import date
from app.core.database import AsyncSessionLocal
from app.models.match_candidate import MatchCandidate
from app.models.population_record import PopulationRecord

async def save_mock_results(job_id: str, case_id: str):
    async with AsyncSessionLocal() as db:
        for i in range(1, 6):
            pop_id = uuid.uuid4()
            pop_record = PopulationRecord(
                id=pop_id,
                subject_name=f"Interpol Subject {str(pop_id)[:4].upper()}",
                date_of_birth=date(1985, 5, 20),
                sex="male" if i % 2 == 0 else "female",
                nationality="Unknown (Ref: INTERPOL-2023-X)",
                record_source="INTERPOL DVI Database",
                last_seen_location="Lyon, France",
            )
            db.add(pop_record)
            
            candidate = MatchCandidate(
                job_id=uuid.UUID(job_id),
                population_record_id=pop_id,
                rank=i,
                overall_confidence=0.98 - (i * 0.04),
                morphology_confidence=0.95,
                restoration_confidence=0.90,
                spatial_confidence=0.85,
                age_alignment_confidence=0.88,
                per_tooth_matches={"highlights": ["Matching Filling #14", "Anatomic variation #21", "Consistent #18 missing"]}
            )
            db.add(candidate)
        await db.commit()

@celery.task(bind=True, max_retries=1, queue='matching')
def match_task(self, case_id: str, opg_image_id: str, filters: dict, job_id: str):
    logging.info(f"Starting matching job for case: {case_id} with filters: {mask_pii(filters)}")
    
    publish_progress(job_id, "segmentation", "running", detail="Segmenting dental arch...")
    import time
    time.sleep(2)
    
    publish_progress(job_id, "feature_extraction", "running", detail="Extracting tooth features...")
    time.sleep(2)
    
    publish_progress(job_id, "matching", "running", detail="Searching 4.2M records...")
    time.sleep(3)
    
    # Save mock results to database
    asyncio.run(save_mock_results(job_id, case_id))
    
    publish_progress(job_id, "complete", "complete", detail="Found 5 candidates", candidate_count=5)
    return {"status": "success", "job_id": job_id}

