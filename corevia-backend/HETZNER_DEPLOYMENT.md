# 🚀 CoreVia Backend - Hetzner Cloud Deployment Guide

## Prerequisites

✅ Hetzner Cloud account
✅ Domain: corevia.life
✅ Basic Linux knowledge

---

## Step 1: Create Hetzner Server

### 1.1 Go to Hetzner Cloud Console
https://console.hetzner.cloud/

### 1.2 Create New Project
- Name: `CoreVia Production`

### 1.3 Create Server
- **Location:** Germany (Nürnberg) - closest to Azerbaijan
- **Image:** Ubuntu 22.04
- **Type:**
  - For testing: **CX11** (2€/month - 1 vCPU, 2GB RAM)
  - For production: **CPX11** (4.5€/month - 2 vCPU, 2GB RAM)
- **SSH Key:** Add your public SSH key
  ```bash
  # Generate if you don't have:
  ssh-keygen -t ed25519 -C "your_email@example.com"
  cat ~/.ssh/id_ed25519.pub  # Copy this
  ```
- **Name:** `corevia-api`

### 1.4 Get Server IP
After creation, copy the IP address (e.g., `95.217.123.45`)

---

## Step 2: Configure DNS

Open `DNS_SETUP.md` and follow instructions.

**Quick version:**
1. Go to your domain provider
2. Add A record: `api` → `YOUR_SERVER_IP`
3. Wait 5-30 minutes for propagation

---

## Step 3: Connect to Server

```bash
ssh root@YOUR_SERVER_IP
```

First time, type `yes` to accept fingerprint.

---

## Step 4: Upload Backend Files

**Option A: Using rsync (from your Mac)**
```bash
cd /Users/vusaldadashov/Desktop/ConsoleApp/corevia-backend

# Upload files to server
rsync -avz --exclude 'venv' --exclude '__pycache__' --exclude '*.pyc' \
  ./ root@YOUR_SERVER_IP:/var/www/corevia/
```

**Option B: Using Git (recommended)**
```bash
# On server:
sudo mkdir -p /var/www/corevia
cd /var/www/corevia

# If you have GitHub repo:
git clone https://github.com/YOUR_USERNAME/corevia-backend.git .

# Or create repo first:
# 1. Create GitHub repo
# 2. Push code:
#    git init
#    git add .
#    git commit -m "Initial commit"
#    git remote add origin https://github.com/YOUR_USERNAME/corevia-backend.git
#    git push -u origin main
```

---

## Step 5: Run Deployment Script

```bash
# On server:
cd /var/www/corevia
chmod +x deploy-hetzner.sh
./deploy-hetzner.sh
```

This will:
- ✅ Install Python, PostgreSQL, Nginx, Redis
- ✅ Setup virtual environment
- ✅ Install dependencies
- ✅ Configure database
- ✅ Setup Nginx reverse proxy
- ✅ Install SSL certificate (Let's Encrypt)
- ✅ Setup Supervisor (auto-restart)

---

## Step 6: Configure Environment Variables

```bash
cd /var/www/corevia
nano .env
```

**IMPORTANT - Change these:**

```env
# Generate SECRET_KEY:
SECRET_KEY=$(openssl rand -hex 32)
# Paste the output here

# Database password (change from script)
DATABASE_URL=postgresql+asyncpg://corevia_user:YOUR_STRONG_PASSWORD@localhost:5432/corevia_production

# Email (if needed)
SMTP_USER=noreply@corevia.life
SMTP_PASSWORD=your-email-password
```

Save: `Ctrl+O`, Enter, `Ctrl+X`

---

## Step 7: Restart Application

```bash
sudo supervisorctl restart corevia
```

---

## Step 8: Verify Deployment

### Check if API is running:
```bash
curl https://api.corevia.life/
```

Should return: `{"message": "CoreVia API"}`

### Check API docs:
Open browser: `https://api.corevia.life/docs`

### Check logs:
```bash
sudo supervisorctl tail -f corevia
```

---

## Step 9: Create Demo Users

```bash
cd /var/www/corevia
source venv/bin/activate
python create_test_users.py
```

Or manually:
```bash
curl -X POST https://api.corevia.life/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Müəllim",
    "email": "testmuellim@demo.com",
    "password": "demo123",
    "user_type": "trainer"
  }'
```

---

## Step 10: Test iOS App Connection

1. Open Xcode
2. Build in **Release** mode (iOS app already configured for `https://api.corevia.life`)
3. Login with: `testmuellim@demo.com` / `demo123`

---

## 🔧 Useful Commands

### Application Management
```bash
# Restart app
sudo supervisorctl restart corevia

# Stop app
sudo supervisorctl stop corevia

# Start app
sudo supervisorctl start corevia

# View logs
sudo supervisorctl tail -f corevia

# Check status
sudo supervisorctl status
```

### Nginx
```bash
# Restart Nginx
sudo systemctl restart nginx

# Check config
sudo nginx -t

# View error logs
sudo tail -f /var/log/nginx/error.log
```

### Database
```bash
# Connect to PostgreSQL
sudo -u postgres psql corevia_production

# Backup database
pg_dump -U corevia_user corevia_production > backup.sql

# Restore database
psql -U corevia_user corevia_production < backup.sql
```

### SSL Certificate
```bash
# Renew SSL (auto-renews via cron)
sudo certbot renew

# Check expiry
sudo certbot certificates
```

### Updates
```bash
# Pull latest code (if using Git)
cd /var/www/corevia
git pull

# Install new dependencies
source venv/bin/activate
pip install -r requirements.txt

# Run migrations
alembic upgrade head

# Restart
sudo supervisorctl restart corevia
```

---

## 📊 Monitoring

### Check server resources:
```bash
# CPU and memory
htop

# Disk usage
df -h

# Network
netstat -tulpn
```

### Check API health:
```bash
curl https://api.corevia.life/health
```

---

## 🔒 Security Checklist

- ✅ Firewall enabled (UFW)
- ✅ SSH key authentication only
- ✅ SSL/HTTPS enabled
- ✅ Database password changed
- ✅ SECRET_KEY generated
- ✅ DEBUG=False in production
- ✅ CORS configured
- ✅ Rate limiting enabled

### Extra security (optional):
```bash
# Disable root login
sudo nano /etc/ssh/sshd_config
# Change: PermitRootLogin no
sudo systemctl restart sshd

# Install fail2ban (blocks brute force)
sudo apt install fail2ban
```

---

## 💰 Cost Estimate

**Hetzner Cloud:**
- Server: 4.5€/month (CPX11)
- Backups: 0.9€/month (optional)
- **Total: ~5€/month**

**Domain:**
- corevia.life: ~10-15€/year

**SSL Certificate:**
- Let's Encrypt: FREE! ✨

---

## 🆘 Troubleshooting

### API not accessible
```bash
# Check if app is running
sudo supervisorctl status corevia

# Check Nginx
sudo systemctl status nginx

# Check firewall
sudo ufw status

# Check DNS
nslookup api.corevia.life
```

### 502 Bad Gateway
```bash
# Backend not running - start it
sudo supervisorctl start corevia

# Check logs
sudo supervisorctl tail -f corevia
```

### Database connection error
```bash
# Check PostgreSQL
sudo systemctl status postgresql

# Check credentials in .env
cat /var/www/corevia/.env | grep DATABASE_URL
```

### SSL certificate error
```bash
# Force renew
sudo certbot renew --force-renewal
```

---

## 📱 Connect iOS App

iOS app already configured with `https://api.corevia.life`!

Just build in **Release** mode and it will connect to production.

---

## 🎉 Success!

Your backend is now live at:
**https://api.corevia.life**

API Docs: **https://api.corevia.life/docs**

---

**Need help?** Check logs:
```bash
sudo supervisorctl tail -f corevia
sudo tail -f /var/log/nginx/error.log
```
