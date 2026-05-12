# Customer Deployment Guide — Bagour Delivery

## Scenario A — العميل عنده infrastructure

### يقدمه العميل
- VPS (4 vCPU / 8 GB RAM / 160 GB SSD recommended)
- Domain + DNS
- MongoDB 7 instance
- Redis (optional, recommended)
- Google Cloud account للـ Maps API
- Firebase project للـ FCM + Auth
- Paymob account
- Cloudinary account
- Apple Developer + Google Play Console accounts

### نقدمه نحن
- ✅ كل الـ source code (backend + 3 Flutter apps + 2 dashboards)
- ✅ docker-compose.prod.yml
- ✅ env.example مع شرح
- ✅ Migration + seed scripts
- ✅ Postman collection
- ✅ 90-min Zoom deployment session
- ✅ Training (4-12 hours حسب الـ tier)
- ✅ Flutter app builds (signed AAB / IPA)
- ✅ Branding customization

### Timeline (7 أيام)
| اليوم | النشاط |
|------|--------|
| 1 | VPS + DNS + TLS + Mongo + backend |
| 2 | Dashboards deploy + first admin user |
| 3-4 | Flutter app builds + Play Store / App Store submit |
| 5 | Zones + restaurants onboarding |
| 6 | Drivers onboarding + training |
| 7 | Soft launch |

---

## Scenario B — إحنا اللي بنشتري ونجهز

### يقدمه العميل
- بيانات الشركة + شعار
- domain (لو موجود)
- بيانات المدير الرئيسي

### نقدمه نحن (شامل في Pro tier)
- ✅ كل اللي في Scenario A
- ✅ VPS purchase (DigitalOcean / Hetzner)
- ✅ MongoDB Atlas managed (M10 cluster)
- ✅ Firebase project (paid Blaze plan setup)
- ✅ Cloudinary account
- ✅ Paymob integration + KYC verification
- ✅ Google Cloud + Maps API setup
- ✅ Apple Developer enrollment ($99/year — pass-through)
- ✅ Google Play Console ($25 one-time — pass-through)
- ✅ Initial 5 restaurants onboarding

### تكاليف infra (Scenario B)
| البند | شهرياً |
|------|-------|
| VPS (4vCPU/8GB) | $40 |
| MongoDB Atlas M10 | $60 |
| Redis Cloud | $7 |
| Cloudinary (Plus) | $99 |
| Google Maps API (first 200K requests free) | varies |
| Firebase Blaze | minimal till scale |
| SMS via Vonage | per-OTP cost |
| **Total typical** | **$200-300** |

---

## Compliance + Security

- 🔒 TLS 1.2/1.3 + HSTS
- 🔒 JWT + refresh rotation
- 🔒 bcrypt 12 rounds + Firebase Auth
- 🔒 CSRF protection
- 🔒 NoSQL injection sanitization (Express-5-compatible)
- 🔒 Rate limiting per role
- 🔒 Audit logging
- 🔒 Daily MongoDB backups
- 🔒 PCI compliance: Paymob handles card data; we don't store PANs
- 🔒 GDPR: data processor; we sign DPA on request

---

## التسليم
1. HANDOVER-CHECKLIST.md signed
2. Source archive ZIP
3. Build artifacts (AAB + IPA + Docker images)
4. Documentation pack
5. Login credentials handover
6. First-month support
