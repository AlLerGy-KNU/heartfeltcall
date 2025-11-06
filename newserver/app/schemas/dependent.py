from pydantic import BaseModel
from typing import Optional
class DependentCreate(BaseModel):
    name: str; birth_date: Optional[str] = None; sex: Optional[str] = "U"
    preferred_call_time: Optional[str] = None; retry_count: Optional[int] = 3; retry_interval_min: Optional[int] = 10
class DependentUpdate(BaseModel):
    name: Optional[str] = None; birth_date: Optional[str] = None; sex: Optional[str] = None
    preferred_call_time: Optional[str] = None; retry_count: Optional[int] = None; retry_interval_min: Optional[int] = None
class DependentOut(BaseModel):
    id: int; name: str; preferred_call_time: str | None = None
    class Config: from_attributes = True
