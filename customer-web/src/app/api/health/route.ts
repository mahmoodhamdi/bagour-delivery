import { NextResponse } from "next/server";

/**
 * Liveness probe for container orchestrators (Docker HEALTHCHECK, k8s
 * readinessProbe, load balancer health checks).
 *
 * Intentionally minimal — does NOT call the backend so a backend outage
 * doesn't cascade-kill the web frontend container. If you need a deeper
 * "ready" probe, add `/api/ready` with backend dependency checks.
 */
export const dynamic = "force-dynamic";

export function GET() {
  return NextResponse.json(
    {
      status: "ok",
      app: "customer-web",
      timestamp: new Date().toISOString(),
    },
    { status: 200 },
  );
}
