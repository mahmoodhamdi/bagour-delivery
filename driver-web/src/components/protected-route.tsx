"use client";

import { useTranslations } from "next-intl";
import { useEffect, type ReactNode } from "react";

import { useRouter } from "@/i18n/navigation";
import { useAuthStore } from "@/stores/auth-store";

/**
 * Client-side auth gate. Shows a spinner skeleton until `hydrated`, then
 * either renders children or redirects anonymous users to `redirectTo`.
 */
export function ProtectedRoute({
  children,
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
