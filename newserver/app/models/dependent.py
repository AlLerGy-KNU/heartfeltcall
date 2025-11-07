from datetime import datetime, date
from sqlalchemy import String, Integer, Date, DateTime, Enum, ForeignKey, Index, Float, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base

class Dependent(Base):
    __tablename__ = "dependents"
    __table_args__ = (
        Index("ix_dependents_caregiver_deleted", "caregiver_id", "deleted_at"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)

    # 언링크 고려 시 nullable=True 권장
    caregiver_id: Mapped[int | None] = mapped_column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=True
    )

    user_id: Mapped[int | None] = mapped_column(
        Integer,
        ForeignKey("users.id"),
        nullable=True
    )

    name: Mapped[str] = mapped_column(String(100))
    birth_date: Mapped[date | None] = mapped_column(Date, nullable=True)  # type hint 정합성
    sex: Mapped[str] = mapped_column(Enum("M", "F", "U", name="sex_enum"), default="U")
    preferred_call_time: Mapped[str | None] = mapped_column(String(5), nullable=True)
    retry_count: Mapped[int] = mapped_column(Integer, default=3)
    retry_interval_min: Mapped[int] = mapped_column(Integer, default=10)
    # 최근 분석 상태 값(부동소수, -1.0=미분석) 및 최근 검사 시각
    last_state: Mapped[float] = mapped_column(Float, default=-1.0)
    last_exam_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    last_mel_image: Mapped[str | None] = mapped_column(Text, nullable=True)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    caregiver = relationship("User", back_populates="dependents", foreign_keys=[caregiver_id])
    voice_sessions = relationship("VoiceSession", back_populates="dependent", cascade="all,delete")
    calls = relationship("Call", back_populates="dependent", cascade="all,delete")
    analyses = relationship("Analysis", back_populates="dependent", cascade="all,delete")
