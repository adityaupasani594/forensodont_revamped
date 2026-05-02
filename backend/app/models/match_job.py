import uuid
from sqlalchemy import Column, DateTime, ForeignKey, String, Float, Integer
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class MatchJob(Base):
    __tablename__ = "match_jobs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id"))
    status = Column(String, default="queued") # 'queued', 'running', 'complete', 'failed'
    filters = Column(JSONB)
    result_count = Column(Integer)
    searched_count = Column(Integer)
    duration_seconds = Column(Float)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    completed_at = Column(DateTime(timezone=True))

    case = relationship("Case", back_populates="match_jobs")
    match_candidates = relationship("MatchCandidate", back_populates="match_job")
