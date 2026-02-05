"""
Locust Load Testing Configuration for CoreVia Backend
Tests API performance under load
"""

from locust import HttpUser, task, between, events
import random
import json


class CoreViaUser(HttpUser):
    """Simulates a typical CoreVia app user"""

    wait_time = between(1, 3)  # Wait 1-3 seconds between requests
    host = "http://localhost:8000"

    def on_start(self):
        """Called when a user starts - login and get token"""
        self.register_or_login()

    def register_or_login(self):
        """Register a new user or login if exists"""
        # Generate random user
        user_num = random.randint(1, 10000)
        self.email = f"loadtest_user{user_num}@test.com"
        self.password = "LoadTest123!"

        # Try to register
        register_response = self.client.post("/api/v1/auth/register", json={
            "email": self.email,
            "password": self.password,
            "full_name": f"Load Test User {user_num}",
            "user_type": "student"
        }, name="Register")

        # If register fails (409), login instead
        if register_response.status_code == 409:
            login_response = self.client.post("/api/v1/auth/login", json={
                "email": self.email,
                "password": self.password,
                "user_type": "student"
            }, name="Login")

            if login_response.status_code == 200:
                self.token = login_response.json()["access_token"]
                self.user_id = login_response.json()["user"]["id"]
        elif register_response.status_code in [200, 201]:
            self.token = register_response.json()["access_token"]
            self.user_id = register_response.json()["user"]["id"]
        else:
            # Fallback: login with predefined user
            self.client.post("/api/v1/auth/login", json={
                "email": "student@test.com",
                "password": "Password123!",
                "user_type": "student"
            })

    @task(10)
    def view_social_feed(self):
        """Most common action: Browse social feed"""
        headers = {"Authorization": f"Bearer {self.token}"}
        self.client.get(
            "/api/v1/social/feed?page=1&page_size=20",
            headers=headers,
            name="Social Feed"
        )

    @task(3)
    def create_post(self):
        """Create a social post"""
        headers = {"Authorization": f"Bearer {self.token}"}
        post_types = ["general", "workout", "meal", "progress"]

        self.client.post(
            "/api/v1/social/posts",
            json={
                "post_type": random.choice(post_types),
                "content": f"Load test post {random.randint(1, 1000)}",
                "is_public": True
            },
            headers=headers,
            name="Create Post"
        )

    @task(5)
    def like_post(self):
        """Like a random post"""
        headers = {"Authorization": f"Bearer {self.token}"}

        # Get feed first
        feed_response = self.client.get(
            "/api/v1/social/feed?page=1&page_size=5",
            headers=headers,
            name="Social Feed (for like)"
        )

        if feed_response.status_code == 200:
            posts = feed_response.json().get("posts", [])
            if posts:
                post_id = random.choice(posts)["id"]
                self.client.post(
                    f"/api/v1/social/posts/{post_id}/like",
                    headers=headers,
                    name="Like Post"
                )

    @task(2)
    def add_comment(self):
        """Add a comment to a post"""
        headers = {"Authorization": f"Bearer {self.token}"}

        # Get feed
        feed_response = self.client.get(
            "/api/v1/social/feed?page=1&page_size=5",
            headers=headers,
            name="Social Feed (for comment)"
        )

        if feed_response.status_code == 200:
            posts = feed_response.json().get("posts", [])
            if posts:
                post_id = random.choice(posts)["id"]
                self.client.post(
                    f"/api/v1/social/posts/{post_id}/comments",
                    json={"content": f"Load test comment {random.randint(1, 100)}"},
                    headers=headers,
                    name="Add Comment"
                )

    @task(7)
    def browse_marketplace(self):
        """Browse marketplace products"""
        headers = {"Authorization": f"Bearer {self.token}"}
        self.client.get(
            "/api/v1/marketplace/products?page=1&page_size=20",
            headers=headers,
            name="Marketplace Browse"
        )

    @task(3)
    def view_product_detail(self):
        """View product details"""
        headers = {"Authorization": f"Bearer {self.token}"}

        # Get products first
        products_response = self.client.get(
            "/api/v1/marketplace/products?page=1&page_size=5",
            headers=headers,
            name="Marketplace Browse (for detail)"
        )

        if products_response.status_code == 200:
            products = products_response.json().get("products", [])
            if products:
                product_id = random.choice(products)["id"]
                self.client.get(
                    f"/api/v1/marketplace/products/{product_id}",
                    headers=headers,
                    name="Product Detail"
                )

    @task(4)
    def view_analytics_dashboard(self):
        """View analytics dashboard"""
        headers = {"Authorization": f"Bearer {self.token}"}
        self.client.get(
            "/api/v1/analytics/dashboard",
            headers=headers,
            name="Analytics Dashboard"
        )

    @task(2)
    def create_workout(self):
        """Log a workout"""
        headers = {"Authorization": f"Bearer {self.token}"}
        self.client.post(
            "/api/v1/workouts",
            json={
                "name": f"Load Test Workout {random.randint(1, 100)}",
                "date": "2026-02-05T10:00:00Z",
                "duration": random.randint(30, 90),
                "exercises": [],
                "is_completed": True
            },
            headers=headers,
            name="Create Workout"
        )

    @task(2)
    def log_food(self):
        """Log food entry"""
        headers = {"Authorization": f"Bearer {self.token}"}
        self.client.post(
            "/api/v1/food",
            json={
                "name": f"Test Food {random.randint(1, 50)}",
                "date": "2026-02-05T12:00:00Z",
                "meal_type": random.choice(["breakfast", "lunch", "dinner", "snack"]),
                "calories": random.randint(100, 800),
                "protein": random.uniform(10, 50),
                "carbs": random.uniform(20, 100),
                "fats": random.uniform(5, 30)
            },
            headers=headers,
            name="Log Food"
        )

    @task(1)
    def get_user_profile(self):
        """Get user profile"""
        headers = {"Authorization": f"Bearer {self.token}"}
        self.client.get(
            "/api/v1/users/profile",
            headers=headers,
            name="User Profile"
        )


class TrainerUser(HttpUser):
    """Simulates a trainer user with different behavior"""

    wait_time = between(2, 5)
    host = "http://localhost:8000"

    def on_start(self):
        """Login as trainer"""
        # Use existing trainer or create new one
        user_num = random.randint(1, 100)
        self.email = f"loadtest_trainer{user_num}@test.com"
        self.password = "LoadTest123!"

        register_response = self.client.post("/api/v1/auth/register", json={
            "email": self.email,
            "password": self.password,
            "full_name": f"Load Test Trainer {user_num}",
            "user_type": "trainer"
        })

        if register_response.status_code in [200, 201]:
            self.token = register_response.json()["access_token"]
        else:
            login_response = self.client.post("/api/v1/auth/login", json={
                "email": self.email,
                "password": self.password,
                "user_type": "trainer"
            })
            if login_response.status_code == 200:
                self.token = login_response.json()["access_token"]

    @task(5)
    def create_marketplace_product(self):
        """Create a product in marketplace"""
        headers = {"Authorization": f"Bearer {self.token}"}
        product_types = ["workout_plan", "meal_plan", "ebook", "consultation"]

        self.client.post(
            "/api/v1/marketplace/products",
            json={
                "product_type": random.choice(product_types),
                "title": f"Load Test Product {random.randint(1, 1000)}",
                "description": "This is a test product for load testing",
                "price": round(random.uniform(9.99, 99.99), 2),
                "currency": "USD",
                "is_active": True
            },
            headers=headers,
            name="Create Product"
        )

    @task(3)
    def view_my_products(self):
        """View trainer's own products"""
        headers = {"Authorization": f"Bearer {self.token}"}
        self.client.get(
            "/api/v1/marketplace/my-products",
            headers=headers,
            name="My Products"
        )

    @task(2)
    def post_trainer_content(self):
        """Post content as trainer"""
        headers = {"Authorization": f"Bearer {self.token}"}
        self.client.post(
            "/api/v1/social/posts",
            json={
                "post_type": "general",
                "content": f"Trainer tip {random.randint(1, 100)}: Stay consistent!",
                "is_public": True
            },
            headers=headers,
            name="Trainer Post"
        )


# Custom event handlers for detailed metrics
@events.request.add_listener
def on_request(request_type, name, response_time, response_length, exception, **kwargs):
    """Log slow requests"""
    if response_time > 2000:  # > 2 seconds
        print(f"SLOW REQUEST: {name} took {response_time}ms")


@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    """Called when test starts"""
    print("=" * 60)
    print("CoreVia Load Test Starting")
    print(f"Target: {environment.host}")
    print("=" * 60)


@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    """Called when test stops"""
    print("=" * 60)
    print("CoreVia Load Test Complete")
    print("=" * 60)
