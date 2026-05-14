"use client";

import type { ReactNode } from "react";

import { ApiProvider } from "@/lib/api-context";
import { QueryProvider } from "@/lib/query-client";

import { InstallPrompt } from "./pwa/install-prompt";
import { SessionHydrator } from "./session-hydrator";
import { ThemeProvider } from "./theme-provider";
import { Toaster } from "./ui/sonner";

/**
 * Single client-side wrapper invoked once from the locale layout.
 */
export function Providers({ children }: { children: ReactNode }) {
  return (
    <ThemeProvider>
      <QueryProvider>
        <ApiProvider>
          <SessionHydrator />
          {children}
          <InstallPrompt />
          <Toaster />
        </ApiProvider>
      </QueryProvider>
    </ThemeProvider>
  );
}
