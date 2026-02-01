from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.user import User, UserType, VerificationStatus
from app.schemas.user import UserResponse, UserProfileUpdate, TrainerListResponse
from app.utils.security import get_current_user

router = APIRouter(prefix="/api/v1/users", tags=["Users"])


@router.get("/profile", response_model=UserResponse)
async def get_profile(current_user: User = Depends(get_current_user)):
    return current_user


@router.put("/profile", response_model=UserResponse)
async def update_profile(
    profile_data: UserProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    update_data = profile_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(current_user, field, value)
    return current_user


@router.get("/trainers", response_model=list[TrainerListResponse])
async def get_trainers(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(User).where(
            User.user_type == UserType.trainer,
            User.is_active == True,
            User.verification_status == VerificationStatus.verified,
        )
    )
    return result.scalars().all()


@router.get("/trainer/{trainer_id}", response_model=UserResponse)
async def get_trainer(trainer_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(User).where(
            User.id == trainer_id,
            User.user_type == UserType.trainer,
        )
    )
    trainer = result.scalar_one_or_none()
    if not trainer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trainer tapilmadi")
    return trainer


@router.post("/assign-trainer/{trainer_id}", response_model=UserResponse)
async def assign_trainer(
    trainer_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if current_user.user_type != UserType.client:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Yalniz client trainer sece biler",
        )

    # Trainer movcudlugunu yoxla
    result = await db.execute(
        select(User).where(
            User.id == trainer_id,
            User.user_type == UserType.trainer,
            User.verification_status == VerificationStatus.verified,
        )
    )
    trainer = result.scalar_one_or_none()
    if not trainer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trainer tapilmadi")

    current_user.trainer_id = trainer_id
    return current_user


@router.get("/my-students", response_model=list[UserResponse])
async def get_my_students(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if current_user.user_type != UserType.trainer:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Yalniz trainer oz telebeleri gore biler",
        )

    result = await db.execute(
        select(User).where(User.trainer_id == current_user.id)
    )
    return result.scalars().all()
