from pydantic import BaseModel
class StartSessionRequest(BaseModel): dependent_id: int
class StartSessionResponse(BaseModel): session_id: int; token: str; expires_in: int = 3600
