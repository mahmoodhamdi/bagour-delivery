import type { ReactNode } from "react";

import { Link } from "@/i18n/navigation";

interface AuthShellProps {
  title: string;
  subtitle: string;
  footer?: ReactNode;
  children: ReactNode;
}

/**
 * Shared shell for every auth page: centered card on desktop, full-width on
 * mobile, brand at top, optional CTA + footer at bottom.
 */
export function AuthShell({ title, subtitle, footer, children }: AuthShellProps) {
  return (
    <main id="main" className="container mx-auto flex max-w-md flex-col gap-8 px-4 py-12">
      <Link href="/" className="flex items-center gap-2 self-start" aria-label="Bagour Driver">
        <span
          aria-hidden
          className="inline-flex h-9 w-9 items-center justify-center rounded-full bg-primary text-primary-foreground font-bold"
        >
          ك
        </span>
        <span className="text-base font-semibold">Bagour Driver</span>
      </Link>

      <header className="space-y-2">
        <h1 className="text-3xl font-bold tracking-tight">{title}</h1>
        <p className="text-muted-foreground">{subtitle}</p>
      </header>

      <section className="space-y-6">{children}</section>

      {footer ? (
        <footer className="border-t pt-6 text-sm text-muted-foreground">{footer}</footer>
      ) : null}
    </main>
  );
}
