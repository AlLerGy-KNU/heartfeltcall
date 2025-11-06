from sqlalchemy import String, Integer, Date, DateTime, Enum, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app.core.database import Base
class Dependent(Base):
    __tablename__ = "dependents"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    caregiver_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    user_id: Mapped[int | None] = mapped_column(Integer, ForeignKey("users.id"), nullable=True)
    name: Mapped[str] = mapped_column(String(100))
    birth_date: Mapped[datetime | None] = mapped_column(Date, nullable=True)
    sex: Mapped[str] = mapped_column(Enum("M","F","U", name="sex_enum"), default="U")
    preferred_call_time: Mapped[str | None] = mapped_column(String(5), nullable=True)
    retry_count: Mapped[int] = mapped_column(Integer, default=3)
    retry_interval_min: Mapped[int] = mapped_column(Integer, default=10)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    caregiver = relationship("User", back_populates="dependents", foreign_keys=[caregiver_id])
    voice_sessions = relationship("VoiceSession", back_populates="dependent", cascade="all,delete")
    calls = relationship("Call", back_populates="dependent", cascade="all,delete")
    analyses = relationship("Analysis", back_populates="dependent", cascade="all,delete")
