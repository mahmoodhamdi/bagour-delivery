# Bagour Delivery — Web Migration Plan

**Status:** Draft — 2026-05-13
**Owner:** Mahmoud Hamdy
**Branch policy:** Each phase = a feature branch off `main` + a PR on `mahmoodhamdi/bagour-delivery`.

---

## 1. Goals & Non-Goals

### Goals

1. Ship a **Customer Web App** (PWA) and **Driver Web App** (PWA) to replace the Flutter apps for primary product delivery.
2. Preserve quality: comprehensive automated tests (unit, component, integration, E2E, Lighthouse, security) on every PR.
3. Keep the codebase easy to customize for downstream clients (sales target).
4. Iterate in small, reviewable PRs — never one monolithic dump.

### Non-Goals

- **Do NOT** delete or refactor the existing Flutter apps (`customer-app/`, `delivery-app/`). They stay as-is for potential future reuse.
- **Do NOT** rewrite the backend. Extend it (Web Push VAPID, CORS for new web origins, possible rate-limit tuning).
- **Do NOT** touch admin/restaurant dashboards beyond bumping shared configs once we extract them.

---

## 2. Decisions (locked in after market scan)

| Decision                 | Choice                                                                                             | Why                                                                                         |
| ------------------------ | -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Web framework            | **Next.js 16** (App Router)                                                                        | Already used by admin + restaurant dashboards; SSR + image opt + middleware out of the box. |
| Language                 | **TypeScript 5.x strict**                                                                          | Type safety = customizability without breakage.                                             |
| Styling                  | **Tailwind v4 + shadcn/ui**                                                                        | Consistent with existing dashboards; easy theme customization per client.                   |
| Server state             | **TanStack Query v5**                                                                              | Cache + retry + stale-while-revalidate for shaky mobile networks.                           |
| Client state             | **Zustand**                                                                                        | Matches existing dashboards; small, fast, no boilerplate.                                   |
| Forms                    | **react-hook-form + Zod**                                                                          | Matches existing dashboards; one schema for client + server.                                |
| PWA                      | **Serwist** (`@serwist/next`)                                                                      | Modern Workbox successor, maintained, Next 14+ first-class.                                 |
| i18n                     | **next-intl** (App Router)                                                                         | Best RTL support; server-component native. AR primary + EN secondary.                       |
| Maps                     | **MapLibre GL JS** + OSM tiles, **OSRM** for routing                                               | Free; better perf than Leaflet for live driver tracking; vector tiles.                      |
| Realtime                 | **socket.io-client**                                                                               | Backend already on socket.io.                                                               |
| Auth                     | JWT (HTTP-only refresh cookie + access token in memory) + **Firebase Auth** for phone OTP + Google | Mirrors mobile auth so backend stays a single contract.                                     |
| Push                     | **Web Push API + VAPID** (web-push lib in backend)                                                 | Native browser API; works on iOS 16.4+, Android Chrome, desktop.                            |
| Background tasks         | Page Visibility + Wake Lock + foreground geolocation                                               | Mobile browsers don't allow true background; document the limitation.                       |
| Payments                 | **Paymob** card flow + cash on delivery                                                            | Backend already integrates Paymob; reuse webhook + redirect URL.                            |
| File uploads             | Cloudinary unsigned uploads via signed presets                                                     | Matches existing backend setup.                                                             |
| Testing — unit/component | **Vitest** + React Testing Library + jsdom                                                         | Faster than Jest; ESM-native; works with Next 16.                                           |
| Testing — integration    | **Vitest + MSW**                                                                                   | Mock the backend HTTP + Socket.io.                                                          |
| Testing — E2E            | **Playwright** (Chromium + Firefox + WebKit, mobile + desktop)                                     | Already pulled into restaurant-dashboard; battle-tested.                                    |
| Testing — a11y           | **@axe-core/playwright**                                                                           | A11y rules enforced inside E2E.                                                             |
| Testing — perf           | **Lighthouse CI** + budgets file                                                                   | Run against Vercel previews.                                                                |
| Testing — security       | OWASP **ZAP baseline** + **Semgrep** + **npm audit** + Dependabot                                  | DAST on previews + SAST in CI.                                                              |
| Visual regression        | Playwright screenshot snapshots (per breakpoint)                                                   | Cheap, no SaaS needed.                                                                      |
| Repo layout              | **pnpm workspaces + Turborepo**                                                                    | Shared packages without giving up per-app independence.                                     |
| CI/CD                    | **GitHub Actions**                                                                                 | Already the repo home; matrix builds + reusable workflows.                                  |
| Hosting                  | Self-hosted Docker on the customer's VPS (primary); **Vercel** for preview deploys (free tier)     | Matches Scenario A/B in DEPLOYMENT.md.                                                      |

---

## 3. Repository Layout (target)

```
bagour-delivery/
├── customer-app/           # Flutter — KEEP frozen
├── delivery-app/           # Flutter — KEEP frozen
├── backend/                # Node/Express/TS — extend, don't break
├── admin-dashboard/        # Next.js — unchanged
├── restaurant-dashboard/   # Next.js — unchanged
│
├── customer-web/           # NEW — Customer PWA
├── driver-web/             # NEW — Driver PWA
│
├── packages/               # NEW — shared workspace packages
│   ├── api-client/         # Typed axios + Zod schemas
│   ├── ui/                 # Shared shadcn primitives + brand theme
│   ├── types/              # Shared TS types (re-export shared/types/)
│   ├── config-tsconfig/    # Base tsconfigs
│   ├── config-eslint/      # Shared ESLint config
│   ├── config-tailwind/    # Shared Tailwind preset
│   └── i18n/               # Shared messages (AR/EN)
│
├── shared/                 # Existing — extend with web-specific constants
├── docs/                   # Existing
├── marketing/              # Existing
├── scripts/                # Existing
│
├── pnpm-workspace.yaml     # NEW
├── turbo.json              # NEW
├── package.json            # NEW (root)
└── .github/workflows/      # NEW — CI for all the things
```

Existing standalone apps (admin/restaurant dashboards + backend) stay runnable on their own. The workspace is **opt-in** — `pnpm install` at root sets it up, but each app still has its own `package.json`.

---

## 4. PR Roadmap

35-ish small PRs across 10 phases. Each PR has: code + tests + docs delta. **No PR ships without green CI.**

### Phase 0 — Foundation (4 PRs)

- **PR-0.1** `feat: pnpm workspaces + turborepo + shared configs`  
  Add `pnpm-workspace.yaml`, `turbo.json`, root `package.json`, `.nvmrc`, `.editorconfig`. Create `packages/config-tsconfig`, `packages/config-eslint`, `packages/config-tailwind`. **Do not** modify existing apps yet.
- **PR-0.2** `feat(shared): @bagour/types package re-exporting shared/types/`  
  Package that re-exports `shared/types/` and `shared/constants/` as `@bagour/types`. Lets new apps `import` without relative `../../shared/...` paths.
- **PR-0.3** `feat(shared): @bagour/api-client typed Zod client + MSW handlers`  
  Hand-typed Zod schemas mirroring backend routes (auth, restaurants, orders, drivers, reviews, coupons, uploads). Exports an axios instance + typed methods + a `useApiClient` React hook. Includes MSW handlers for tests.
- **PR-0.4** `ci: GitHub Actions — lint, typecheck, unit, e2e, lighthouse, zap, securityheaders`  
  Reusable workflow `.github/workflows/web-ci.yml` invoked per app. Matrix: Node 22, OS Ubuntu, Playwright browsers. Jobs: install → lint → typecheck → unit → build → E2E → Lighthouse CI → ZAP baseline → securityheaders check. Coverage uploaded to GitHub artifacts.

### Phase 1 — Customer Web: Shell + Auth (5 PRs)

- **PR-1.1** `feat(customer-web): scaffold Next.js 16 + Serwist PWA + manifest + theme`
- **PR-1.2** `feat(customer-web): next-intl AR/EN + RTL + Cairo font + theme tokens`
- **PR-1.3** `feat(customer-web): layout shell, header, bottom nav, side drawer`
- **PR-1.4** `feat(customer-web): auth — email/password login + register + JWT refresh rotation`
- **PR-1.5** `feat(customer-web): auth — phone OTP via Firebase + Google sign-in + tests`

### Phase 2 — Customer Web: Browse + Order (5 PRs)

- **PR-2.1** `feat(customer-web): zones + restaurants listing + filters + search`
- **PR-2.2** `feat(customer-web): restaurant detail + menu + categories + item modal`
- **PR-2.3** `feat(customer-web): cart store + persistence + quantity + notes`
- **PR-2.4** `feat(customer-web): addresses management + map picker (MapLibre)`
- **PR-2.5** `feat(customer-web): checkout — coupon + Paymob + cash + place order + E2E`

### Phase 3 — Customer Web: Tracking + History (4 PRs)

- **PR-3.1** `feat(customer-web): order tracking — live driver map + status timeline + ETA`
- **PR-3.2** `feat(customer-web): order history + reorder + cancel + invoice download`
- **PR-3.3** `feat(customer-web): reviews — restaurant + driver rating + flow`
- **PR-3.4** `feat(customer-web): web push subscription + in-app notifications center`

### Phase 4 — Customer Web: Polish (3 PRs)

- **PR-4.1** `feat(customer-web): offline shell + SW caching strategies + retry queue`
- **PR-4.2** `feat(customer-web): loyalty points + coupons wall`
- **PR-4.3** `chore(customer-web): Lighthouse pass + a11y fixes + final polish`

### Phase 5 — Driver Web: Shell + Auth (3 PRs)

- **PR-5.1** `feat(driver-web): scaffold Next.js 16 + PWA + i18n + brand theme`
- **PR-5.2** `feat(driver-web): auth + KYC upload (camera + Cloudinary)`
- **PR-5.3** `feat(driver-web): layout shell + driver-specific nav`

### Phase 6 — Driver Web: Order Lifecycle (5 PRs)

- **PR-6.1** `feat(driver-web): online/offline toggle + Wake Lock + foreground location stream`
- **PR-6.2** `feat(driver-web): order assignment — 30s window + sound + vibration + Web Push`
- **PR-6.3** `feat(driver-web): pickup navigation (MapLibre + OSRM) + status updates`
- **PR-6.4** `feat(driver-web): delivery navigation + completion + photo proof`
- **PR-6.5** `test(driver-web): full E2E driver flow + offline retries`

### Phase 7 — Driver Web: Earnings + Profile (2 PRs)

- **PR-7.1** `feat(driver-web): earnings dashboard + payout request + history`
- **PR-7.2** `feat(driver-web): profile + KYC re-upload + rating display + preferences`

### Phase 8 — Backend Extensions (3 PRs)

- **PR-8.1** `feat(backend): Web Push — VAPID keys + push subscriptions API + send helper`
- **PR-8.2** `feat(backend): CORS + cookie security for customer-web + driver-web origins`
- **PR-8.3** `feat(backend): rate-limit profiles tuned for browser clients`

### Phase 9 — Hardening (3 PRs)

- **PR-9.1** `feat(security): CSP nonces + HSTS + COOP/COEP + securityheaders A+`
- **PR-9.2** `ci(security): Semgrep + npm audit gate + OWASP ZAP weekly scan`
- **PR-9.3** `test(e2e): cross-browser matrix + mobile viewports + visual snapshots`

### Phase 10 — Rollout (2 PRs)

- **PR-10.1** `feat(deploy): docker-compose.prod for customer-web + driver-web + Nginx`
- **PR-10.2** `docs: web migration ops runbook + customization guide`

---

## 5. Testing Matrix (enforced in CI)

| Layer         | Tooling                               | Coverage target                          | Runs on                  |
| ------------- | ------------------------------------- | ---------------------------------------- | ------------------------ |
| Unit          | Vitest                                | ≥ 80% lines on `lib/` and `hooks/`       | every PR                 |
| Component     | Vitest + RTL + jsdom                  | ≥ 70% of components                      | every PR                 |
| Integration   | Vitest + MSW                          | ≥ 60% of feature modules                 | every PR                 |
| E2E           | Playwright (3 browsers × 2 viewports) | golden paths + 5 critical regressions    | every PR                 |
| A11y          | @axe-core/playwright                  | 0 critical, 0 serious violations         | every PR                 |
| Lighthouse    | LHCI                                  | Perf ≥ 90, A11y ≥ 95, SEO ≥ 95, PWA pass | preview deploy           |
| Security SAST | Semgrep + ESLint security plugin      | 0 high findings                          | every PR                 |
| Security DAST | OWASP ZAP baseline                    | 0 high findings                          | weekly + nightly preview |
| Deps          | npm audit + Dependabot                | 0 high/critical                          | every PR + weekly        |
| Headers       | securityheaders.com via curl          | A+ rating                                | weekly                   |

---

## 6. Quality Gates per PR

A PR is mergeable only if **all** are green:

1. `pnpm lint` (ESLint + Prettier check) — 0 errors
2. `pnpm typecheck` (tsc --noEmit) — 0 errors
3. `pnpm test:unit` — passes, coverage at or above target
4. `pnpm test:component` — passes
5. `pnpm test:integration` — passes
6. `pnpm build` — succeeds
7. `pnpm test:e2e` — passes on 3 browsers
8. Lighthouse CI — within budget
9. Semgrep + npm audit — 0 high/critical
10. axe-core — 0 critical/serious

---

## 7. Security Baseline (cross-cutting)

- TLS 1.3 + HSTS preload
- Strict CSP with per-request nonces (no `unsafe-inline`)
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy` locked to what each app needs (geolocation only on driver-web, camera only on KYC/proof routes, etc.)
- COOP/COEP/CORP for isolation
- HTTP-only + Secure + SameSite=Lax cookies for refresh token
- Access token in memory only (never localStorage)
- CSRF token on state-changing fetches (double-submit cookie)
- Rate-limit per role on the backend
- All form input revalidated server-side via Zod schemas shared with client

---

## 8. PWA Capabilities Used

| Capability               |    Customer     |     Driver     | Notes                                                     |
| ------------------------ | :-------------: | :------------: | --------------------------------------------------------- |
| Web App Manifest         |       ✅        |       ✅       | AR/EN names, brand colors                                 |
| Service Worker (Serwist) |       ✅        |       ✅       | Stale-while-revalidate for menu, network-first for orders |
| Web Push (VAPID)         |       ✅        |       ✅       | iOS 16.4+, Android, desktop                               |
| Add to Home Screen       |       ✅        |       ✅       | Custom install prompt                                     |
| Geolocation (foreground) | ✅ pick address | ✅ live stream |                                                           |
| Wake Lock                |       ❌        |       ✅       | Keep screen on while delivering                           |
| Web Share                |       ✅        |       ❌       | Share restaurant link                                     |
| Camera                   |   ✅ profile    | ✅ KYC + proof | `getUserMedia`                                            |
| Vibration                |       ✅        |       ✅       | New order                                                 |
| Background Sync          |       ✅        |       ✅       | Retry failed POSTs while offline                          |

> **Driver background limitation:** Mobile browsers do not allow true background GPS like a native app. The driver web app must stay open (foreground) while delivering. We mitigate with Wake Lock + a "Stay online" toast + push notifications that wake the tab. Document this prominently in the driver UX.

---

## 9. Operating Model

- Branches: feature branches off `main`, e.g. `web/foundation`, `web/customer-shell`, `web/driver-online-toggle`.
- Commit style: Conventional Commits (`feat`, `fix`, `chore`, `test`, `ci`, `docs`, `refactor`).
- PR title = commit title. PR body = bullets of what changed + test plan + screenshots if UI.
- I open PRs and push branches; **I never merge my own PRs.** Mahmoud reviews + merges.
- CI must be green before requesting review.
- After merge, I rebase the next branch off `main` and continue.

---

## 10. Out of Scope (for now)

- Native iOS/Android publication of the PWAs (TWA wrapping etc.) — can do later.
- Server-driven UI / remote config.
- AI-powered routing / dispatch optimization.
- Multi-tenant white-labeling (single brand for now).
- Marketing site rewrite.
