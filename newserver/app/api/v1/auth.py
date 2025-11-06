from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user
from app.schemas.auth import SignupRequest, LoginRequest, TokenResponse, MeResponse
from app.models.user import User
from app.core.security import get_password_hash, verify_password, create_access_token, check_password_strength

router = APIRouter()

@router.post("/signup", response_model=dict)
def signup(data: SignupRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == data.email).first():
        raise HTTPException(400, "Email already registered")
    try:
        check_password_strength(data.password)
    except ValueError as e:
        raise HTTPException(400, str(e))
    user = User(name=data.name, email=data.email, password_hash=get_password_hash(data.password), phone=data.phone, role="CAREGIVER")
    db.add(user); db.commit(); db.refresh(user)
    return {"success": True, "user_id": user.id}

@router.post("/login", response_model=TokenResponse)
def login(data: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    if not user or not verify_password(data.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    token = create_access_token(str(user.id))
    return TokenResponse(access_token=token)

@router.get("/me", response_model=MeResponse)
def me(user: User = Depends(get_current_user)):
    return MeResponse(id=user.id, role=user.role, email=user.email, name=user.name)
