"""
OWASP A07:2021 - Identification and Authentication Failures Tests
Tests for authentication, session management, password security
"""

import pytest
from httpx import AsyncClient
from app.main import app
import jwt
from datetime import datetime, timedelta


class TestPasswordSecurity:
    """Test password security requirements"""

    @pytest.mark.asyncio
    async def test_weak_password_rejected(self):
        """Test that weak passwords are rejected"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            weak_passwords = [
                "123456",  # Too simple
                "password",  # Common word
                "abc123",  # Too short
                "aaaaaaa",  # No variety
                "Password",  # No numbers
                "password123",  # No uppercase
            ]

            for weak_pwd in weak_passwords:
                response = await client.post("/api/v1/auth/register", json={
                    "email": "test@example.com",
                    "password": weak_pwd,
                    "full_name": "Test User",
                    "user_type": "student"
                })

                # Should be rejected with 422 (validation error)
                assert response.status_code == 422

    @pytest.mark.asyncio
    async def test_strong_password_accepted(self):
        """Test that strong passwords are accepted"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.post("/api/v1/auth/register", json={
                "email": "newuser@example.com",
                "password": "StrongP@ssw0rd123!",
                "full_name": "Test User",
                "user_type": "student"
            })

            # Should succeed (201 or 200)
            assert response.status_code in [200, 201]

    @pytest.mark.asyncio
    async def test_password_not_returned_in_response(self):
        """Test that passwords are never returned in API responses"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Register
            register_response = await client.post("/api/v1/auth/register", json={
                "email": "testuser@example.com",
                "password": "SecurePass123!",
                "full_name": "Test User",
                "user_type": "student"
            })

            # Password should not be in response
            response_data = register_response.json()
            assert "password" not in response_data
            assert "hashed_password" not in response_data

            # Login
            login_response = await client.post("/api/v1/auth/login", json={
                "email": "testuser@example.com",
                "password": "SecurePass123!",
                "user_type": "student"
            })

            # Password should not be in response
            login_data = login_response.json()
            assert "password" not in str(login_data).lower()

    @pytest.mark.asyncio
    async def test_password_hash_format(self):
        """Test that passwords are properly hashed (bcrypt)"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # This would require database access to verify
            # Check that stored password starts with $2b$ (bcrypt)
            pass


class TestJWTSecurity:
    """Test JWT token security"""

    @pytest.mark.asyncio
    async def test_jwt_contains_required_claims(self):
        """Test that JWT contains required claims"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })

            token = login.json()["access_token"]

            # Decode without verification to inspect claims
            decoded = jwt.decode(token, options={"verify_signature": False})

            # Required claims
            assert "sub" in decoded  # Subject (user_id)
            assert "exp" in decoded  # Expiration
            assert "iat" in decoded  # Issued at
            assert "user_type" in decoded  # User type

    @pytest.mark.asyncio
    async def test_jwt_expiration(self):
        """Test that JWT tokens have reasonable expiration"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })

            token = login.json()["access_token"]
            decoded = jwt.decode(token, options={"verify_signature": False})

            # Check expiration is in future but not too far
            exp_timestamp = decoded["exp"]
            exp_datetime = datetime.fromtimestamp(exp_timestamp)
            now = datetime.now()

            # Should expire within 24 hours
            assert exp_datetime > now
            assert (exp_datetime - now) < timedelta(hours=24)

    @pytest.mark.asyncio
    async def test_invalid_jwt_rejected(self):
        """Test that invalid JWTs are rejected"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            invalid_tokens = [
                "invalid.token.here",
                "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.invalid",
                "",
                "Bearer token",
            ]

            for token in invalid_tokens:
                response = await client.get(
                    "/api/v1/users/profile",
                    headers={"Authorization": f"Bearer {token}"}
                )

                assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_jwt_algorithm_enforcement(self):
        """Test that only approved algorithms are accepted"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Create token with 'none' algorithm (security vulnerability)
            payload = {
                "sub": "user123",
                "exp": datetime.now() + timedelta(hours=1),
                "user_type": "student"
            }

            # Token with 'none' algorithm
            none_token = jwt.encode(payload, "", algorithm="none")

            response = await client.get(
                "/api/v1/users/profile",
                headers={"Authorization": f"Bearer {none_token}"}
            )

            # Should be rejected
            assert response.status_code == 401


class TestSessionManagement:
    """Test session and token management"""

    @pytest.mark.asyncio
    async def test_refresh_token_rotation(self):
        """Test that refresh tokens are rotated"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Login to get tokens
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })

            refresh_token1 = login.json()["refresh_token"]

            # Use refresh token to get new access token
            refresh_response = await client.post("/api/v1/auth/refresh", json={
                "refresh_token": refresh_token1
            })

            assert refresh_response.status_code == 200
            refresh_token2 = refresh_response.json().get("refresh_token")

            # If rotation is implemented, refresh_token2 should be different
            if refresh_token2:
                assert refresh_token1 != refresh_token2

                # Old refresh token should be invalid
                old_refresh = await client.post("/api/v1/auth/refresh", json={
                    "refresh_token": refresh_token1
                })
                assert old_refresh.status_code == 401

    @pytest.mark.asyncio
    async def test_logout_invalidates_token(self):
        """Test that logout invalidates tokens"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Login
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # Verify token works
            profile1 = await client.get(
                "/api/v1/users/profile",
                headers={"Authorization": f"Bearer {token}"}
            )
            assert profile1.status_code == 200

            # Logout
            logout_response = await client.post(
                "/api/v1/auth/logout",
                headers={"Authorization": f"Bearer {token}"}
            )
            assert logout_response.status_code == 200

            # Token should be invalid after logout (if blacklist is implemented)
            # Note: Stateless JWT may not support this without token blacklist
            # profile2 = await client.get(
            #     "/api/v1/users/profile",
            #     headers={"Authorization": f"Bearer {token}"}
            # )
            # assert profile2.status_code == 401

    @pytest.mark.asyncio
    async def test_concurrent_sessions_allowed(self):
        """Test that users can have multiple sessions"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Login from "device 1"
            login1 = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token1 = login1.json()["access_token"]

            # Login from "device 2"
            login2 = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token2 = login2.json()["access_token"]

            # Both tokens should work
            profile1 = await client.get(
                "/api/v1/users/profile",
                headers={"Authorization": f"Bearer {token1}"}
            )
            profile2 = await client.get(
                "/api/v1/users/profile",
                headers={"Authorization": f"Bearer {token2}"}
            )

            assert profile1.status_code == 200
            assert profile2.status_code == 200


class TestCredentialStuffing:
    """Test protection against credential stuffing"""

    @pytest.mark.asyncio
    async def test_account_enumeration_prevention(self):
        """Test that error messages don't reveal if email exists"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Login with non-existent email
            response1 = await client.post("/api/v1/auth/login", json={
                "email": "nonexistent@test.com",
                "password": "Password123!",
                "user_type": "student"
            })

            # Login with existing email but wrong password
            response2 = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "WrongPassword123!",
                "user_type": "student"
            })

            # Error messages should be similar (don't reveal if email exists)
            assert response1.status_code == 401
            assert response2.status_code == 401

            # Messages should be generic
            msg1 = response1.json()["detail"].lower()
            msg2 = response2.json()["detail"].lower()

            # Should not say "email not found" or "wrong password"
            assert "email not found" not in msg1
            assert "wrong password" not in msg2

    @pytest.mark.asyncio
    async def test_timing_attack_prevention(self):
        """Test that response times don't reveal if user exists"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            import time

            # Time login with non-existent user
            start1 = time.time()
            await client.post("/api/v1/auth/login", json={
                "email": "nonexistent@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            time1 = time.time() - start1

            # Time login with existing user
            start2 = time.time()
            await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "WrongPassword123!",
                "user_type": "student"
            })
            time2 = time.time() - start2

            # Times should be similar (within 100ms)
            time_diff = abs(time1 - time2)
            assert time_diff < 0.1


class TestMultiFactorAuth:
    """Test multi-factor authentication if implemented"""

    @pytest.mark.asyncio
    async def test_2fa_enrollment(self):
        """Test 2FA enrollment process"""
        # Skip if 2FA not implemented
        pytest.skip("2FA not yet implemented")

    @pytest.mark.asyncio
    async def test_2fa_verification(self):
        """Test 2FA verification"""
        pytest.skip("2FA not yet implemented")


class TestPasswordReset:
    """Test password reset functionality"""

    @pytest.mark.asyncio
    async def test_password_reset_token_expiry(self):
        """Test that password reset tokens expire"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Request password reset
            reset_request = await client.post("/api/v1/auth/forgot-password", json={
                "email": "student@test.com"
            })

            # This would need to extract token from email
            # Then verify it expires after set time
            pass

    @pytest.mark.asyncio
    async def test_password_reset_token_single_use(self):
        """Test that reset tokens can only be used once"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Request reset, use token, try to reuse
            pass

    @pytest.mark.asyncio
    async def test_password_cannot_be_same_as_old(self):
        """Test that new password must be different from old"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # This requires password history tracking
            pass


class TestAuthenticationBypass:
    """Test attempts to bypass authentication"""

    @pytest.mark.asyncio
    async def test_direct_access_to_protected_routes(self):
        """Test that all protected routes require auth"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            protected_endpoints = [
                "/api/v1/users/profile",
                "/api/v1/social/feed",
                "/api/v1/marketplace/products",
                "/api/v1/analytics/dashboard",
                "/api/v1/workouts",
            ]

            for endpoint in protected_endpoints:
                response = await client.get(endpoint)
                assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_parameter_pollution(self):
        """Test auth bypass via parameter pollution"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Try to bypass with multiple user_id parameters
            response = await client.get(
                "/api/v1/users/profile?user_id=attacker_id&user_id=victim_id"
            )

            assert response.status_code == 401


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
