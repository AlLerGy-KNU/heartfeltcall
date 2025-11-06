from pydantic import BaseModel
from typing import Optional
class AnalysisOut(BaseModel):
    state: Optional[str] = None; risk_score: Optional[float] = None; created_at: str
class LatestAnalysisOut(BaseModel):
    state: Optional[str] = None; risk_score: Optional[float] = None; created_at: str
