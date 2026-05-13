"use client";

import { useQuery } from "@tanstack/react-query";
import { useEffect } from "react";

import { ApiError } from "@bagour/api-client";

import { useApi } from "@/lib/api-context";
import { useAuthStore } from "@/stores/auth-store";

/**
 * Cold-load session hydrate. After the persisted user snapshot rehydrates,
 * ping /auth/me to refresh the driver record + prove the refresh cookie is
 * still valid. On 401 we clear the store.
 */
export function useSession() {
  const api = useApi();
  const user = useAuthStore((s) => s.user);
  const hydrated = useAuthStore((s) => s.hydrated);
  const setUser = useAuthStore((s) => s.setUser);
  const clear = useAuthStore((s) => s.clear);

  const query = useQuery({
    queryKey: ["auth", "me"],
    queryFn: () => api.auth.me(),
    enabled: hydrated && user !== null,
    staleTime: 60_000,
    retry: false,
  });

  useEffect(() => {
    if (query.data) {
      setUser(query.data);
    }
  }, [query.data, setUser]);

  useEffect(() => {
    if (query.error instanceof ApiError && query.error.isAuthError) {
      clear();
    }
  }, [query.error, clear]);

  return {
    user,
    hydrated,
    isLoading: query.isLoading,
    error: query.error,
  };
}
