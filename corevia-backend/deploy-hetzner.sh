#!/bin/bash

# ============================================
# CoreVia Backend - Hetzner Deployment Script
# Domain: corevia.life
# ============================================

set -e  # Exit on error

echo "🚀 CoreVia Backend - Hetzner Deployment"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="corevia"
APP_DIR="/var/www/corevia"
DOMAIN="api.corevia.life"
PYTHON_VERSION="3.11"

echo -e "${BLUE}1. Updating system packages...${NC}"
sudo apt update
sudo apt upgrade -y

echo -e "${BLUE}2. Installing dependencies...${NC}"
sudo apt install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python3-pip \
    postgresql postgresql-contrib nginx certbot python3-certbot-nginx \
    git curl supervisor redis-server

echo -e "${BLUE}3. Setting up PostgreSQL (same server)...${NC}"

# Start PostgreSQL if not running
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Generate random password for database
DB_PASSWORD=$(openssl rand -base64 32)
echo "Database password: $DB_PASSWORD" > /tmp/db_password.txt
echo -e "${GREEN}Database password saved to: /tmp/db_password.txt${NC}"

# Create database user and database
sudo -u postgres psql << EOSQL
-- Create user if not exists
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'corevia_user') THEN
        CREATE USER corevia_user WITH PASSWORD '$DB_PASSWORD';
    END IF;
END
\$\$;

-- Create database if not exists
SELECT 'CREATE DATABASE corevia_production OWNER corevia_user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'corevia_production')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE corevia_production TO corevia_user;

-- Enable required extensions
\c corevia_production
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
EOSQL

# Configure PostgreSQL for better performance
echo -e "${BLUE}Optimizing PostgreSQL configuration...${NC}"
sudo tee -a /etc/postgresql/*/main/postgresql.conf > /dev/null <<EOF

# CoreVia Performance Tuning
max_connections = 100
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 2621kB
min_wal_size = 1GB
max_wal_size = 4GB
EOF

# Restart PostgreSQL to apply changes
sudo systemctl restart postgresql

echo -e "${GREEN}✅ PostgreSQL configured and running on localhost:5432${NC}"

echo -e "${BLUE}4. Creating app directory...${NC}"
sudo mkdir -p $APP_DIR
sudo chown -R $USER:$USER $APP_DIR

echo -e "${BLUE}5. Copying application files...${NC}"
# Bu scripti local-dan run edirsənsə, faylları upload et
# rsync -avz --exclude 'venv' --exclude '__pycache__' ./ root@YOUR_SERVER_IP:$APP_DIR/

echo -e "${BLUE}6. Setting up Python virtual environment...${NC}"
cd $APP_DIR
python${PYTHON_VERSION} -m venv venv
source venv/bin/activate

echo -e "${BLUE}7. Installing Python dependencies...${NC}"
pip install --upgrade pip
pip install -r requirements.txt

echo -e "${BLUE}8. Setting up environment variables...${NC}"
if [ ! -f .env ]; then
    cp .env.production .env
    echo -e "${RED}⚠️  IMPORTANT: Edit .env file with real credentials!${NC}"
    echo "   nano $APP_DIR/.env"
fi

echo -e "${BLUE}9. Running database migrations...${NC}"
alembic upgrade head

echo -e "${BLUE}10. Setting up Nginx...${NC}"
sudo tee /etc/nginx/sites-available/$APP_NAME > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    client_max_body_size 10M;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /uploads/ {
        alias $APP_DIR/uploads/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

echo -e "${BLUE}11. Setting up SSL with Let's Encrypt...${NC}"
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@corevia.life

echo -e "${BLUE}12. Setting up Supervisor (process manager)...${NC}"
sudo tee /etc/supervisor/conf.d/$APP_NAME.conf > /dev/null <<EOF
[program:$APP_NAME]
directory=$APP_DIR
command=$APP_DIR/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
user=$USER
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/supervisor/$APP_NAME.log
environment=PATH="$APP_DIR/venv/bin"
EOF

sudo mkdir -p /var/log/supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart $APP_NAME

echo -e "${BLUE}13. Setting up automatic SSL renewal...${NC}"
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

echo -e "${BLUE}14. Setting up automatic database backups...${NC}"
# Daily backup at 3 AM
(crontab -l 2>/dev/null; echo "0 3 * * * $APP_DIR/backup-database.sh >> /var/log/corevia-backup.log 2>&1") | crontab -
echo -e "${GREEN}✅ Daily database backups scheduled at 3:00 AM${NC}"

echo -e "${BLUE}15. Configuring firewall...${NC}"
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw --force enable

echo ""
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo ""
echo "🌐 Your API is now running at: https://$DOMAIN"
echo ""
echo "📋 Next Steps:"
echo "   1. Edit .env file: nano $APP_DIR/.env"
echo "   2. Generate SECRET_KEY: openssl rand -hex 32"
echo "   3. Update database password in .env"
echo "   4. Restart: sudo supervisorctl restart $APP_NAME"
echo "   5. Check logs: sudo tail -f /var/log/supervisor/$APP_NAME.log"
echo ""
echo "🔧 Useful Commands:"
echo "   • Restart app: sudo supervisorctl restart $APP_NAME"
echo "   • View logs: sudo supervisorctl tail -f $APP_NAME"
echo "   • Restart nginx: sudo systemctl restart nginx"
echo "   • Check status: sudo supervisorctl status"
echo ""
