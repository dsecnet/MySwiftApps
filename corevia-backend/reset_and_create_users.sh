#!/bin/bash

echo "🔄 CoreVia Database Reset & User Creation Script"
echo "================================================"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. Stop backend
echo -e "${BLUE}1. Stopping backend...${NC}"
lsof -ti:8000 | xargs kill -9 2>/dev/null
sleep 2

# 2. Reset database
echo -e "${BLUE}2. Resetting database...${NC}"
psql -h localhost -U postgres -d postgres -c "DROP DATABASE IF EXISTS corevia_db WITH (FORCE);" > /dev/null 2>&1
psql -h localhost -U postgres -d postgres -c "CREATE DATABASE corevia_db;" > /dev/null 2>&1

# 3. Run migrations
echo -e "${BLUE}3. Running migrations...${NC}"
cd /Users/vusaldadashov/Desktop/ConsoleApp/corevia-backend
source venv/bin/activate
alembic upgrade head > /dev/null 2>&1

# 4. Create social tables
echo -e "${BLUE}4. Creating social tables...${NC}"
psql -h localhost -U postgres -d corevia_db << 'EOF' > /dev/null 2>&1
CREATE TABLE IF NOT EXISTS posts (
    id VARCHAR PRIMARY KEY,
    user_id VARCHAR NOT NULL REFERENCES users(id),
    post_type VARCHAR(50) NOT NULL,
    content TEXT,
    image_url VARCHAR(500),
    workout_id VARCHAR,
    food_entry_id VARCHAR,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    is_public BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS post_likes (
    id VARCHAR PRIMARY KEY,
    post_id VARCHAR NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id VARCHAR NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);
CREATE TABLE IF NOT EXISTS post_comments (
    id VARCHAR PRIMARY KEY,
    post_id VARCHAR NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id VARCHAR NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS follows (
    id VARCHAR PRIMARY KEY,
    follower_id VARCHAR NOT NULL REFERENCES users(id),
    following_id VARCHAR NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(follower_id, following_id)
);
CREATE TABLE IF NOT EXISTS achievements (
    id VARCHAR PRIMARY KEY,
    user_id VARCHAR NOT NULL REFERENCES users(id),
    achievement_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    earned_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS marketplace_products (
    id VARCHAR PRIMARY KEY,
    seller_id VARCHAR NOT NULL REFERENCES users(id),
    product_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'AZN',
    cover_image_url VARCHAR(500),
    preview_video_url VARCHAR(500),
    content_data JSONB,
    sales_count INTEGER DEFAULT 0,
    rating NUMERIC(3, 2),
    reviews_count INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_follows_follower ON follows(follower_id);
EOF

# 5. Start backend
echo -e "${BLUE}5. Starting backend...${NC}"
cd /Users/vusaldadashov/Desktop/ConsoleApp/corevia-backend
source venv/bin/activate
nohup uvicorn app.main:app --reload --port 8000 > /tmp/corevia-backend.log 2>&1 &
sleep 5

# 6. Create users via API
echo -e "${BLUE}6. Creating users...${NC}"

# Student
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Tələbə",
    "email": "test_student@corevia.com",
    "password": "Student123",
    "user_type": "client",
    "age": 22,
    "weight": 70.0,
    "height": 175.0,
    "goal": "Stay fit and healthy"
  }' > /dev/null 2>&1

# Trainer
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Muellim",
    "email": "testmuellim@corevia.com",
    "password": "Test123456",
    "user_type": "trainer",
    "age": 35,
    "specialization": "General Fitness",
    "experience": 8,
    "bio": "Experienced fitness trainer"
  }' > /dev/null 2>&1

# Demo Teacher (Ready-to-use account, no registration needed)
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Müəllim",
    "email": "testmuellim@demo.com",
    "password": "demo123",
    "user_type": "trainer",
    "age": 30,
    "specialization": "Fitness və Qidalanma",
    "experience": 5,
    "bio": "Peşəkar fitness məşqçisi və qidalanma mütəxəssisi"
  }' > /dev/null 2>&1

sleep 2

echo ""
echo -e "${GREEN}✅ CoreVia hazırdır!${NC}"
echo ""
echo "📍 Backend: http://localhost:8000"
echo "📖 Docs: http://localhost:8000/docs"
echo ""
echo "👤 Login məlumatları:"
echo "  📚 Tələbə:  test_student@corevia.com / Student123"
echo "  👨‍🏫 Müəllim: testmuellim@corevia.com / Test123456"
echo "  🎯 Demo:    testmuellim@demo.com / demo123"
echo ""
echo "🚀 CoreVia app-ı açıb login ol!"
