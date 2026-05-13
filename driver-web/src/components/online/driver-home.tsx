"use client";

import { AlertTriangle } from "lucide-react";
import { useTranslations } from "next-intl";

import { Skeleton } from "@/components/ui/skeleton";
import { Link } from "@/i18n/navigation";
import { useDriverProfile } from "@/lib/hooks/use-driver";

import { OnlineToggle } from "./online-toggle";

/**
 * Home dashboard for signed-in drivers: status + online toggle. Renders
 * "complete onboarding" guidance for drivers who haven't filled in their
 * profile yet.
 */
export function DriverHome() {
  const t = useTranslations();
  const profile = useDriverProfile();

  if (profile.isLoading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-24 w-full" />
        <Skeleton className="h-12 w-1/2" />
      </div>
    );
  }

  if (profile.isError || !profile.data) {
    return (
      <div
        role="alert"
        className="flex items-start gap-3 rounded-2xl border border-destructive/30 bg-destructive/10 p-4 text-destructive"
        data-testid="driver-home-error"
      >
        <AlertTriangle aria-hidden className="size-5" />
        <div className="space-y-2">
          <p className="text-sm font-semibold">{t("Online.profileLoadError")}</p>
          <Link href="/onboarding" className="text-sm font-medium underline">
            {t("Online.goToOnboarding")}
          </Link>
        </div>
      </div>
    );
  }

  const driver = profile.data;
  const needsOnboarding =
    !driver.vehicleModel ||
    !driver.documents.nationalIdFront ||
    !driver.documents.driverLicenseFront;

  return (
    <div className="space-y-6">
      <OnlineToggle driver={driver} />

      {needsOnboarding ? (
        <div
          className="rounded-2xl border border-amber-300 bg-amber-50 p-4 text-amber-900 dark:border-amber-800 dark:bg-amber-950/40 dark:text-amber-100"
          data-testid="needs-onboarding"
        >
          <p className="text-sm font-medium">{t("Online.completeProfilePrompt")}</p>
          <Link
            href="/onboarding"
            className="mt-2 inline-flex text-sm font-semibold underline"
          >
            {t("Online.completeProfileCta")}
          </Link>
        </div>
      ) : null}
    </div>
  );
}
