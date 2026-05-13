"use client";

import { useSession } from "@/lib/hooks/use-session";

/**
 * Mount-once hook host that fires `useSession()` so the persisted user is
 * refreshed once on cold reload. Renders nothing.
 */
export function SessionHydrator() {
  useSession();
  return null;
}
