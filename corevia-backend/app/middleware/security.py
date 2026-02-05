"""
Security Middleware - OWASP Top 10 2021 Compliant

A05:2021 – Security Misconfiguration
A09:2021 – Security Logging and Monitoring Failures
A10:2021 – Server-Side Request Forgery (SSRF)
"""

import time
import logging
from collections import defaultdict
from datetime import datetime, timedelta
from fastapi import Request, HTTPException, status
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response

logger = logging.getLogger(__name__)


# ============================================================
# A05:2021 - Security Headers Middleware
# ============================================================

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Add security headers to all responses"""

    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)

        # OWASP A05:2021 - Security Headers
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        response.headers["Content-Security-Policy"] = "default-src 'self'"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        response.headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()"

        # Remove server version disclosure - OWASP A05:2021
        response.headers.pop("Server", None)

        return response


# ============================================================
# A04:2021 - Rate Limiting (DDoS Protection)
# ============================================================

class RateLimitMiddleware(BaseHTTPMiddleware):
    """
    Rate limiting to prevent abuse
    OWASP A04:2021 - Insecure Design
    """

    def __init__(self, app, requests_per_minute: int = 60):
        super().__init__(app)
        self.requests_per_minute = requests_per_minute
        self.requests: dict[str, list[float]] = defaultdict(list)

    def _get_client_ip(self, request: Request) -> str:
        """Get client IP (supports proxy headers)"""
        # Check X-Forwarded-For first (proxy)
        forwarded_for = request.headers.get("X-Forwarded-For")
        if forwarded_for:
            # Take first IP (client)
            return forwarded_for.split(",")[0].strip()

        # Fallback to direct connection
        return request.client.host if request.client else "unknown"

    async def dispatch(self, request: Request, call_next):
        client_ip = self._get_client_ip(request)
        current_time = time.time()

        # Clean old requests (older than 1 minute)
        cutoff_time = current_time - 60
        self.requests[client_ip] = [
            req_time for req_time in self.requests[client_ip]
            if req_time > cutoff_time
        ]

        # Check rate limit
        if len(self.requests[client_ip]) >= self.requests_per_minute:
            logger.warning(
                f"Rate limit exceeded for IP: {client_ip} "
                f"({len(self.requests[client_ip])} requests/min)"
            )
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Çoxlu sorğu göndərildi. Bir az gözləyin.",
            )

        # Add current request
        self.requests[client_ip].append(current_time)

        response = await call_next(request)

        # Add rate limit headers
        response.headers["X-RateLimit-Limit"] = str(self.requests_per_minute)
        response.headers["X-RateLimit-Remaining"] = str(
            self.requests_per_minute - len(self.requests[client_ip])
        )

        return response


# ============================================================
# A09:2021 - Request Logging Middleware
# ============================================================

class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """
    Log all requests for security monitoring
    OWASP A09:2021 - Security Logging and Monitoring Failures
    """

    async def dispatch(self, request: Request, call_next):
        start_time = time.time()

        # Log request
        logger.info(
            f"Request: {request.method} {request.url.path} "
            f"from {request.client.host if request.client else 'unknown'}"
        )

        try:
            response = await call_next(request)

            # Log response time
            process_time = time.time() - start_time
            response.headers["X-Process-Time"] = str(process_time)

            logger.info(
                f"Response: {request.method} {request.url.path} "
                f"status={response.status_code} time={process_time:.3f}s"
            )

            return response

        except Exception as e:
            # Log errors
            logger.error(
                f"Error: {request.method} {request.url.path} "
                f"error={str(e)}"
            )
            raise


# ============================================================
# A03:2021 - SQL Injection Protection (Content Validation)
# ============================================================

class InputSanitizationMiddleware(BaseHTTPMiddleware):
    """
    Basic input validation to detect common injection patterns
    OWASP A03:2021 - Injection
    Note: This is defense-in-depth; main defense is parameterized queries
    """

    SUSPICIOUS_PATTERNS = [
        "'; DROP TABLE",
        "' OR '1'='1",
        "<script>",
        "javascript:",
        "onload=",
        "onerror=",
        "../",  # Path traversal
        "etc/passwd",
    ]

    async def dispatch(self, request: Request, call_next):
        # Check URL path
        url_path = str(request.url.path).lower()
        for pattern in self.SUSPICIOUS_PATTERNS:
            if pattern.lower() in url_path:
                logger.warning(
                    f"Suspicious pattern detected in URL: {pattern} "
                    f"from IP: {request.client.host if request.client else 'unknown'}"
                )
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Etibarsız sorğu"
                )

        # Check query parameters
        for key, value in request.query_params.items():
            value_lower = str(value).lower()
            for pattern in self.SUSPICIOUS_PATTERNS:
                if pattern.lower() in value_lower:
                    logger.warning(
                        f"Suspicious pattern detected in query param '{key}': {pattern} "
                        f"from IP: {request.client.host if request.client else 'unknown'}"
                    )
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="Etibarsız sorğu parametri"
                    )

        return await call_next(request)


# ============================================================
# HELPER: Detect Brute Force Attacks
# ============================================================

class BruteForceProtection:
    """
    Track failed login attempts - OWASP A07:2021
    Usage in auth.py login endpoint
    """

    def __init__(self, max_attempts: int = 5, lockout_minutes: int = 15):
        self.max_attempts = max_attempts
        self.lockout_minutes = lockout_minutes
        self.failed_attempts: dict[str, list[datetime]] = defaultdict(list)
        self.locked_accounts: dict[str, datetime] = {}

    def is_locked(self, identifier: str) -> bool:
        """Check if account/IP is locked"""
        if identifier in self.locked_accounts:
            lockout_until = self.locked_accounts[identifier]
            if datetime.utcnow() < lockout_until:
                return True
            else:
                # Lockout expired
                del self.locked_accounts[identifier]
                del self.failed_attempts[identifier]
        return False

    def record_failed_attempt(self, identifier: str):
        """Record failed login attempt"""
        now = datetime.utcnow()

        # Clean old attempts (older than lockout period)
        cutoff = now - timedelta(minutes=self.lockout_minutes)
        self.failed_attempts[identifier] = [
            attempt_time for attempt_time in self.failed_attempts[identifier]
            if attempt_time > cutoff
        ]

        # Add current attempt
        self.failed_attempts[identifier].append(now)

        # Check if should lock
        if len(self.failed_attempts[identifier]) >= self.max_attempts:
            lockout_until = now + timedelta(minutes=self.lockout_minutes)
            self.locked_accounts[identifier] = lockout_until
            logger.warning(
                f"Account/IP locked due to {self.max_attempts} failed attempts: {identifier}"
            )

    def record_successful_login(self, identifier: str):
        """Clear failed attempts on successful login"""
        if identifier in self.failed_attempts:
            del self.failed_attempts[identifier]
        if identifier in self.locked_accounts:
            del self.locked_accounts[identifier]


# Global brute force protection instance
brute_force_protection = BruteForceProtection(max_attempts=5, lockout_minutes=15)
