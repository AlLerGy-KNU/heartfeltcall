import secrets, string, base64
from datetime import datetime, timedelta

ALPHA_UPPER_NUM = string.ascii_uppercase + string.digits
ALPHANUM        = string.ascii_letters + string.digits

def gen_code_16() -> str:
    return "".join(secrets.choice(ALPHA_UPPER_NUM) for _ in range(16))

def gen_code_22() -> str:
    b = secrets.token_bytes(16)  # 128-bit
    return base64.urlsafe_b64encode(b).decode().rstrip("=")

def gen_auth_code(n: int = 40) -> str:
    return "".join(secrets.choice(ALPHANUM) for _ in range(n))

def utcnow():
    return datetime.utcnow()

def plus_minutes(m: int) -> datetime:
    return utcnow() + timedelta(minutes=m)
