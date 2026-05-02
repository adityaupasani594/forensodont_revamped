import uuid
from typing import Optional, Dict, Any
from fastapi import Request
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.audit_log import AuditLog

async def log_audit_event(
    session: AsyncSession,
    action: str,
    user_id: Optional[uuid.UUID] = None,
    case_id: Optional[uuid.UUID] = None,
    detail: Optional[Dict[str, Any]] = None,
    request: Optional[Request] = None
):
    ip_address = None
    user_agent = None

    if request:
        ip_address = request.client.host if request.client else None
        user_agent = request.headers.get("user-agent")

    audit_entry = AuditLog(
        user_id=user_id,
        case_id=case_id,
        action=action,
        detail=detail,
        ip_address=ip_address,
        user_agent=user_agent
    )
    
    session.add(audit_entry)
    # Don't commit here to allow it to be part of a larger transaction if needed,
    # or the caller can commit.
