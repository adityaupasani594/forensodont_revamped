from typing import List, Optional
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "Forensodont Multimodal OPG Intelligence"
    API_V1_STR: str = "/api/v1"
    ENVIRONMENT: str = "development"
    SECRET_KEY: str = "super-secret-key-for-development"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # Database
    POSTGRES_SERVER: str = "localhost"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "postgres"
    POSTGRES_DB: str = "forensodont"
    DATABASE_URL: Optional[str] = None

    @property
    def sqlalchemy_database_uri(self) -> str:
        if self.DATABASE_URL:
            return self.DATABASE_URL
        return f"postgresql+asyncpg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_SERVER}/{self.POSTGRES_DB}"

    # Redis and Celery
    REDIS_URL: str = "redis://localhost:6379/0"
    CELERY_BROKER_URL: str = "redis://localhost:6379/1"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/2"

    # AI Models
    MODEL_PATH_SEGMENTATION: str = "app/ml/models/segmentation_v1.pth"
    MODEL_PATH_EMBEDDING: str = "app/ml/models/embedding_v1.pth"
    FAISS_INDEX_PATH: str = "app/ml/faiss_index.bin"
    FAISS_IDS_PATH: str = "app/ml/faiss_ids.npy"
    
    # Storage
    UPLOAD_DIR: str = "uploads"
    REPORT_DIR: str = "reports"

    model_config = SettingsConfigDict(env_file=".env", case_sensitive=True)

settings = Settings()
