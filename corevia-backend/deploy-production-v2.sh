#!/bin/bash

#################################################
# CoreVia Production Deployment v2
# Fixed Python version compatibility
#################################################

set -e

echo "🚀 CoreVia Production Deployment v2 Starting..."
echo "================================================"

# Configuration
DOMAIN="corevia.life"
API_SUBDOMAIN="api.corevia.life"
DB_NAME="corevia_production"
DB_USER="corevia_user"
APP_DIR="/var/www/corevia-backend"
DEPLOY_USER="corevia"

GREEN='\033[0;32m'
NC='\033[0m'

print_step() {
    echo -e "${GREEN}▶ $1${NC}"
}

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

print_step "1. Install Dependencies"
apt-get update
apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    python3-dev \
    build-essential \
    postgresql \
    postgresql-contrib \
    nginx \
    supervisor \
    certbot \
    python3-certbot-nginx \
    git \
    ufw \
    curl

print_step "2. Configure Firewall"
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

print_step "3. Create User"
useradd -m -s /bin/bash $DEPLOY_USER 2>/dev/null || echo "User exists"
usermod -aG sudo $DEPLOY_USER

print_step "4. Setup PostgreSQL"
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || echo "DB exists"

DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
echo "$DB_PASSWORD" > /tmp/db_password.txt
chmod 600 /tmp/db_password.txt

sudo -u postgres psql << PSQL
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = '$DB_USER') THEN
        CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
    END IF;
END
\$\$;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
ALTER DATABASE $DB_NAME OWNER TO $DB_USER;
PSQL

cat >> /etc/postgresql/*/main/postgresql.conf << PGCONF

# CoreVia Tuning
max_connections = 200
shared_buffers = 256MB
effective_cache_size = 1GB
PGCONF

systemctl restart postgresql

print_step "5. Setup App Directory"
mkdir -p $APP_DIR
mkdir -p $APP_DIR/uploads
chown -R $DEPLOY_USER:$DEPLOY_USER $APP_DIR

print_step "6. Create Python venv"
cd $APP_DIR
sudo -u $DEPLOY_USER python3 -m venv venv

print_step "7. Generate .env"
SECRET_KEY=$(openssl rand -hex 32)

cat > $APP_DIR/.env << ENVFILE
DATABASE_URL=postgresql+asyncpg://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME
SECRET_KEY=$SECRET_KEY
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
APP_NAME=CoreVia API
DEBUG=False
ENVIRONMENT=production
CORS_ORIGINS=https://$DOMAIN,https://$API_SUBDOMAIN
WHATSAPP_OTP_MOCK=true
ENVFILE

chown $DEPLOY_USER:$DEPLOY_USER $APP_DIR/.env
chmod 600 $APP_DIR/.env

print_step "8. Setup Supervisor (3 instances)"
cat > /etc/supervisor/conf.d/corevia.conf << 'SUPER'
[program:corevia-backend-1]
directory=/var/www/corevia-backend
command=/var/www/corevia-backend/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8001
user=corevia
autostart=true
autorestart=true
stderr_logfile=/var/log/corevia/backend-1.err.log
stdout_logfile=/var/log/corevia/backend-1.out.log

[program:corevia-backend-2]
directory=/var/www/corevia-backend
command=/var/www/corevia-backend/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8002
user=corevia
autostart=true
autorestart=true
stderr_logfile=/var/log/corevia/backend-2.err.log
stdout_logfile=/var/log/corevia/backend-2.out.log

[program:corevia-backend-3]
directory=/var/www/corevia-backend
command=/var/www/corevia-backend/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8003
user=corevia
autostart=true
autorestart=true
stderr_logfile=/var/log/corevia/backend-3.err.log
stdout_logfile=/var/log/corevia/backend-3.out.log

[group:corevia-backend]
programs=corevia-backend-1,corevia-backend-2,corevia-backend-3
SUPER

mkdir -p /var/log/corevia
chown -R $DEPLOY_USER:$DEPLOY_USER /var/log/corevia

print_step "9. Setup Nginx Load Balancer"
cat > /etc/nginx/sites-available/$API_SUBDOMAIN << 'NGINX'
upstream corevia_backend {
    server 127.0.0.1:8001 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:8002 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:8003 max_fails=3 fail_timeout=30s;
    keepalive 32;
}

server {
    listen 80;
    server_name api.corevia.life;
    client_max_body_size 20M;

    access_log /var/log/nginx/corevia-access.log;
    error_log /var/log/nginx/corevia-error.log;

    location / {
        proxy_pass http://corevia_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    location /uploads/ {
        alias /var/www/corevia-backend/uploads/;
        expires 30d;
    }
}
NGINX

ln -sf /etc/nginx/sites-available/$API_SUBDOMAIN /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t

print_step "10. Create Management Scripts"

cat > $APP_DIR/restart.sh << 'RESTART'
#!/bin/bash
sudo supervisorctl restart corevia-backend:*
sudo supervisorctl status corevia-backend:*
RESTART

cat > $APP_DIR/status.sh << 'STATUS'
#!/bin/bash
echo "Backend Status:"
sudo supervisorctl status corevia-backend:*
echo ""
echo "Nginx:"
sudo systemctl status nginx --no-pager | head -5
echo ""
echo "PostgreSQL:"
sudo systemctl status postgresql --no-pager | head -5
STATUS

cat > $APP_DIR/logs.sh << 'LOGS'
#!/bin/bash
tail -f /var/log/corevia/backend-*.out.log
LOGS

chmod +x $APP_DIR/*.sh
chown -R $DEPLOY_USER:$DEPLOY_USER $APP_DIR

print_step "11. Reload Services"
supervisorctl reread
supervisorctl update
systemctl reload nginx

echo ""
echo "=============================================="
echo "✅ Deployment Complete!"
echo "=============================================="
echo ""
echo "📋 Next Steps:"
echo "1. Upload code: scp -r corevia-backend/* root@89.167.53.205:/var/www/corevia-backend/"
echo "2. Install deps: cd /var/www/corevia-backend && sudo -u corevia ./venv/bin/pip install -r requirements.txt"
echo "3. Run migrations: sudo -u corevia ./venv/bin/alembic upgrade head"
echo "4. Setup DNS: api.corevia.life → 89.167.53.205"
echo "5. Setup SSL: certbot --nginx -d api.corevia.life"
echo "6. Start: sudo supervisorctl start corevia-backend:*"
echo ""
echo "DB Password: /tmp/db_password.txt"
echo "Environment: /var/www/corevia-backend/.env"
