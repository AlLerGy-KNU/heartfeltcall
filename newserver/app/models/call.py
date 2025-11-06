from sqlalchemy import String, Integer, Float, DateTime, Enum, ForeignKey, Text, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app.core.database import Base
class Call(Base):
    __tablename__ = "calls"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    dependent_id: Mapped[int] = mapped_column(Integer, ForeignKey("dependents.id", ondelete="CASCADE"))
    voice_session_id: Mapped[int] = mapped_column(Integer, ForeignKey("voice_sessions.id", ondelete="CASCADE"), nullable=True)
    status: Mapped[str] = mapped_column(Enum("SCHEDULED","RINGING","CONNECTED","COMPLETED","FAILED","CANCELLED", name="call_status"), default="CONNECTED", index=True)
    question_audio_path: Mapped[str] = mapped_column(String(512))
    answer_audio_path: Mapped[str] = mapped_column(String(512))
    transcript: Mapped[str | None] = mapped_column(Text, nullable=True)
    features: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    risk_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    dependent = relationship("Dependent", back_populates="calls")
    voice_session = relationship("VoiceSession", back_populates="calls")
    analysis = relationship("Analysis", back_populates="call", uselist=False)
