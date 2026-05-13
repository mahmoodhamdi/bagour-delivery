"use client";

import { ArrowRight, Package } from "lucide-react";
import { useLocale, useTranslations } from "next-intl";

import { Skeleton } from "@/components/ui/skeleton";
import { Link } from "@/i18n/navigation";
import { useDriverMyOrders } from "@/lib/hooks/use-driver-orders";
import { formatCurrency, formatTimeAgo } from "@/lib/format";

const ACTIVE_STATUSES = ["picked_up", "on_the_way"] as const;
const ACCEPTED_STATUSES = ["confirmed", "preparing", "ready"] as const;

/**
 * Active orders list — orders this driver has accepted but not yet delivered.
 */
export function MyOrdersList() {
  const t = useTranslations("Orders");
  const locale = useLocale();
  const { data, isLoading, isError } = useDriverMyOrders();

  if (isLoading) {
    return (
      <div className="space-y-3" aria-hidden>
        <Skeleton className="h-20 w-full rounded-2xl" />
        <Skeleton className="h-20 w-full rounded-2xl" />
      </div>
    );
  }

  if (isError) {
    return (
      <p role="alert" className="rounded-2xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive">
        {t("loadError")}
      </p>
    );
  }

  const orders = data?.data ?? [];
  const active = orders.filter(
    (o) =>
      ACTIVE_STATUSES.includes(o.status as (typeof ACTIVE_STATUSES)[number]) ||
      ACCEPTED_STATUSES.includes(o.status as (typeof ACCEPTED_STATUSES)[number]),
  );

  if (active.length === 0) {
    return (
      <p
        className="rounded-2xl border bg-card p-6 text-center text-sm text-muted-foreground"
        data-testid="my-orders-empty"
      >
        {t("noActive")}
      </p>
    );
  }

  return (
    <ul className="space-y-3">
      {active.map((order) => (
        <li key={order.id}>
          <Link
            href={`/active/${order.id}`}
            className="flex items-center justify-between gap-4 rounded-2xl border bg-card p-4 shadow-sm transition-colors hover:bg-accent/40 focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
            data-testid={`my-order-${order.id}`}
          >
            <div className="space-y-1">
              <div className="flex items-center gap-2 text-sm font-semibold">
                <Package aria-hidden className="size-4 text-primary" />
                <span>#{order.orderNumber}</span>
                <span className="font-normal text-muted-foreground">
                  · {formatTimeAgo(order.createdAt, locale)}
                </span>
              </div>
              <p className="text-sm text-muted-foreground">
                {order.deliveryAddress.area} · {order.deliveryAddress.city}
              </p>
              <p className="text-xs font-medium uppercase tracking-widest text-primary">
                {t(`status.${order.status}`)}
              </p>
            </div>
            <div className="flex flex-col items-end gap-1">
              <span className="text-base font-bold text-emerald-700 dark:text-emerald-300">
                {formatCurrency(order.driverEarnings, locale)}
              </span>
              <ArrowRight aria-hidden className="size-4 text-muted-foreground rtl:rotate-180" />
            </div>
          </Link>
        </li>
      ))}
    </ul>
  );
}
