# Changelog

All notable changes are recorded here. Dates are absolute (YYYY-MM-DD).

## 2026-05-14 — Web migration complete

Replaces the Flutter customer and driver apps with two web PWAs. The Flutter
sources were removed from the repo (recoverable via `git log -- customer-app/`).

### Added

#### customer-web (Next.js 16 PWA — `:3000`)

- Locale routing (AR/EN) with full RTL support and Cairo type
- Auth — login, register, OTP verify, forgot/reset password
- Profile — edit profile, change password, addresses CRUD
- Restaurants — featured row, infinite search/filter grid
- Menu — restaurant detail, item modal with options + addons + quantity
- Cart — drawer + header badge + cross-restaurant switch confirmation
- Checkout — address picker, payment radios, coupon validation, place order
- Order tracking — `/orders/[id]` with 15 s polling timeline + cancel
- Order history — `/orders` with status pills
- **Rate-your-order** — 5-star RadioGroup for restaurant / food / driver / overall + comment
- **Reorder** — one-tap re-create cart from a delivered order
- PWA — manifest, service worker, install prompt, offline-aware caching
- Lighthouse CI budget (perf ≥ 0.85, a11y ≥ 0.95, best-practices ≥ 0.9)
- `/api/health` liveness probe
- `error.tsx` / `loading.tsx` / `global-error.tsx` route boundaries
- robots + sitemap with hreflang AR/EN alternates
- Bundle analyzer (`pnpm analyze`)

#### driver-web (Next.js 16 PWA — `:3001` dev / `:3010` Docker)

- Locale routing + RTL (mirrors customer-web stack)
- Auth — driver register (role forced server-side), login (rejects non-driver), OTP, forgot/reset
- Onboarding — vehicle profile + KYC document uploads (national ID, license) to Cloudinary
- Online / offline toggle — `POST /driver/online` + Screen Wake Lock + geolocation stream (debounced 5 s / thresholded 25 m)
- Available orders feed — 8 s poll while online
- 30 s acceptance modal — countdown + vibration
- Order detail — 6-stage status timeline + lifecycle CTAs (pickup → on-the-way → delivered)
- Delivery proof — camera capture → Cloudinary upload → forwarded to `markDelivered`
- **MapLibre + OSRM** route map on order detail with driver/destination markers + polyline + ETA
- Earnings dashboard — totals + day-grouped history
- Profile — vehicle + KYC re-upload routes back to onboarding
- PWA + install prompt
- E2E smoke tests (nav, auth, ProtectedRoute)
- `/api/health`, error/loading boundaries, robots (denies all)

#### Workspace + infra

- pnpm workspaces + Turborepo
- Shared packages: `@bagour/types`, `@bagour/api-client` (axios + MSW), `@bagour/config-{eslint,tailwind,tsconfig}`
- GitHub Actions: lint, typecheck, unit/component, Playwright on chromium/firefox/webkit/mobile, Lighthouse CI, CodeQL, semgrep, dependency-review, Dependabot
- Multi-stage Dockerfiles for both PWAs (`output: "standalone"`, ~50 MB runtime images, non-root user, HEALTHCHECK)
- docker-compose entries with port mapping (3000 customer, 3010 driver)
- `docs/WEB_OPS_RUNBOOK.md` — env vars, common issues, production hardening checklist

### Removed

- `customer-app/` (Flutter)
- `delivery-app/` (Flutter)
- `restaurant-app/` (Flutter)

### Known follow-ups

Tracked in [`WEB_MIGRATION_PLAN.md`](WEB_MIGRATION_PLAN.md):

- **Backend Phase 8** — dedicated `GET /driver/orders/{id}` endpoint, web push VAPID, CORS allow-list for the new web origins, rate-limit profiles per role
- **Driver onboarding** — extend register payload to accept `{nationalId, licenseNumber, dateOfBirth, vehicleType, licenseExpiryDate}` (currently the Driver record is created with empty fields and filled in via admin tools)
- Customer web push subscription UI (depends on backend VAPID)
- Loyalty redemption UI
- Map-based address picker for customer-web
- Self-hosted OSRM with Egypt extract (public demo is rate-limited)
- TLS reverse proxy + nonce-based CSP for production
