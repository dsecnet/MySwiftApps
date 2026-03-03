import logging
from datetime import datetime, timedelta, timezone

import httpx

from app.config import get_settings
from app.utils.security import generate_otp

settings = get_settings()
logger = logging.getLogger(__name__)

# In-memory OTP store. In production, use Redis.
_otp_store: dict[str, dict] = {}
_rate_limit_store: dict[str, list[datetime]] = {}


class SMSService:
    """Service for sending SMS messages and managing OTP codes."""

    @staticmethod
    async def send_otp(phone: str) -> dict:
        """
        Generate and send an OTP to the given phone number.
        Returns dict with success status and message.
        """
        # Rate limiting check
        now = datetime.now(timezone.utc)
        if phone in _rate_limit_store:
            # Remove expired entries
            _rate_limit_store[phone] = [
                ts
                for ts in _rate_limit_store[phone]
                if now - ts < timedelta(minutes=settings.OTP_RATE_LIMIT_MINUTES)
            ]
            if len(_rate_limit_store[phone]) >= settings.OTP_MAX_ATTEMPTS:
                return {
                    "success": False,
                    "message": "Too many OTP requests. Please try again later.",
                }

        # Generate OTP
        otp_code = generate_otp(settings.OTP_LENGTH)

        # Store OTP
        _otp_store[phone] = {
            "code": otp_code,
            "created_at": now,
            "expires_at": now + timedelta(minutes=settings.OTP_EXPIRE_MINUTES),
            "attempts": 0,
        }

        # Record rate limit
        if phone not in _rate_limit_store:
            _rate_limit_store[phone] = []
        _rate_limit_store[phone].append(now)

        # Send SMS via provider
        sent = await SMSService._send_sms(
            phone=phone,
            message=f"Menzilim: Sizin dogrulama kodunuz: {otp_code}",
        )

        if not sent:
            logger.warning(f"Failed to send SMS to {phone}, OTP: {otp_code}")
            # In development, still return success so we can test with stored OTP
            return {
                "success": True,
                "message": "OTP sent (dev mode - check logs)",
                "code": otp_code,  # Remove this in production
            }

        return {
            "success": True,
            "message": "OTP sent successfully",
        }

    @staticmethod
    def verify_otp(phone: str, code: str) -> bool:
        """Verify an OTP code for the given phone number."""
        if phone not in _otp_store:
            return False

        otp_data = _otp_store[phone]
        now = datetime.now(timezone.utc)

        # Check expiration
        if now > otp_data["expires_at"]:
            del _otp_store[phone]
            return False

        # Check max attempts
        if otp_data["attempts"] >= 5:
            del _otp_store[phone]
            return False

        # Increment attempts
        otp_data["attempts"] += 1

        # Verify code
        if otp_data["code"] != code:
            return False

        # OTP is valid, remove it
        del _otp_store[phone]
        return True

    @staticmethod
    async def _send_sms(phone: str, message: str) -> bool:
        """Send SMS via the configured provider. Returns True if sent."""
        if not settings.SMS_API_KEY or not settings.SMS_API_URL:
            logger.info(f"SMS (mock): to={phone}, message={message}")
            return False

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.post(
                    settings.SMS_API_URL,
                    json={
                        "api_key": settings.SMS_API_KEY,
                        "to": phone,
                        "from": settings.SMS_SENDER,
                        "message": message,
                    },
                )
                response.raise_for_status()
                logger.info(f"SMS sent to {phone}")
                return True
        except Exception as e:
            logger.error(f"Failed to send SMS to {phone}: {e}")
            return False


sms_service = SMSService()
