# Bagour Delivery — توصيل الباجور

A full-stack food-delivery platform built for Bagour, Monufia, Egypt. Customer + driver web apps, restaurant and admin dashboards, and an Express backend.

---

## Stack

| Component | Tech |
|---|---|
| Backend | Node.js + Express + TypeScript + MongoDB + Socket.IO |
| **Customer web** (Phase 5 migration) | Next.js 16 + React 19 + TypeScript + Tailwind 4 + PWA |
| **Driver web** | Next.js 16 + React 19 + TypeScript + Tailwind 4 + PWA + MapLibre |
| Restaurant dashboard | Next.js + Tailwind + shadcn/ui |
| Admin dashboard | Next.js + Tailwind + shadcn/ui |
| Auth | JWT (access in memory, refresh in httpOnly cookie) + Firebase optional |
| Storage | Cloudinary |
| Routing maps | MapLibre GL + OSRM |
| Payments | Paymob |
| i18n | next-intl v4 — Arabic-first with English, RTL-aware |
| Tests | Vitest + Playwright + axe-core |
| Monorepo | pnpm workspaces + Turborepo |
| Deployment | Docker + docker-compose |

## Workspace layout

```
bagour-delivery/
├── backend/                # Node.js REST + Socket.IO
├── customer-web/           # Next.js 16 PWA — customer-facing (:3000)
├── driver-web/             # Next.js 16 PWA — driver-facing (:3001 dev, :3010 docker)
├── restaurant-dashboard/   # Next.js — restaurant owners (:3001 docker)
├── admin-dashboard/        # Next.js — admin panel (:3002 docker)
├── packages/               # Workspace shared packages
│   ├── @bagour/types       # Shared TS types + Zod schemas
│   ├── @bagour/api-client  # Typed axios client + MSW handlers
│   ├── @bagour/config-eslint
│   ├── @bagour/config-tailwind
│   └── @bagour/config-tsconfig
├── docs/                   # Ops + migration plan
└── docker-compose.yml      # Full stack
```

> **Note**: The Flutter apps (`customer-app`, `delivery-app`, `restaurant-app`) were retired in favor of the web PWAs. They live in git history if you need to revive them — `git log -- customer-app/` shows the last commit before removal.

## Quick start

### Full stack (Docker)

```bash
cp .env.example .env       # fill in secrets — see docs/WEB_OPS_RUNBOOK.md
docker compose up -d --build
```

| App | URL |
|---|---|
| Customer web | http://localhost:3000 |
| Driver web | http://localhost:3010 |
| Restaurant dashboard | http://localhost:3001 |
| Admin dashboard | http://localhost:3002 |
| Backend API | http://localhost:5000 |
| Health checks | `/api/health` on each web app |

### Local dev (no Docker)

```bash
# Install all workspaces
pnpm install

# Start backend
cd backend && pnpm dev   # :5000

# Start customer web
cd customer-web && pnpm dev   # :3000

# Start driver web
cd driver-web && pnpm dev     # :3001
```

The two webs use different localStorage keys (`bagour-auth` vs `bagour-driver-auth`), so they can run side-by-side without auth collision.

## Per-app commands

Each `web` app supports the same Turborepo task surface:

```bash
pnpm dev          # turbopack dev server
pnpm build        # production build (Next.js standalone output)
pnpm analyze      # bundle analyzer (writes to .next/analyze/)
pnpm start        # serve the production build
pnpm lint         # ESLint
pnpm typecheck    # tsc --noEmit
pnpm test         # Vitest unit/component
pnpm test:e2e     # Playwright + axe-core
```

Workspace-wide variants live at the repo root:

```bash
pnpm turbo run build     # all packages
pnpm turbo run test      # all packages
pnpm turbo run lint
```

## Roles

- **Customer** — browses restaurants, places orders, tracks delivery, rates orders, reorders past favorites
- **Driver** — onboards (KYC), goes online with Wake Lock + GPS streaming, accepts orders within a 30 s window, runs lifecycle (pickup → on-the-way → delivered + photo proof), tracks earnings
- **Restaurant owner** — menu management, order acceptance, kitchen workflow (dashboard, not migrated to PWA)
- **Admin** — platform management (dashboard)

## Quality gates

| Tool | Where |
|---|---|
| ESLint flat config | per-package `eslint.config.mjs` |
| TypeScript strict | per-package `tsconfig.json` |
| Vitest (unit/component) | `*.test.ts(x)` |
| Playwright (E2E + axe) | `e2e/*.spec.ts` — runs on Chromium, Firefox, WebKit, mobile Chrome, mobile Safari |
| Lighthouse CI | budget: perf ≥ 0.85, a11y ≥ 0.95, best-practices ≥ 0.9 (`.lighthouserc.json` + `.github/workflows/lighthouse.yml`) |
| CodeQL + Semgrep | `.github/workflows/{codeql,ci}.yml` |
| Dependabot | `.github/dependabot.yml` (weekly grouped) |

## Documentation

- **[WEB_MIGRATION_PLAN.md](WEB_MIGRATION_PLAN.md)** — full plan for the Flutter → web migration (phases, decisions, status)
- **[docs/WEB_OPS_RUNBOOK.md](docs/WEB_OPS_RUNBOOK.md)** — runtime ops, env vars, common issues, hardening checklist
- **[CHANGELOG.md](CHANGELOG.md)** — release notes
- **[DEPLOYMENT.md](DEPLOYMENT.md)** — backend deployment notes
- **[FEATURES.md](FEATURES.md)** — feature catalog by role

## License

Proprietary — All rights reserved.
