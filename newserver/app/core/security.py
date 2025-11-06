from datetime import datetime, timedelta
from typing import Optional
from jose import jwt, JWTError
from passlib.context import CryptContext
from app.core.config import settings
import re

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str) -> str: return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(
    subject: str | None = None,
    data: dict | None = None,
    expires_minutes: int | None = None,
    expires_delta_minutes: int | None = None,
) -> str:
    minutes = (
        expires_delta_minutes
        if expires_delta_minutes is not None
        else (expires_minutes if expires_minutes is not None else settings.access_token_expire_minutes)
    )
    expire = datetime.utcnow() + timedelta(minutes=minutes)

    payload: dict = {}
    if data is not None:
        payload.update(data)
    elif subject is not None:
        payload["sub"] = subject
    else:
        raise ValueError("subject or data required")

    payload["exp"] = expire
    return jwt.encode(payload, settings.secret_key, algorithm=settings.algorithm)

def decode_token(token: str) -> Optional[dict]:
    try: return jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
    except JWTError: return None


def check_password_strength(password: str) -> None:
    """
    Enforce policy: length >= 12 and at least 3 of 4 categories
    (lowercase, uppercase, digit, special).
    Raises ValueError with a human-readable message when invalid.
    """
    if not isinstance(password, str):
        raise ValueError("Invalid password type")
    if len(password) < 12:
        raise ValueError("Password must be at least 12 characters")
    has_lower = bool(re.search(r"[a-z]", password))
    has_upper = bool(re.search(r"[A-Z]", password))
    has_digit = bool(re.search(r"\d", password))
    has_special = bool(re.search(r"[^A-Za-z0-9]", password))
    categories = sum([has_lower, has_upper, has_digit, has_special])
    if categories < 3:
        raise ValueError("Password must include at least 3 of: lowercase, uppercase, digit, special")
