"use client";

import { DollarSign, Star, Truck, Wallet } from "lucide-react";
import { useLocale, useTranslations } from "next-intl";

import { Skeleton } from "@/components/ui/skeleton";
import { useDriverStats } from "@/lib/hooks/use-driver-earnings";
import { formatCurrency, formatNumber } from "@/lib/format";

export function EarningsSummary() {
  const t = useTranslations("Earnings");
  const locale = useLocale();
  const { data, isLoading, isError } = useDriverStats();

  if (isLoading) {
    return (
      <div className="grid grid-cols-2 gap-3" aria-hidden>
        <Skeleton className="h-24 rounded-2xl" />
        <Skeleton className="h-24 rounded-2xl" />
        <Skeleton className="h-24 rounded-2xl" />
        <Skeleton className="h-24 rounded-2xl" />
      </div>
    );
  }

  if (isError || !data) {
    return (
      <p
        role="alert"
        className="rounded-2xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive"
      >
        {t("loadError")}
      </p>
    );
  }

  const cards = [
    {
      icon: Wallet,
      label: t("walletBalance"),
      value: formatCurrency(data.walletBalance, locale),
      accent: "text-emerald-700 dark:text-emerald-300",
    },
    {
      icon: DollarSign,
      label: t("totalEarnings"),
      value: formatCurrency(data.totalEarnings, locale),
      accent: "text-foreground",
    },
    {
      icon: Truck,
      label: t("totalDeliveries"),
      value: formatNumber(data.totalDeliveries, locale),
      accent: "text-foreground",
    },
    {
      icon: Star,
      label: t("rating"),
      value: `${data.rating.toFixed(1)} (${formatNumber(data.totalReviews, locale)})`,
      accent: "text-amber-600 dark:text-amber-400",
    },
  ];

  return (
    <section
      aria-label={t("summarySectionLabel")}
      className="grid grid-cols-2 gap-3"
      data-testid="earnings-summary"
    >
      {cards.map(({ icon: Icon, label, value, accent }) => (
        <article key={label} className="rounded-2xl border bg-card p-4">
          <Icon aria-hidden className={`mb-2 size-5 ${accent}`} />
          <p className="text-xs font-medium uppercase tracking-widest text-muted-foreground">
            {label}
          </p>
          <p className={`mt-1 text-xl font-bold ${accent}`}>{value}</p>
        </article>
      ))}

      {data.pendingPayouts > 0 ? (
        <p className="col-span-2 rounded-2xl border border-amber-300 bg-amber-50 p-3 text-sm text-amber-900 dark:border-amber-800 dark:bg-amber-950/40 dark:text-amber-100">
          {t("pendingPayouts", { amount: formatCurrency(data.pendingPayouts, locale) })}
        </p>
      ) : null}
    </section>
  );
}
