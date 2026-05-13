"use client";

import { Badge, CheckCircle2, Clock3, ShieldAlert, Truck, XCircle } from "lucide-react";
import { useLocale, useTranslations } from "next-intl";

import type { DriverStatus } from "@bagour/types";

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { Skeleton } from "@/components/ui/skeleton";
import { Link } from "@/i18n/navigation";
import { useDriverProfile } from "@/lib/hooks/use-driver";
import { formatCurrency, formatNumber } from "@/lib/format";
import { useAuthStore } from "@/stores/auth-store";

const STATUS_ICON: Record<DriverStatus, typeof CheckCircle2> = {
  approved: CheckCircle2,
  pending: Clock3,
  rejected: XCircle,
  suspended: ShieldAlert,
};

const STATUS_ACCENT: Record<DriverStatus, string> = {
  approved: "border-emerald-300 bg-emerald-50 text-emerald-900 dark:border-emerald-800 dark:bg-emerald-950/40 dark:text-emerald-100",
  pending: "border-amber-300 bg-amber-50 text-amber-900 dark:border-amber-800 dark:bg-amber-950/40 dark:text-amber-100",
  rejected: "border-destructive/40 bg-destructive/10 text-destructive",
  suspended: "border-destructive/40 bg-destructive/10 text-destructive",
};

export function DriverProfileView() {
  const t = useTranslations();
  const locale = useLocale();
  const user = useAuthStore((s) => s.user);
  const profile = useDriverProfile();

  if (profile.isLoading || !user) {
    return (
      <div className="space-y-3" aria-hidden>
        <Skeleton className="h-24 w-full rounded-2xl" />
        <Skeleton className="h-16 w-full rounded-2xl" />
        <Skeleton className="h-16 w-full rounded-2xl" />
      </div>
    );
  }

  if (profile.isError || !profile.data) {
    return (
      <p
        role="alert"
        className="rounded-2xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive"
      >
        {t("Profile.loadError")}
      </p>
    );
  }

  const driver = profile.data;
  const StatusIcon = STATUS_ICON[driver.status];

  return (
    <div className="space-y-6">
      <header className="flex items-center gap-4">
        <Avatar className="size-16">
          {user.avatar ? <AvatarImage src={user.avatar} alt="" /> : null}
          <AvatarFallback className="text-lg">
            {user.name.slice(0, 1).toUpperCase()}
          </AvatarFallback>
        </Avatar>
        <div className="min-w-0">
          <h2 className="truncate text-xl font-bold">{user.name}</h2>
          <p className="truncate text-sm text-muted-foreground">{user.email}</p>
          <p className="text-sm text-muted-foreground">{user.phone}</p>
        </div>
      </header>

      <div
        className={`flex items-center gap-3 rounded-2xl border p-4 ${STATUS_ACCENT[driver.status]}`}
        data-testid={`status-${driver.status}`}
      >
        <StatusIcon aria-hidden className="size-5" />
        <div className="flex-1">
          <p className="text-sm font-semibold">{t(`Profile.driverStatus.${driver.status}`)}</p>
          {driver.rejectionReason ? (
            <p className="text-xs">{driver.rejectionReason}</p>
          ) : null}
        </div>
        {driver.status !== "approved" ? (
          <Button asChild size="sm" variant="outline">
            <Link href="/onboarding">{t("Profile.actions.editKyc")}</Link>
          </Button>
        ) : null}
      </div>

      <section className="space-y-3 rounded-2xl border bg-card p-4">
        <h3 className="flex items-center gap-2 text-sm font-semibold uppercase tracking-widest text-muted-foreground">
          <Truck aria-hidden className="size-4" />
          {t("Profile.vehicle")}
        </h3>
        <dl className="grid grid-cols-2 gap-3 text-sm">
          <div>
            <dt className="text-xs text-muted-foreground">{t("Onboarding.fields.vehicleModel")}</dt>
            <dd className="font-medium">{driver.vehicleModel ?? "—"}</dd>
          </div>
          <div>
            <dt className="text-xs text-muted-foreground">{t("Onboarding.fields.vehicleColor")}</dt>
            <dd className="font-medium">{driver.vehicleColor ?? "—"}</dd>
          </div>
          <div>
            <dt className="text-xs text-muted-foreground">
              {t("Onboarding.fields.vehiclePlateNumber")}
            </dt>
            <dd className="font-medium">{driver.vehiclePlateNumber}</dd>
          </div>
          <div>
            <dt className="text-xs text-muted-foreground">{t("Profile.vehicleType")}</dt>
            <dd className="font-medium">{t(`Profile.vehicleTypes.${driver.vehicleType}`)}</dd>
          </div>
        </dl>
        <Button asChild variant="outline" size="sm">
          <Link href="/onboarding">{t("Profile.actions.editVehicle")}</Link>
        </Button>
      </section>

      <section className="space-y-3 rounded-2xl border bg-card p-4">
        <h3 className="flex items-center gap-2 text-sm font-semibold uppercase tracking-widest text-muted-foreground">
          <Badge aria-hidden className="size-4" />
          {t("Profile.documents")}
        </h3>
        <ul className="grid grid-cols-2 gap-2 text-sm">
          <DocStatus
            label={t("Onboarding.documents.nationalIdFront")}
            present={!!driver.documents.nationalIdFront}
          />
          <DocStatus
            label={t("Onboarding.documents.nationalIdBack")}
            present={!!driver.documents.nationalIdBack}
          />
          <DocStatus
            label={t("Onboarding.documents.driverLicenseFront")}
            present={!!driver.documents.driverLicenseFront}
          />
          <DocStatus
            label={t("Onboarding.documents.driverLicenseBack")}
            present={!!driver.documents.driverLicenseBack}
          />
        </ul>
        <Button asChild variant="outline" size="sm">
          <Link href="/onboarding">{t("Profile.actions.editDocuments")}</Link>
        </Button>
      </section>

      <Separator />

      <section className="grid grid-cols-2 gap-3">
        <article className="rounded-2xl border bg-card p-4">
          <p className="text-xs font-medium uppercase tracking-widest text-muted-foreground">
            {t("Profile.stats.deliveries")}
          </p>
          <p className="mt-1 text-xl font-bold">{formatNumber(driver.totalDeliveries, locale)}</p>
        </article>
        <article className="rounded-2xl border bg-card p-4">
          <p className="text-xs font-medium uppercase tracking-widest text-muted-foreground">
            {t("Profile.stats.earnings")}
          </p>
          <p className="mt-1 text-xl font-bold text-emerald-700 dark:text-emerald-300">
            {formatCurrency(driver.totalEarnings, locale)}
          </p>
        </article>
      </section>
    </div>
  );
}

function DocStatus({ label, present }: { label: string; present: boolean }) {
  return (
    <li
      className={`flex items-center gap-2 rounded-xl border p-2 ${
        present
          ? "border-emerald-300 bg-emerald-50 dark:border-emerald-800 dark:bg-emerald-950/40"
          : "border-amber-300 bg-amber-50 dark:border-amber-800 dark:bg-amber-950/40"
      }`}
    >
      {present ? (
        <CheckCircle2 aria-hidden className="size-4 text-emerald-600 dark:text-emerald-300" />
      ) : (
        <Clock3 aria-hidden className="size-4 text-amber-600 dark:text-amber-400" />
      )}
      <span className="text-xs font-medium">{label}</span>
    </li>
  );
}
