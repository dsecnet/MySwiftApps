from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.user import User
from app.models.subscription import Subscription
from app.schemas.subscription import (
    SubscriptionCreate,
    SubscriptionResponse,
    PremiumStatusResponse,
)
from app.utils.security import get_current_user
from app.services.premium_service import (
    get_plan_info,
    calculate_expiry,
    validate_apple_receipt,
    check_subscription_active,
    PREMIUM_FEATURES,
)

router = APIRouter(prefix="/api/v1/premium", tags=["Premium"])


@router.get("/status", response_model=PremiumStatusResponse)
async def get_premium_status(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Istifadecinin premium statusunu yoxla"""
    # Son aktiv abuneligi tap
    result = await db.execute(
        select(Subscription)
        .where(Subscription.user_id == current_user.id, Subscription.is_active == True)
        .order_by(Subscription.expires_at.desc())
    )
    subscription = result.scalar_one_or_none()

    if subscription and check_subscription_active(subscription.expires_at):
        return PremiumStatusResponse(
            is_premium=True,
            plan_type=subscription.plan_type,
            expires_at=subscription.expires_at,
            auto_renew=subscription.auto_renew,
            features=PREMIUM_FEATURES,
        )

    # Abunəlik bitibse, user-in premium statusunu sondur
    if subscription and not check_subscription_active(subscription.expires_at):
        subscription.is_active = False
        if current_user.is_premium:
            current_user.is_premium = False

    return PremiumStatusResponse(
        is_premium=current_user.is_premium,
        features=PREMIUM_FEATURES if current_user.is_premium else [],
    )


@router.post("/subscribe", response_model=SubscriptionResponse)
async def subscribe(
    data: SubscriptionCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Premium abunəlik al (iOS app-dan Apple IAP receipt ile)"""
    plan = get_plan_info(data.product_id)
    if not plan:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Tanınmayan product_id: {data.product_id}. Movcud planlar: com.corevia.monthly, com.corevia.yearly",
        )

    # Apple receipt dogrula (hazirda mock)
    if data.receipt_data:
        validation = await validate_apple_receipt(data.receipt_data)
        if not validation:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Apple receipt dogrulana bilmedi",
            )

    # Eyni transaction_id ile tekrar satin alma yoxla
    if data.transaction_id:
        existing = await db.execute(
            select(Subscription).where(Subscription.transaction_id == data.transaction_id)
        )
        if existing.scalar_one_or_none():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Bu transaction artiq movcuddur",
            )

    # Kohne aktiv abunelikleri sondur
    old_subs = await db.execute(
        select(Subscription).where(
            Subscription.user_id == current_user.id,
            Subscription.is_active == True,
        )
    )
    for old_sub in old_subs.scalars().all():
        old_sub.is_active = False

    # Yeni abunəlik yarat
    expires_at = calculate_expiry(data.product_id)

    subscription = Subscription(
        user_id=current_user.id,
        product_id=data.product_id,
        transaction_id=data.transaction_id,
        original_transaction_id=data.original_transaction_id,
        receipt_data=data.receipt_data,
        plan_type=plan["plan_type"],
        price=plan["price"],
        currency=plan["currency"],
        expires_at=expires_at,
    )
    db.add(subscription)

    # User-i premium et
    current_user.is_premium = True

    await db.flush()
    return subscription


@router.post("/cancel")
async def cancel_subscription(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Abunəliyi legv et (auto-renew sondurulur, mddət bitene kimi isleyir)"""
    result = await db.execute(
        select(Subscription).where(
            Subscription.user_id == current_user.id,
            Subscription.is_active == True,
        )
    )
    subscription = result.scalar_one_or_none()

    if not subscription:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Aktiv abunəlik tapilmadi",
        )

    subscription.auto_renew = False
    subscription.cancelled_at = datetime.utcnow()

    return {
        "message": "Abunəlik legv olundu. Premium muddət bitene kimi davam edecek.",
        "expires_at": subscription.expires_at.isoformat(),
    }


@router.post("/restore")
async def restore_subscription(
    data: SubscriptionCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Apple IAP restore purchases (cihaz deyisdikde)"""
    if data.receipt_data:
        validation = await validate_apple_receipt(data.receipt_data)
        if not validation:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Receipt dogrulana bilmedi",
            )

    # original_transaction_id ile abuneligi tap
    if data.original_transaction_id:
        result = await db.execute(
            select(Subscription).where(
                Subscription.original_transaction_id == data.original_transaction_id,
            )
        )
        subscription = result.scalar_one_or_none()

        if subscription and check_subscription_active(subscription.expires_at):
            # Bu user-e bagla
            subscription.user_id = current_user.id
            subscription.is_active = True
            current_user.is_premium = True
            return {
                "message": "Abunəlik berpa olundu",
                "plan_type": subscription.plan_type,
                "expires_at": subscription.expires_at.isoformat(),
            }

    return {
        "message": "Berpa olunacaq aktiv abunəlik tapilmadi",
        "is_restored": False,
    }


@router.get("/history", response_model=list[SubscriptionResponse])
async def get_subscription_history(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Abunəlik tarixcesi"""
    result = await db.execute(
        select(Subscription)
        .where(Subscription.user_id == current_user.id)
        .order_by(Subscription.created_at.desc())
    )
    return result.scalars().all()


@router.get("/plans")
async def get_available_plans():
    """Movcud premium planlar (login olmadan da gorune biler)"""
    return {
        "plans": [
            {
                "product_id": "com.corevia.monthly",
                "name": "Ayliq Premium",
                "price": 9.99,
                "currency": "AZN",
                "period": "monthly",
                "features": PREMIUM_FEATURES,
            },
            {
                "product_id": "com.corevia.yearly",
                "name": "Illik Premium",
                "price": 79.99,
                "currency": "AZN",
                "period": "yearly",
                "save_percent": 20,
                "features": PREMIUM_FEATURES,
                "is_popular": True,
            },
        ],
    }
