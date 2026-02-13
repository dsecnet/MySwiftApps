# CoreVia Backend - Deployment Guide

## 🚀 Railway Deployment (Recommended)

### 1. Prerequisites
- Railway account (https://railway.app)
- GitHub account
- Domain: corevia.life

### 2. Deploy to Railway

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Initialize project
railway init

# Link to GitHub (optional but recommended)
railway link

# Add PostgreSQL database
railway add
# Select PostgreSQL from the list

# Deploy
railway up
```

### 3. Configure Environment Variables

Railway Dashboard → Variables → Add all:

```env
# Database (Auto-configured by Railway)
DATABASE_URL=postgresql+asyncpg://...

# JWT
SECRET_KEY=<generate-strong-secret-key>
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# CORS
CORS_ORIGINS=https://api.corevia.life,https://corevia.life

# App
APP_NAME=CoreVia API
DEBUG=False

# AWS S3 (optional - for file uploads)
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
AWS_BUCKET_NAME=corevia-uploads
AWS_REGION=eu-central-1

# OpenAI (optional - for AI features)
OPENAI_API_KEY=your-openai-key

# Redis (optional - can add from Railway)
REDIS_URL=redis://...
```

### 4. Custom Domain Setup

#### In Railway:
1. Go to Settings → Domains
2. Click "Add Custom Domain"
3. Enter: `api.corevia.life`
4. Railway will give you a CNAME record

#### In Your Domain Provider (GoDaddy/Namecheap):
1. Go to DNS Management
2. Add CNAME record:
   ```
   Type: CNAME
   Name: api
   Value: <Railway-provided-URL>
   TTL: 3600
   ```
3. Save and wait 5-30 minutes for DNS propagation

### 5. SSL Certificate
Railway automatically provides SSL certificate for custom domains.
Your API will be accessible at: `https://api.corevia.life`

### 6. Verify Deployment

```bash
# Test health endpoint
curl https://api.corevia.life/

# Test API docs
https://api.corevia.life/docs
```

---

## 🔧 Alternative: DigitalOcean App Platform

### 1. Create App
- Go to DigitalOcean → Apps → Create App
- Connect GitHub repository
- Select branch: `main`

### 2. Configure Build
- Build Command: (auto-detected)
- Run Command: `uvicorn app.main:app --host 0.0.0.0 --port 8080`

### 3. Add Database
- Add PostgreSQL database component
- DigitalOcean will auto-configure DATABASE_URL

### 4. Environment Variables
Same as Railway (see above)

### 5. Custom Domain
- Settings → Domains → Add Domain
- Point DNS to DigitalOcean nameservers

---

## 📱 iOS App Configuration

After deployment, update iOS app:

**File:** `CoreVia/Services/APIService.swift`

```swift
#if DEBUG
let baseURL = "http://localhost:8000"  // Development
#else
let baseURL = "https://api.corevia.life"  // Production ✅
#endif
```

Build app in **Release mode** for production:
```bash
# In Xcode:
Product → Scheme → Edit Scheme → Run → Build Configuration → Release
```

---

## 🔐 Security Checklist

- ✅ Strong SECRET_KEY generated
- ✅ DEBUG=False in production
- ✅ HTTPS enabled (SSL certificate)
- ✅ CORS configured properly
- ✅ Database credentials secured
- ✅ API keys in environment variables (not in code)
- ✅ Rate limiting enabled
- ✅ Input sanitization middleware active

---

## 📊 Monitoring

### Railway:
- Dashboard → Metrics
- View logs: `railway logs`
- Monitor CPU, Memory, Network

### Health Check:
```bash
# Check if API is running
curl https://api.corevia.life/
```

---

## 🐛 Troubleshooting

### Deploy Failed
```bash
# Check logs
railway logs

# Redeploy
railway up --detach
```

### Database Connection Error
- Verify DATABASE_URL in environment variables
- Check PostgreSQL is running in Railway

### CORS Error from iOS
- Verify CORS_ORIGINS includes your domain
- Check if HTTPS is properly configured

---

## 📝 Post-Deployment Tasks

1. ✅ Test all API endpoints
2. ✅ Run database migrations
3. ✅ Create demo/test users
4. ✅ Test iOS app connection
5. ✅ Monitor logs for errors
6. ✅ Set up automated backups (Railway/DO)

---

## 🔄 CI/CD (Optional)

Railway auto-deploys on git push if GitHub connected:
```bash
git add .
git commit -m "Update API"
git push origin main
# Railway automatically deploys! 🚀
```

---

## 💰 Cost Estimate

### Railway (Hobby Plan)
- Free tier: $5 credit/month
- PostgreSQL: ~$5/month
- App: Pay as you go
- **Total: ~$10-15/month**

### DigitalOcean
- Basic App: $5/month
- Database: $15/month
- **Total: ~$20/month**

---

## 📞 Support

Issues? Check:
1. Railway/DO logs
2. Environment variables
3. DNS propagation (nslookup api.corevia.life)
4. SSL certificate status

---

**🎉 Backend hazır! İndi iOS app deploy edə bilərsən!**
