from typing import List
import uuid
import json
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.population_record import PopulationRecord
from app.services.matching_engine import SearchFilters
from app.core.config import settings
import redis.asyncio as redis

redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)

async def apply_filters(session: AsyncSession, filters: SearchFilters) -> List[uuid.UUID]:
    """
    Build and execute filtered query against population_records.
    Returns list of eligible record IDs.
    Cached in Redis for 10 minutes per filter hash.
    """
    filter_dict = {
        "age_min": filters.age_min,
        "age_max": filters.age_max,
        "sex": filters.sex,
        "regions": filters.regions
    }
    # Create deterministic hash for cache key
    filter_hash = hash(json.dumps(filter_dict, sort_keys=True))
    cache_key = f"filters:{filter_hash}"
    
    cached_ids = await redis_client.get(cache_key)
    if cached_ids:
        return [uuid.UUID(id_str) for id_str in json.loads(cached_ids)]
        
    query = select(PopulationRecord.id)
    if filters.age_min is not None:
        query = query.where(PopulationRecord.age_at_record >= filters.age_min)
    if filters.age_max is not None:
        query = query.where(PopulationRecord.age_at_record <= filters.age_max)
    if filters.sex and filters.sex != 'unknown':
        query = query.where(PopulationRecord.sex == filters.sex)
    if filters.regions:
        query = query.where(PopulationRecord.region.in_(filters.regions))
        
    result = await session.execute(query)
    record_ids = [row[0] for row in result.all()]
    
    # Cache for 10 minutes (600 seconds)
    await redis_client.setex(cache_key, 600, json.dumps([str(r_id) for r_id in record_ids]))
    
    return record_ids
