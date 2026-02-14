#!/bin/bash

#################################################
# CoreVia Production Deployment
# Nginx Load Balancer + 3 Backend Instances + PostgreSQL
#################################################

set -e  # Exit on error

echo "🚀 CoreVia Production Deployment Starting..."
echo "=============================================="

# Configuration
DOMAIN="corevia.life"
API_SUBDOMAIN="api.corevia.life"
DB_NAME="corevia_production"
DB_USER="corevia_user"
APP_DIR="/var/www/corevia-backend"
DEPLOY_USER="corevia"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${GREEN}▶ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (sudo)"
    exit 1
fi

print_step "1. System Update & Install Dependencies"
apt-get update
apt-get upgrade -y
apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3-pip \
    postgresql \
    postgresql-contrib \
    nginx \
    supervisor \
    certbot \
    python3-certbot-nginx \
    git \
    ufw \
    htop \
    curl

print_step "2. Configure Firewall"
ufw --force enable
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw status

print_step "3. Create Deploy User"
if id "$DEPLOY_USER" &>/dev/null; then
    print_warning "User $DEPLOY_USER already exists"
else
    useradd -m -s /bin/bash $DEPLOY_USER
    usermod -aG sudo $DEPLOY_USER
    echo "$DEPLOY_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$DEPLOY_USER
    print_step "User $DEPLOY_USER created"
fi

print_step "4. Setup PostgreSQL Database"
# Configure PostgreSQL
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || print_warning "Database already exists"

# Generate secure password
DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
echo "$DB_PASSWORD" > /tmp/db_password.txt
chmod 600 /tmp/db_password.txt

# Create database user
sudo -u postgres psql << EOF
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = '$DB_USER') THEN
        CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
    END IF;
END
\$\$;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
ALTER DATABASE $DB_NAME OWNER TO $DB_USER;
EOF

print_step "Database password saved to /tmp/db_password.txt"

# PostgreSQL performance tuning
cat >> /etc/postgresql/*/main/postgresql.conf << EOF

# CoreVia Performance Tuning
max_connections = 200
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
EOF

systemctl restart postgresql

print_step "5. Setup Application Directory"
mkdir -p $APP_DIR
chown -R $DEPLOY_USER:$DEPLOY_USER $APP_DIR

print_step "6. Clone Repository"
# Note: User must upload code manually or setup git deploy key
print_warning "Code deployment: Please copy your backend code to $APP_DIR"
print_warning "Or setup git deployment manually"

# Create uploads directory
mkdir -p $APP_DIR/uploads
chown -R $DEPLOY_USER:$DEPLOY_USER $APP_DIR/uploads

print_step "7. Setup Python Virtual Environment"
cd $APP_DIR
sudo -u $DEPLOY_USER python3.11 -m venv venv
sudo -u $DEPLOY_USER $APP_DIR/venv/bin/pip install --upgrade pip

print_step "8. Generate Environment Variables"
SECRET_KEY=$(openssl rand -hex 32)

cat > $APP_DIR/.env << EOF
# Database
DATABASE_URL=postgresql+asyncpg://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME

# JWT
SECRET_KEY=$SECRET_KEY
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# App Settings
APP_NAME=CoreVia API
DEBUG=False
ENVIRONMENT=production

# CORS
CORS_ORIGINS=https://$DOMAIN,https://$API_SUBDOMAIN

# Redis (optional)
REDIS_URL=redis://localhost:6379/0

# AWS S3 (configure later)
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
AWS_BUCKET_NAME=corevia-uploads
AWS_REGION=eu-central-1

# OpenAI (configure later)
OPENAI_API_KEY=your-openai-key

# WhatsApp OTP
WHATSAPP_OTP_MOCK=true
TWILIO_ACCOUNT_SID=your-account-sid
TWILIO_AUTH_TOKEN=your-auth-token
TWILIO_WHATSAPP_FROM=whatsapp:+14155238886

# Mapbox (configure later)
MAPBOX_ACCESS_TOKEN=your-mapbox-token
EOF

chown $DEPLOY_USER:$DEPLOY_USER $APP_DIR/.env
chmod 600 $APP_DIR/.env

print_step "9. Setup Supervisor (3 Backend Instances)"
cat > /etc/supervisor/conf.d/corevia.conf << 'EOF'
; CoreVia Backend Instance 1
[program:corevia-backend-1]
directory=/var/www/corevia-backend
command=/var/www/corevia-backend/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8001 --workers 1
user=corevia
autostart=true
autorestart=true
stderr_logfile=/var/log/corevia/backend-1.err.log
stdout_logfile=/var/log/corevia/backend-1.out.log
environment=PATH="/var/www/corevia-backend/venv/bin"

; CoreVia Backend Instance 2
[program:corevia-backend-2]
directory=/var/www/corevia-backend
command=/var/www/corevia-backend/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8002 --workers 1
user=corevia
autostart=true
autorestart=true
stderr_logfile=/var/log/corevia/backend-2.err.log
stdout_logfile=/var/log/corevia/backend-2.out.log
environment=PATH="/var/www/corevia-backend/venv/bin"

; CoreVia Backend Instance 3
[program:corevia-backend-3]
directory=/var/www/corevia-backend
command=/var/www/corevia-backend/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8003 --workers 1
user=corevia
autostart=true
autorestart=true
stderr_logfile=/var/log/corevia/backend-3.err.log
stdout_logfile=/var/log/corevia/backend-3.out.log
environment=PATH="/var/www/corevia-backend/venv/bin"

; Group all instances
[group:corevia-backend]
programs=corevia-backend-1,corevia-backend-2,corevia-backend-3
EOF

# Create log directory
mkdir -p /var/log/corevia
chown -R $DEPLOY_USER:$DEPLOY_USER /var/log/corevia

print_step "10. Setup Nginx Load Balancer"
cat > /etc/nginx/sites-available/$API_SUBDOMAIN << 'EOF'
# CoreVia Backend - Load Balancer
upstream corevia_backend {
    # Round-robin load balancing
    server 127.0.0.1:8001 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:8002 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:8003 max_fails=3 fail_timeout=30s;

    # Keep-alive connections
    keepalive 32;
}

server {
    listen 80;
    server_name api.corevia.life;

    # Redirect to HTTPS (after SSL setup)
    # return 301 https://$server_name$request_uri;

    # Client body size (for file uploads)
    client_max_body_size 20M;

    # Logging
    access_log /var/log/nginx/corevia-access.log;
    error_log /var/log/nginx/corevia-error.log;

    # API endpoint
    location / {
        proxy_pass http://corevia_backend;

        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Health check endpoint
    location /health {
        access_log off;
        proxy_pass http://corevia_backend;
    }

    # Static files (uploads)
    location /uploads/ {
        alias /var/www/corevia-backend/uploads/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/$API_SUBDOMAIN /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test nginx config
nginx -t

print_step "11. SSL Certificate Setup"
print_warning "SSL setup requires DNS to be configured first!"
print_warning "Run this after DNS is pointing to server:"
print_warning "  sudo certbot --nginx -d api.corevia.life"

print_step "12. Create Management Scripts"

# Restart script
cat > $APP_DIR/restart.sh << 'EOF'
#!/bin/bash
echo "🔄 Restarting all backend instances..."
sudo supervisorctl restart corevia-backend:*
echo "✅ All instances restarted"
sudo supervisorctl status corevia-backend:*
EOF
chmod +x $APP_DIR/restart.sh

# Deploy script
cat > $APP_DIR/deploy.sh << 'EOF'
#!/bin/bash
set -e
echo "🚀 Deploying CoreVia Backend..."

cd /var/www/corevia-backend

# Pull latest code (if using git)
# git pull origin main

# Install dependencies
./venv/bin/pip install -r requirements.txt

# Run migrations
./venv/bin/alembic upgrade head

# Restart services
sudo supervisorctl restart corevia-backend:*

echo "✅ Deployment complete!"
sudo supervisorctl status corevia-backend:*
EOF
chmod +x $APP_DIR/deploy.sh

# Status script
cat > $APP_DIR/status.sh << 'EOF'
#!/bin/bash
echo "📊 CoreVia Backend Status:"
echo "=========================="
sudo supervisorctl status corevia-backend:*
echo ""
echo "🔌 Nginx Status:"
sudo systemctl status nginx --no-pager | head -5
echo ""
echo "🗄️ PostgreSQL Status:"
sudo systemctl status postgresql --no-pager | head -5
echo ""
echo "💾 Database Connections:"
sudo -u postgres psql -c "SELECT count(*) as connections FROM pg_stat_activity WHERE datname='corevia_production';"
EOF
chmod +x $APP_DIR/status.sh

# Logs script
cat > $APP_DIR/logs.sh << 'EOF'
#!/bin/bash
echo "Which logs do you want to see?"
echo "1) Backend Instance 1"
echo "2) Backend Instance 2"
echo "3) Backend Instance 3"
echo "4) Nginx Access"
echo "5) Nginx Error"
echo "6) All Backend (tail -f)"
read -p "Choice: " choice

case $choice in
    1) tail -f /var/log/corevia/backend-1.out.log ;;
    2) tail -f /var/log/corevia/backend-2.out.log ;;
    3) tail -f /var/log/corevia/backend-3.out.log ;;
    4) tail -f /var/log/nginx/corevia-access.log ;;
    5) tail -f /var/log/nginx/corevia-error.log ;;
    6) tail -f /var/log/corevia/backend-*.out.log ;;
    *) echo "Invalid choice" ;;
esac
EOF
chmod +x $APP_DIR/logs.sh

chown -R $DEPLOY_USER:$DEPLOY_USER $APP_DIR

print_step "13. Reload Services"
supervisorctl reread
supervisorctl update
systemctl reload nginx

print_step "14. Create Backup Script"
cat > /usr/local/bin/backup-corevia.sh << EOF
#!/bin/bash
BACKUP_DIR="/var/backups/corevia"
mkdir -p \$BACKUP_DIR
DATE=\$(date +%Y%m%d_%H%M%S)

# Database backup
sudo -u postgres pg_dump $DB_NAME | gzip > \$BACKUP_DIR/db_\$DATE.sql.gz

# Keep only last 7 days
find \$BACKUP_DIR -name "db_*.sql.gz" -mtime +7 -delete

echo "✅ Backup completed: \$BACKUP_DIR/db_\$DATE.sql.gz"
EOF
chmod +x /usr/local/bin/backup-corevia.sh

# Schedule daily backup
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-corevia.sh") | crontab -

print_step "15. Setup Complete! 🎉"
echo ""
echo "=============================================="
echo "📋 Next Steps:"
echo "=============================================="
echo ""
echo "1️⃣ Upload your backend code to: $APP_DIR"
echo "   scp -r corevia-backend/* root@89.167.53.205:$APP_DIR/"
echo ""
echo "2️⃣ Install Python dependencies:"
echo "   cd $APP_DIR && ./venv/bin/pip install -r requirements.txt"
echo ""
echo "3️⃣ Run database migrations:"
echo "   cd $APP_DIR && ./venv/bin/alembic upgrade head"
echo ""
echo "4️⃣ Configure DNS A record:"
echo "   api.corevia.life → 89.167.53.205"
echo ""
echo "5️⃣ Setup SSL certificate:"
echo "   sudo certbot --nginx -d api.corevia.life"
echo ""
echo "6️⃣ Start backend instances:"
echo "   sudo supervisorctl start corevia-backend:*"
echo ""
echo "=============================================="
echo "📊 Management Commands:"
echo "=============================================="
echo ""
echo "Status:   cd $APP_DIR && ./status.sh"
echo "Logs:     cd $APP_DIR && ./logs.sh"
echo "Restart:  cd $APP_DIR && ./restart.sh"
echo "Deploy:   cd $APP_DIR && ./deploy.sh"
echo ""
echo "=============================================="
echo "🔐 Credentials:"
echo "=============================================="
echo ""
echo "Database:"
echo "  Name:     $DB_NAME"
echo "  User:     $DB_USER"
echo "  Password: (saved in /tmp/db_password.txt)"
echo "  Host:     localhost:5432"
echo ""
echo "Secret Key: (saved in $APP_DIR/.env)"
echo ""
echo "=============================================="
print_step "Deployment script completed successfully! ✅"
