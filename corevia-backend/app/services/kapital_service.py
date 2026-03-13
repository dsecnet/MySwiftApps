"""
Kapital Bank Payment Gateway Service
https://pg.kapitalbank.az/docs
"""
import logging
import httpx
from app.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()

# Cloudflare WAF browser User-Agent tələb edir
HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "application/json",
}

# Production və Test URL-ləri
KAPITAL_PROD_URL = "https://e-commerce.kapitalbank.az/api"
KAPITAL_TEST_URL = "https://txpgtst.kapitalbank.az/api"


def _get_base_url() -> str:
    if settings.kapital_use_production:
        return KAPITAL_PROD_URL
    return settings.kapital_base_url or KAPITAL_TEST_URL


def _get_auth() -> tuple[str, str]:
    return (settings.kapital_username, settings.kapital_password)


async def create_order(
    amount: str,
    description: str,
    redirect_url: str | None = None,
) -> dict:
    """
    Kapital Bank-da yeni sifariş yaradır.
    Qaytarır: {id, hppUrl, password, status, redirect_url}
    """
    base_url = _get_base_url()
    callback = redirect_url or settings.kapital_callback_url

    payload = {
        "order": {
            "typeRid": "Order_SMS",
            "amount": str(amount),
            "currency": settings.kapital_currency,
            "language": settings.kapital_language,
            "description": description,
            "hppRedirectUrl": callback,
        }
    }

    async with httpx.AsyncClient(timeout=30.0, headers=HEADERS) as client:
        response = await client.post(
            f"{base_url}/order",
            json=payload,
            auth=_get_auth(),
        )

    if response.status_code != 200:
        logger.error(f"Kapital Bank order creation failed: {response.status_code} - {response.text}")
        return {"error": True, "status_code": response.status_code, "detail": response.text}

    data = response.json()
    order = data.get("order", {})

    # HPP redirect URL-ini yaradırıq
    hpp_url = order.get("hppUrl", "")
    order_id = order.get("id", "")
    password = order.get("password", "")
    full_redirect_url = f"{hpp_url}?id={order_id}&password={password}"

    return {
        "order_id": order_id,
        "hpp_url": hpp_url,
        "password": password,
        "status": order.get("status"),
        "redirect_url": full_redirect_url,
        "secret": order.get("secret"),
    }


async def get_order_details(order_id: int | str) -> dict:
    """
    Sifarişin detallarını alır (status yoxlaması üçün).
    """
    base_url = _get_base_url()

    async with httpx.AsyncClient(timeout=30.0, headers=HEADERS) as client:
        response = await client.get(
            f"{base_url}/order/{order_id}?tranDetailLevel=2&tokenDetailLevel=2&orderDetailLevel=2",
            auth=_get_auth(),
        )

    if response.status_code != 200:
        logger.error(f"Kapital Bank order details failed: {response.status_code} - {response.text}")
        return {"error": True, "status_code": response.status_code, "detail": response.text}

    return response.json()


async def refund_order(order_id: int | str, amount: str | None = None) -> dict:
    """
    Ödənişi geri qaytarır (refund).
    """
    base_url = _get_base_url()

    payload = {
        "tran": {
            "phase": "Single",
            "type": "Refund",
        }
    }
    if amount:
        payload["tran"]["amount"] = str(amount)

    async with httpx.AsyncClient(timeout=30.0, headers=HEADERS) as client:
        response = await client.post(
            f"{base_url}/order/{order_id}/exec-tran",
            json=payload,
            auth=_get_auth(),
        )

    if response.status_code != 200:
        logger.error(f"Kapital Bank refund failed: {response.status_code} - {response.text}")
        return {"error": True, "status_code": response.status_code, "detail": response.text}

    return response.json()


async def reverse_order(order_id: int | str, void_kind: str = "Full", amount: str | None = None) -> dict:
    """
    Gün ərzində əməliyyatı ləğv edir (reversal).
    void_kind: "Full" və ya "Partial"
    """
    base_url = _get_base_url()

    payload = {
        "tran": {
            "phase": "Single",
            "voidKind": void_kind,
        }
    }
    if void_kind == "Partial" and amount:
        payload["tran"]["amount"] = str(amount)

    async with httpx.AsyncClient(timeout=30.0, headers=HEADERS) as client:
        response = await client.post(
            f"{base_url}/order/{order_id}/exec-tran",
            json=payload,
            auth=_get_auth(),
        )

    if response.status_code != 200:
        logger.error(f"Kapital Bank reversal failed: {response.status_code} - {response.text}")
        return {"error": True, "status_code": response.status_code, "detail": response.text}

    return response.json()
