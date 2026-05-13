import type { ReactNode } from "react";

import "./globals.css";

/**
 * The root layout is intentionally minimal because next-intl's
 * `[locale]/layout.tsx` is what renders the actual <html> element with
 * the proper `lang` and `dir`. Next.js requires SOME `app/layout.tsx`
 * to exist, so we provide this pass-through.
 */
export default function RootLayout({ children }: { children: ReactNode }) {
  return children;
}
