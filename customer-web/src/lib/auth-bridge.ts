import type { AuthTokenStore } from "@bagour/api-client";

import { useAuthStore } from "@/stores/auth-store";

/**
 * Adapter that exposes the Zustand auth store as the `AuthTokenStore`
 * interface that @bagour/api-client expects.
 *
 * On terminal refresh failure the client calls `clear()` → the Zustand
 * store empties → the Header re-renders with the signed-out variant.
 */
export const tokenStore: AuthTokenStore = {
  getAccessToken: () => useAuthStore.getState().accessToken,
  setTokens: ({ accessToken }) => {
    useAuthStore.getState().setAccessToken(accessToken);
  },
  clear: () => {
    useAuthStore.getState().clear();
  },
  // No getRefreshToken — the refresh token rides in the httpOnly cookie set
  // by the backend on login. Browser sends it automatically while
  // withCredentials is true on the axios instance.
};
