#!/bin/bash

# ============================================
# CoreVia - Automatic .env Setup Script
# Avtomatik passwordları generate edib .env-ə yazır
# ============================================

set -e

APP_DIR="/var/www/corevia"
ENV_FILE="$APP_DIR/.env"

echo "🔐 CoreVia Environment Setup"
echo "============================="
echo ""

# 1. Get database password from deployment
if [ -f /tmp/db_password.txt ]; then
    DB_PASSWORD=$(cat /tmp/db_password.txt | grep "Database password:" | cut -d: -f2 | xargs)
    echo "✅ Database password found"
else
    echo "❌ Database password not found! Run deploy-hetzner.sh first"
    exit 1
fi

# 2. Generate SECRET_KEY
echo "🔑 Generating SECRET_KEY..."
SECRET_KEY=$(openssl rand -hex 32)
echo "✅ SECRET_KEY generated"

# 3. Create .env file
echo "📝 Creating .env file..."

cat > $ENV_FILE << EOF
# ============================================
# CoreVia Backend - PRODUCTION Configuration
# Auto-generated: $(date)
# ============================================

# Database - PostgreSQL (localhost)
DATABASE_URL=postgresql+asyncpg://corevia_user:${DB_PASSWORD}@localhost:5432/corevia_production

# JWT Security
SECRET_KEY=${SECRET_KEY}
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# CORS - iOS App və Web üçün
CORS_ORIGINS=https://api.corevia.life,https://corevia.life,https://www.corevia.life

# App Settings
APP_NAME=CoreVia API
DEBUG=False

# AWS S3 (optional - lazım olsa doldur)
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_BUCKET_NAME=corevia-uploads
AWS_REGION=eu-central-1

# OpenAI (optional - AI features üçün)
OPENAI_API_KEY=

# Redis (optional - caching üçün)
REDIS_URL=redis://localhost:6379/0

# Email Settings (optional - notification üçün)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=
SMTP_PASSWORD=
SMTP_FROM=CoreVia <noreply@corevia.life>

# Mapbox (optional - map features üçün)
MAPBOX_ACCESS_TOKEN=

# Firebase (optional - push notifications üçün)
FIREBASE_CREDENTIALS_PATH=/var/www/corevia/firebase-credentials.json

# Server Settings
HOST=0.0.0.0
PORT=8000
WORKERS=4

# Logging
LOG_LEVEL=INFO
LOG_FILE=/var/log/corevia/backend.log
EOF

# Set proper permissions
chmod 600 $ENV_FILE
chown $USER:$USER $ENV_FILE

echo ""
echo "✅ .env file created successfully!"
echo ""
echo "📋 Configuration:"
echo "   Database User: corevia_user"
echo "   Database: corevia_production"
echo "   Secret Key: ✅ Generated (64 chars)"
echo "   Database Password: ✅ Set from deployment"
echo ""
echo "📄 File location: $ENV_FILE"
echo ""
echo "⚠️  Optional: Edit .env to add:"
echo "   • AWS credentials (for file uploads)"
echo "   • Email settings (for notifications)"
echo "   • OpenAI API key (for AI features)"
echo ""
echo "Run: nano $ENV_FILE"
echo ""
echo "🔄 Restart backend to apply:"
echo "   sudo supervisorctl restart corevia"
echo ""
