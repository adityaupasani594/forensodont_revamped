import uuid
from sqlalchemy import Column, DateTime, ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class ExpertReview(Base):
    __tablename__ = "expert_reviews"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id"))
    candidate_id = Column(UUID(as_uuid=True), ForeignKey("match_candidates.id"))
    odontologist_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    decision = Column(String) # 'confirmed', 'rejected', 'escalated'
    comment = Column(Text, nullable=False)
    annotations = Column(JSONB)
    interpol_dvi_ref = Column(String)
    reviewed_at = Column(DateTime(timezone=True), server_default=func.now())

    case = relationship("Case")
    candidate = relationship("MatchCandidate")
    odontologist = relationship("User")
