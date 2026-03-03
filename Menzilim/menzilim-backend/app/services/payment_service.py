import uuid
import logging
from decimal import Decimal

import httpx
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models.payment import Payment, PaymentStatus
from app.services.notification_service import notification_service

settings = get_settings()
logger = logging.getLogger(__name__)

# Product ID to pricing map
PRODUCT_PRICING = {
    "com.menzilim.boost.standard.7": {"type": "boost_standard", "amount": Decimal("5.99"), "currency": "AZN"},
    "com.menzilim.boost.standard.30": {"type": "boost_standard", "amount": Decimal("14.99"), "currency": "AZN"},
    "com.menzilim.boost.premium.7": {"type": "boost_premium", "amount": Decimal("9.99"), "currency": "AZN"},
    "com.menzilim.boost.premium.30": {"type": "boost_premium", "amount": Decimal("24.99"), "currency": "AZN"},
    "com.menzilim.boost.vip.7": {"type": "boost_vip", "amount": Decimal("19.99"), "currency": "AZN"},
    "com.menzilim.boost.vip.30": {"type": "boost_vip", "amount": Decimal("49.99"), "currency": "AZN"},
    "com.menzilim.premium.agent.monthly": {"type": "agent_premium", "amount": Decimal("29.99"), "currency": "AZN"},
    "com.menzilim.premium.agent.yearly": {"type": "agent_premium", "amount": Decimal("249.99"), "currency": "AZN"},
}


class PaymentService:
    """Service for handling Apple In-App Purchase receipt verification."""

    @staticmethod
    async def verify_apple_receipt(
        db: AsyncSession,
        user_id: uuid.UUID,
        receipt_data: str,
        transaction_id: str | None = None,
        product_id: str | None = None,
    ) -> Payment:
        """
        Verify an Apple receipt and create a payment record.
        Uses Apple's verifyReceipt endpoint.
        """
        # First try production URL
        result = await PaymentService._call_apple_verify(
            receipt_data, settings.APPLE_VERIFY_URL
        )

        # If status 21007, it's a sandbox receipt - retry with sandbox URL
        if result and result.get("status") == 21007:
            result = await PaymentService._call_apple_verify(
                receipt_data, settings.APPLE_SANDBOX_VERIFY_URL
            )

        if not result or result.get("status") != 0:
            # Create a failed payment record
            payment = Payment(
                user_id=user_id,
                type=product_id or "unknown",
                amount=Decimal("0"),
                currency="AZN",
                apple_transaction_id=transaction_id,
                status=PaymentStatus.FAILED,
            )
            db.add(payment)
            await db.flush()
            logger.warning(
                f"Apple receipt verification failed for user={user_id}: "
                f"status={result.get('status') if result else 'no response'}"
            )
            return payment

        # Extract latest receipt info
        latest_receipt = result.get("latest_receipt_info", [])
        receipt_info = result.get("receipt", {})
        in_app = receipt_info.get("in_app", [])

        # Use the latest transaction
        transactions = latest_receipt or in_app
        if not transactions:
            payment = Payment(
                user_id=user_id,
                type=product_id or "unknown",
                amount=Decimal("0"),
                currency="AZN",
                apple_transaction_id=transaction_id,
                status=PaymentStatus.FAILED,
            )
            db.add(payment)
            await db.flush()
            return payment

        latest = transactions[-1]
        apple_product_id = latest.get("product_id", product_id or "unknown")
        apple_txn_id = latest.get("transaction_id", transaction_id)

        # Look up pricing
        pricing = PRODUCT_PRICING.get(apple_product_id, {
            "type": apple_product_id,
            "amount": Decimal("0"),
            "currency": "AZN",
        })

        # Create successful payment
        payment = Payment(
            user_id=user_id,
            type=pricing["type"],
            amount=pricing["amount"],
            currency=pricing["currency"],
            apple_transaction_id=apple_txn_id,
            status=PaymentStatus.COMPLETED,
        )
        db.add(payment)
        await db.flush()

        # Send notification
        await notification_service.notify_payment_success(
            db=db,
            user_id=user_id,
            payment_type=pricing["type"],
            amount=f"{pricing['amount']} {pricing['currency']}",
        )

        logger.info(
            f"Payment completed: user={user_id}, type={pricing['type']}, "
            f"amount={pricing['amount']} {pricing['currency']}"
        )
        return payment

    @staticmethod
    async def _call_apple_verify(
        receipt_data: str, verify_url: str
    ) -> dict | None:
        """Call Apple's verifyReceipt endpoint."""
        try:
            payload = {"receipt-data": receipt_data}
            if settings.APPLE_SHARED_SECRET:
                payload["password"] = settings.APPLE_SHARED_SECRET

            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(verify_url, json=payload)
                response.raise_for_status()
                return response.json()
        except Exception as e:
            logger.error(f"Apple receipt verification error: {e}")
            return None


payment_service = PaymentService()
