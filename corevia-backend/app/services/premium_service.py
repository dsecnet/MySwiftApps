import logging
from datetime import datetime, timedelta

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


async def validate_apple_receipt(receipt_data: str) -> dict | None:
    """Apple receipt-i dogrula (App Store Server API)

    Production-da Apple-in verifyReceipt endpoint-ine request gonderilir.
    Hazirda mock implementasiya - her zaman valid qaytarir.
    """
    if not receipt_data:
        return None

    # TODO: Production-da Apple App Store Server API ile dogrulama
    # https://developer.apple.com/documentation/appstoreserverapi
    #
    # async with httpx.AsyncClient() as client:
    #     response = await client.post(
    #         "https://buy.itunes.apple.com/verifyReceipt",
    #         json={"receipt-data": receipt_data, "password": SHARED_SECRET}
    #     )
    #     data = response.json()
    #     if data["status"] == 0:
    #         return data["latest_receipt_info"]

    logger.info("[MOCK] Apple receipt validation - ugurlu (mock)")
    return {
        "status": "valid",
        "is_mock": True,
    }


def check_subscription_active(expires_at: datetime) -> bool:
    """Abunəlik hele aktiv-mi yoxla"""
    return datetime.utcnow() < expires_at
