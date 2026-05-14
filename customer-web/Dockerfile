# --- builder ----------------------------------------------------------------
FROM node:20-alpine AS builder
RUN apk add --no-cache libc6-compat
RUN corepack enable && corepack prepare pnpm@9 --activate
WORKDIR /repo

# Bring in the entire workspace so the customer-web build can resolve the
# `@bagour/*` workspace packages.
COPY pnpm-workspace.yaml pnpm-lock.yaml package.json turbo.json ./
COPY packages ./packages
COPY customer-web ./customer-web
COPY driver-web ./driver-web

RUN pnpm install --frozen-lockfile

WORKDIR /repo/customer-web
ENV NEXT_TELEMETRY_DISABLED=1
RUN pnpm build

# --- runner -----------------------------------------------------------------
FROM node:20-alpine AS runner
RUN apk add --no-cache wget
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

RUN addgroup --system --gid 1001 nodejs \
 && adduser --system --uid 1001 nextjs

# Next.js `output: "standalone"` ships only the files needed at runtime.
COPY --from=builder --chown=nextjs:nodejs /repo/customer-web/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /repo/customer-web/.next/static ./customer-web/.next/static
COPY --from=builder --chown=nextjs:nodejs /repo/customer-web/public ./customer-web/public

USER nextjs
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/api/health || exit 1

CMD ["node", "customer-web/server.js"]
