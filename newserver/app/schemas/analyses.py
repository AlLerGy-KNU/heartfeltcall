from pydantic import BaseModel
from typing import Optional

# state: 부동소수(분석 점수). 미분석 시 -1.0 반환.
class AnalysisOut(BaseModel):
    state: float
    risk_score: Optional[float] = None
    created_at: str
    mel_image: Optional[str] = None

class LatestAnalysisOut(BaseModel):
    state: float
    risk_score: Optional[float] = None
    created_at: str
    mel_image: Optional[str] = None
