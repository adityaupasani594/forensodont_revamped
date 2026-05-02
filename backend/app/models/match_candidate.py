import uuid
from sqlalchemy import Column, DateTime, ForeignKey, Float, Integer
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class MatchCandidate(Base):
    __tablename__ = "match_candidates"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    job_id = Column(UUID(as_uuid=True), ForeignKey("match_jobs.id"))
    population_record_id = Column(UUID(as_uuid=True), ForeignKey("population_records.id"))
    rank = Column(Integer)
    overall_confidence = Column(Float)
    morphology_confidence = Column(Float)
    restoration_confidence = Column(Float)
    spatial_confidence = Column(Float)
    age_alignment_confidence = Column(Float)
    per_tooth_matches = Column(JSONB)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    match_job = relationship("MatchJob", back_populates="match_candidates")
    population_record = relationship("PopulationRecord")
