from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.core.security import decode_token
from app.models.user import User
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")
def get_db():
    db = SessionLocal()
    try: yield db
    finally: db.close()
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    payload = decode_token(token)
    if not payload or "sub" not in payload:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    user = db.query(User).filter(User.id == int(payload["sub"])).first()
    if not user or not user.is_active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Inactive or missing user")
    return user
def require_caregiver(user: User = Depends(get_current_user)) -> User:
    if user.role not in ("CAREGIVER","ADMIN"):
        raise HTTPException(status_code=403, detail="Caregiver role required")
    return user
