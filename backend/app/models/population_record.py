import uuid
from sqlalchemy import Column, DateTime, ForeignKey, String, Date, Boolean, Integer
from sqlalchemy.dialects.postgresql import UUID, JSONB, BYTEA, ARRAY
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class PopulationRecord(Base):
    __tablename__ = "population_records"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    opg_image_id = Column(UUID(as_uuid=True), ForeignKey("opg_images.id"))
    subject_name = Column(String)
    date_of_birth = Column(Date)
    sex = Column(String) # 'male', 'female', 'unknown'
    nationality = Column(String)
    region = Column(String)
    ethnicity = Column(String)
    record_source = Column(String)
    dental_practice = Column(String)
    last_dental_visit = Column(Date)
    missing_person_ref = Column(String)
    feature_vector = Column(BYTEA)
    restoration_flags = Column(JSONB)
    missing_teeth = Column(ARRAY(Integer))
    anomaly_flags = Column(JSONB)
    age_at_record = Column(Integer)
    is_identified = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    opg_image = relationship("OPGImage", back_populates="population_record")
