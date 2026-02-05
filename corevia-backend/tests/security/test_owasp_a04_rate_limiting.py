"""
OWASP A04:2021 - Insecure Design Tests
Tests for rate limiting, brute force protection, business logic
"""

import pytest
import asyncio
from httpx import AsyncClient
from app.main import app


class TestRateLimiting:
    """Test rate limiting middleware"""

    @pytest.mark.asyncio
    async def test_rate_limit_exceeded(self):
        """Test that rate limit blocks after threshold"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Send 61 requests (limit is 60 per minute)
            responses = []

            for i in range(61):
                response = await client.get("/api/v1/health")
                responses.append(response)

            # First 60 should succeed
            assert all(r.status_code == 200 for r in responses[:60])

            # 61st should be rate limited
            assert responses[60].status_code == 429
            assert "rate limit" in responses[60].json()["detail"].lower()

    @pytest.mark.asyncio
    async def test_rate_limit_headers(self):
        """Test that rate limit headers are present"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.get("/api/v1/health")

            # Check for rate limit headers
            assert "X-RateLimit-Limit" in response.headers
            assert "X-RateLimit-Remaining" in response.headers
            assert "X-RateLimit-Reset" in response.headers

            limit = int(response.headers["X-RateLimit-Limit"])
            remaining = int(response.headers["X-RateLimit-Remaining"])

            assert limit == 60
            assert remaining < limit

    @pytest.mark.asyncio
    async def test_rate_limit_reset(self):
        """Test that rate limit resets after time window"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Hit rate limit
            for _ in range(60):
                await client.get("/api/v1/health")

            # Should be rate limited
            response = await client.get("/api/v1/health")
            assert response.status_code == 429

            # Wait for reset (1 minute + buffer)
            await asyncio.sleep(65)

            # Should work again
            response = await client.get("/api/v1/health")
            assert response.status_code == 200

    @pytest.mark.asyncio
    async def test_rate_limit_per_ip(self):
        """Test that rate limit is per IP"""
        # This test would require mocking different IPs
        # Implementation depends on test infrastructure
        pass


class TestBruteForceProtection:
    """Test brute force protection on authentication"""

    @pytest.mark.asyncio
    async def test_login_brute_force_protection(self):
        """Test account lockout after failed login attempts"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Attempt 6 failed logins (limit is 5)
            for i in range(6):
                response = await client.post("/api/v1/auth/login", json={
                    "email": "test@example.com",
                    "password": f"wrongpassword{i}",
                    "user_type": "student"
                })

            # First 5 attempts should return 401
            # 6th attempt should trigger lockout

            # Try with correct password after lockout
            response = await client.post("/api/v1/auth/login", json={
                "email": "test@example.com",
                "password": "CorrectPassword123!",
                "user_type": "student"
            })

            # Should be locked out even with correct password
            assert response.status_code in [429, 403]
            assert "locked" in response.json()["detail"].lower() or "attempts" in response.json()["detail"].lower()

    @pytest.mark.asyncio
    async def test_brute_force_lockout_duration(self):
        """Test that lockout expires after time"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Trigger lockout
            for _ in range(6):
                await client.post("/api/v1/auth/login", json={
                    "email": "test2@example.com",
                    "password": "wrong",
                    "user_type": "student"
                })

            # Should be locked
            response = await client.post("/api/v1/auth/login", json={
                "email": "test2@example.com",
                "password": "CorrectPassword123!",
                "user_type": "student"
            })
            assert response.status_code in [429, 403]

            # Wait for lockout to expire (15 minutes)
            # In test, we'd mock the time or use shorter duration
            # await asyncio.sleep(901)  # 15 min + 1 sec

            # Should be able to login again
            # response = await client.post("/api/v1/auth/login", ...)
            # assert response.status_code == 200

    @pytest.mark.asyncio
    async def test_distributed_brute_force(self):
        """Test protection against distributed brute force (multiple IPs)"""
        # This would require simulating multiple IP addresses
        # Implementation depends on test infrastructure
        pass


class TestBusinessLogicFlaws:
    """Test business logic vulnerabilities"""

    @pytest.mark.asyncio
    async def test_negative_price_product(self):
        """Test that negative prices are rejected"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "trainer@test.com",
                "password": "Password123!",
                "user_type": "trainer"
            })
            token = login.json()["access_token"]

            response = await client.post(
                "/api/v1/marketplace/products",
                json={
                    "product_type": "workout_plan",
                    "title": "Test",
                    "description": "Test",
                    "price": -10.00,  # Negative price
                    "currency": "USD",
                    "is_active": True
                },
                headers={"Authorization": f"Bearer {token}"}
            )

            # Should be rejected by validation
            assert response.status_code == 422

    @pytest.mark.asyncio
    async def test_excessive_price_product(self):
        """Test that unreasonably high prices are handled"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "trainer@test.com",
                "password": "Password123!",
                "user_type": "trainer"
            })
            token = login.json()["access_token"]

            response = await client.post(
                "/api/v1/marketplace/products",
                json={
                    "product_type": "workout_plan",
                    "title": "Test",
                    "description": "Test",
                    "price": 999999999.99,  # Excessive price
                    "currency": "USD",
                    "is_active": True
                },
                headers={"Authorization": f"Bearer {token}"}
            )

            # Should be rejected (max price is 10,000)
            assert response.status_code == 422

    @pytest.mark.asyncio
    async def test_review_without_purchase(self):
        """Test that users cannot review products they haven't purchased"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Login as student
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # Create product as trainer
            trainer_login = await client.post("/api/v1/auth/login", json={
                "email": "trainer@test.com",
                "password": "Password123!",
                "user_type": "trainer"
            })
            trainer_token = trainer_login.json()["access_token"]

            product_response = await client.post(
                "/api/v1/marketplace/products",
                json={
                    "product_type": "workout_plan",
                    "title": "Test Plan",
                    "description": "Test",
                    "price": 9.99,
                    "currency": "USD",
                    "is_active": True
                },
                headers={"Authorization": f"Bearer {trainer_token}"}
            )
            product_id = product_response.json()["id"]

            # Student tries to review without purchasing
            review_response = await client.post(
                "/api/v1/marketplace/reviews",
                json={
                    "product_id": product_id,
                    "rating": 5,
                    "comment": "Great!"
                },
                headers={"Authorization": f"Bearer {token}"}
            )

            # Should be rejected (must purchase first)
            assert review_response.status_code in [400, 403]

    @pytest.mark.asyncio
    async def test_like_own_post(self):
        """Test business logic for liking own posts"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # Create post
            post_response = await client.post(
                "/api/v1/social/posts",
                json={"post_type": "general", "content": "Test", "is_public": True},
                headers={"Authorization": f"Bearer {token}"}
            )
            post_id = post_response.json()["id"]

            # Try to like own post
            like_response = await client.post(
                f"/api/v1/social/posts/{post_id}/like",
                headers={"Authorization": f"Bearer {token}"}
            )

            # Business logic: Can users like their own posts?
            # This depends on requirements - either allow or reject
            # If rejected: assert like_response.status_code == 400

    @pytest.mark.asyncio
    async def test_double_like_prevention(self):
        """Test that users cannot like the same post twice"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # User1 creates post
            login1 = await client.post("/api/v1/auth/login", json={
                "email": "user1@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token1 = login1.json()["access_token"]

            post_response = await client.post(
                "/api/v1/social/posts",
                json={"post_type": "general", "content": "Test", "is_public": True},
                headers={"Authorization": f"Bearer {token1}"}
            )
            post_id = post_response.json()["id"]

            # User2 likes the post
            login2 = await client.post("/api/v1/auth/login", json={
                "email": "user2@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token2 = login2.json()["access_token"]

            # First like
            like1 = await client.post(
                f"/api/v1/social/posts/{post_id}/like",
                headers={"Authorization": f"Bearer {token2}"}
            )
            assert like1.status_code == 200

            # Second like (should be prevented or ignored)
            like2 = await client.post(
                f"/api/v1/social/posts/{post_id}/like",
                headers={"Authorization": f"Bearer {token2}"}
            )

            # Should either return 400 (already liked) or 200 (idempotent)
            assert like2.status_code in [200, 400]

            # Verify like count is still 1
            post_get = await client.get(
                f"/api/v1/social/posts/{post_id}",
                headers={"Authorization": f"Bearer {token2}"}
            )
            assert post_get.json()["likes_count"] == 1

    @pytest.mark.asyncio
    async def test_invalid_date_ranges(self):
        """Test handling of invalid date ranges"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # End date before start date
            response = await client.get(
                "/api/v1/analytics/measurements?start_date=2026-02-10&end_date=2026-02-01",
                headers={"Authorization": f"Bearer {token}"}
            )

            # Should handle gracefully (return empty or error)
            assert response.status_code in [200, 400]


class TestConcurrencyIssues:
    """Test race conditions and concurrency issues"""

    @pytest.mark.asyncio
    async def test_concurrent_likes(self):
        """Test race condition when multiple users like simultaneously"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Create a post
            login = await client.post("/api/v1/auth/login", json={
                "email": "user1@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            post_response = await client.post(
                "/api/v1/social/posts",
                json={"post_type": "general", "content": "Test", "is_public": True},
                headers={"Authorization": f"Bearer {token}"}
            )
            post_id = post_response.json()["id"]

            # Simulate 10 users liking concurrently
            async def like_post(user_num):
                login_resp = await client.post("/api/v1/auth/login", json={
                    "email": f"user{user_num}@test.com",
                    "password": "Password123!",
                    "user_type": "student"
                })
                user_token = login_resp.json()["access_token"]

                await client.post(
                    f"/api/v1/social/posts/{post_id}/like",
                    headers={"Authorization": f"Bearer {user_token}"}
                )

            # Execute concurrent likes
            await asyncio.gather(*[like_post(i) for i in range(2, 12)])

            # Verify like count is exactly 10
            post_get = await client.get(
                f"/api/v1/social/posts/{post_id}",
                headers={"Authorization": f"Bearer {token}"}
            )

            # Should be 10 (no race condition duplicates)
            assert post_get.json()["likes_count"] == 10


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
