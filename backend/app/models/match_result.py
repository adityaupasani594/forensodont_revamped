from sqlalchemy import Column, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from app.core.database import Base

class MatchResult(Base):
    __tablename__ = "match_results"

    id = Column(Integer, primary_key=True, index=True)
    opg_record_id = Column(Integer, ForeignKey("opg_records.id"))
    matched_opg_id = Column(Integer, ForeignKey("opg_records.id"))
    similarity_score = Column(Float, nullable=False)
    rank = Column(Integer, nullable=False)

    opg_record = relationship("OPGRecord", foreign_keys=[opg_record_id], back_populates="match_results")
    matched_opg = relationship("OPGRecord", foreign_keys=[matched_opg_id])
