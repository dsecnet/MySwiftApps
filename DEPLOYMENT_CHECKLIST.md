# 🚀 CoreVia Deployment Checklist

## 📋 Complete Deployment Guide

---

## PHASE 1: Backend Deployment ⚙️

### ☐ 1. Prepare Backend
```bash
cd /Users/vusaldadashov/Desktop/ConsoleApp/corevia-backend
```

### ☐ 2. Install Railway CLI
```bash
npm i -g @railway/cli
railway login
```

### ☐ 3. Deploy to Railway
```bash
railway init
railway add  # Select PostgreSQL
railway up
```

### ☐ 4. Configure Environment Variables
In Railway Dashboard → Variables, add:
```env
SECRET_KEY=<generate-strong-random-key>
CORS_ORIGINS=https://api.corevia.life,https://corevia.life
DEBUG=False
```

### ☐ 5. Add Custom Domain
1. Railway → Settings → Domains → Add Domain
2. Enter: `api.corevia.life`
3. Copy CNAME value

### ☐ 6. Configure DNS
In your domain provider (GoDaddy/Namecheap):
```
Type: CNAME
Name: api
Value: <Railway CNAME>
TTL: 3600
```

### ☐ 7. Verify Backend
```bash
curl https://api.corevia.life/
# Should return: {"message": "CoreVia API"}
```

**✅ Backend DONE!**

---

## PHASE 2: iOS App Deployment 📱

### ☐ 1. Configure Xcode
1. Open CoreVia.xcodeproj
2. Xcode → Settings → Accounts → Add Apple ID
3. Project → Signing & Capabilities
4. ✅ Automatically manage signing
5. Select Team (your Apple ID)
6. Change Bundle ID: `com.YOURNAME.corevia`

### ☐ 2. API Already Configured ✅
File: `CoreVia/Services/APIService.swift`
```swift
#if DEBUG
let baseURL = "http://localhost:8000"
#else
let baseURL = "https://api.corevia.life"  // ✅ Already set!
#endif
```

### ☐ 3. Connect iPhone
1. USB cable → Connect iPhone
2. Unlock iPhone
3. Trust This Computer
4. Xcode → Select your iPhone (not Simulator)

### ☐ 4. Build & Run
```bash
# In Xcode:
Cmd+Shift+K  # Clean
Cmd+B        # Build
Cmd+R        # Run
```

### ☐ 5. Trust Developer (First Time)
iPhone: Settings → General → VPN & Device Management → Trust

**✅ iOS App DONE!**

---

## PHASE 3: Testing 🧪

### ☐ Backend Tests
```bash
# Test health endpoint
curl https://api.corevia.life/

# Test API docs (if DEBUG=True)
open https://api.corevia.life/docs

# Test auth
curl -X POST https://api.corevia.life/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"testmuellim@demo.com","password":"demo123"}'
```

### ☐ iOS App Tests
1. ✅ Login with demo account (testmuellim@demo.com / demo123)
2. ✅ Browse trainers
3. ✅ Join a trainer
4. ✅ Send message in chat
5. ✅ View workouts
6. ✅ Check premium features
7. ✅ Test profile page
8. ✅ Test logout

**✅ All Tests DONE!**

---

## PHASE 4: App Store (Optional) 🏪

### ☐ Prerequisites
- Apple Developer Program ($99/year)
- App Store Connect access

### ☐ Steps
1. Product → Archive
2. Distribute App → App Store Connect
3. Upload to TestFlight
4. Add testers
5. Submit for App Store Review

**✅ App Store DONE!**

---

## 📊 Final Verification

### Backend Checklist
- ✅ API accessible at https://api.corevia.life
- ✅ HTTPS/SSL enabled
- ✅ Database connected
- ✅ CORS configured
- ✅ Environment variables set
- ✅ Logs monitored

### iOS Checklist
- ✅ App installed on real iPhone
- ✅ Connects to production API
- ✅ All features working
- ✅ No crashes
- ✅ UI looks good
- ✅ Performance smooth

### Domain Checklist
- ✅ api.corevia.life points to Railway
- ✅ SSL certificate active
- ✅ DNS propagated (check: `nslookup api.corevia.life`)

---

## 🎯 Quick Commands Reference

### Backend
```bash
# Deploy
cd corevia-backend && railway up

# Check logs
railway logs

# Open dashboard
railway open
```

### iOS
```bash
# Open project
open CoreVia.xcodeproj

# Clean
Cmd+Shift+K

# Build & Run
Cmd+R
```

### DNS Check
```bash
# Check if domain resolves
nslookup api.corevia.life

# Test API
curl https://api.corevia.life/
```

---

## 🐛 Common Issues & Fixes

### Backend not responding
```bash
railway logs  # Check errors
railway restart  # Restart service
```

### DNS not resolving
```bash
# Wait 5-30 minutes for propagation
# Check with: nslookup api.corevia.life
```

### iOS build failed
```bash
# Clean build
Cmd+Shift+K
# Remove DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### CORS error from iOS
```bash
# Check Railway env vars:
CORS_ORIGINS=https://api.corevia.life
```

---

## 📞 Support

### Railway
- Dashboard: railway.app
- Logs: `railway logs`
- Docs: docs.railway.app

### Xcode
- Clean: Cmd+Shift+K
- Build: Cmd+B
- Run: Cmd+R
- Stop: Cmd+.

### Domain
- Check DNS: `nslookup api.corevia.life`
- Check SSL: `curl -I https://api.corevia.life`

---

## 🎉 Success Criteria

✅ Backend API live at https://api.corevia.life
✅ iOS app installed on iPhone
✅ App connects to production backend
✅ Demo login works (testmuellim@demo.com)
✅ Chat functionality works
✅ No crashes or errors

---

## 💡 Next Steps After Deployment

1. Monitor Railway logs for errors
2. Test all features thoroughly
3. Add more demo users
4. Create backup strategy
5. Set up automated deployments (git push → auto deploy)
6. Configure push notifications (optional)
7. Add analytics tracking (optional)
8. Submit to App Store (when ready)

---

**🚀 DEPLOYMENT COMPLETE! CoreVia is LIVE! 🎊**

Backend: https://api.corevia.life
iOS App: On your iPhone

Əla iş! 💪
