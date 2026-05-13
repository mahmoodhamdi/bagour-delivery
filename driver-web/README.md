# driver-web

Bagour Delivery — driver-facing Next.js 16 PWA. Arabic-first with English, RTL-aware, installable.

## Scripts

```bash
pnpm dev           # turbopack dev server on :3001
pnpm build         # production build
pnpm start         # serve the production build on :3001
pnpm lint          # eslint
pnpm typecheck     # tsc --noEmit
pnpm test          # vitest run
pnpm test:e2e      # playwright
```

## Environment

Copy `.env.local.example` to `.env.local` and fill in:

| var | default | what for |
|---|---|---|
| `NEXT_PUBLIC_API_URL` | `http://localhost:5000` | Bagour backend |
| `NEXT_PUBLIC_APP_URL` | `http://localhost:3001` | This app's public URL (used by metadata + OG) |
| `NEXT_PUBLIC_DEFAULT_LOCALE` | `ar` | Default locale |
| `NEXT_PUBLIC_VAPID_PUBLIC_KEY` | _(optional)_ | Web Push subscription |

## Stack

- Next.js 16 (Turbopack), React 19, TypeScript strict
- next-intl v4 (AR/EN, RTL)
- Tailwind v4 + shadcn/ui primitives
- TanStack Query v5 + Zustand v5
- Serwist v9 PWA (manifest + offline-aware SW)
- Vitest + Playwright (with axe-core a11y checks)

This app reuses `@bagour/api-client`, `@bagour/types`, and the shared eslint/tsconfig/tailwind configs from the workspace.
