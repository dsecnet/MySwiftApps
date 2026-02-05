import logging
from datetime import datetime, timedelta
import httpx

logger = logging.getLogger(__name__)

# Product ID -> Plan melumatlari
PRODUCT_PLANS = {
    "com.corevia.monthly": {
        "plan_type": "monthly",
        "price": 9.99,
        "currency": "AZN",
        "duration_days": 30,
    },
    "com.corevia.yearly": {
        "plan_type": "yearly",
        "price": 79.99,
        "currency": "AZN",
        "duration_days": 365,
    },
}

# Premium features siyahisi
PREMIUM_FEATURES = [
    "unlimited_workouts",
    "detailed_statistics",
    "smart_notifications",
    "premium_trainers",
    "ai_recommendations",
    "cloud_sync",
]


def get_plan_info(product_id: str) -> dict | None:
    """Product ID-ye gore plan melumatlari al"""
    return PRODUCT_PLANS.get(product_id)


def calculate_expiry(product_id: str, start: datetime | None = None) -> datetime:
    """Abunəliyin bitmə tarixini hesabla"""
    plan = PRODUCT_PLANS.get(product_id)
    if not plan:
        return datetime.utcnow() + timedelta(days=30)  # default 30 gun
    start = start or datetime.utcnow()
    return start + timedelta(days=plan["duration_days"])


async def validate_apple_receipt(
    receipt_data: str,
    use_production: bool = False,
    shared_secret: str | None = None
) -> dict | None:
    """Apple receipt-i dogrula (App Store Server API)

    Args:
        receipt_data: Base64 encoded receipt data from iOS
        use_production: True = production server, False = sandbox
        shared_secret: App-specific shared secret (optional, for subscriptions)

    Returns:
        dict with validation results or None if invalid
    """
    if not receipt_data:
        logger.warning("Empty receipt data provided")
        return None

    # Apple verifyReceipt endpoint
    # Sandbox: https://sandbox.itunes.apple.com/verifyReceipt
    # Production: https://buy.itunes.apple.com/verifyReceipt
    url = (
        "https://buy.itunes.apple.com/verifyReceipt"
        if use_production
        else "https://sandbox.itunes.apple.com/verifyReceipt"
    )

    payload = {"receipt-data": receipt_data}
    if shared_secret:
        payload["password"] = shared_secret

    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.post(url, json=payload)
            data = response.json()

            # Status codes: https://developer.apple.com/documentation/appstorereceipts/status
            status = data.get("status")

            if status == 0:
                # Valid receipt
                logger.info(f"Apple receipt validation successful (environment: {'production' if use_production else 'sandbox'})")
                return {
                    "status": "valid",
                    "environment": data.get("environment"),
                    "receipt": data.get("receipt"),
                    "latest_receipt_info": data.get("latest_receipt_info"),
                    "pending_renewal_info": data.get("pending_renewal_info"),
                }

            elif status == 21007:
                # Sandbox receipt sent to production - retry with sandbox
                if use_production:
                    logger.info("Receipt is sandbox, retrying with sandbox server")
                    return await validate_apple_receipt(receipt_data, use_production=False, shared_secret=shared_secret)

            elif status == 21008:
                # Production receipt sent to sandbox - retry with production
                if not use_production:
                    logger.info("Receipt is production, retrying with production server")
                    return await validate_apple_receipt(receipt_data, use_production=True, shared_secret=shared_secret)

            else:
                # Other errors
                error_messages = {
                    21000: "App Store could not read the receipt",
                    21002: "Receipt data is malformed",
                    21003: "Receipt could not be authenticated",
                    21004: "Shared secret does not match",
                    21005: "Receipt server unavailable",
                    21006: "Receipt valid but subscription expired",
                    21009: "Internal data access error",
                    21010: "User account not found",
                }
                error_msg = error_messages.get(status, f"Unknown status code: {status}")
                logger.warning(f"Apple receipt validation failed: {error_msg}")
                return None

    except httpx.TimeoutException:
        logger.error("Apple receipt validation timeout")
        return None
    except httpx.RequestError as e:
        logger.error(f"Apple receipt validation network error: {e}")
        return None
    except Exception as e:
        logger.error(f"Apple receipt validation unexpected error: {e}")
        return None


def check_subscription_active(expires_at: datetime) -> bool:
    """Abunəlik hele aktiv-mi yoxla"""
    return datetime.utcnow() < expires_at
