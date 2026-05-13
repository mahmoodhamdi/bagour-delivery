import { createApiClient, type BagourApi } from "@bagour/api-client";

import { tokenStore } from "./auth-bridge";
import { env } from "./env";

/**
 * Construct a Bagour API client wired into the driver Zustand auth store.
 * Components consume this through <ApiProvider> + useApi().
 */
export function makeApiClient(options?: Partial<Parameters<typeof createApiClient>[0]>): BagourApi {
  return createApiClient({
    baseURL: env.NEXT_PUBLIC_API_URL,
    auth: tokenStore,
    ...options,
  });
}
