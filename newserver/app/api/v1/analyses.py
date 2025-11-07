from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.api.deps import get_db, require_caregiver
from app.models.analysis import Analysis
from app.models.dependent import Dependent
from app.schemas.analyses import LatestAnalysisOut, AnalysisOut
from datetime import datetime

router = APIRouter()
@router.get("/{dep_id}/analyses/latest", response_model=LatestAnalysisOut)
def latest(dep_id: int, db: Session = Depends(get_db), user=Depends(require_caregiver)):
    dep = db.query(Dependent).filter(Dependent.id == dep_id, Dependent.caregiver_id == user.id).first()
    if not dep: raise HTTPException(404, "Dependent not found")
    a = db.query(Analysis).filter(Analysis.dependent_id == dep.id).order_by(Analysis.id.desc()).first()
    if not a:
        return LatestAnalysisOut(state=-1.0, risk_score=None, created_at=datetime.utcnow().isoformat(), mel_image=dep.last_mel_image)
    return LatestAnalysisOut(state=float(a.state), risk_score=a.risk_score, created_at=a.created_at.isoformat(), mel_image=a.mel_image)

@router.get("/{dep_id}/analyses/history", response_model=dict)
def history(dep_id: int, db: Session = Depends(get_db), user=Depends(require_caregiver)):
    dep = db.query(Dependent).filter(Dependent.id == dep_id, Dependent.caregiver_id == user.id).first()
    if not dep: raise HTTPException(404, "Dependent not found")
    items = db.query(Analysis).filter(Analysis.dependent_id == dep.id).order_by(Analysis.id.desc()).all()
    return {"analyses": [
        AnalysisOut(state=float(i.state), risk_score=i.risk_score, created_at=i.created_at.isoformat(), mel_image=i.mel_image).model_dump()
        for i in items
    ]}
