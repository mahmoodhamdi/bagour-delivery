"use client";

import { useTranslations } from "next-intl";
import { useEffect, type ReactNode } from "react";

import { useRouter } from "@/i18n/navigation";
import { useAuthStore } from "@/stores/auth-store";

/**
 * Client-side auth gate. Routes that need a signed-in user wrap their
 * tree in this. While `hydrated` is false we show a centered spinner
 * skeleton so the page never flashes its content to anonymous users.
 *
 * For SEO + true protection, sensitive routes must also be guarded
 * server-side (middleware / route handler). This guard handles the
 * client-side UX.
 */
export function ProtectedRoute({
  children,
  /** Where to send anonymous users. */
  redirectTo = "/login",
}: {
  children: ReactNode;
  redirectTo?: string;
}) {
  const t = useTranslations("Common");
  const hydrated = useAuthStore((s) => s.hydrated);
  const user = useAuthStore((s) => s.user);
  const router = useRouter();

  useEffect(() => {
    if (hydrated && !user) {
      router.replace(redirectTo);
    }
  }, [hydrated, user, redirectTo, router]);

  if (!hydrated || !user) {
    return (
      <div
        role="status"
        aria-live="polite"
        className="flex min-h-[40vh] flex-col items-center justify-center gap-3 text-muted-foreground"
        data-testid="protected-loading"
      >
        <div className="size-8 animate-spin rounded-full border-2 border-current border-t-transparent" />
        <span>{t("loading")}</span>
      </div>
    );
  }

  return <>{children}</>;
}
