from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user
from app.models.invitation import Invitation
from app.models.dependent import Dependent
from app.models.user import User
from app.utils.shorttokens import gen_code_22, gen_code_16, gen_auth_code, utcnow, plus_minutes
from app.core.security import create_access_token  # 기존 JWT 유틸

router = APIRouter()

INVITE_TTL_MIN = 15
DEPENDENT_JWT_TTL_MIN = 24 * 60  # 예: 1일

def _norm(s: str) -> str:
    return (s or "").strip().upper()

# (1) 피보호자앱: 익명 초대 생성 (비인증)
@router.post("/connections")
def create_invitation(db: Session = Depends(get_db)):
    # code = gen_code_16()  # 16자 원하면 사용
    code = gen_code_22()      # 권장: 22자 base64url(128-bit)
    inv = Invitation(
        code=code,
        status="pending",
        created_at=utcnow(),
        expires_at=plus_minutes(INVITE_TTL_MIN)
    )
    db.add(inv); db.commit()
    return {"code": code, "expires_at": inv.expires_at.isoformat()}

# (2) 피보호자앱: 초대 상태 폴링 (공개 GET)
@router.get("/connections/{code}/status")
def get_invitation_status(code: str, db: Session = Depends(get_db)):
    inv = db.query(Invitation).filter(Invitation.code == _norm(code)).first()
    if not inv or inv.expires_at < utcnow():
        return {"status": "expired"}

    resp = {"status": inv.status}
    if inv.status == "connected" and inv.auth_code:
        resp["auth_code"] = inv.auth_code  # 1회용 교환 코드
    return resp

# (3) 보호자앱: 초대 수락 + 피보호자 생성/재바인딩 + auth_code 발급 (JWT 필요)
@router.post("/connections/accept")
def accept_invitation(
    payload: dict,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    code = _norm(payload.get("code"))
    if not code:
        raise HTTPException(400, "code required")

    inv = db.query(Invitation).filter(Invitation.code == code).with_for_update().first()
    if not inv or inv.expires_at < utcnow():
        raise HTTPException(400, "Invalid or expired code")
    if inv.status in ("connected", "used"):
        raise HTTPException(409, "Already connected/used")

    dep_id = payload.get("dependent_id")
    if dep_id:
        dep = db.query(Dependent).get(dep_id)
        if not dep:
            raise HTTPException(404, "Dependent not found")
        if dep.caregiver_id and dep.caregiver_id != current_user.id:
            raise HTTPException(409, "Already linked to another caregiver")
        dep.caregiver_id = current_user.id
    else:
        info = payload.get("dependent") or {}
        name = info.get("name")
        if not name:
            raise HTTPException(400, "dependent.name required")
        dep = Dependent(
            name=name,
            birth_date=info.get("birth_date"),
            relation=info.get("relation"),
            preferred_call_time=info.get("preferred_call_time"),
            retry_interval_min=info.get("retry_interval_min"),
            caregiver_id=current_user.id
        )
        db.add(dep); db.flush()

    inv.dependent_id = dep.id
    inv.caregiver_id = current_user.id
    inv.status = "connected"
    inv.connected_at = utcnow()
    inv.auth_code = gen_auth_code(40)  # 1회용 교환 코드

    db.commit()
    return {"success": True, "dependent_id": dep.id}

# (4) 피보호자앱: auth_code ↔ 피보호자 JWT 교환 (공개 POST)
@router.post("/auth/dependent/exchange")
def exchange_auth_code_for_jwt(payload: dict, db: Session = Depends(get_db)):
    code = _norm(payload.get("code"))
    auth_code = payload.get("auth_code")
    if not code or not auth_code:
        raise HTTPException(400, "code and auth_code required")

    inv = db.query(Invitation).filter(Invitation.code == code).with_for_update().first()
    if not inv or inv.expires_at < utcnow():
        raise HTTPException(400, "Invalid or expired code")
    if inv.status != "connected" or not inv.auth_code:
        raise HTTPException(409, "Not connected or already exchanged")

    if auth_code != inv.auth_code:
        raise HTTPException(401, "Invalid auth_code")

    # 1회용 코드 소비
    inv.status = "used"
    inv.auth_code = None

    access_token = create_access_token(
        data={"sub": f"dependent:{inv.dependent_id}", "role": "dependent"},
        expires_delta_minutes=DEPENDENT_JWT_TTL_MIN
    )
    db.commit()

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": DEPENDENT_JWT_TTL_MIN * 60,
        "dependent_id": inv.dependent_id
    }
