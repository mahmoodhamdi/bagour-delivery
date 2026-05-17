# Smoke tests

Quick end-to-end checks that exercise the running backend against the
typed `@bagour/api-client` plus the admin-dashboard's HTTP surface. They
expect the dev stack to be live:

| Service        | URL                       |
|----------------|---------------------------|
| Backend API    | http://localhost:5001     |
| customer-web   | http://localhost:3010     |
| driver-web     | http://localhost:3011     |
| admin-dashboard| http://localhost:3012     |

…and the seed data already loaded (`pnpm --filter @bagour/api-client …`
won't help — the seed script lives in `backend/`).

## Scripts

- `customer-web/api-smoke.mjs` — pings every endpoint in
  `@bagour/api-client` for the customer and driver roles. Run from
  inside `customer-web/` so the workspace import resolves:

      cd customer-web && pnpm exec tsx api-smoke.mjs

- `customer-web/e2e-smoke.mjs` — walks the full order lifecycle:
  customer creates an order → restaurant confirms → driver delivers →
  customer sees the delivered order. Same invocation:

      cd customer-web && pnpm exec tsx e2e-smoke.mjs

- `scripts/smoke/admin-smoke.mjs` — exercises the admin-dashboard's
  backend dependencies without going through the React UI:

      node scripts/smoke/admin-smoke.mjs

Each script prints a `PASS / FAIL` row per check and exits non-zero if
any step failed.
