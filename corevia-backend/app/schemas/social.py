from pydantic import BaseModel
from datetime import datetime
from typing import Optional


# ============================================================
# Post Schemas
# ============================================================

class PostCreate(BaseModel):
    post_type: str  # workout, meal, progress, achievement, general
    content: Optional[str] = None
    workout_id: Optional[str] = None
    food_entry_id: Optional[str] = None
    is_public: bool = True


class PostUpdate(BaseModel):
    content: Optional[str] = None
    is_public: Optional[bool] = None


class PostAuthor(BaseModel):
    id: str
    name: str
    profile_image_url: Optional[str] = None
    user_type: str

    class Config:
        from_attributes = True


class PostResponse(BaseModel):
    id: str
    user_id: str
    post_type: str
    content: Optional[str]
    image_url: Optional[str]
    workout_id: Optional[str]
    food_entry_id: Optional[str]
    likes_count: int
    comments_count: int
    is_public: bool
    created_at: datetime
    updated_at: datetime

    # Extra fields
    author: Optional[PostAuthor] = None
    is_liked: Optional[bool] = False  # Current user liked this post

    class Config:
        from_attributes = True


# ============================================================
# Comment Schemas
# ============================================================

class CommentCreate(BaseModel):
    content: str


class CommentAuthor(BaseModel):
    id: str
    name: str
    profile_image_url: Optional[str] = None

    class Config:
        from_attributes = True


class CommentResponse(BaseModel):
    id: str
    post_id: str
    user_id: str
    content: str
    created_at: datetime
    author: Optional[CommentAuthor] = None

    class Config:
        from_attributes = True


# ============================================================
# Follow Schemas
# ============================================================

class FollowResponse(BaseModel):
    id: str
    follower_id: str
    following_id: str
    created_at: datetime

    class Config:
        from_attributes = True


class UserProfileSummary(BaseModel):
    id: str
    name: str
    profile_image_url: Optional[str] = None
    user_type: str
    bio: Optional[str] = None
    followers_count: int = 0
    following_count: int = 0
    posts_count: int = 0
    is_following: Optional[bool] = False  # Current user following this user

    class Config:
        from_attributes = True


# ============================================================
# Achievement Schemas
# ============================================================

class AchievementResponse(BaseModel):
    id: str
    user_id: str
    achievement_type: str
    title: str
    description: Optional[str]
    icon_url: Optional[str]
    earned_at: datetime

    class Config:
        from_attributes = True


# ============================================================
# Feed Schemas
# ============================================================

class FeedResponse(BaseModel):
    posts: list[PostResponse]
    total: int
    page: int
    page_size: int
    has_more: bool
