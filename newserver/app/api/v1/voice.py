from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import hashlib, os
from app.api.deps import get_db, require_caregiver
from app.core.config import settings
from app.models.voice_session import VoiceSession
from app.models.call import Call
from app.models.dependent import Dependent
from app.schemas.voice import StartSessionRequest, StartSessionResponse
from app.services.storage import save_upload, ensure_dir
from app.services.analysis import run_voice_analysis
router = APIRouter()
@router.post("/sessions", response_model=StartSessionResponse)
def start_session(payload: StartSessionRequest, db: Session = Depends(get_db), user=Depends(require_caregiver)):
    dep = db.query(Dependent).filter(Dependent.id == payload.dependent_id, Dependent.caregiver_id == user.id).first()
    if not dep: raise HTTPException(404, "Dependent not found")
    token = os.urandom(24).hex(); token_hash = hashlib.sha256(token.encode()).hexdigest()
    sess = VoiceSession(dependent_id=dep.id, token_hash=token_hash, status="OPEN", expires_at=datetime.utcnow() + timedelta(hours=1))
    db.add(sess); db.commit(); db.refresh(sess)
    return StartSessionResponse(session_id=sess.id, token=token, expires_in=3600)
def session_dir(session_id: int) -> str:
    base = os.path.join(settings.media_root, f"session-{session_id}"); ensure_dir(base); return base
@router.post("/sessions/{session_id}/question", response_model=dict)
def upload_question(session_id: int, file: UploadFile = File(...), db: Session = Depends(get_db), user=Depends(require_caregiver)):
    sess = db.query(VoiceSession).filter(VoiceSession.id == session_id, VoiceSession.status == "OPEN").first()
    if not sess: raise HTTPException(404, "Session not found or closed")
    d = session_dir(session_id); qpath = save_upload(d, file, filename="question.wav")
    call = Call(dependent_id=sess.dependent_id, voice_session_id=sess.id, status="CONNECTED", question_audio_path=qpath)
    db.add(call); db.commit(); db.refresh(call)
    return {"success": True, "call_id": call.id}
@router.post("/sessions/{session_id}/answer", response_model=dict)
async def upload_answer(session_id: int, file: UploadFile = File(...), db: Session = Depends(get_db), user=Depends(require_caregiver)):
    sess = db.query(VoiceSession).filter(VoiceSession.id == session_id).first()
    if not sess or sess.status != "OPEN": raise HTTPException(404, "Session not found or closed")
    call = db.query(Call).filter(Call.voice_session_id == sess.id).order_by(Call.id.desc()).first()
    if not call: raise HTTPException(400, "No call created. Upload question first.")
    d = session_dir(session_id); apath = save_upload(d, file, filename="answer.wav"); call.answer_audio_path = apath; db.commit()
    analysis_json = await run_voice_analysis(d)
    if not analysis_json or not analysis_json.get("success"):
        return {"success": False, "message": analysis_json.get("message") if analysis_json else "analysis failed"}
    from app.models.analysis import Analysis
    score = float(analysis_json["result"]["prediction"]) / 100.0
    call.risk_score = score; db.add(call)
    an = Analysis(dependent_id=sess.dependent_id, call_id=call.id, state=None, risk_score=score, model_version="v1")
    db.add(an); db.commit()
    return {"success": True, "risk": "warning" if score >= 0.4 else "ok", "score": score}
@router.delete("/sessions/{session_id}", response_model=dict)
def end_session(session_id: int, db: Session = Depends(get_db), user=Depends(require_caregiver)):
    sess = db.query(VoiceSession).filter(VoiceSession.id == session_id).first()
    if not sess: raise HTTPException(404, "Session not found")
    sess.status = "CLOSED"; db.commit(); return {"success": True, "message": "session closed"}
