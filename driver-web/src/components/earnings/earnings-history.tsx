"use client";

import { useLocale, useTranslations } from "next-intl";

import { Skeleton } from "@/components/ui/skeleton";
import { useEarningsHistory } from "@/lib/hooks/use-driver-earnings";
import { formatCurrency } from "@/lib/format";

export function EarningsHistory() {
  const t = useTranslations("Earnings");
  const locale = useLocale();
  const { data, isLoading, isError } = useEarningsHistory();

  if (isLoading) {
    return (
      <div className="space-y-3" aria-hidden>
        <Skeleton className="h-16 rounded-2xl" />
        <Skeleton className="h-16 rounded-2xl" />
        <Skeleton className="h-16 rounded-2xl" />
      </div>
    );
  }

  if (isError) {
    return (
      <p
        role="alert"
        className="rounded-2xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive"
      >
        {t("historyError")}
      </p>
    );
  }

  if (!data || data.length === 0) {
    return (
      <p className="rounded-2xl border bg-card p-6 text-center text-sm text-muted-foreground">
        {t("noHistory")}
      </p>
    );
  }

  const dateFormatter = new Intl.DateTimeFormat(locale === "ar" ? "ar-EG" : "en-US", {
    weekday: "long",
    day: "numeric",
    month: "short",
  });

  return (
    <ul className="space-y-3">
      {data.map((row) => (
        <li
          key={row.day}
          className="flex items-center justify-between gap-3 rounded-2xl border bg-card p-4"
          data-testid={`earnings-row-${row.day}`}
        >
          <div>
            <p className="text-sm font-semibold">{dateFormatter.format(new Date(row.day))}</p>
            <p className="text-xs text-muted-foreground">
              {t("deliveriesLabel", { count: row.count })}
            </p>
          </div>
          <p className="text-base font-bold text-emerald-700 dark:text-emerald-300">
            {formatCurrency(row.total, locale)}
          </p>
        </li>
      ))}
    </ul>
  );
}
