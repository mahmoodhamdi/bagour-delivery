"use client";

import type { BagourApi } from "@bagour/api-client";
import { createContext, useContext, useMemo, type ReactNode } from "react";

import { makeApiClient } from "./api";

const ApiContext = createContext<BagourApi | null>(null);

/**
 * Wraps the driver app with a single API client so every component down the
 * tree shares the same axios + auth interceptors. Pass `client` in tests.
 */
export function ApiProvider({ children, client }: { children: ReactNode; client?: BagourApi }) {
  const value = useMemo(() => client ?? makeApiClient(), [client]);
  return <ApiContext.Provider value={value}>{children}</ApiContext.Provider>;
}

export function useApi(): BagourApi {
  const ctx = useContext(ApiContext);
  if (!ctx) {
    throw new Error("useApi() must be used inside <ApiProvider>");
  }
  return ctx;
}
