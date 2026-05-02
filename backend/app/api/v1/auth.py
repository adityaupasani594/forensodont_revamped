from datetime import timedelta
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status, Request
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.core import security
from app.core.config import settings
from app.core.database import get_db
from app.models.user import User

router = APIRouter()

class LoginResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str
    user: dict

class RefreshRequest(BaseModel):
    refresh_token: str

@router.post("/login", response_model=LoginResponse)
async def login(
    request: Request,
    form_data: dict, # email, password
    db: AsyncSession = Depends(get_db)
) -> Any:
    email = form_data.get("email")
    password = form_data.get("password")
    
    query = select(User).where(User.email == email)
    result = await db.execute(query)
    user = result.scalars().first()
    
    if not user or not security.verify_password(password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    elif not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    
    access_token = security.create_access_token(user.id)
    refresh_token = security.create_refresh_token(user.id)
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "user": {
            "id": str(user.id),
            "name": user.full_name,
            "role": user.role,
            "credentials": user.credentials
        }
    }

@router.post("/refresh")
async def refresh_token(
    request: RefreshRequest,
    db: AsyncSession = Depends(get_db)
):
    # Mocking refresh logic for scaffolding
    # In reality, decode JWT, check JTI against Redis, issue new access token.
    return {"access_token": "new_access_token"}

@router.post("/logout")
async def logout(
    request: Request
):
    # Mocking logout - invalidate refresh token
    return {"status": "success"}
