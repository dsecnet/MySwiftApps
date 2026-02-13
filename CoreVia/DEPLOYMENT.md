# CoreVia iOS App - Deployment Guide

## 📱 Deploy to Real iPhone (USB)

### 1. Prerequisites
- ✅ Mac with Xcode installed
- ✅ iPhone with USB Lightning cable
- ✅ Apple ID (free Developer Account)
- ✅ Backend deployed at `https://api.corevia.life`

---

## 🔧 Step-by-Step Deployment

### Step 1: Configure Apple Developer Account

1. **Open Xcode** → **Settings** (Cmd+,)
2. Go to **Accounts** tab
3. Click **"+"** button
4. Sign in with your **Apple ID**
5. Click **Manage Certificates** → **"+"** → **iOS Development**

### Step 2: Configure Project Signing

1. Open `CoreVia.xcodeproj` in Xcode
2. Click **CoreVia** project (blue icon) in Navigator
3. Select **CoreVia** under **TARGETS**
4. Go to **Signing & Capabilities** tab
5. ✅ Check **"Automatically manage signing"**
6. Select your **Team** (Apple ID)
7. **Change Bundle Identifier** to unique:
   ```
   Original: com.corevia.app
   Change to: com.YOURNAME.corevia
   ```
   Example: `com.vusal.corevia`

### Step 3: Connect iPhone

1. Connect iPhone via **USB Lightning cable**
2. Unlock iPhone
3. Tap **"Trust This Computer"** on iPhone
4. Enter iPhone passcode

### Step 4: Select Device

1. In Xcode toolbar (top), click **device selector**
2. Select your **iPhone** (not Simulator!)
3. Example: "Vusal's iPhone"

### Step 5: Configure API URL (Production)

**File:** `CoreVia/Services/APIService.swift`

Already configured! ✅
```swift
#if DEBUG
let baseURL = "http://localhost:8000"  // Development
#else
let baseURL = "https://api.corevia.life"  // Production
#endif
```

### Step 6: Build & Run

1. **Clean Build Folder:** Product → Clean Build Folder (Cmd+Shift+K)
2. **Build:** Product → Build (Cmd+B)
3. **Run on iPhone:** Product → Run (Cmd+R) or click ▶️ button

### Step 7: Trust Developer on iPhone

First time only:
1. App will install but won't open
2. On iPhone: **Settings** → **General** → **VPN & Device Management**
3. Find **Developer App** section
4. Tap your Apple ID email
5. Tap **"Trust [Your Apple ID]"**
6. Tap **"Trust"** again in popup
7. Go back and open CoreVia app ✅

---

## 🚀 Deploy to TestFlight (Beta Testing)

### Prerequisites
- Apple Developer Program ($99/year)
- App Store Connect access

### Steps:

1. **Archive App**
   - Product → Archive
   - Wait for build to complete
   - Xcode Organizer will open

2. **Upload to App Store Connect**
   - Click **Distribute App**
   - Select **App Store Connect**
   - Click **Upload**
   - Wait for processing (~5-10 minutes)

3. **Configure TestFlight**
   - Go to App Store Connect
   - Select CoreVia app
   - Go to **TestFlight** tab
   - Add **Internal Testers** (up to 100)
   - Share **Public Link** for external testers

4. **Install from TestFlight**
   - Testers download TestFlight app from App Store
   - Open invite link
   - Install CoreVia beta

---

## 🏪 Deploy to App Store (Production)

### 1. Prepare App Store Assets

Create in **App Store Connect**:
- App Name: CoreVia
- Category: Health & Fitness
- Screenshots (required sizes):
  - 6.7" (iPhone 14 Pro Max)
  - 6.5" (iPhone 11 Pro Max)
  - 5.5" (iPhone 8 Plus)
- App Icon: 1024x1024px
- Description
- Keywords
- Privacy Policy URL
- Support URL

### 2. App Store Review Information

- Demo Account:
  ```
  Email: testmuellim@demo.com
  Password: demo123
  ```
- Review Notes: "Fitness app with trainer connection"

### 3. Submit for Review

1. Archive & Upload (same as TestFlight)
2. App Store Connect → CoreVia → **App Store** tab
3. Click **"+"** to create new version
4. Fill all required info
5. Select build from TestFlight
6. Click **Submit for Review**
7. Wait 1-3 days for Apple review

---

## 🔐 App Security & Privacy

### Required Privacy Permissions

**Info.plist** already configured with:
- Camera Usage: "Profile photo capture"
- Photo Library: "Upload workout photos"
- Location: "Find nearby trainers"

### App Tracking Transparency (iOS 14.5+)

If using analytics:
```xml
<key>NSUserTrackingUsageDescription</key>
<string>We use tracking to improve your experience</string>
```

---

## 🐛 Troubleshooting

### "Untrusted Developer" Error
- Settings → General → VPN & Device Management → Trust

### Build Failed - Code Signing Error
- Check Apple ID is signed in
- Verify Bundle Identifier is unique
- Try manual signing instead of automatic

### App Crashes on Launch
- Check backend URL is correct: `https://api.corevia.life`
- Verify backend is running
- Check Xcode console for error logs

### "Could Not Launch" Error
- Disconnect & reconnect iPhone
- Clean build folder (Cmd+Shift+K)
- Restart Xcode
- Restart iPhone

### API Connection Failed
- Verify backend deployed: `curl https://api.corevia.life/`
- Check CORS configured correctly
- Ensure HTTPS (not HTTP) in production

---

## 📊 App Analytics & Monitoring

### Crash Reporting (Optional)
Add Firebase Crashlytics:
```bash
# Install via CocoaPods
pod 'Firebase/Crashlytics'
pod 'Firebase/Analytics'
```

### TestFlight Feedback
- Users can submit feedback in TestFlight
- View in App Store Connect → TestFlight → Feedback

---

## 🔄 Update App (New Version)

### 1. Increment Version
In Xcode:
- Select CoreVia project
- TARGETS → CoreVia → General
- **Version:** 1.0.0 → 1.0.1 (bug fixes)
- **Version:** 1.0.0 → 1.1.0 (new features)
- **Build:** Increment by 1

### 2. Update Code
```bash
git add .
git commit -m "Version 1.0.1 - Bug fixes"
git tag v1.0.1
git push origin main --tags
```

### 3. Archive & Upload
Same process as initial deployment

---

## 📱 App Store Optimization (ASO)

### Keywords
```
fitness, health, workout, trainer, nutrition, diet,
exercise, gym, personal trainer, fitness coach
```

### App Name
```
CoreVia - Fitness & Nutrition
```

### Subtitle (30 chars)
```
Your Personal Trainer App
```

### Description Template
```
CoreVia - Your complete fitness and nutrition solution!

🏋️ FEATURES:
• Connect with certified trainers
• Personalized workout plans
• Nutrition tracking
• Progress monitoring
• Chat with your trainer
• Premium workout programs

💪 WHY COREVIA?
• Easy to use interface
• Professional trainers
• Custom meal plans
• Track your progress
• Achieve your fitness goals

📊 PREMIUM FEATURES:
• Unlimited trainer access
• Advanced analytics
• Custom nutrition plans
• Priority support

Download CoreVia today and start your fitness journey! 🚀
```

---

## 🎯 Post-Launch Checklist

- ✅ App live on App Store
- ✅ Backend API running at api.corevia.life
- ✅ Database backups configured
- ✅ Crash reporting enabled
- ✅ Analytics tracking
- ✅ Push notifications configured (optional)
- ✅ Customer support email set up
- ✅ Social media accounts created
- ✅ Marketing materials prepared

---

## 💰 Costs

### Development
- **Free:** Using free Apple ID
- **$99/year:** Apple Developer Program (for App Store)

### Backend
- **~$10-15/month:** Railway/DigitalOcean
- **Optional:** AWS S3 for uploads (~$5/month)

### Domain
- **~$10-15/year:** corevia.life domain

**Total: ~$99/year + $15/month**

---

## 📞 Support Resources

- **Apple Developer Forums:** https://developer.apple.com/forums/
- **App Store Connect Help:** https://help.apple.com/app-store-connect/
- **TestFlight Guide:** https://developer.apple.com/testflight/

---

**🎉 CoreVia iOS app hazır! Uğurlar! 🚀**
