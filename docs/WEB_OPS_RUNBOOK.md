# Web Apps Ops Runbook

Operations guide for the Bagour Delivery PWAs (`customer-web` and
`driver-web`). For app-internal architecture, see `WEB_MIGRATION_PLAN.md`.

## Topology

| Service | Image | Container port | Host port (dev) |
|---|---|---|---|
| MongoDB | `mongo:7` | 27017 | 27021 |
| Backend (Express) | `./backend/Dockerfile` | 5000 | 5000 |
| restaurant-dashboard | `./restaurant-dashboard/Dockerfile` | 3000 | 3001 |
| admin-dashboard | `./admin-dashboard/Dockerfile` | 3000 | 3002 |
| **customer-web** | `./customer-web/Dockerfile` | 3000 | **3000** |
| **driver-web** | `./driver-web/Dockerfile` | 3001 | **3010** |

All services share the `bagour-network` Docker bridge. Internal
service-to-service calls use the service names as DNS (e.g. `http://backend:5000`).

## First-time setup

1. Copy env templates:
   ```bash
   cp .env.example .env
   cp customer-web/.env.local.example customer-web/.env.local
   cp driver-web/.env.local.example driver-web/.env.local
   ```
2. Fill in the required secrets in `.env` (see "Environment variables" below).
3. Build + start the full stack:
   ```bash
   docker compose up -d --build
   ```
4. Verify health:
   - http://localhost:5000/health — backend
   - http://localhost:3000 — customer-web
   - http://localhost:3010 — driver-web

## Local development (no Docker)

Both web apps run independently against a backend you've already started:

```bash
# Backend
cd backend && pnpm dev   # listens on :5000

# Customer web
cd customer-web && pnpm dev   # listens on :3000

# Driver web
cd driver-web && pnpm dev     # listens on :3001 (note: not 3010 — that's the docker host port)
```

Each web app reads its own `.env.local`. The two apps can run side-by-side
without auth-store collision because they persist to different localStorage
keys (`bagour-auth` vs `bagour-driver-auth`).

## Environment variables

### Required (`.env`, used by `docker-compose.yml`)

| Var | Used by | Purpose |
|---|---|---|
| `MONGO_USERNAME` / `MONGO_PASSWORD` | mongodb, backend | DB credentials |
| `JWT_ACCESS_SECRET` / `JWT_REFRESH_SECRET` | backend | Auth signing |
| `CLOUDINARY_CLOUD_NAME` / `CLOUDINARY_API_KEY` / `CLOUDINARY_API_SECRET` | backend | Image uploads (avatars, KYC, delivery proof) |
| `FIREBASE_PROJECT_ID` | backend | Phone OTP (optional today) |
| `PAYMOB_API_KEY` / `PAYMOB_INTEGRATION_ID` / `PAYMOB_HMAC_SECRET` | backend | Card payments |

### Optional (`.env`)

| Var | Default | Purpose |
|---|---|---|
| `API_URL` | `http://localhost:5000` | Browser-facing backend URL (set this for prod domains) |
| `CUSTOMER_WEB_URL` | `http://localhost:3000` | OG/metadata base for customer-web |
| `DRIVER_WEB_URL` | `http://localhost:3010` | OG/metadata base for driver-web |
| `MAP_TILE_URL` | OSM public tiles | Raster tile template URL for the driver map |
| `OSRM_URL` | Public OSRM demo | Routing endpoint for driver pickup/delivery polylines |

### Per-app `.env.local`

Each `*.env.local.example` documents the app-specific vars. The keys are
`NEXT_PUBLIC_*`-prefixed so Next.js inlines them at build time.

## Building only the webs

```bash
docker compose build customer-web driver-web
docker compose up -d customer-web driver-web
```

## Logs / debugging

```bash
docker compose logs -f customer-web
docker compose logs -f driver-web
docker compose logs -f backend
```

## Common issues

- **CORS errors in the browser console** — the backend allow-list must
  include the customer-web and driver-web origins. Update
  `backend/src/config/cors.ts` to include `CUSTOMER_WEB_URL` and
  `DRIVER_WEB_URL` (Phase 8 backend extension).
- **Cookies not setting on cross-origin requests** — refresh tokens ride
  in an httpOnly cookie. Ensure the backend sets `SameSite=None; Secure`
  for production HTTPS deployments.
- **Service worker stuck on an old version** — visit `/sw.js` directly
  and confirm the precache manifest hash changed; if not, the build was
  cached. Re-build with `docker compose build --no-cache <service>`.
- **Driver map shows tiles but no route** — public OSRM demo is
  rate-limited and may return 429. Self-host OSRM with the Egypt extract
  or swap providers via `OSRM_URL`.

## Production hardening checklist

Production deployments should layer on:

- TLS termination via nginx/caddy reverse proxy with `Strict-Transport-Security`
  (the apps already emit it but only matter behind HTTPS)
- Per-origin `Content-Security-Policy` headers — currently set at the
  Next.js header level; for a stricter nonce-based policy use middleware
- Rate limits in front of the backend (`/api/v1/auth/*`, `/upload/*`)
- A CDN in front of the `_next/static/*` assets for the two PWAs
- Real domain certificates for the manifest `start_url` so PWA install
  works without browser warnings

## Rollback

```bash
docker compose down customer-web driver-web
# Re-tag a previous image and bring back up:
docker tag bagour/customer-web:previous bagour/customer-web:latest
docker compose up -d customer-web driver-web
```
