from pydantic import BaseModel
class GenerateCodeRequest(BaseModel): dependent_id: int
class CodeBody(BaseModel): code: str
