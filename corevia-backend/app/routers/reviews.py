from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, update

from app.database import get_db
from app.models.user import User, UserType
from app.models.review import Review
from app.schemas.review import ReviewCreate, ReviewResponse, ReviewSummary
from app.utils.security import get_current_user

router = APIRouter(prefix="/api/v1/trainer", tags=["Reviews"])


@router.post("/{trainer_id}/reviews", response_model=ReviewResponse)
async def create_review(
    trainer_id: str,
    review_data: ReviewCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Student trainer-e review yazar."""
    if current_user.user_type != UserType.client:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Yalniz telebeleler review yaza biler",
        )

    # Trainer movcud olmalidi
    result = await db.execute(
        select(User).where(User.id == trainer_id, User.user_type == UserType.trainer)
    )
    trainer = result.scalar_one_or_none()
    if not trainer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trainer tapilmadi")

    # Eyni telebe eyni trainer-e yalniz 1 review yaza biler
    existing = await db.execute(
        select(Review).where(
            Review.trainer_id == trainer_id,
            Review.student_id == current_user.id,
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Siz artiq bu trainer-e review yazmisiniz",
        )

    review = Review(
        trainer_id=trainer_id,
        student_id=current_user.id,
        rating=review_data.rating,
        comment=review_data.comment,
    )
    db.add(review)
    await db.flush()

    # Orta rating-i yenile
    avg_result = await db.execute(
        select(func.avg(Review.rating)).where(Review.trainer_id == trainer_id)
    )
    avg_rating = avg_result.scalar() or 0.0
    await db.execute(
        update(User).where(User.id == trainer_id).values(rating=round(float(avg_rating), 1))
    )

    return ReviewResponse(
        id=review.id,
        trainer_id=review.trainer_id,
        student_id=review.student_id,
        student_name=current_user.name,
        student_profile_image=current_user.profile_image_url,
        rating=review.rating,
        comment=review.comment,
        created_at=review.created_at,
    )


@router.get("/{trainer_id}/reviews", response_model=list[ReviewResponse])
async def get_trainer_reviews(
    trainer_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Trainer-in butun review-larini getir."""
    result = await db.execute(
        select(Review).where(Review.trainer_id == trainer_id).order_by(Review.created_at.desc())
    )
    reviews = result.scalars().all()

    response = []
    for review in reviews:
        student_result = await db.execute(select(User).where(User.id == review.student_id))
        student = student_result.scalar_one_or_none()
        response.append(
            ReviewResponse(
                id=review.id,
                trainer_id=review.trainer_id,
                student_id=review.student_id,
                student_name=student.name if student else "Unknown",
                student_profile_image=student.profile_image_url if student else None,
                rating=review.rating,
                comment=review.comment,
                created_at=review.created_at,
            )
        )

    return response


@router.get("/{trainer_id}/reviews/summary", response_model=ReviewSummary)
async def get_review_summary(
    trainer_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Trainer-in review xulasesini getir."""
    result = await db.execute(
        select(Review.rating).where(Review.trainer_id == trainer_id)
    )
    ratings = [r[0] for r in result.all()]

    if not ratings:
        return ReviewSummary(
            average_rating=0.0,
            total_reviews=0,
            rating_distribution={5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        )

    distribution = {i: ratings.count(i) for i in range(1, 6)}
    return ReviewSummary(
        average_rating=round(sum(ratings) / len(ratings), 1),
        total_reviews=len(ratings),
        rating_distribution=distribution,
    )


@router.delete("/{trainer_id}/reviews", status_code=status.HTTP_204_NO_CONTENT)
async def delete_my_review(
    trainer_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Student oz review-unu silsin."""
    result = await db.execute(
        select(Review).where(
            Review.trainer_id == trainer_id,
            Review.student_id == current_user.id,
        )
    )
    review = result.scalar_one_or_none()
    if not review:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Review tapilmadi")

    await db.delete(review)
    await db.flush()

    # Orta rating-i yenile
    avg_result = await db.execute(
        select(func.avg(Review.rating)).where(Review.trainer_id == trainer_id)
    )
    avg_rating = avg_result.scalar()
    await db.execute(
        update(User).where(User.id == trainer_id).values(
            rating=round(float(avg_rating), 1) if avg_rating else None
        )
    )
