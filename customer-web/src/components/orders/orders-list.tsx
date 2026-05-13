"use client";

import { Package } from "lucide-react";
import { useTranslations } from "next-intl";

import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Link } from "@/i18n/navigation";
import { useMyOrders } from "@/lib/hooks/use-orders";

import { OrderListItem } from "./order-list-item";

export function OrdersList() {
  const t = useTranslations("Orders");
  const query = useMyOrders({ limit: 20 });

  if (query.isLoading) {
    return (
      <ul aria-busy="true" className="space-y-3" data-testid="orders-loading">
        {[0, 1, 2].map((i) => (
          <li key={i}>
            <Skeleton className="h-20 w-full rounded-2xl" />
          </li>
        ))}
      </ul>
    );
  }

  if (query.isError || !query.data) {
    return (
      <p
        role="alert"
        className="rounded-lg border border-destructive/30 bg-destructive/10 p-4 text-sm font-medium text-destructive"
      >
        {t("loadError")}
      </p>
    );
  }

  const orders = query.data.data;

  if (orders.length === 0) {
    return (
      <div
        className="flex flex-col items-center gap-3 rounded-2xl border-2 border-dashed bg-card p-10 text-center"
        data-testid="orders-empty"
      >
        <Package aria-hidden className="size-10 text-muted-foreground" />
        <p className="font-semibold">{t("empty")}</p>
        <p className="text-sm text-muted-foreground">{t("emptyDesc")}</p>
        <Button asChild>
          <Link href="/restaurants">{t("browseRestaurants")}</Link>
        </Button>
      </div>
    );
  }

  return (
    <ul className="space-y-3" data-testid="orders-list">
      {orders.map((order) => (
        <li key={order.id}>
          <OrderListItem order={order} />
        </li>
      ))}
    </ul>
  );
}
