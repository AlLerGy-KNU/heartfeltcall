# app/api/v1/connections.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import secrets, string

from app.api.deps import get_db, get_current_user
from app.models.connection_code import ConnectionCode
from app.models.dependent import Dependent
from app.models.user import User

router = APIRouter()

def gen_code(n: int = 12) -> str:
    alphabet = string.ascii_uppercase + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(n))

def _norm(s: str) -> str:
    return (s or "").strip().upper()

@router.post("", response_model=dict)
def create_anonymous_code(db: Session = Depends(get_db)):
    code = gen_code()
    cc = ConnectionCode(
        code=code,
        expires_at=datetime.utcnow() + timedelta(minutes=15)
    )
    db.add(cc)
    db.commit()
    return {"code": code, "expires_at": cc.expires_at.isoformat()}

@router.post("/verify", response_model=dict)
def verify_code(payload: dict, db: Session = Depends(get_db)):
    code = _norm(payload.get("code"))
    conn = db.query(ConnectionCode).filter_by(code=code).first()
    if not conn:
        return {"valid": False, "reason": "not_found"}
    if conn.used_at:
        return {"valid": False, "reason": "already_used"}
    if conn.expires_at and conn.expires_at < datetime.utcnow():
        return {"valid": False, "reason": "expired"}
    return {"valid": True}

@router.post("/accept", response_model=dict)
def accept_and_create(payload: dict,
                      db: Session = Depends(get_db),
                      current_user: User = Depends(get_current_user)):
    code = _norm(payload.get("code"))
    conn = (
        db.query(ConnectionCode)
        .filter_by(code=code)
        .with_for_update()
        .first()
    )
    if not conn:
        raise HTTPException(400, "Invalid code")
    if conn.used_at:
        raise HTTPException(400, "Code already used")
    if conn.expires_at and conn.expires_at < datetime.utcnow():
        raise HTTPException(400, "Code expired")

    dep_id = payload.get("dependent_id")
    if dep_id:
        dep = db.query(Dependent).get(dep_id)
        if not dep:
            raise HTTPException(404, "Dependent not found")
        if dep.caregiver_id and dep.caregiver_id != current_user.id:
            raise HTTPException(409, "Already linked to another caregiver")
    else:
        data = (payload.get("dependent") or {})
        name = data.get("name")
        if not name:
            raise HTTPException(400, "dependent.name is required")
        dep = Dependent(
            name=name,
            birth_date=data.get("birth_date"),
            relation=data.get("relation"),
            preferred_call_time=data.get("preferred_call_time"),
            retry_interval_min=data.get("retry_interval_min"),
            caregiver_id=current_user.id
        )
        db.add(dep)
        db.flush()  # dep.id 확보

    # 코드 사용 처리
    conn.used_at = datetime.utcnow()
    conn.used_by = current_user.id
    # 선택: conn.dependent_id = dep.id; conn.caregiver_id = current_user.id
    db.commit()
    return {"success": True, "dependent_id": dep.id}
