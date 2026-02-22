from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, or_, desc
from typing import Optional

from app.database import get_db
from app.models.user import User
from app.models.social import Post, PostLike, PostComment, Follow, Achievement
from app.schemas.social import (
    PostCreate,
    PostUpdate,
    PostResponse,
    PostAuthor,
    CommentCreate,
    CommentResponse,
    CommentAuthor,
    FollowResponse,
    UserProfileSummary,
    AchievementResponse,
    FeedResponse,
)
from app.utils.security import get_current_user
from app.services.file_service import save_upload

router = APIRouter(prefix="/api/v1/social", tags=["Social"])


# ============================================================
# POSTS
# ============================================================

@router.post("/posts", response_model=PostResponse, status_code=status.HTTP_201_CREATED)
async def create_post(
    post_data: PostCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new post"""
    post = Post(
        user_id=current_user.id,
        post_type=post_data.post_type,
        content=post_data.content,
        workout_id=post_data.workout_id,
        food_entry_id=post_data.food_entry_id,
        is_public=post_data.is_public,
    )
    db.add(post)
    await db.flush()
    await db.refresh(post)

    # Build response with author
    response = PostResponse.model_validate(post)
    response.author = PostAuthor(
        id=current_user.id,
        name=current_user.name,
        profile_image_url=current_user.profile_image_url,
        user_type=current_user.user_type.value,
    )
    return response


@router.post("/posts/{post_id}/image")
async def upload_post_image(
    post_id: str,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Upload image for a post"""
    result = await db.execute(select(Post).where(Post.id == post_id))
    post = result.scalar_one_or_none()

    if not post:
        raise HTTPException(status_code=404, detail="Post tapılmadı")

    if post.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Bu post sizə aid deyil")

    # Save image
    file_path = await save_upload(file, "posts")
    post.image_url = file_path
    await db.commit()

    return {"image_url": file_path}


@router.get("/feed", response_model=FeedResponse)
async def get_feed(
    page: int = 1,
    page_size: int = 20,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get social feed (posts from followed users + own posts)"""
    offset = (page - 1) * page_size

    # Get following IDs
    following_result = await db.execute(
        select(Follow.following_id).where(Follow.follower_id == current_user.id)
    )
    following_ids = [row[0] for row in following_result.fetchall()]
    following_ids.append(current_user.id)  # Include own posts

    # Get posts
    query = (
        select(Post)
        .where(and_(Post.user_id.in_(following_ids), Post.is_public == True))
        .order_by(desc(Post.created_at))
        .offset(offset)
        .limit(page_size)
    )
    result = await db.execute(query)
    posts = result.scalars().all()

    # Get total count
    count_result = await db.execute(
        select(func.count(Post.id)).where(
            and_(Post.user_id.in_(following_ids), Post.is_public == True)
        )
    )
    total = count_result.scalar()

    # Build response with authors and like status
    post_responses = []
    for post in posts:
        # Get author
        author_result = await db.execute(select(User).where(User.id == post.user_id))
        author = author_result.scalar_one_or_none()

        # Check if current user liked
        like_result = await db.execute(
            select(PostLike).where(
                and_(PostLike.post_id == post.id, PostLike.user_id == current_user.id)
            )
        )
        is_liked = like_result.scalar_one_or_none() is not None

        post_response = PostResponse.model_validate(post)
        if author:
            post_response.author = PostAuthor(
                id=author.id,
                name=author.name,
                profile_image_url=author.profile_image_url,
                user_type=author.user_type.value,
            )
        post_response.is_liked = is_liked
        post_responses.append(post_response)

    return FeedResponse(
        posts=post_responses,
        total=total,
        page=page,
        page_size=page_size,
        has_more=(offset + page_size) < total,
    )


@router.get("/posts/{post_id}", response_model=PostResponse)
async def get_post(
    post_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get single post"""
    result = await db.execute(select(Post).where(Post.id == post_id))
    post = result.scalar_one_or_none()

    if not post:
        raise HTTPException(status_code=404, detail="Post tapılmadı")

    # Get author
    author_result = await db.execute(select(User).where(User.id == post.user_id))
    author = author_result.scalar_one_or_none()

    # Check if liked
    like_result = await db.execute(
        select(PostLike).where(
            and_(PostLike.post_id == post.id, PostLike.user_id == current_user.id)
        )
    )
    is_liked = like_result.scalar_one_or_none() is not None

    post_response = PostResponse.model_validate(post)
    if author:
        post_response.author = PostAuthor(
            id=author.id,
            name=author.name,
            profile_image_url=author.profile_image_url,
            user_type=author.user_type.value,
        )
    post_response.is_liked = is_liked
    return post_response


@router.delete("/posts/{post_id}")
async def delete_post(
    post_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Delete a post"""
    result = await db.execute(select(Post).where(Post.id == post_id))
    post = result.scalar_one_or_none()

    if not post:
        raise HTTPException(status_code=404, detail="Post tapılmadı")

    if post.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Bu post sizə aid deyil")

    await db.delete(post)
    await db.commit()
    return {"message": "Post silindi"}


# ============================================================
# LIKES
# ============================================================

@router.post("/posts/{post_id}/like")
async def like_post(
    post_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Like a post"""
    # Check if post exists
    post_result = await db.execute(select(Post).where(Post.id == post_id))
    post = post_result.scalar_one_or_none()

    if not post:
        raise HTTPException(status_code=404, detail="Post tapılmadı")

    # Check if already liked
    existing_like = await db.execute(
        select(PostLike).where(
            and_(PostLike.post_id == post_id, PostLike.user_id == current_user.id)
        )
    )
    if existing_like.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Artıq bəyənmisiz")

    # Create like
    like = PostLike(post_id=post_id, user_id=current_user.id)
    db.add(like)

    # Increment likes count
    post.likes_count += 1
    await db.commit()

    return {"message": "Post bəyənildi", "likes_count": post.likes_count}


@router.delete("/posts/{post_id}/like")
async def unlike_post(
    post_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Unlike a post"""
    # Find like
    result = await db.execute(
        select(PostLike).where(
            and_(PostLike.post_id == post_id, PostLike.user_id == current_user.id)
        )
    )
    like = result.scalar_one_or_none()

    if not like:
        raise HTTPException(status_code=404, detail="Bəyənmə tapılmadı")

    # Delete like
    await db.delete(like)

    # Decrement count
    post_result = await db.execute(select(Post).where(Post.id == post_id))
    post = post_result.scalar_one_or_none()
    if post:
        post.likes_count = max(0, post.likes_count - 1)

    await db.commit()
    return {"message": "Bəyənmə silindi"}


# ============================================================
# COMMENTS
# ============================================================

@router.post("/posts/{post_id}/comments", response_model=CommentResponse)
async def create_comment(
    post_id: str,
    comment_data: CommentCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Comment on a post"""
    # Check if post exists
    post_result = await db.execute(select(Post).where(Post.id == post_id))
    post = post_result.scalar_one_or_none()

    if not post:
        raise HTTPException(status_code=404, detail="Post tapılmadı")

    # Create comment
    comment = PostComment(
        post_id=post_id, user_id=current_user.id, content=comment_data.content
    )
    db.add(comment)

    # Increment comments count
    post.comments_count += 1
    await db.flush()
    await db.refresh(comment)

    # Build response
    response = CommentResponse.model_validate(comment)
    response.author = CommentAuthor(
        id=current_user.id,
        name=current_user.name,
        profile_image_url=current_user.profile_image_url,
    )
    return response


@router.get("/posts/{post_id}/comments", response_model=list[CommentResponse])
async def get_comments(
    post_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get comments for a post"""
    result = await db.execute(
        select(PostComment)
        .where(PostComment.post_id == post_id)
        .order_by(PostComment.created_at)
    )
    comments = result.scalars().all()

    # Get authors
    responses = []
    for comment in comments:
        author_result = await db.execute(select(User).where(User.id == comment.user_id))
        author = author_result.scalar_one_or_none()

        response = CommentResponse.model_validate(comment)
        if author:
            response.author = CommentAuthor(
                id=author.id,
                name=author.name,
                profile_image_url=author.profile_image_url,
            )
        responses.append(response)

    return responses


@router.delete("/comments/{comment_id}")
async def delete_comment(
    comment_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Delete a comment"""
    result = await db.execute(select(PostComment).where(PostComment.id == comment_id))
    comment = result.scalar_one_or_none()

    if not comment:
        raise HTTPException(status_code=404, detail="Şərh tapılmadı")

    if comment.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Bu şərh sizə aid deyil")

    # Decrement count
    post_result = await db.execute(select(Post).where(Post.id == comment.post_id))
    post = post_result.scalar_one_or_none()
    if post:
        post.comments_count = max(0, post.comments_count - 1)

    await db.delete(comment)
    await db.commit()
    return {"message": "Şərh silindi"}


# ============================================================
# FOLLOW/UNFOLLOW
# ============================================================

@router.post("/follow/{user_id}")
async def follow_user(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Follow a user"""
    if user_id == current_user.id:
        raise HTTPException(status_code=400, detail="Özünüzü izləyə bilməzsiniz")

    # Check if user exists
    user_result = await db.execute(select(User).where(User.id == user_id))
    if not user_result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="İstifadəçi tapılmadı")

    # Check if already following
    existing = await db.execute(
        select(Follow).where(
            and_(Follow.follower_id == current_user.id, Follow.following_id == user_id)
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Artıq izləyirsiniz")

    # Create follow
    follow = Follow(follower_id=current_user.id, following_id=user_id)
    db.add(follow)
    await db.commit()

    return {"message": "İstifadəçi izlənilir"}


@router.delete("/follow/{user_id}")
async def unfollow_user(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Unfollow a user"""
    result = await db.execute(
        select(Follow).where(
            and_(Follow.follower_id == current_user.id, Follow.following_id == user_id)
        )
    )
    follow = result.scalar_one_or_none()

    if not follow:
        raise HTTPException(status_code=404, detail="İzləmə tapılmadı")

    await db.delete(follow)
    await db.commit()
    return {"message": "İzləmə dayandırıldı"}


@router.get("/profile/{user_id}", response_model=UserProfileSummary)
async def get_user_profile(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get user profile summary"""
    # Get user
    user_result = await db.execute(select(User).where(User.id == user_id))
    user = user_result.scalar_one_or_none()

    if not user:
        raise HTTPException(status_code=404, detail="İstifadəçi tapılmadı")

    # Get counts
    followers_count = await db.execute(
        select(func.count(Follow.id)).where(Follow.following_id == user_id)
    )
    following_count = await db.execute(
        select(func.count(Follow.id)).where(Follow.follower_id == user_id)
    )
    posts_count = await db.execute(
        select(func.count(Post.id)).where(Post.user_id == user_id)
    )

    # Check if current user follows this user
    follow_check = await db.execute(
        select(Follow).where(
            and_(Follow.follower_id == current_user.id, Follow.following_id == user_id)
        )
    )
    is_following = follow_check.scalar_one_or_none() is not None

    return UserProfileSummary(
        id=user.id,
        name=user.name,
        profile_image_url=user.profile_image_url,
        user_type=user.user_type.value,
        bio=user.bio,
        followers_count=followers_count.scalar(),
        following_count=following_count.scalar(),
        posts_count=posts_count.scalar(),
        is_following=is_following,
    )


# ============================================================
# ACHIEVEMENTS
# ============================================================

@router.get("/achievements", response_model=list[AchievementResponse])
async def get_my_achievements(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get current user's achievements"""
    result = await db.execute(
        select(Achievement)
        .where(Achievement.user_id == current_user.id)
        .order_by(desc(Achievement.earned_at))
    )
    achievements = result.scalars().all()
    return [AchievementResponse.model_validate(a) for a in achievements]


@router.get("/achievements/all")
async def get_all_achievements(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get all available achievements with user's progress"""
    from app.models.workout import Workout

    # Get user's earned achievements
    result = await db.execute(
        select(Achievement).where(Achievement.user_id == current_user.id)
    )
    earned = {a.achievement_type: a for a in result.scalars().all()}

    # Count user's workouts for progress
    workout_count_result = await db.execute(
        select(func.count(Workout.id)).where(Workout.user_id == current_user.id)
    )
    workout_count = workout_count_result.scalar() or 0

    # Count user's posts
    post_count_result = await db.execute(
        select(func.count(Post.id)).where(Post.user_id == current_user.id)
    )
    post_count = post_count_result.scalar() or 0

    # Define all possible achievements
    all_achievements = [
        {
            "achievement_type": "first_workout",
            "title": "İlk Məşq",
            "description": "İlk məşqinizi tamamlayın",
            "icon": "fitness_center",
            "target": 1,
            "current": min(workout_count, 1),
        },
        {
            "achievement_type": "10_workouts",
            "title": "Məşq Həvəskarı",
            "description": "10 məşq tamamlayın",
            "icon": "local_fire_department",
            "target": 10,
            "current": min(workout_count, 10),
        },
        {
            "achievement_type": "50_workouts",
            "title": "Məşq Ustası",
            "description": "50 məşq tamamlayın",
            "icon": "emoji_events",
            "target": 50,
            "current": min(workout_count, 50),
        },
        {
            "achievement_type": "100_workouts",
            "title": "Məşq Legendası",
            "description": "100 məşq tamamlayın",
            "icon": "military_tech",
            "target": 100,
            "current": min(workout_count, 100),
        },
        {
            "achievement_type": "first_post",
            "title": "İlk Post",
            "description": "İlk postunuzu paylaşın",
            "icon": "forum",
            "target": 1,
            "current": min(post_count, 1),
        },
        {
            "achievement_type": "10_posts",
            "title": "Aktiv Paylaşımçı",
            "description": "10 post paylaşın",
            "icon": "share",
            "target": 10,
            "current": min(post_count, 10),
        },
        {
            "achievement_type": "social_butterfly",
            "title": "Sosial Kəpənək",
            "description": "5 nəfəri izləyin",
            "icon": "people",
            "target": 5,
            "current": 0,
        },
        {
            "achievement_type": "consistency",
            "title": "Ardıcıllıq",
            "description": "7 gün ardıcıl məşq edin",
            "icon": "calendar_month",
            "target": 7,
            "current": 0,
        },
    ]

    # Build response
    response = []
    for ach in all_achievements:
        is_earned = ach["achievement_type"] in earned
        earned_data = earned.get(ach["achievement_type"])
        response.append({
            "id": earned_data.id if earned_data else ach["achievement_type"],
            "achievement_type": ach["achievement_type"],
            "title": ach["title"],
            "description": ach["description"],
            "icon": ach["icon"],
            "is_unlocked": is_earned,
            "progress": ach["current"] / ach["target"] if ach["target"] > 0 else 0,
            "target": ach["target"],
            "current": ach["current"],
            "earned_at": earned_data.earned_at.isoformat() if earned_data else None,
        })

    return response


@router.get("/profile/{user_id}/posts", response_model=list[PostResponse])
async def get_user_posts(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get posts by a specific user"""
    result = await db.execute(
        select(Post)
        .where(and_(Post.user_id == user_id, Post.is_public == True))
        .order_by(desc(Post.created_at))
        .limit(50)
    )
    posts = result.scalars().all()

    post_responses = []
    for post in posts:
        author_result = await db.execute(select(User).where(User.id == post.user_id))
        author = author_result.scalar_one_or_none()

        like_result = await db.execute(
            select(PostLike).where(
                and_(PostLike.post_id == post.id, PostLike.user_id == current_user.id)
            )
        )
        is_liked = like_result.scalar_one_or_none() is not None

        post_response = PostResponse.model_validate(post)
        if author:
            post_response.author = PostAuthor(
                id=author.id,
                name=author.name,
                profile_image_url=author.profile_image_url,
                user_type=author.user_type.value,
            )
        post_response.is_liked = is_liked
        post_responses.append(post_response)

    return post_responses
