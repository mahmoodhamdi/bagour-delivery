# --- builder ----------------------------------------------------------------
FROM node:20-alpine AS builder
RUN apk add --no-cache libc6-compat
RUN corepack enable && corepack prepare pnpm@9 --activate
WORKDIR /repo

COPY pnpm-workspace.yaml pnpm-lock.yaml package.json turbo.json ./
COPY packages ./packages
COPY customer-web ./customer-web
COPY driver-web ./driver-web

RUN pnpm install --frozen-lockfile

WORKDIR /repo/driver-web
ENV NEXT_TELEMETRY_DISABLED=1
RUN pnpm build

# --- runner -----------------------------------------------------------------
FROM node:20-alpine AS runner
RUN apk add --no-cache wget
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3001
ENV HOSTNAME=0.0.0.0

RUN addgroup --system --gid 1001 nodejs \
 && adduser --system --uid 1001 nextjs

COPY --from=builder --chown=nextjs:nodejs /repo/driver-web/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /repo/driver-web/.next/static ./driver-web/.next/static
COPY --from=builder --chown=nextjs:nodejs /repo/driver-web/public ./driver-web/public

USER nextjs
EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3001/api/health || exit 1

CMD ["node", "driver-web/server.js"]
