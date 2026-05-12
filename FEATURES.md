# Features Inventory — Bagour Delivery

Legend: ✅ ships / 🟡 caveat / 🔵 optional / ⛔ out of scope

---

## Customer App
| Feature | Status | Notes |
|---------|:------:|-------|
| Phone + OTP registration | ✅ | Vonage SMS |
| Email + password login | ✅ | bcrypt 12 rounds |
| Browse restaurants by zone | ✅ | |
| Filter by cuisine / rating / price | ✅ | |
| Menu with images + descriptions | ✅ | Arabic + English |
| Cart with quantity + notes | ✅ | |
| Order placement | ✅ | |
| Real-time driver tracking | ✅ | Socket.io + Google Maps |
| Push notifications | ✅ | FCM |
| Order history + reorder | ✅ | |
| Reviews + ratings | ✅ | per restaurant + per driver |
| Coupon code redemption | ✅ | |
| Loyalty points | 🔵 | basic tier |
| Multiple addresses | ✅ | |
| Multiple payment methods (cash / card / wallet) | 🟡 | cash + Paymob card; wallet in Enterprise |
| Bilingual AR/EN | ✅ | |

## Restaurant App / Dashboard
| Feature | Status | Notes |
|---------|:------:|-------|
| Order queue real-time | ✅ | sound notification |
| Accept / reject orders | ✅ | with prep time |
| Menu CRUD | ✅ | images via Cloudinary |
| Categories + sections | ✅ | |
| Schedule (opening hours) | ✅ | |
| Earnings dashboard | ✅ | daily / weekly / monthly |
| Payout requests | ✅ | |
| Analytics (top items, busy hours) | ✅ | |
| Multi-branch support | 🔵 | Enterprise add-on |
| Insurance integration | 🔵 | Enterprise |

## Driver App
| Feature | Status | Notes |
|---------|:------:|-------|
| Online / offline toggle | ✅ | |
| Order acceptance window (30s) | ✅ | |
| Pickup + delivery navigation | ✅ | Google Maps deep-link |
| Order status updates | ✅ | |
| Earnings + payout history | ✅ | |
| Push notifications | ✅ | FCM |
| Driver rating | ✅ | |
| KYC document upload | ✅ | Cloudinary |
| Geofencing for pickup zone | 🟡 | basic; advanced = Enterprise |

## Admin Dashboard
| Feature | Status | Notes |
|---------|:------:|-------|
| Restaurants management (approve/suspend) | ✅ | |
| Drivers management (approve/suspend) | ✅ | |
| Orders monitoring real-time | ✅ | |
| Customers management | ✅ | |
| Zones + delivery fees config | ✅ | |
| Coupons / promotions | ✅ | |
| Payouts management | ✅ | restaurants + drivers |
| Platform analytics (orders, revenue, top performers) | ✅ | |
| Reports + CSV export | ✅ | |
| Notification broadcasts | 🟡 | per-segment broadcasts in Enterprise |

## Backend
| Feature | Status | Notes |
|---------|:------:|-------|
| 120+ REST endpoints | ✅ | full Postman collection |
| Socket.io real-time events | ✅ | per-role rooms |
| JWT auth + refresh rotation | ✅ | |
| Firebase Auth integration | ✅ | conditional init when creds present |
| Paymob payment integration | ✅ | webhook handling included |
| Cloudinary image uploads | ✅ | |
| Google Maps geocoding | ✅ | |
| Rate limiting per route | ✅ | IPv6-safe |
| CSRF + helmet + sanitize | ✅ | Express-5 compatible |
| Audit logging | ✅ | |
| Daily MongoDB backup script | ✅ | |
| Health endpoint | ✅ | /health and /api/v1/health |

## Out of Scope
| Feature | Why |
|---------|-----|
| Subscription / monthly billing for customers | Different product; ad-hoc orders only |
| Inventory management for restaurants | Use a dedicated POS like the pharmacy/clinic systems |
| Driver dispatch optimization (AI routing) | Enterprise add-on with custom development |
| Group orders | Not in current roadmap |
| Scheduled deliveries | Q3 2026 roadmap |
