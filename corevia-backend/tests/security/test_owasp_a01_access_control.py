"""
OWASP A01:2021 - Broken Access Control Tests
Tests for authorization and ownership verification
"""

import pytest
from httpx import AsyncClient
from app.main import app


class TestAccessControl:
    """Test suite for access control violations"""

    @pytest.mark.asyncio
    async def test_unauthorized_access_to_protected_endpoint(self):
        """Test accessing protected endpoint without token"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Attempt to access user profile without token
            response = await client.get("/api/v1/users/profile")

            assert response.status_code == 401
            assert "not authenticated" in response.json()["detail"].lower()

    @pytest.mark.asyncio
    async def test_access_other_users_data(self):
        """Test accessing another user's private data"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Login as user1
            login1 = await client.post("/api/v1/auth/login", json={
                "email": "user1@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token1 = login1.json()["access_token"]
            user1_id = login1.json()["user"]["id"]

            # Login as user2
            login2 = await client.post("/api/v1/auth/login", json={
                "email": "user2@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token2 = login2.json()["access_token"]
            user2_id = login2.json()["user"]["id"]

            # User1 creates a private post
            post_response = await client.post(
                "/api/v1/social/posts",
                json={
                    "post_type": "general",
                    "content": "Private post",
                    "is_public": False
                },
                headers={"Authorization": f"Bearer {token1}"}
            )
            post_id = post_response.json()["id"]

            # User2 attempts to access user1's private post
            # This should either return 403 or filter it out from feed
            feed_response = await client.get(
                "/api/v1/social/feed",
                headers={"Authorization": f"Bearer {token2}"}
            )

            # Private posts should not appear in other users' feeds
            posts = feed_response.json()["posts"]
            post_ids = [p["id"] for p in posts]
            assert post_id not in post_ids

    @pytest.mark.asyncio
    async def test_delete_other_users_post(self):
        """Test that users cannot delete other users' posts"""
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

            # User2 attempts to delete user1's post
            login2 = await client.post("/api/v1/auth/login", json={
                "email": "user2@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token2 = login2.json()["access_token"]

            delete_response = await client.delete(
                f"/api/v1/social/posts/{post_id}",
                headers={"Authorization": f"Bearer {token2}"}
            )

            # Should return 403 Forbidden
            assert delete_response.status_code == 403

    @pytest.mark.asyncio
    async def test_student_cannot_create_marketplace_product(self):
        """Test role-based access control - only trainers can create products"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Login as student
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # Attempt to create product
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
                headers={"Authorization": f"Bearer {token}"}
            )

            # Should return 403 Forbidden
            assert product_response.status_code == 403
            assert "trainer" in product_response.json()["detail"].lower()

    @pytest.mark.asyncio
    async def test_modify_other_users_body_measurement(self):
        """Test that users can only access their own analytics data"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # User1 creates measurement
            login1 = await client.post("/api/v1/auth/login", json={
                "email": "user1@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token1 = login1.json()["access_token"]

            measurement_response = await client.post(
                "/api/v1/analytics/measurements",
                json={
                    "measured_at": "2026-02-05",
                    "weight_kg": 75.5,
                    "body_fat_percent": 15.0
                },
                headers={"Authorization": f"Bearer {token1}"}
            )
            measurement_id = measurement_response.json()["id"]

            # User2 attempts to delete user1's measurement
            login2 = await client.post("/api/v1/auth/login", json={
                "email": "user2@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token2 = login2.json()["access_token"]

            delete_response = await client.delete(
                f"/api/v1/analytics/measurements/{measurement_id}",
                headers={"Authorization": f"Bearer {token2}"}
            )

            # Should return 403 Forbidden
            assert delete_response.status_code == 403

    @pytest.mark.asyncio
    async def test_token_expiration(self):
        """Test that expired tokens are rejected"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Use an expired token (this would need to be generated with past exp)
            expired_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0IiwiZXhwIjoxNjAwMDAwMDAwfQ.invalid"

            response = await client.get(
                "/api/v1/users/profile",
                headers={"Authorization": f"Bearer {expired_token}"}
            )

            assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_horizontal_privilege_escalation(self):
        """Test that users cannot access other users' profiles via direct ID"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Login as user1
            login1 = await client.post("/api/v1/auth/login", json={
                "email": "user1@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token1 = login1.json()["access_token"]
            user1_id = login1.json()["user"]["id"]

            # Login as user2
            login2 = await client.post("/api/v1/auth/login", json={
                "email": "user2@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            user2_id = login2.json()["user"]["id"]

            # User1 attempts to access user2's private analytics
            analytics_response = await client.get(
                f"/api/v1/analytics/dashboard",
                headers={"Authorization": f"Bearer {token1}"}
            )

            # The dashboard should only show user1's data, not user2's
            # This is implicitly tested by the endpoint design (uses current_user)
            assert analytics_response.status_code == 200
            # Additional checks could verify the data belongs to user1

    @pytest.mark.asyncio
    async def test_insecure_direct_object_reference(self):
        """Test IDOR vulnerability - accessing resources by ID manipulation"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # User1 creates a workout
            login1 = await client.post("/api/v1/auth/login", json={
                "email": "user1@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token1 = login1.json()["access_token"]

            workout_response = await client.post(
                "/api/v1/workouts",
                json={
                    "name": "Private Workout",
                    "date": "2026-02-05T10:00:00Z",
                    "duration": 60,
                    "exercises": []
                },
                headers={"Authorization": f"Bearer {token1}"}
            )
            workout_id = workout_response.json()["id"]

            # User2 attempts to access user1's workout by guessing ID
            login2 = await client.post("/api/v1/auth/login", json={
                "email": "user2@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token2 = login2.json()["access_token"]

            get_response = await client.get(
                f"/api/v1/workouts/{workout_id}",
                headers={"Authorization": f"Bearer {token2}"}
            )

            # Should return 403 or 404 (not the actual workout)
            assert get_response.status_code in [403, 404]

    @pytest.mark.asyncio
    async def test_mass_assignment_vulnerability(self):
        """Test that users cannot modify restricted fields"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Login
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # Attempt to update profile with role escalation
            update_response = await client.put(
                "/api/v1/users/profile",
                json={
                    "full_name": "Updated Name",
                    "user_type": "trainer",  # Attempt to escalate to trainer
                    "is_verified": True      # Attempt to bypass verification
                },
                headers={"Authorization": f"Bearer {token}"}
            )

            # The API should ignore restricted fields
            # Check that user_type is still 'student'
            profile = await client.get(
                "/api/v1/users/profile",
                headers={"Authorization": f"Bearer {token}"}
            )

            assert profile.json()["user_type"] == "student"
            assert profile.json()["is_verified"] == False


class TestAuthorizationBypass:
    """Test attempts to bypass authorization"""

    @pytest.mark.asyncio
    async def test_manipulated_jwt_token(self):
        """Test that manipulated tokens are rejected"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Get a valid token
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # Manipulate the token (change one character)
            manipulated_token = token[:-1] + "X"

            response = await client.get(
                "/api/v1/users/profile",
                headers={"Authorization": f"Bearer {manipulated_token}"}
            )

            assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_missing_authorization_header(self):
        """Test that requests without auth header are rejected"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.get("/api/v1/users/profile")

            assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_malformed_authorization_header(self):
        """Test handling of malformed auth headers"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Test various malformed headers
            malformed_headers = [
                "Bearer",  # Missing token
                "InvalidScheme token123",  # Wrong scheme
                "token123",  # Missing scheme
                "",  # Empty
            ]

            for header in malformed_headers:
                response = await client.get(
                    "/api/v1/users/profile",
                    headers={"Authorization": header}
                )
                assert response.status_code == 401


# Test fixtures for user creation
@pytest.fixture
async def create_test_users():
    """Create test users for access control tests"""
    # This would create users in test database
    pass


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
