import random
import logging
from datetime import datetime, timedelta
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import Dict
import aiosmtplib
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, func
from app.models.otp import OTPCode
from app.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()


class EmailOTPService:
    """Email OTP servisi - Gmail SMTP ilə OTP göndərir"""

    def __init__(self):
        self.mock_mode = settings.email_otp_mock
        self.smtp_host = settings.smtp_host
        self.smtp_port = settings.smtp_port
        self.smtp_username = settings.smtp_username
        self.smtp_password = settings.smtp_password
        self.from_email = settings.smtp_from_email or settings.smtp_username
        self.from_name = settings.smtp_from_name

        logger.info(f"EmailOTPService initialized (mock_mode={self.mock_mode})")

    def generate_otp_code(self) -> str:
        """6 rəqəmli OTP kod yaradır"""
        return str(random.randint(100000, 999999))

    async def send_otp(
        self, email: str, purpose: str, db: AsyncSession
    ) -> Dict[str, any]:
        """
        Email-ə OTP göndərir

        Args:
            email: İstifadəçi email-i
            purpose: 'forgot_password' və ya 'email_verification'
            db: Database session

        Returns:
            Dict with success, message, code (yalnız mock mode-da)
        """
        # Rate limiting: son 5 dəqiqədə neçə dəfə request göndərilib?
        five_minutes_ago = datetime.now() - timedelta(minutes=5)
        stmt = select(func.count()).select_from(OTPCode).where(
            and_(
                OTPCode.email == email,
                OTPCode.purpose == purpose,
                OTPCode.created_at >= five_minutes_ago,
            )
        )
        result = await db.execute(stmt)
        request_count = result.scalar()

        if request_count >= 3:
            return {
                "success": False,
                "message": "Çox tez-tez cəhd. 5 dəqiqə gözləyin.",
            }

        # OTP kod yaradırıq
        code = self.generate_otp_code()

        # Expire time: 10 dəqiqə
        expires_at = datetime.now() + timedelta(minutes=10)

        # DB-yə yazırıq
        otp_record = OTPCode(
            email=email, code=code, purpose=purpose, expires_at=expires_at
        )
        db.add(otp_record)
        await db.commit()

        # Email göndəririk (və ya mock mode-da console-a yazırıq)
        if self.mock_mode:
            logger.info(f"[MOCK MODE] OTP kod {email} üçün: {code} (purpose: {purpose})")
            return {"success": True, "message": "OTP göndərildi (mock mode)", "code": code}
        else:
            try:
                await self._send_email(
                    to_email=email,
                    subject="CoreVia - Şifrə Bərpası OTP",
                    otp_code=code,
                )
                logger.info(f"OTP email göndərildi: {email}")
                return {
                    "success": True,
                    "message": "OTP kodunuz email-ə göndərildi. 10 dəqiqə etibarlıdır.",
                }
            except Exception as e:
                logger.error(f"Email göndərilmədi: {str(e)}")
                return {"success": False, "message": "Email göndərilə bilmədi. Yenidən cəhd edin."}

    async def verify_otp(
        self, email: str, code: str, purpose: str, db: AsyncSession
    ) -> Dict[str, any]:
        """
        OTP kodunu yoxlayır

        Args:
            email: İstifadəçi email-i
            code: OTP kod
            purpose: 'forgot_password' və ya 'email_verification'
            db: Database session

        Returns:
            Dict with success, message
        """
        # OTP tap
        stmt = (
            select(OTPCode)
            .where(
                and_(
                    OTPCode.email == email,
                    OTPCode.code == code,
                    OTPCode.purpose == purpose,
                    OTPCode.is_used == False,
                    OTPCode.expires_at > datetime.now(),
                )
            )
            .order_by(OTPCode.created_at.desc())
        )
        result = await db.execute(stmt)
        otp_record = result.scalar_one_or_none()

        if not otp_record:
            # Ola bilsin ki kod vaxtı keçib və ya yanlışdır
            # Attempt sayını artıraq
            stmt_expired = (
                select(OTPCode)
                .where(
                    and_(
                        OTPCode.email == email,
                        OTPCode.code == code,
                        OTPCode.purpose == purpose,
                        OTPCode.is_used == False,
                    )
                )
                .order_by(OTPCode.created_at.desc())
            )
            result_expired = await db.execute(stmt_expired)
            expired_record = result_expired.scalar_one_or_none()

            if expired_record:
                expired_record.attempts += 1
                await db.commit()

                if expired_record.expires_at < datetime.now():
                    return {"success": False, "message": "OTP kodunun vaxtı keçib. Yenisini istəyin."}
                elif expired_record.attempts >= 5:
                    return {"success": False, "message": "Çox səhv cəhd. Yeni OTP istəyin."}

            return {"success": False, "message": "Yanlış OTP kod."}

        # Attempt sayını artır
        otp_record.attempts += 1

        # Max 5 cəhd
        if otp_record.attempts > 5:
            await db.commit()
            return {"success": False, "message": "Çox səhv cəhd. Yeni OTP istəyin."}

        # OTP-ni işarələ (used)
        otp_record.is_used = True
        await db.commit()

        logger.info(f"OTP təsdiqləndi: {email}")
        return {"success": True, "message": "OTP təsdiqləndi"}

    async def _send_email(self, to_email: str, subject: str, otp_code: str):
        """
        Gmail SMTP ilə email göndərir

        Args:
            to_email: Alıcı email
            subject: Email mövzusu
            otp_code: OTP kod
        """
        # Email mesajı hazırla (HTML + Plain Text)
        message = MIMEMultipart("alternative")
        message["Subject"] = subject
        message["From"] = f"{self.from_name} <{self.from_email}>"
        message["To"] = to_email

        # Plain text version
        text_body = f"""CoreVia Şifrə Bərpası

Hörmətli istifadəçi,

Şifrənizi bərpa etmək üçün aşağıdakı təsdiq kodunu istifadə edin:

    █ {otp_code} █

Bu kod 10 dəqiqə ərzində etibarlıdır.

⚠️ Bu kodu heç kimlə paylaşmayın! CoreVia əməkdaşları heç vaxt sizdən kod istəməz.

Bu sorğunu siz göndərməmisinizsə, bu mesajı nəzərə almayın.

Hörmətlə,
CoreVia Komandası
"""

        # HTML version
        html_body = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
             line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">

    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
        <h1 style="color: white; margin: 0; font-size: 24px; font-weight: 600;">CoreVia</h1>
    </div>

    <div style="background: #ffffff; padding: 40px 30px; border: 1px solid #e0e0e0;
                border-top: none; border-radius: 0 0 10px 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">

        <h2 style="color: #333; margin-top: 0; margin-bottom: 20px; font-size: 20px;">Şifrə Bərpası</h2>

        <p style="color: #666; margin-bottom: 25px;">Hörmətli istifadəçi,</p>

        <p style="color: #666; margin-bottom: 25px;">
            Şifrənizi bərpa etmək üçün aşağıdakı təsdiq kodunu istifadə edin:
        </p>

        <div style="background: #f7f7f7; border: 2px dashed #667eea;
                    padding: 25px; text-align: center; margin: 30px 0; border-radius: 8px;">
            <div style="font-size: 36px; font-weight: bold; letter-spacing: 10px;
                       color: #667eea; font-family: 'Courier New', monospace;">
                {otp_code}
            </div>
        </div>

        <p style="color: #666; font-size: 14px; margin: 25px 0;">
            ⏱️ Bu kod <strong>10 dəqiqə</strong> ərzində etibarlıdır.
        </p>

        <div style="background: #fff3cd; border-left: 4px solid #ffc107;
                    padding: 15px; margin: 25px 0; border-radius: 4px;">
            <p style="margin: 0; color: #856404; font-size: 14px;">
                ⚠️ <strong>Diqqət:</strong> Bu kodu heç kimlə paylaşmayın! CoreVia əməkdaşları heç vaxt sizdən
                kod istəməz.
            </p>
        </div>

        <p style="color: #999; font-size: 13px; margin-top: 35px;
                  padding-top: 25px; border-top: 1px solid #eee;">
            Bu sorğunu siz göndərməmisinizsə, bu mesajı nəzərə almayın.
        </p>

        <p style="color: #667eea; font-weight: 500; margin-bottom: 0; margin-top: 20px;">
            Hörmətlə,<br>
            CoreVia Komandası
        </p>
    </div>

    <div style="text-align: center; margin-top: 20px; padding: 15px;">
        <p style="color: #999; font-size: 12px; margin: 0;">
            © 2026 CoreVia. Bütün hüquqlar qorunur.
        </p>
    </div>

</body>
</html>"""

        # MIME parts
        part1 = MIMEText(text_body, "plain", "utf-8")
        part2 = MIMEText(html_body, "html", "utf-8")
        message.attach(part1)
        message.attach(part2)

        # SMTP ilə göndər
        try:
            await aiosmtplib.send(
                message,
                hostname=self.smtp_host,
                port=self.smtp_port,
                username=self.smtp_username,
                password=self.smtp_password,
                start_tls=True,
                timeout=30,
            )
            logger.info(f"Email uğurla göndərildi: {to_email}")
        except Exception as e:
            logger.error(f"SMTP xətası: {str(e)}")
            raise


# Singleton instance
email_service = EmailOTPService()
