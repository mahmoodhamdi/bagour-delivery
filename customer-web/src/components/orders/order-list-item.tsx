"use client";

import { ChevronRight, Package } from "lucide-react";
import { useLocale, useTranslations } from "next-intl";

import type { Order } from "@bagour/types";
import { Constants } from "@bagour/types";

import { Link } from "@/i18n/navigation";
import { formatCurrency, formatNumber } from "@/lib/format";

interface OrderListItemProps {
  order: Order;
}

export function OrderListItem({ order }: OrderListItemProps) {
  const t = useTranslations("Orders");
  const locale = useLocale();

  const statusMeta = Constants.ORDER_STATUS_META[order.status];
  const label = locale === "ar" ? statusMeta.label : statusMeta.labelEn;

  const formatter = new Intl.DateTimeFormat(locale === "ar" ? "ar-EG" : "en-US", {
    day: "2-digit",
    month: "short",
    hour: "2-digit",
    minute: "2-digit",
  });

  return (
    <Link
      href={`/orders/${order.id}`}
      data-testid={`order-list-item-${order.id}`}
      className="flex items-center gap-3 rounded-2xl border bg-card p-4 transition-colors hover:bg-accent/40 focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
    >
      <div className="rounded-xl bg-accent/40 p-2 text-primary">
        <Package aria-hidden className="size-5" />
      </div>

      <div className="min-w-0 flex-1">
        <header className="flex flex-wrap items-center gap-2">
          <p className="font-semibold">{order.orderNumber}</p>
          <span
            className="rounded-full px-2 py-0.5 text-xs font-semibold text-white"
            style={{ backgroundColor: statusMeta.color }}
          >
            {label}
          </span>
        </header>
        <p className="mt-1 text-xs text-muted-foreground">
          {formatter.format(new Date(order.createdAt))} · {formatNumber(order.items.length, locale)}{" "}
          {t("itemsLabel")} · {formatCurrency(order.total, locale)}
        </p>
      </div>

      <ChevronRight aria-hidden className="size-5 shrink-0 text-muted-foreground rtl:rotate-180" />
    </Link>
  );
}
