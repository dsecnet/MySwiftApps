"""
WhatsApp OTP Service
Twilio WhatsApp Business API istifadə edərək OTP göndərir
"""

import random
import logging
import os
from datetime import datetime, timedelta
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from app.models.otp import OTPCode
from app.models.user import User

logger = logging.getLogger(__name__)


class WhatsAppOTPService:
    def __init__(self):
        # Mock mode (.env-dən oxu)
        self.mock_mode = os.getenv('WHATSAPP_OTP_MOCK', 'true').lower() == 'true'

        # Twilio credentials
        self.account_sid = os.getenv('TWILIO_ACCOUNT_SID')
        self.auth_token = os.getenv('TWILIO_AUTH_TOKEN')
        self.whatsapp_from = os.getenv('TWILIO_WHATSAPP_FROM', 'whatsapp:+14155238886')

    def generate_otp_code(self) -> str:
        """6 rəqəmli OTP kod yaradır"""
        return str(random.randint(100000, 999999))

    async def send_otp(
        self,
        phone_number: str,
        purpose: str,
        db: AsyncSession
    ) -> dict:
        """
        WhatsApp ilə OTP göndərir

        Args:
            phone_number: +994XXXXXXXXX formatında
            purpose: 'forgot_password' və ya 'phone_verification'
            db: Database session

        Returns:
            dict: {'success': bool, 'message': str, 'code': str (mock mode only)}
        """

        # Rate limiting - son 5 dəqiqədə 3-dən çox request
        recent_otps = await db.execute(
            select(OTPCode).where(
                and_(
                    OTPCode.phone_number == phone_number,
                    OTPCode.created_at >= datetime.utcnow() - timedelta(minutes=5)
                )
            )
        )
        if len(recent_otps.scalars().all()) >= 3:
            return {
                'success': False,
                'message': 'Çox tez-tez cəhd. 5 dəqiqə gözləyin.'
            }

        # Generate OTP
        otp_code = self.generate_otp_code()
        expires_at = datetime.utcnow() + timedelta(minutes=10)

        # Save to database
        otp_record = OTPCode(
            phone_number=phone_number,
            code=otp_code,
            purpose=purpose,
            expires_at=expires_at,
            is_used=False,
            attempts=0
        )
        db.add(otp_record)
        await db.commit()

        # Send via WhatsApp
        if self.mock_mode:
            # Mock mode - log OTP code
            logger.info(f"🔐 OTP Code for {phone_number}: {otp_code} (expires in 10 min)")
            return {
                'success': True,
                'message': 'OTP göndərildi (test mode)',
                'code': otp_code  # Only in mock mode!
            }
        else:
            # Real Twilio WhatsApp integration
            try:
                from twilio.rest import Client

                if not self.account_sid or not self.auth_token:
                    logger.error("Twilio credentials not configured")
                    return {
                        'success': False,
                        'message': 'WhatsApp konfiqurasiyası düzgün deyil'
                    }

                client = Client(self.account_sid, self.auth_token)
                message = client.messages.create(
                    body=f"CoreVia təsdiq kodu: {otp_code}\n\nEtibarlılıq: 10 dəqiqə\n\nBu kodu heç kimlə paylaşmayın!",
                    from_=self.whatsapp_from,
                    to=f'whatsapp:{phone_number}'
                )

                logger.info(f"WhatsApp OTP sent to {phone_number}, SID: {message.sid}")

                return {
                    'success': True,
                    'message': 'OTP WhatsApp ilə göndərildi'
                }
            except Exception as e:
                logger.error(f"WhatsApp OTP error: {str(e)}")
                return {
                    'success': False,
                    'message': f'OTP göndərilərkən xəta: {str(e)}'
                }

    async def verify_otp(
        self,
        phone_number: str,
        code: str,
        purpose: str,
        db: AsyncSession
    ) -> dict:
        """
        OTP kodunu yoxlayır

        Returns:
            dict: {'success': bool, 'message': str}
        """

        # Find valid OTP
        result = await db.execute(
            select(OTPCode).where(
                and_(
                    OTPCode.phone_number == phone_number,
                    OTPCode.code == code,
                    OTPCode.purpose == purpose,
                    OTPCode.is_used == False,
                    OTPCode.expires_at > datetime.utcnow()
                )
            )
        )
        otp_record = result.scalar_one_or_none()

        if not otp_record:
            # Check if expired
            expired_result = await db.execute(
                select(OTPCode).where(
                    and_(
                        OTPCode.phone_number == phone_number,
                        OTPCode.code == code,
                        OTPCode.is_used == False
                    )
                )
            )
            expired_otp = expired_result.scalar_one_or_none()

            if expired_otp and expired_otp.expires_at <= datetime.utcnow():
                return {
                    'success': False,
                    'message': 'OTP kodunun vaxtı keçib'
                }

            return {
                'success': False,
                'message': 'Yanlış OTP kodu'
            }

        # Increment attempts
        otp_record.attempts += 1

        if otp_record.attempts > 5:
            return {
                'success': False,
                'message': 'Çox sayda yanlış cəhd'
            }

        # Mark as used
        otp_record.is_used = True
        await db.commit()

        return {
            'success': True,
            'message': 'OTP təsdiqləndi'
        }


# Singleton instance
whatsapp_service = WhatsAppOTPService()
