import type { ReactNode } from "react";

import "./globals.css";

/**
 * Root layout is intentionally minimal — the actual <html> + lang/dir live
 * in `[locale]/layout.tsx` so next-intl can pick the right one.
 */
export default function RootLayout({ children }: { children: ReactNode }) {
  return children;
}
