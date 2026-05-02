import uuid
from fastapi import APIRouter, Depends, Response
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.services.report_generator import generate_pdf_report

router = APIRouter()

@router.get("/cases/{case_id}")
async def get_report(case_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    pdf_bytes = await generate_pdf_report(case_id, db)
    return Response(content=pdf_bytes, media_type="application/pdf", headers={"Content-Disposition": f"attachment; filename=report_{case_id}.pdf"})
@router.post("/match/{job_id}")
async def create_match_report(job_id: uuid.UUID):
    # In a real scenario, this would trigger a background task to generate the PDF,
    # upload it to secure storage (S3/MinIO), and return a signed URL.
    return {
        "status": "success", 
        "report_url": f"https://storage.forensodont.com/reports/REPORT-{str(job_id)[:8]}.pdf"
    }
