# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build Next.js app
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

# Production stage
FROM node:20-alpine AS production

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextuser -u 1001 -G nodejs

# Copy built files
COPY --from=builder --chown=nextuser:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextuser:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextuser:nodejs /app/public ./public

# Switch to non-root user
USER nextuser

# Expose port
EXPOSE 3000

# Set environment
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

# Start server
CMD ["node", "server.js"]
