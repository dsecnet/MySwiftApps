from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.config import get_settings
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
settings = get_settings()


@router.get("/status", response_model=PremiumStatusResponse)
async def get_premium_status(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Istifadecinin premium statusunu yoxla"""
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

    if data.receipt_data:
        # Real Apple receipt validation with config settings
        validation = await validate_apple_receipt(
            receipt_data=data.receipt_data,
            use_production=settings.apple_use_production,
            shared_secret=settings.apple_shared_secret or None
        )
        if not validation or validation.get("status") != "valid":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Apple receipt doğrulana bilmədi. Ödəniş uğursuz oldu.",
            )

    if data.transaction_id:
        existing = await db.execute(
            select(Subscription).where(Subscription.transaction_id == data.transaction_id)
        )
        if existing.scalar_one_or_none():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Bu transaction artiq movcuddur",
            )

    old_subs = await db.execute(
        select(Subscription).where(
            Subscription.user_id == current_user.id,
            Subscription.is_active == True,
        )
    )
    for old_sub in old_subs.scalars().all():
        old_sub.is_active = False

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

    current_user.is_premium = True

    await db.flush()
    return subscription


@router.post("/activate")
async def activate_premium(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Premium-u birbaşa aktivləşdir (development/test üçün).

    Production-da Apple IAP /subscribe endpoint istifadə olunacaq.
    Bu endpoint test məqsədli olaraq useri birbaşa premium edir.
    """
    if not get_settings().debug:
        raise HTTPException(status_code=404, detail="Not found")

    if current_user.is_premium:
        return {
            "message": "Artıq premium istifadəçisiniz",
            "is_premium": True,
        }

    current_user.is_premium = True

    expires_at = calculate_expiry("com.corevia.monthly")
    subscription = Subscription(
        user_id=current_user.id,
        product_id="com.corevia.monthly",
        transaction_id=f"dev_{current_user.id}_{datetime.utcnow().timestamp()}",
        original_transaction_id=f"dev_orig_{current_user.id}",
        plan_type="monthly",
        price=9.99,
        currency="AZN",
        expires_at=expires_at,
    )
    db.add(subscription)

    return {
        "message": "Premium uğurla aktivləşdirildi!",
        "is_premium": True,
        "plan_type": "monthly",
        "expires_at": expires_at.isoformat(),
    }


@router.post("/cancel")
async def cancel_subscription(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Abunəliyi ləğv et — premium dərhal söndürülür"""
    result = await db.execute(
        select(Subscription).where(
            Subscription.user_id == current_user.id,
            Subscription.is_active == True,
        )
    )
    subscriptions = result.scalars().all()

    for sub in subscriptions:
        sub.is_active = False
        sub.auto_renew = False
        sub.cancelled_at = datetime.utcnow()

    current_user.is_premium = False

    if current_user.trainer_id:
        current_user.trainer_id = None

    return {
        "message": "Premium abunəlik ləğv olundu.",
        "is_premium": False,
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

    if data.original_transaction_id:
        result = await db.execute(
            select(Subscription).where(
                Subscription.original_transaction_id == data.original_transaction_id,
            )
        )
        subscription = result.scalar_one_or_none()

        if subscription and check_subscription_active(subscription.expires_at):
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
