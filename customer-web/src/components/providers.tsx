"use client";

import type { ReactNode } from "react";

import { ApiProvider } from "@/lib/api-context";
import { QueryProvider } from "@/lib/query-client";

import { ThemeProvider } from "./theme-provider";
import { Toaster } from "./ui/sonner";

/**
 * Single client-side wrapper invoked once from the locale layout. Keeps
 * the layout file declarative and avoids three nested `"use client"`
 * trees in server components.
 */
export function Providers({ children }: { children: ReactNode }) {
  return (
    <ThemeProvider>
      <QueryProvider>
        <ApiProvider>
          {children}
          <Toaster />
        </ApiProvider>
      </QueryProvider>
    </ThemeProvider>
  );
}
