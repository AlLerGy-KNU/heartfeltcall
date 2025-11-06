from sqlalchemy import String, Integer, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app.core.database import Base


class ConnectionCode(Base):
    __tablename__ = "connection_codes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    dependent_id: Mapped[int] = mapped_column(
        Integer,
        ForeignKey("dependents.id", ondelete="CASCADE")
    )
    caregiver_id: Mapped[int] = mapped_column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE")
    )
    code: Mapped[str] = mapped_column(String(32), unique=True, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime)
    used_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    used_by: Mapped[int | None] = mapped_column(
        Integer,
        ForeignKey("users.id"),
        nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    dependent = relationship("Dependent")
