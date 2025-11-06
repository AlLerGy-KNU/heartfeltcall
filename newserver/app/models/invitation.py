from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base

class Invitation(Base):
    __tablename__ = "invitations"

    id = Column(Integer, primary_key=True)
    # 비밀로 쓰는 초대코드: 22자 base64url(128bit) 권장. (16자 대문자/숫자도 가능)
    code = Column(String(32), unique=True, index=True, nullable=False)

    dependent_id = Column(Integer, ForeignKey("dependents.id"), nullable=True, index=True)
    caregiver_id = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)

    status = Column(String(16), nullable=False, default="pending")  # pending | connected | used | expired
    auth_code = Column(String(64), nullable=True)                   # 1회용 교환 코드

    created_at = Column(DateTime, nullable=False)
    connected_at = Column(DateTime, nullable=True)
    expires_at = Column(DateTime, nullable=False)

    dependent = relationship("Dependent", backref="invitations", lazy="joined")
