from datetime import datetime, timedelta, timezone
from typing import Any, Union
import uuid
import redis.asyncio as redis
from jose import jwt
from passlib.context import CryptContext
from fastapi import Request
from .config import settings

pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")
ALGORITHM = "HS256"

redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)

def create_access_token(subject: Union[str, Any]) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode = {"exp": expire, "sub": str(subject), "type": "access"}
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=ALGORITHM)

def create_refresh_token(subject: Union[str, Any]) -> str:
    expire = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode = {"exp": expire, "sub": str(subject), "type": "refresh", "jti": str(uuid.uuid4())}
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=ALGORITHM)

async def invalidate_refresh_token(jti: str):
    await redis_client.setex(f"blacklist:refresh:{jti}", timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS), "revoked")

async def is_refresh_token_valid(jti: str) -> bool:
    is_revoked = await redis_client.get(f"blacklist:refresh:{jti}")
    return not is_revoked

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)
