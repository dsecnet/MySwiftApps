from pathlib import Path
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import HTMLResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.database import get_db
from app.models.user import User, UserType, VerificationStatus
from app.models.subscription import Subscription
from app.models.review import Review
from app.models.chat import ChatMessage
from app.schemas.user import UserResponse, TrainerListResponse
from app.utils.security import get_current_user

router = APIRouter(prefix="/api/v1/admin", tags=["Admin"])

TEMPLATE_DIR = Path(__file__).parent.parent / "templates"


@router.get("/panel", response_class=HTMLResponse, include_in_schema=False)
async def admin_panel():
    """Admin web panel - HTML serve."""
    html_path = TEMPLATE_DIR / "admin.html"
    if not html_path.exists():
        return HTMLResponse("<h1>Admin template not found</h1>", status_code=404)
    return HTMLResponse(html_path.read_text(encoding="utf-8"))


def require_admin(current_user: User = Depends(get_current_user)) -> User:
    """Yalniz is_admin=True olan istifadeci daxil ola biler."""
    if not current_user.is_admin:
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
    total_users = await db.execute(select(func.count(User.id)))
    total_clients = await db.execute(select(func.count(User.id)).where(User.user_type == UserType.client))
    total_trainers = await db.execute(select(func.count(User.id)).where(User.user_type == UserType.trainer))
    pending_trainers = await db.execute(
        select(func.count(User.id)).where(
            User.user_type == UserType.trainer,
            User.verification_status == VerificationStatus.pending,
        )
    )
    verified_trainers = await db.execute(
        select(func.count(User.id)).where(
            User.user_type == UserType.trainer,
            User.verification_status == VerificationStatus.verified,
        )
    )
    premium_users = await db.execute(
        select(func.count(User.id)).where(User.is_premium == True)
    )
    active_subs = await db.execute(
        select(func.count(Subscription.id)).where(Subscription.is_active == True)
    )
    total_reviews = await db.execute(select(func.count(Review.id)))
    total_messages = await db.execute(select(func.count(ChatMessage.id)))

    # Son 7 gun qeydiyyat
    week_ago = datetime.utcnow() - timedelta(days=7)
    new_users_week = await db.execute(
        select(func.count(User.id)).where(User.created_at >= week_ago)
    )

    # Son 30 gun qeydiyyat
    month_ago = datetime.utcnow() - timedelta(days=30)
    new_users_month = await db.execute(
        select(func.count(User.id)).where(User.created_at >= month_ago)
    )

    return {
        "total_users": total_users.scalar(),
        "total_clients": total_clients.scalar(),
        "total_trainers": total_trainers.scalar(),
        "verified_trainers": verified_trainers.scalar(),
        "pending_verifications": pending_trainers.scalar(),
        "premium_users": premium_users.scalar(),
        "active_subscriptions": active_subs.scalar(),
        "total_reviews": total_reviews.scalar(),
        "total_messages": total_messages.scalar(),
        "new_users_this_week": new_users_week.scalar(),
        "new_users_this_month": new_users_month.scalar(),
    }


@router.get("/metrics")
async def get_metrics(
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    """MAU, retention, growth metrikleri (demo data + real data mix)."""
    now = datetime.utcnow()

    # Son 6 ay ucun ayliq qeydiyyat
    monthly_signups = []
    for i in range(5, -1, -1):
        month_start = (now.replace(day=1) - timedelta(days=30 * i)).replace(day=1)
        if i > 0:
            month_end = (now.replace(day=1) - timedelta(days=30 * (i - 1))).replace(day=1)
        else:
            month_end = now

        count_result = await db.execute(
            select(func.count(User.id)).where(
                User.created_at >= month_start,
                User.created_at < month_end,
            )
        )
        count = count_result.scalar() or 0
        monthly_signups.append({
            "month": month_start.strftime("%b %Y"),
            "signups": count,
        })

    # Premium conversion rate
    total = (await db.execute(select(func.count(User.id)))).scalar() or 1
    premium = (await db.execute(select(func.count(User.id)).where(User.is_premium == True))).scalar() or 0

    return {
        "monthly_signups": monthly_signups,
        "mau_estimate": total,
        "premium_conversion_rate": round((premium / total) * 100, 1) if total > 0 else 0,
        "retention_data": [
            {"period": "Week 1", "rate": 85},
            {"period": "Week 2", "rate": 72},
            {"period": "Week 3", "rate": 65},
            {"period": "Week 4", "rate": 58},
            {"period": "Month 2", "rate": 45},
            {"period": "Month 3", "rate": 38},
        ],
        "growth_data": [
            {"metric": "User Growth", "value": "+24%", "trend": "up"},
            {"metric": "Premium Conv.", "value": f"{round((premium / total) * 100, 1)}%", "trend": "up"},
            {"metric": "Avg. Session", "value": "12 min", "trend": "up"},
            {"metric": "Trainer Satisfaction", "value": "4.6/5", "trend": "stable"},
        ],
    }
