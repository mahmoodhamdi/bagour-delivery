"use client";

import type { Order } from "@bagour/types";
import { Package, MapPin, Loader2, AlertTriangle } from "lucide-react";
import { useLocale, useTranslations } from "next-intl";
import { useEffect, useMemo, useState } from "react";

import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { useAvailableOrders } from "@/lib/hooks/use-driver-orders";
import { useDriverProfile } from "@/lib/hooks/use-driver";
import { useCurrentPosition } from "@/lib/hooks/use-current-position";
import { formatCurrency, formatTimeAgo } from "@/lib/format";

import { AcceptOrderModal } from "./accept-order-modal";

/**
 * Available orders panel. Polls every 8 s while the driver is online.
 * Tapping a card opens a 30-second acceptance modal with audio + vibration.
 */
export function AvailableOrdersFeed() {
  const t = useTranslations("Orders");
  const locale = useLocale();
  const profile = useDriverProfile();
  const isOnline = profile.data?.isOnline ?? false;
  const isApproved = profile.data?.status === "approved";

  const geo = useCurrentPosition();
  const location = geo.position
    ? { lat: geo.position.latitude, lng: geo.position.longitude }
    : null;

  const { data, isLoading, isError } = useAvailableOrders({
    enabled: isOnline && isApproved,
    location,
  });

  const [selected, setSelected] = useState<Order | null>(null);
  const orders = data ?? [];

  if (!isApproved) return null;
  if (!isOnline) {
    return (
      <div
        role="status"
        className="rounded-2xl border bg-card p-5 text-sm text-muted-foreground"
        data-testid="orders-offline-hint"
      >
        {t("offlineHint")}
      </div>
    );
  }
  if (isOnline && !location && !geo.isLoading) {
    return (
      <div
        role="alert"
        className="flex items-start gap-2 rounded-2xl border border-amber-500/40 bg-amber-500/10 p-4 text-sm text-amber-900 dark:text-amber-200"
        data-testid="orders-need-location"
      >
        <AlertTriangle aria-hidden className="size-4 mt-0.5" />
        <span>{t("locationRequired")}</span>
      </div>
    );
  }

  return (
    <section className="space-y-3" data-testid="available-orders-feed">
      <header className="flex items-baseline justify-between">
        <h2 className="text-xl font-semibold">{t("availableTitle")}</h2>
        {data ? (
          <span className="text-xs text-muted-foreground">
            {t("availableCount", { count: orders.length })}
          </span>
        ) : null}
      </header>

      {isLoading ? <FeedSkeleton /> : null}

      {isError ? (
        <div
          role="alert"
          className="flex items-center gap-2 rounded-2xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive"
        >
          <AlertTriangle aria-hidden className="size-4" />
          {t("loadError")}
        </div>
      ) : null}

      {!isLoading && orders.length === 0 && !isError ? (
        <p
          className="rounded-2xl border bg-card p-6 text-center text-sm text-muted-foreground"
          data-testid="available-orders-empty"
        >
          {t("noAvailable")}
        </p>
      ) : null}

      <ul className="space-y-3">
        {orders.map((order) => (
          <li key={order.id}>
            <AvailableOrderCard
              order={order}
              locale={locale}
              onTake={() => setSelected(order)}
            />
          </li>
        ))}
      </ul>

      {selected ? (
        <AcceptOrderModal order={selected} onClose={() => setSelected(null)} />
      ) : null}
    </section>
  );
}

function AvailableOrderCard({
  order,
  locale,
  onTake,
}: {
  order: Order;
  locale: string;
  onTake: () => void;
}) {
  const t = useTranslations("Orders");
  const [now, setNow] = useState(() => Date.now());

  useEffect(() => {
    const id = window.setInterval(() => setNow(Date.now()), 30_000);
    return () => window.clearInterval(id);
  }, []);

  const ageLabel = useMemo(() => formatTimeAgo(order.createdAt, locale, now), [order.createdAt, locale, now]);
  const earnings = formatCurrency(order.driverEarnings, locale);

  return (
    <article className="flex items-center justify-between gap-4 rounded-2xl border bg-card p-4 shadow-sm">
      <div className="space-y-1">
        <div className="flex items-center gap-2 text-sm font-semibold">
          <Package aria-hidden className="size-4 text-primary" />
          <span>#{order.orderNumber}</span>
          <span className="text-muted-foreground font-normal">· {ageLabel}</span>
        </div>
        <p className="flex items-center gap-1.5 text-sm text-muted-foreground">
          <MapPin aria-hidden className="size-3.5" />
          {order.deliveryAddress.area} · {order.deliveryAddress.city}
        </p>
        <p className="text-xs text-muted-foreground">
          {t("itemsCount", { count: order.items.length })}
        </p>
      </div>
      <div className="flex flex-col items-end gap-2">
        <span className="text-base font-bold text-emerald-700 dark:text-emerald-300">{earnings}</span>
        <Button size="sm" onClick={onTake} data-testid={`accept-${order.id}`}>
          {t("takeOrder")}
        </Button>
      </div>
    </article>
  );
}

function FeedSkeleton() {
  return (
    <div className="space-y-3" aria-hidden>
      <Skeleton className="h-20 w-full rounded-2xl" />
      <Skeleton className="h-20 w-full rounded-2xl" />
    </div>
  );
}

export const __test__ = { LoaderIcon: Loader2 };
