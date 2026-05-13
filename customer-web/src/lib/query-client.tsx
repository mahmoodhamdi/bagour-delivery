"use client";

import { QueryClient, QueryClientProvider, isServer } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { useState, type ReactNode } from "react";

import { ApiError } from "@bagour/api-client";

/**
 * Single QueryClient per request on the server, single per mount on the
 * client. Matches the TanStack Query SSR pattern.
 */
function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        // Stale-while-revalidate by default; we override per-feature.
        staleTime: 30_000,
        gcTime: 5 * 60_000,
        refetchOnWindowFocus: false,
        retry: (failureCount, error) => {
          // Don't retry auth errors or 4xx — caller should sign-out / show the form error.
          if (
            error instanceof ApiError &&
            (error.isAuthError || (error.statusCode >= 400 && error.statusCode < 500))
          ) {
            return false;
          }
          return failureCount < 2;
        },
      },
      mutations: {
        retry: 0,
      },
    },
  });
}

let browserQueryClient: QueryClient | undefined;

function getQueryClient() {
  if (isServer) {
    // Server: always make a new client.
    return makeQueryClient();
  }
  // Browser: reuse to keep the cache hot across re-renders.
  browserQueryClient ??= makeQueryClient();
  return browserQueryClient;
}

export function QueryProvider({ children }: { children: ReactNode }) {
  // useState so we don't recreate the client on hot-reload re-renders.
  const [client] = useState(() => getQueryClient());

  return (
    <QueryClientProvider client={client}>
      {children}
      {process.env.NODE_ENV !== "production" && <ReactQueryDevtools initialIsOpen={false} />}
    </QueryClientProvider>
  );
}

export const __test__ = { makeQueryClient };
