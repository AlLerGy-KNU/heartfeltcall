from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import secrets, string
from app.api.deps import get_db, require_caregiver
from app.models.connection_code import ConnectionCode
from app.models.dependent import Dependent
from app.models.user import User
from app.schemas.connections import GenerateCodeRequest, CodeBody
router = APIRouter()
def gen_code(n: int = 12) -> str:
    import string, secrets
    alphabet = string.ascii_uppercase + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(n))
@router.post("", response_model=dict)
def generate_code(payload: GenerateCodeRequest, db: Session = Depends(get_db), user: User = Depends(require_caregiver)):
    dep = db.query(Dependent).filter(Dependent.id == payload.dependent_id, Dependent.caregiver_id == user.id).first()
    if not dep: raise HTTPException(404, "Dependent not found")
    code = gen_code()
    cc = ConnectionCode(dependent_id=dep.id, caregiver_id=user.id, code=code, expires_at=datetime.utcnow() + timedelta(minutes=15))
    db.add(cc); db.commit(); return {"code": code, "expires_at": cc.expires_at.isoformat()}
@router.post("/verify", response_model=dict)
def verify_code(body: CodeBody, db: Session = Depends(get_db)):
    cc = db.query(ConnectionCode).filter(ConnectionCode.code == body.code).first()
    if not cc: raise HTTPException(404, "Code not found")
    if cc.used_at: return {"success": False, "message": "Code already used"}
    if cc.expires_at < datetime.utcnow(): return {"success": False, "message": "Code expired"}
    caregiver = db.query(User).filter(User.id == cc.caregiver_id).first()
    return {"success": True, "caregiver_name": caregiver.name if caregiver else None}
@router.post("/accept", response_model=dict)
def accept_code(body: CodeBody, db: Session = Depends(get_db)):
    cc = db.query(ConnectionCode).filter(ConnectionCode.code == body.code).first()
    if not cc: raise HTTPException(404, "Code not found")
    if cc.used_at: return {"success": False, "message": "Code already used"}
    if cc.expires_at < datetime.utcnow(): return {"success": False, "message": "Code expired"}
    cc.used_at = datetime.utcnow(); db.commit(); return {"success": True}
