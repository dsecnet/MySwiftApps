#!/bin/bash

# ============================================
# CoreVia - Database Connection Test
# Test PostgreSQL connection from backend
# ============================================

echo "🔍 Testing Database Connection..."
echo "=================================="
echo ""

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Extract database info from DATABASE_URL
DB_URL=$DATABASE_URL
echo "Database URL: ${DB_URL:0:50}..."
echo ""

# Test using psql
echo "1️⃣ Testing with psql..."
sudo -u postgres psql -c "SELECT version();" corevia_production 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ PostgreSQL connection: OK"
else
    echo "❌ PostgreSQL connection: FAILED"
fi

echo ""

# Test from Python
echo "2️⃣ Testing from Python..."
python3 << EOF
import asyncio
import asyncpg
import os

async def test_connection():
    try:
        conn = await asyncpg.connect(os.getenv('DATABASE_URL').replace('postgresql+asyncpg://', 'postgresql://'))
        version = await conn.fetchval('SELECT version()')
        print(f"✅ Python connection: OK")
        print(f"   PostgreSQL version: {version.split(',')[0]}")
        await conn.close()
    except Exception as e:
        print(f"❌ Python connection: FAILED")
        print(f"   Error: {e}")

asyncio.run(test_connection())
EOF

echo ""

# Show database stats
echo "3️⃣ Database Statistics..."
sudo -u postgres psql corevia_production << EOSQL
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;
EOSQL

echo ""
echo "✅ Database test complete!"
