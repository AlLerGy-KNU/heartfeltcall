from pydantic import BaseModel, EmailStr
class SignupRequest(BaseModel):
    name: str; email: EmailStr; password: str; phone: str | None = None
class LoginRequest(BaseModel):
    email: EmailStr; password: str
class TokenResponse(BaseModel):
    access_token: str; token_type: str = "bearer"
class MeResponse(BaseModel):
    id: int; role: str; email: EmailStr; name: str | None = None
