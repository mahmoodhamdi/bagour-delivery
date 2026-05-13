import { createApiClient, type BagourApi } from "@bagour/api-client";

import { env } from "./env";

/**
 * Construct a Bagour API client. The auth token store is provided by the
 * caller; for unauthenticated browse endpoints, pass `null`. Once the
 * session store lands (PR-1.3), wrap it here so every component gets the
 * same instance with bearer-token injection + refresh handling.
 */
export function makeApiClient(options?: Partial<Parameters<typeof createApiClient>[0]>): BagourApi {
  return createApiClient({
    baseURL: env.NEXT_PUBLIC_API_URL,
    auth: null,
    ...options,
  });
}
