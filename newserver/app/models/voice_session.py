from sqlalchemy import String, Integer, DateTime, Enum, ForeignKey, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app.core.database import Base


class VoiceSession(Base):
    __tablename__ = "voice_sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    dependent_id: Mapped[int] = mapped_column(
        Integer,
        ForeignKey("dependents.id", ondelete="CASCADE")
    )
    token_hash: Mapped[str] = mapped_column(String(128), index=True)
    status: Mapped[str] = mapped_column(
        Enum("OPEN", "CLOSED", "EXPIRED", name="session_status"),
        default="OPEN",
        index=True
    )
    expires_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    meta: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow
    )

    dependent = relationship("Dependent", back_populates="voice_sessions")
    calls = relationship("Call", back_populates="voice_session", cascade="all,delete")
