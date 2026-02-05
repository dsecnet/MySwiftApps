#!/bin/bash

# CoreVia Backend - Database Migration Script
# Run this script to apply all v2.0 database changes

echo "🔄 CoreVia v2.0 - Database Migration"
echo "===================================="
echo ""

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found. Creating..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "📦 Activating virtual environment..."
source venv/bin/activate

# Install/upgrade dependencies
echo "📦 Installing dependencies..."
pip install -q --upgrade pip
pip install -q -r requirements.txt

# Check if alembic is initialized
if [ ! -d "alembic" ]; then
    echo "⚙️  Initializing Alembic..."
    alembic init alembic
fi

# Generate migration
echo ""
echo "🔍 Generating migration for v2.0 tables..."
echo "   - social (posts, likes, comments, follows, achievements)"
echo "   - marketplace (products, purchases, reviews)"
echo "   - analytics (daily_stats, weekly_stats, body_measurements)"
echo ""

alembic revision --autogenerate -m "Add v2.0 social marketplace analytics tables"

if [ $? -eq 0 ]; then
    echo "✅ Migration generated successfully!"
    echo ""

    # Show migration file
    LATEST_MIGRATION=$(ls -t alembic/versions/*.py | head -1)
    echo "📄 Migration file: $LATEST_MIGRATION"
    echo ""

    # Ask for confirmation
    read -p "🚀 Apply migration to database? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 Applying migration..."
        alembic upgrade head

        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Migration applied successfully!"
            echo ""
            echo "📊 Database tables created:"
            echo "   ✓ posts"
            echo "   ✓ post_likes"
            echo "   ✓ post_comments"
            echo "   ✓ follows"
            echo "   ✓ achievements"
            echo "   ✓ marketplace_products"
            echo "   ✓ product_purchases"
            echo "   ✓ product_reviews"
            echo "   ✓ daily_stats"
            echo "   ✓ weekly_stats"
            echo "   ✓ body_measurements"
            echo ""
            echo "🎉 Database is ready for v2.0!"
        else
            echo "❌ Migration failed. Check errors above."
            exit 1
        fi
    else
        echo "⏸️  Migration not applied. Run manually when ready:"
        echo "   alembic upgrade head"
    fi
else
    echo "❌ Migration generation failed. Check errors above."
    exit 1
fi

echo ""
echo "📚 Next steps:"
echo "1. Start backend: uvicorn app.main:app --reload"
echo "2. Visit docs: http://localhost:8000/docs"
echo "3. Test new endpoints"
