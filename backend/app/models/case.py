import uuid
from sqlalchemy import Column, DateTime, ForeignKey, String, Text, Date
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class Case(Base):
    __tablename__ = "cases"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    reference_number = Column(String, unique=True, index=True, nullable=False)
    incident_name = Column(String)
    location = Column(String)
    discovery_date = Column(Date)
    investigator_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    status = Column(String, nullable=False, default="drafting")
    missing_person_id = Column(String)
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    investigator = relationship("User", back_populates="cases")
    opg_images = relationship("OPGImage", back_populates="case")
    match_jobs = relationship("MatchJob", back_populates="case")
