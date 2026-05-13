import type { AuthTokenStore } from "@bagour/api-client";

import { useAuthStore } from "@/stores/auth-store";

/**
 * Adapter exposing the Zustand auth store as the `AuthTokenStore` interface
 * that @bagour/api-client expects. On terminal refresh failure the client
 * calls `clear()` → store empties → header re-renders signed-out.
 */
export const tokenStore: AuthTokenStore = {
  getAccessToken: () => useAuthStore.getState().accessToken,
  setTokens: ({ accessToken }) => {
    useAuthStore.getState().setAccessToken(accessToken);
  },
  clear: () => {
    useAuthStore.getState().clear();
  },
};
