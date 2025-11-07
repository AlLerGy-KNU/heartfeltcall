from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from fastapi.responses import FileResponse, Response
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import hashlib, os
from app.api.deps import get_db, get_current_dependent
from app.core.config import settings
from app.models.voice_session import VoiceSession
from app.models.call import Call
from app.models.dependent import Dependent
from app.schemas.voice import StartSessionResponse
from app.services.storage import ensure_dir
from app.services.analysis import run_multi_voice_analysis
from app.services.questions import ensure_global_questions, global_questions_dir

router = APIRouter()


@router.post("/sessions", response_model=StartSessionResponse)
def start_session_for_dependent(
    db: Session = Depends(get_db),
    dep: Dependent = Depends(get_current_dependent)
):
    token = os.urandom(24).hex()
    token_hash = hashlib.sha256(token.encode()).hexdigest()

    sess = VoiceSession(
        dependent_id=dep.id,
        token_hash=token_hash,
        status="OPEN",
        expires_at=datetime.utcnow() + timedelta(hours=1)
    )
    db.add(sess)
    db.commit()
    db.refresh(sess)

    # Prepare global questions to be available
    ensure_global_questions()

    return StartSessionResponse(session_id=sess.id, token=token, expires_in=3600)


def session_dir(session_id: int) -> str:
    base = os.path.join(settings.media_root, f"session-{session_id}")
    ensure_dir(base)
    return base


@router.get("/sessions/{session_id}/question", response_model=dict)
def get_session_questions(
    session_id: int,
    db: Session = Depends(get_db),
    dep: Dependent = Depends(get_current_dependent)
):
    sess = db.query(VoiceSession).filter(VoiceSession.id == session_id, VoiceSession.dependent_id == dep.id).first()
    if not sess or sess.status != "OPEN":
        raise HTTPException(404, "Session not found or closed")
    qdir = global_questions_dir()
    count = max(1, int(getattr(settings, 'daily_questions_count', 3)))
    files = [f"a{i}.wav" for i in range(1, count + 1)]
    available = [f for f in files if os.path.exists(os.path.join(qdir, f))]
    return {
        "files": [{"name": f, "url": f"/voice/sessions/{session_id}/question/{f}"} for f in available]
    }


@router.get("/sessions/{session_id}/question/{filename}")
def download_session_question(
    session_id: int,
    filename: str,
    db: Session = Depends(get_db),
    dep: Dependent = Depends(get_current_dependent)
):
    sess = db.query(VoiceSession).filter(VoiceSession.id == session_id, VoiceSession.dependent_id == dep.id).first()
    if not sess or sess.status != "OPEN":
        raise HTTPException(404, "Session not found or closed")
    qdir = global_questions_dir()
    path = os.path.join(qdir, filename)
    if not os.path.exists(path):
        raise HTTPException(404, "File not found")
    return FileResponse(path, media_type="audio/wav", filename=filename)


@router.get("/sessions/{session_id}/question/files")
def download_session_questions_as_formdata(
    session_id: int,
    db: Session = Depends(get_db),
    dep: Dependent = Depends(get_current_dependent)
):
    """
    Returns the available question WAV files (a1..aN.wav) as a multipart/form-data response.
    Each part has Content-Disposition: form-data; name="file"; filename="a{i}.wav".
    """
    sess = db.query(VoiceSession).filter(VoiceSession.id == session_id, VoiceSession.dependent_id == dep.id).first()
    if not sess or sess.status != "OPEN":
        raise HTTPException(404, "Session not found or closed")
    qdir = global_questions_dir()
    count = max(1, int(getattr(settings, 'daily_questions_count', 3)))
    files = [f"a{i}.wav" for i in range(1, count + 1)]
    available = [f for f in files if os.path.exists(os.path.join(qdir, f))]
    if not available:
        raise HTTPException(404, "No question files available")

    boundary = "----memoryon-boundary"
    chunks: list[bytes] = []
    for fname in available:
        path = os.path.join(qdir, fname)
        header = (
            f"--{boundary}\r\n"
            f"Content-Disposition: form-data; name=\"file\"; filename=\"{fname}\"\r\n"
            f"Content-Type: audio/wav\r\n\r\n"
        ).encode("utf-8")
        with open(path, "rb") as f:
            data = f.read()
        chunks.append(header + data + b"\r\n")
    chunks.append(f"--{boundary}--\r\n".encode("utf-8"))
    body = b"".join(chunks)
    return Response(content=body, media_type=f"multipart/form-data; boundary={boundary}")


@router.post("/sessions/{session_id}/answer", response_model=dict)
async def upload_answers(
    session_id: int,
    files: list[UploadFile] = File(...),
    db: Session = Depends(get_db),
    dep: Dependent = Depends(get_current_dependent)
):
    sess = db.query(VoiceSession).filter(VoiceSession.id == session_id, VoiceSession.dependent_id == dep.id).first()
    if not sess or sess.status != "OPEN":
        raise HTTPException(404, "Session not found or closed")

    # Persist files under MEDIA_ROOT/call-{session}-{rand} so external service can read voice-files/{callId}
    import uuid, shutil
    call_id = f"call-{session_id}-{uuid.uuid4().hex[:8]}"
    base_dir = os.path.join(settings.media_root, call_id)
    ensure_dir(base_dir)
    try:
        for i, upload in enumerate(files[:3], start=1):
            fp = os.path.join(base_dir, f"answer{i}.wav")
            with open(fp, "wb") as f:
                f.write(upload.file.read())
        # Call analysis (external service or local fallback)
        analysis_json = await run_multi_voice_analysis(base_dir)
    finally:
        # Clean up uploaded files after analysis attempt
        try:
            shutil.rmtree(base_dir)
        except Exception:
            pass
    score: float | None = None
    if analysis_json and analysis_json.get("success"):
        # Accept either top-level score or nested under result
        raw = None
        if "score" in analysis_json:
            raw = analysis_json.get("score")
        elif isinstance(analysis_json.get("result"), dict):
            raw = analysis_json["result"].get("score")
        try:
            if raw is not None:
                score = float(raw)
        except Exception:
            score = None

    if score is not None:
        # Encode mel image (if provided) and update dependent
        mel_b64 = None
        import base64
        mel_path = analysis_json.get("mel_path") if isinstance(analysis_json, dict) else None
        if mel_path and os.path.exists(mel_path):
            try:
                with open(mel_path, "rb") as f:
                    mel_b64 = base64.b64encode(f.read()).decode("ascii")
            except Exception:
                mel_b64 = None

        dep.last_state = score
        dep.last_exam_at = datetime.utcnow()
        if mel_b64:
            dep.last_mel_image = mel_b64
        db.add(dep)

        # Persist analysis history record without audio
        from app.models.analysis import Analysis
        an = Analysis(
            dependent_id=dep.id,
            call_id=None,
            state=score,
            risk_score=score,
            model_version="v1",
            mel_image=mel_b64
        )
        db.add(an)
        db.commit()
        return {"success": True, "score": score}
    else:
        return {"success": False, "message": analysis_json.get("message") if analysis_json else "analysis failed"}


@router.delete("/sessions/{session_id}", response_model=dict)
def end_session(
    session_id: int,
    db: Session = Depends(get_db),
    dep: Dependent = Depends(get_current_dependent)
):
    sess = db.query(VoiceSession).filter(VoiceSession.id == session_id, VoiceSession.dependent_id == dep.id).first()
    if not sess:
        raise HTTPException(404, "Session not found")
    sess.status = "CLOSED"
    db.commit()
    return {"success": True, "message": "session closed"}
