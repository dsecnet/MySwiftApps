# 🚀 CoreVia - Complete Deployment Summary

## ✅ What's Ready

### Backend
- ✅ Domain configured: `corevia.life`
- ✅ API endpoint: `https://api.corevia.life`
- ✅ CORS configured for domain
- ✅ Production `.env` template ready
- ✅ Hetzner deployment script ready
- ✅ SSL auto-setup (Let's Encrypt)
- ✅ Auto-restart (Supervisor)

### iOS App
- ✅ Production API URL configured: `https://api.corevia.life`
- ✅ iOS 16+ compatible
- ✅ Environment switching (Debug/Release)
- ✅ Ready to build and deploy

---

## 📋 Deployment Checklist

### 1️⃣ Hetzner Setup (15 min)
- [ ] Create Hetzner account
- [ ] Create Ubuntu 22.04 server (CPX11 - 4.5€/month)
- [ ] Get server IP address
- [ ] Add SSH key

### 2️⃣ DNS Configuration (5 min + wait)
- [ ] Add A record: `api` → Server IP
- [ ] Add A record: `@` → Server IP
- [ ] Wait 5-30 min for DNS propagation
- [ ] Verify: `nslookup api.corevia.life`

### 3️⃣ Backend Deployment (10 min)
- [ ] SSH to server: `ssh root@YOUR_IP`
- [ ] Upload files: `rsync` or `git clone`
- [ ] Run: `./deploy-hetzner.sh`
- [ ] Edit `.env` with real credentials
- [ ] Generate SECRET_KEY: `openssl rand -hex 32`
- [ ] Restart: `sudo supervisorctl restart corevia`
- [ ] Test: `curl https://api.corevia.life/`

### 4️⃣ iOS App (2 min)
- [ ] Open Xcode
- [ ] Select Release scheme
- [ ] Build (Cmd+B)
- [ ] Run on device (Cmd+R)
- [ ] Login: `testmuellim@demo.com` / `demo123`

---

## 📁 Important Files

```
corevia-backend/
├── .env.production          # Production environment template
├── deploy-hetzner.sh        # Automated deployment script
├── HETZNER_DEPLOYMENT.md    # Full deployment guide
├── DNS_SETUP.md             # DNS configuration guide
└── DEPLOYMENT.md            # General deployment info

CoreVia/
├── Services/APIService.swift  # Already configured!
│   #if DEBUG
│     baseURL = "http://localhost:8000"
│   #else
│     baseURL = "https://api.corevia.life"  ✅
│   #endif
└── DEPLOYMENT.md            # iOS deployment guide
```

---

## 🌐 URLs After Deployment

- **API:** https://api.corevia.life
- **API Docs:** https://api.corevia.life/docs
- **Main Site:** https://corevia.life (future)

---

## 💰 Monthly Cost

- **Hetzner Server:** 4.5€/month (CPX11)
- **Backups (optional):** 0.9€/month
- **Domain:** ~1€/month (paid yearly)
- **SSL:** FREE (Let's Encrypt)

**Total: ~6€/month** 💸

---

## ⚡ Quick Start Commands

```bash
# 1. Connect to server
ssh root@YOUR_SERVER_IP

# 2. Deploy
cd /var/www/corevia
./deploy-hetzner.sh

# 3. Configure
nano .env  # Edit credentials

# 4. Restart
sudo supervisorctl restart corevia

# 5. Check
curl https://api.corevia.life/
```

---

## 🔧 Most Used Commands

```bash
# Restart backend
sudo supervisorctl restart corevia

# View logs
sudo supervisorctl tail -f corevia

# Check status
sudo supervisorctl status

# Update code (if using Git)
git pull && pip install -r requirements.txt && alembic upgrade head
sudo supervisorctl restart corevia
```

---

## 📱 Test After Deployment

### Backend
```bash
curl https://api.corevia.life/
# Should return: {"message": "CoreVia API"}
```

### iOS App
1. Build in Release mode
2. Login: `testmuellim@demo.com` / `demo123`
3. Test chat, workouts, profile
4. ✅ Works!

---

## 🆘 Need Help?

1. **Check logs:**
   ```bash
   sudo supervisorctl tail -f corevia
   sudo tail -f /var/log/nginx/error.log
   ```

2. **Read guides:**
   - `HETZNER_DEPLOYMENT.md` - Full deployment
   - `DNS_SETUP.md` - DNS issues
   - `DEPLOYMENT.md` - General info

3. **Common issues:**
   - 502 Bad Gateway → Backend not running
   - 404 Not Found → DNS not propagated
   - 500 Error → Check logs
   - CORS error → Check .env CORS_ORIGINS

---

## ✨ You're Ready to Deploy!

Follow `HETZNER_DEPLOYMENT.md` step-by-step and you'll be live in 30 minutes! 🚀

**Domain:** corevia.life ✅
**Backend:** Ready ✅
**iOS App:** Ready ✅
**Deployment Scripts:** Ready ✅

Good luck! 💪
