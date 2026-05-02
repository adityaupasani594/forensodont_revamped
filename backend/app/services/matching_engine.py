import faiss
import numpy as np
import os
import uuid
from typing import List, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.core.config import settings
from app.models.population_record import PopulationRecord
from app.models.match_candidate import MatchCandidate
from app.models.match_job import MatchJob

class SearchFilters:
    def __init__(self, age_min: int = None, age_max: int = None, sex: str = None, regions: List[str] = None):
        self.age_min = age_min
        self.age_max = age_max
        self.sex = sex
        self.regions = regions

class MatchingEngine:
    def __init__(self, dimension: int = 544):
        self.dimension = dimension
        self.index = None
        self.id_map = [] # To map index to uuid string
        
        if os.path.exists(settings.FAISS_INDEX_PATH) and os.path.exists(settings.FAISS_IDS_PATH):
            self.index = faiss.read_index(settings.FAISS_INDEX_PATH)
            self.id_map = np.load(settings.FAISS_IDS_PATH, allow_pickle=True).tolist()
        else:
            # Create a dummy index for development if it doesn't exist
            quantizer = faiss.IndexFlatL2(dimension)
            self.index = faiss.IndexIVFPQ(quantizer, dimension, 1, 8, 8)
            # Needs training, but for stub we'll just leave it empty.

    async def run_matching(self, session: AsyncSession, feature_vector: np.ndarray, filters: SearchFilters, job_id: uuid.UUID) -> List[MatchCandidate]:
        """
        1. Filter phase (PostgreSQL)
        2. Vector search (FAISS)
        3. Ensemble re-scoring
        4. Write MatchCandidate records
        """
        if not self.index or not self.index.is_trained:
            return [] # No trained index available

        # 1. Filter Phase
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
        filtered_ids = [row[0] for row in result.all()]
        
        # Determine FAISS internal indices for these UUIDs
        filtered_faiss_indices = [i for i, r_id in enumerate(self.id_map) if uuid.UUID(r_id) in filtered_ids]
        
        if not filtered_faiss_indices:
            return [] # No records matched the filter
            
        # 2. Vector search with IDSelector
        id_selector = faiss.IDSelectorBatch(filtered_faiss_indices)
        self.index.nprobe = 1 # Update based on num cells
        
        v_np = np.array([feature_vector]).astype('float32')
        # This is pseudo-code for search_with_filter depending on faiss version, 
        # usually requires passing params to the search function.
        # Since we use faiss-cpu, exact method might vary. For now, search all and filter:
        distances, indices = self.index.search(v_np, 100)
        
        # 3. Ensemble re-scoring (Mock logic)
        candidates = []
        rank = 1
        for dist, idx in zip(distances[0], indices[0]):
            if idx == -1 or idx not in filtered_faiss_indices:
                continue
            
            pop_record_id = uuid.UUID(self.id_map[idx])
            
            # Mock confidences
            morph = 0.9
            rest = 0.85
            spat = 0.88
            age = 0.95
            
            overall = 0.35 * morph + 0.30 * rest + 0.25 * spat + 0.10 * age
            
            candidate = MatchCandidate(
                job_id=job_id,
                population_record_id=pop_record_id,
                rank=rank,
                overall_confidence=overall,
                morphology_confidence=morph,
                restoration_confidence=rest,
                spatial_confidence=spat,
                age_alignment_confidence=age,
                per_tooth_matches={}
            )
            session.add(candidate)
            candidates.append(candidate)
            rank += 1
            if rank > 10:
                break
                
        # 4. Update Job
        job = await session.get(MatchJob, job_id)
        if job:
            job.status = 'complete'
            job.result_count = len(candidates)
            job.searched_count = len(filtered_ids)
            job.completed_at = func.now()
            
        await session.commit()
        return candidates

matching_engine = MatchingEngine()
