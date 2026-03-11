"""
Kapital Bank Payment Gateway Router
Ödəniş yaratma, callback və status yoxlama endpoint-ləri
"""
import logging
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status, Request
from fastapi.responses import RedirectResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.config import get_settings
from app.models.user import User
from app.models.payment import Payment
from app.models.subscription import Subscription
from app.schemas.payment import (
    PaymentCreateRequest,
    PaymentCreateResponse,
    PaymentStatusResponse,
)
from app.utils.security import get_current_user
from app.services.kapital_service import create_order, get_order_details, refund_order
from app.services.premium_service import get_plan_info, calculate_expiry, PREMIUM_FEATURES

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/v1/payment", tags=["Payment"])
settings = get_settings()


@router.post("/create-order", response_model=PaymentCreateResponse)
async def create_payment_order(
    data: PaymentCreateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Kapital Bank-da yeni ödəniş sifarişi yaradır.
    iOS app bu URL-i alıb browser-də açmalıdır.
    """
    plan = get_plan_info(data.product_id)
    if not plan:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Yanlış product_id. Mövcud planlar: com.corevia.monthly, com.corevia.yearly"
        )

    # Kapital Bank-da sifariş yarat
    result = await create_order(
        amount=str(plan["price"]),
        description=f"CoreVia Premium - {plan['plan_type'].capitalize()}",
    )

    if result.get("error"):
        logger.error(f"Kapital Bank order creation failed for user {current_user.id}: {result}")
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Ödəniş sistemi ilə əlaqə qurula bilmədi. Zəhmət olmasa bir az sonra yenidən cəhd edin."
        )

    # Payment qeydini DB-yə yaz
    payment = Payment(
        user_id=current_user.id,
        kapital_order_id=result["order_id"],
        kapital_password=result.get("password"),
        product_id=data.product_id,
        plan_type=plan["plan_type"],
        amount=plan["price"],
        currency=plan.get("currency", "AZN"),
        status="Preparing",
    )
    db.add(payment)
    await db.flush()

    return PaymentCreateResponse(
        payment_id=payment.id,
        kapital_order_id=result["order_id"],
        redirect_url=result["redirect_url"],
        amount=plan["price"],
        currency=plan.get("currency", "AZN"),
        status="Preparing",
    )


@router.get("/callback")
async def payment_callback(
    request: Request,
    db: AsyncSession = Depends(get_db),
):
    """
    Kapital Bank ödənişdən sonra bura yönləndirir.
    URL parametrləri: ?ID=1234&STATUS=FullyPaid
    """
    order_id = request.query_params.get("ID") or request.query_params.get("id")
    callback_status = request.query_params.get("STATUS") or request.query_params.get("status")

    if not order_id:
        raise HTTPException(status_code=400, detail="Order ID tapılmadı")

    # Payment-i DB-dən tap
    result = await db.execute(
        select(Payment).where(Payment.kapital_order_id == int(order_id))
    )
    payment = result.scalar_one_or_none()

    if not payment:
        logger.error(f"Payment not found for kapital_order_id: {order_id}")
        raise HTTPException(status_code=404, detail="Ödəniş tapılmadı")

    # Kapital Bank-dan əsl statusu yoxla (callback STATUS-a güvənmə)
    order_details = await get_order_details(order_id)

    if order_details.get("error"):
        logger.error(f"Failed to verify order {order_id}: {order_details}")
        payment.status = "Error"
        await db.flush()
        return RedirectResponse(url=f"corevia://payment?status=error&payment_id={payment.id}")

    actual_status = order_details.get("order", {}).get("status", "")
    payment.status = actual_status

    if actual_status == "FullyPaid":
        payment.is_paid = True
        payment.paid_at = datetime.utcnow()

        # Premium-u aktivləşdir
        await _activate_premium(payment, db)

        logger.info(f"Payment successful: order_id={order_id}, user_id={payment.user_id}")
        return RedirectResponse(url=f"corevia://payment?status=success&payment_id={payment.id}")
    else:
        logger.warning(f"Payment not completed: order_id={order_id}, status={actual_status}")
        return RedirectResponse(url=f"corevia://payment?status={actual_status}&payment_id={payment.id}")


@router.get("/status/{payment_id}", response_model=PaymentStatusResponse)
async def get_payment_status(
    payment_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Ödəniş statusunu yoxlayır. iOS app callback-dən sonra bunu çağırır.
    """
    result = await db.execute(
        select(Payment).where(
            Payment.id == payment_id,
            Payment.user_id == current_user.id,
        )
    )
    payment = result.scalar_one_or_none()

    if not payment:
        raise HTTPException(status_code=404, detail="Ödəniş tapılmadı")

    # Əgər hələ ödənilməyibsə, Kapital Bank-dan yenilə
    if not payment.is_paid:
        order_details = await get_order_details(payment.kapital_order_id)
        if not order_details.get("error"):
            actual_status = order_details.get("order", {}).get("status", "")
            payment.status = actual_status

            if actual_status == "FullyPaid" and not payment.is_paid:
                payment.is_paid = True
                payment.paid_at = datetime.utcnow()
                await _activate_premium(payment, db)

            await db.flush()

    return PaymentStatusResponse(
        payment_id=payment.id,
        kapital_order_id=payment.kapital_order_id,
        product_id=payment.product_id,
        plan_type=payment.plan_type,
        amount=payment.amount,
        currency=payment.currency,
        status=payment.status,
        is_paid=payment.is_paid,
        created_at=payment.created_at,
        paid_at=payment.paid_at,
    )


@router.post("/refund/{payment_id}")
async def refund_payment(
    payment_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Admin və ya istifadəçi tərəfindən geri ödəniş."""
    result = await db.execute(
        select(Payment).where(
            Payment.id == payment_id,
            Payment.user_id == current_user.id,
        )
    )
    payment = result.scalar_one_or_none()

    if not payment:
        raise HTTPException(status_code=404, detail="Ödəniş tapılmadı")

    if not payment.is_paid:
        raise HTTPException(status_code=400, detail="Bu ödəniş hələ tamamlanmayıb")

    refund_result = await refund_order(payment.kapital_order_id)

    if refund_result.get("error"):
        raise HTTPException(status_code=502, detail="Geri ödəniş uğursuz oldu")

    payment.status = "Refunded"

    # Premium-u deaktiv et
    user_result = await db.execute(select(User).where(User.id == payment.user_id))
    user = user_result.scalar_one_or_none()
    if user:
        user.is_premium = False

    # Aktiv subscription-ları deaktiv et
    sub_result = await db.execute(
        select(Subscription).where(
            Subscription.user_id == payment.user_id,
            Subscription.is_active == True,
        )
    )
    for sub in sub_result.scalars():
        sub.is_active = False
        sub.cancelled_at = datetime.utcnow()

    await db.flush()

    return {"message": "Geri ödəniş uğurla tamamlandı", "status": "Refunded"}


async def _activate_premium(payment: Payment, db: AsyncSession):
    """Ödəniş uğurlu olduqda premium-u aktivləşdirir."""
    plan = get_plan_info(payment.product_id)
    if not plan:
        return

    # User-in premium statusunu yenilə
    user_result = await db.execute(select(User).where(User.id == payment.user_id))
    user = user_result.scalar_one_or_none()
    if not user:
        return

    # Əvvəlki aktiv subscription-ları deaktiv et
    old_subs = await db.execute(
        select(Subscription).where(
            Subscription.user_id == payment.user_id,
            Subscription.is_active == True,
        )
    )
    for sub in old_subs.scalars():
        sub.is_active = False

    # Yeni subscription yarat
    expires_at = calculate_expiry(payment.product_id)
    subscription = Subscription(
        user_id=payment.user_id,
        product_id=payment.product_id,
        transaction_id=f"kapital_{payment.kapital_order_id}",
        plan_type=payment.plan_type,
        price=payment.amount,
        currency=payment.currency,
        is_active=True,
        auto_renew=False,
        expires_at=expires_at,
    )
    db.add(subscription)

    # User premium et
    user.is_premium = True
    await db.flush()

    logger.info(f"Premium activated for user {payment.user_id}: {payment.plan_type} until {expires_at}")
