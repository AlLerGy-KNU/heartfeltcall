from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.api.deps import get_db, require_caregiver
from app.models.dependent import Dependent
from app.models.user import User
from app.schemas.dependent import DependentCreate, DependentUpdate, DependentOut
router = APIRouter()
@router.post("", response_model=DependentOut)
def create_dependent(payload: DependentCreate, db: Session = Depends(get_db), user: User = Depends(require_caregiver)):
    dep = Dependent(caregiver_id=user.id, name=payload.name, birth_date=payload.birth_date if payload.birth_date else None,
                    sex=payload.sex or "U", preferred_call_time=payload.preferred_call_time,
                    retry_count=payload.retry_count or 3, retry_interval_min=payload.retry_interval_min or 10)
    db.add(dep); db.commit(); db.refresh(dep); return dep
@router.get("", response_model=dict)
def list_dependents(db: Session = Depends(get_db), user: User = Depends(require_caregiver)):
    deps = db.query(Dependent).filter(Dependent.caregiver_id == user.id, Dependent.deleted_at.is_(None)).order_by(Dependent.id.desc()).all()
    return {"dependents": [DependentOut.model_validate(d) for d in deps]}
@router.get("/{dep_id}", response_model=DependentOut)
def get_dependent(dep_id: int, db: Session = Depends(get_db), user: User = Depends(require_caregiver)):
    dep = db.query(Dependent).filter(Dependent.id == dep_id, Dependent.caregiver_id == user.id).first()
    if not dep: raise HTTPException(404, "Dependent not found")
    return dep
@router.put("/{dep_id}", response_model=dict)
def update_dependent(dep_id: int, payload: DependentUpdate, db: Session = Depends(get_db), user: User = Depends(require_caregiver)):
    dep = db.query(Dependent).filter(Dependent.id == dep_id, Dependent.caregiver_id == user.id).first()
    if not dep: raise HTTPException(404, "Dependent not found")
    for k, v in payload.model_dump(exclude_none=True).items(): setattr(dep, k, v)
    db.commit(); return {"success": True}
@router.delete("/{dep_id}", response_model=dict)
def delete_dependent(dep_id: int, db: Session = Depends(get_db), user: User = Depends(require_caregiver)):
    dep = db.query(Dependent).filter(Dependent.id == dep_id, Dependent.caregiver_id == user.id).first()
    if not dep: raise HTTPException(404, "Dependent not found")
    import datetime as _dt; dep.deleted_at = _dt.datetime.utcnow(); db.commit(); return {"success": True}
