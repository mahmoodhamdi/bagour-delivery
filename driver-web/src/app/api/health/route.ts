import { NextResponse } from "next/server";

/**
 * Liveness probe for container orchestrators. Intentionally minimal —
 * does NOT call the backend so a backend outage doesn't cascade-kill
 * this container.
 */
export const dynamic = "force-dynamic";

export function GET() {
  return NextResponse.json(
    {
      status: "ok",
      app: "driver-web",
      timestamp: new Date().toISOString(),
    },
    { status: 200 },
  );
}
