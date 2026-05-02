import uuid
from sqlalchemy import Column, DateTime, ForeignKey, String, Float
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class OPGImage(Base):
    __tablename__ = "opg_images"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    case_id = Column(UUID(as_uuid=True), ForeignKey("cases.id"), nullable=True)
    image_type = Column(String, nullable=False) # 'post_mortem', 'ante_mortem'
    s3_key = Column(String, nullable=False)
    s3_key_preprocessed = Column(String)
    original_filename = Column(String)
    file_format = Column(String)
    quality_score = Column(Float)
    quality_flags = Column(JSONB)
    dicom_metadata = Column(JSONB)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    case = relationship("Case", back_populates="opg_images")
    population_record = relationship("PopulationRecord", back_populates="opg_image", uselist=False)
