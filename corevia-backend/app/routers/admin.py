from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.user import User, UserType, VerificationStatus
from app.schemas.user import UserResponse, TrainerListResponse
from app.utils.security import get_current_user

router = APIRouter(prefix="/api/v1/admin", tags=["Admin"])


def require_admin(current_user: User = Depends(get_current_user)) -> User:
    """Sadece admin (ilk trainer verified olan) icaze verir.
    Production-da bunu daha ciddi etmek lazimdir (admin role elave etmekle)."""
    # Helelik: her hansi verified trainer admin ola biler
    # Gelecekde: User model-ine is_admin field elave olunacaq
    if current_user.user_type != UserType.trainer:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin icazesi lazimdir")
    return current_user


@router.get("/pending-trainers", response_model=list[TrainerListResponse])
async def get_pending_trainers(
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(User).where(
            User.user_type == UserType.trainer,
            User.verification_status == VerificationStatus.pending,
        ).order_by(User.created_at.desc())
    )
    return result.scalars().all()


@router.post("/verify-trainer/{trainer_id}")
async def verify_trainer(
    trainer_id: str,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(User).where(
            User.id == trainer_id,
            User.user_type == UserType.trainer,
        )
    )
    trainer = result.scalar_one_or_none()
    if not trainer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trainer tapilmadi")

    trainer.verification_status = VerificationStatus.verified
    return {
        "message": f"Trainer '{trainer.name}' verifikasiya olundu",
        "trainer_id": trainer.id,
        "status": "verified",
    }


@router.post("/reject-trainer/{trainer_id}")
async def reject_trainer(
    trainer_id: str,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(User).where(
            User.id == trainer_id,
            User.user_type == UserType.trainer,
        )
    )
    trainer = result.scalar_one_or_none()
    if not trainer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trainer tapilmadi")

    trainer.verification_status = VerificationStatus.rejected
    return {
        "message": f"Trainer '{trainer.name}' redd edildi",
        "trainer_id": trainer.id,
        "status": "rejected",
    }


@router.get("/all-trainers", response_model=list[TrainerListResponse])
async def get_all_trainers(
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(User).where(User.user_type == UserType.trainer).order_by(User.created_at.desc())
    )
    return result.scalars().all()


@router.get("/stats")
async def get_admin_stats(
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    from sqlalchemy import func

    total_users = await db.execute(select(func.count(User.id)))
    total_clients = await db.execute(select(func.count(User.id)).where(User.user_type == UserType.client))
    total_trainers = await db.execute(select(func.count(User.id)).where(User.user_type == UserType.trainer))
    pending_trainers = await db.execute(
        select(func.count(User.id)).where(
            User.user_type == UserType.trainer,
            User.verification_status == VerificationStatus.pending,
        )
    )

    return {
        "total_users": total_users.scalar(),
        "total_clients": total_clients.scalar(),
        "total_trainers": total_trainers.scalar(),
        "pending_verifications": pending_trainers.scalar(),
    }
