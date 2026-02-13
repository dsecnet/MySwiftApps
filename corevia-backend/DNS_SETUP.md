# 🌐 DNS Setup Guide - corevia.life

## Domain Provider-də (GoDaddy/Namecheap/Cloudflare)

Hetzner server-in IP ünvanını tapandan sonra (məsələn: `95.217.123.45`), domain provider-də bu DNS record-ları əlavə et:

### A Records

```
Type: A
Name: api
Value: 95.217.123.45  (Hetzner server IP-n)
TTL: 3600
```

```
Type: A
Name: @
Value: 95.217.123.45  (same IP)
TTL: 3600
```

```
Type: A
Name: www
Value: 95.217.123.45  (same IP)
TTL: 3600
```

### CNAME Records (optional - subdomain redirects)

```
Type: CNAME
Name: app
Value: api.corevia.life
TTL: 3600
```

## Nəticə

5-30 dəqiqə sonra DNS propagate olacaq və bu URL-lər işləyəcək:

- ✅ `https://api.corevia.life` → Backend API
- ✅ `https://corevia.life` → Main domain (future web app)
- ✅ `https://www.corevia.life` → Same as above

## DNS Yoxlama

```bash
# Check if DNS is working
nslookup api.corevia.life

# Or
dig api.corevia.life

# Or online
https://dnschecker.org/#A/api.corevia.life
```

## SSL Certificate

Deployment script avtomatik Let's Encrypt SSL certificate yaradacaq.
HTTPS avtomatik olacaq! 🔒

---

**Important:** DNS propagation 5-30 dəqiqə çəkir. Tələsməyin!
