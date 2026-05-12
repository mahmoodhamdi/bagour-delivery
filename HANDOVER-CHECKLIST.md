# Handover Checklist — Bagour Delivery

**Project**: Bagour Delivery Platform
**Client**: ___________________________
**Delivery date**: ____ / ____ / ______
**Tier**: ☐ Starter / ☐ Pro / ☐ Enterprise

---

## 1. Infrastructure
- [ ] VPS provisioned (4 vCPU / 8 GB RAM / 160 GB SSD)
- [ ] Ubuntu 22.04 / 24.04 patched
- [ ] Firewall (ufw) + Fail2ban
- [ ] Timezone Africa/Cairo

## 2. Domain + TLS
- [ ] DNS A record
- [ ] Wildcard or per-subdomain Let's Encrypt
- [ ] HSTS + HTTPS redirect

## 3. Backend (Node + Express + MongoDB)
- [ ] Node 20+
- [ ] MongoDB 7+ running
- [ ] Redis 7+ running
- [ ] `.env` populated (NOT defaults)
- [ ] JWT secrets random 32+ chars
- [ ] Firebase service account key in place
- [ ] Paymob keys configured
- [ ] Cloudinary keys configured
- [ ] Google Maps API key configured
- [ ] `npm ci` + `npm run build` succeeded
- [ ] systemd service for backend
- [ ] /health returns 200
- [ ] /api/v1/health returns 200

## 4. Dashboards (Next.js 16)
- [ ] Restaurant dashboard built + running
- [ ] Admin dashboard built + running
- [ ] systemd or PM2 services
- [ ] Nginx reverse-proxy with subdomains
- [ ] NEXT_PUBLIC_API_URL set to production backend
- [ ] CORS_ORIGIN updated on backend to include dashboard URLs

## 5. Flutter Apps
- [ ] Flutter SDK 3.6.2+ installed on build machine
- [ ] Customer app: `flutter build appbundle --release` succeeded
- [ ] Driver app: `flutter build appbundle --release` succeeded
- [ ] Restaurant app: `flutter build appbundle --release` succeeded
- [ ] iOS builds: `flutter build ipa --release` (if iOS in scope)
- [ ] Apple Developer enrollment active
- [ ] Google Play Console set up
- [ ] Internal testing track uploaded
- [ ] App-store screenshots prepared

## 6. Seeded Data
- [ ] Admin user created (NOT demo seeder)
- [ ] Zones for service area configured
- [ ] Delivery fees per zone set
- [ ] Initial 5 restaurants invited (email)
- [ ] Initial 10 drivers invited

## 7. Integrations
- [ ] Firebase project created (Auth + FCM)
- [ ] FCM tokens stored on backend
- [ ] Paymob test transactions succeeded
- [ ] Production Paymob keys verified
- [ ] Cloudinary upload preset configured
- [ ] Google Maps quota verified

## 8. Security
- [ ] composer/npm audit clean
- [ ] No `.env` files committed
- [ ] Default admin password CHANGED
- [ ] Rate limiting verified
- [ ] CSRF verified on dashboards

## 9. Monitoring
- [ ] Uptime monitor (Better Uptime / UptimeRobot)
- [ ] Log aggregation (Loki / Datadog) — optional
- [ ] Backup cron + S3 sync
- [ ] Alert email/SMS configured

## 10. Training
- [ ] Admin training (60 min, recorded)
- [ ] Restaurant onboarding flow (30 min, recorded)
- [ ] Driver onboarding flow (30 min, recorded)
- [ ] Operator quick-reference one-pager

## 11. Documentation
- [ ] README + DEPLOYMENT.md + API documentation shared
- [ ] FIREBASE_AUTH_SETUP.md shared
- [ ] SUPPORT-PLANS.md signed
- [ ] This checklist signed
- [ ] Postman collection delivered

## 12. Legal + Commercial
- [ ] MSA signed
- [ ] DPA signed (if EU/UK)
- [ ] Payment received
- [ ] Next invoice schedule confirmed

## 13. 48h go/no-go
- [ ] Test customer registers + verifies OTP
- [ ] Test customer places order
- [ ] Test restaurant accepts order
- [ ] Test driver picks up + delivers
- [ ] Test customer receives + reviews
- [ ] Test admin sees in dashboard
- [ ] Test payout flow
- [ ] Backup ran overnight
- [ ] Uptime monitor green for 48h

---

**Client**: ____________________  Date: ____ / ____ / ______
**Developer**: Mahmoud Hamdy — Date: ____ / ____ / ______
