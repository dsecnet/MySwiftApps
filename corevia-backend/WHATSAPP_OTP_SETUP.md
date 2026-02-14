# 📱 WhatsApp OTP - Real Integration Guide

CoreVia forgot password funksiyası üçün WhatsApp OTP konfiqurasiyası.

---

## 🚀 Quick Start (5 dəqiqə)

### 1️⃣ Twilio Account Yarat

1. https://www.twilio.com/try-twilio
2. Sign up (email + phone verify)
3. **$15.50 FREE credit** alacaqsan

### 2️⃣ WhatsApp Sandbox Aktivləşdir

1. Twilio Console-a daxil ol
2. Sol menü: **Messaging** → **Try it out** → **Send a WhatsApp message**
3. WhatsApp Sandbox səhifəsi açılacaq

**Sandbox-a qoşul:**
- WhatsApp-da **+1 415 523 8886** nömrəsini aç
- Mesaj göndər: **`join [kod]`** (kod Twilio console-da göstərilir)
- Məsələn: `join before-stick`
- Cavab: "You are all set!" 🎉

### 3️⃣ Credentials Götür

Twilio Console → **Account Dashboard**:
- **Account SID**: `ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
- **Auth Token**: "Show" düyməsinə bas və kopyala

### 4️⃣ Backend Konfiqurasiya

**Avtomatik yol** (tövsiyə olunur):
```bash
cd /Users/vusaldadashov/Desktop/ConsoleApp/corevia-backend
./setup_twilio.sh
```

**Manual yol:**
`.env` faylını redaktə et:
```bash
# WhatsApp OTP - REAL MODE
WHATSAPP_OTP_MOCK=false

# Twilio Credentials
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_WHATSAPP_FROM=whatsapp:+14155238886
```

### 5️⃣ Backend Restart

```bash
# Local development
lsof -ti:8000 | xargs kill -9
uvicorn app.main:app --reload

# Production (Hetzner)
sudo supervisorctl restart corevia
```

---

## 🧪 Test

**Test script ilə:**
```bash
./test_whatsapp_otp.sh
```

**Manual test:**
```bash
curl -X POST http://localhost:8000/api/v1/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email": "test@corevia.life", "phone_number": "+994559412091"}'
```

WhatsApp-a mesaj gələcək! 🎉

---

## 📝 Sandbox Məhdudiyyətləri

### Sandbox Mode:
- ✅ Pulsuz test
- ✅ Trial credit bitənə qədər işləyir
- ❌ Yalnız "join" etmiş nömrələrə göndərir
- ❌ Twilio branding var

### Production Mode:
- ✅ İstənilən nömrəyə göndər
- ✅ Custom branding
- ❌ Aylıq ödəniş lazım ($50+/ay)
- ❌ Facebook Business Manager qoşulmalı

---

## 💰 Qiymət

**Trial (Sandbox):**
- $15.50 pulsuz credit
- ~3100 mesaj göndərə bilərsən
- Hər mesaj: ~$0.005

**Production:**
- Mesaj qiyməti: $0.005-$0.01
- Aylıq minimum: $50
- Əlavə xərclər: Facebook Business verification

---

## 🔧 Troubleshooting

### Problem: "This number is not enabled for WhatsApp"
**Həll:** Sandbox-a join etməmisən. WhatsApp-da `join [kod]` göndər.

### Problem: "Authentication failed"
**Həll:** Account SID və Auth Token düzgün deyil. Yenidən yoxla.

### Problem: "Twilio credentials not configured"
**Həll:** `.env` faylında credentials mövcud deyil və ya yanlışdır.

### Problem: Mesaj getmir
**Həll 1:** Backend log-a bax: `tail -f backend.log`
**Həll 2:** WHATSAPP_OTP_MOCK=false olduğunu yoxla
**Həll 3:** Backend restart et

---

## 📱 iOS Test

1. iOS app-i run et
2. Login → "Şifrəni unutdunuz?"
3. Email: `test@corevia.life`
4. Phone: `+994559412091` (sandbox-a join etmiş nömrə)
5. "WhatsApp-a OTP Göndər" bas
6. WhatsApp-da kod görünəcək!

---

## 🚀 Production Deployment

Production-da real WhatsApp Business istifadə etmək üçün:

1. **Twilio Business Account** yarat
2. **Facebook Business Manager** qoş
3. **WhatsApp Business Profile** yarad
4. **WhatsApp Business API** aktivləşdir
5. Twilio console-da production number təyin et

**Qeyd:** Bu proses 1-2 həftə çəkə bilər və Facebook tərəfindən təsdiq lazımdır.

---

## 📊 Monitoring

Backend log-da OTP göndərilməsini izlə:

```bash
# Real-time monitoring
tail -f backend.log | grep "WhatsApp OTP"

# Son 50 OTP
grep "WhatsApp OTP" backend.log | tail -50
```

Success mesajı:
```
INFO: WhatsApp OTP sent to +994559412091, SID: SM...
```

---

## ✅ Summary

**Hal-hazırda:**
- ✅ Backend hazırdır (Twilio integrated)
- ✅ iOS app hazırdır (email + phone input)
- ✅ Mock mode işləyir (test üçün)
- ⏳ Real mode üçün Twilio account lazımdır

**Real WhatsApp üçün:**
1. Twilio account yarat (5 dəq)
2. Sandbox aktivləşdir (2 dəq)
3. `.env` konfiqurasiya et (1 dəq)
4. Backend restart (10 san)
5. Test et! 🎉

**Qiymət:** FREE (trial credit bitənə qədər)
**Müddət:** ~8 dəqiqə
**Nəticə:** Real WhatsApp OTP! 📱✨
