"""
News Models - Bookmark functionality
"""
import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey, UniqueConstraint
from app.database import Base


class NewsBookmark(Base):
    """User's bookmarked news articles"""
    __tablename__ = "news_bookmarks"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    article_id = Column(String, nullable=False, index=True)
    article_title = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    __table_args__ = (
        UniqueConstraint('user_id', 'article_id', name='uq_user_article_bookmark'),
    )
