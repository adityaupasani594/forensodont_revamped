import asyncio
from pathlib import Path

from sqlalchemy import select
from sqlalchemy.exc import OperationalError

from app.core.config import settings
from app.core.database import AsyncSessionLocal, Base, engine
from app.core.security import get_password_hash
from app.models.audit_log import AuditLog
from app.models.case import Case
from app.models.expert_review import ExpertReview
from app.models.match_candidate import MatchCandidate
from app.models.match_job import MatchJob
from app.models.opg_image import OPGImage
from app.models.population_record import PopulationRecord
from app.models.user import User


DEMO_EMAIL = "demo@forensodont.local"
DEMO_PASSWORD = "demo1234"


async def init_dev_environment() -> None:
    """Create the database schema and seed a demo user for local runs."""
    Path(settings.UPLOAD_DIR).mkdir(parents=True, exist_ok=True)
    Path(settings.REPORT_DIR).mkdir(parents=True, exist_ok=True)

    # References above intentionally import every model so SQLAlchemy sees all
    # tables and relationships before create_all runs.
    _ = (
        AuditLog,
        Case,
        ExpertReview,
        MatchCandidate,
        MatchJob,
        OPGImage,
        PopulationRecord,
        User,
    )

    last_error: OperationalError | None = None
    for _ in range(20):
        try:
            async with engine.begin() as conn:
                await conn.run_sync(Base.metadata.create_all)
            last_error = None
            break
        except OperationalError as exc:
            last_error = exc
            await asyncio.sleep(1)

    if last_error is not None:
        raise last_error

    async with AsyncSessionLocal() as session:
        result = await session.execute(select(User).where(User.email == DEMO_EMAIL))
        user = result.scalar_one_or_none()
        if user is None:
            session.add(
                User(
                    email=DEMO_EMAIL,
                    hashed_password=get_password_hash(DEMO_PASSWORD),
                    full_name="Demo Investigator",
                    role="investigator",
                    credentials="Local demo account",
                )
            )
            await session.commit()
