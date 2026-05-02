from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, JSON, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class OPGRecord(Base):
    __tablename__ = "opg_records"

    id = Column(Integer, primary_key=True, index=True)
    case_id = Column(Integer, ForeignKey("cases.id"))
    file_path = Column(String, nullable=False)
    record_type = Column(String, nullable=False) # ante_mortem, post_mortem
    embedding_vector = Column(JSON) # Stored as list of floats
    is_processed = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    case = relationship("Case", back_populates="opg_records")
    match_results = relationship("MatchResult", back_populates="opg_record")
