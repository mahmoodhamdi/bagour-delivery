"use client";

import {
  Bike,
  Check,
  ChefHat,
  CircleDashed,
  Package,
  PackageCheck,
  ShieldX,
  ShoppingBag,
} from "lucide-react";
import { useLocale, useTranslations } from "next-intl";
import type { LucideIcon } from "lucide-react";

import type { Order, OrderStatus } from "@bagour/types";

import { cn } from "@/lib/utils";

const STAGE_ORDER: OrderStatus[] = [
  "pending",
  "confirmed",
  "preparing",
  "ready",
  "picked_up",
  "on_the_way",
  "delivered",
];

const STAGE_ICONS: Record<OrderStatus, LucideIcon> = {
  pending: CircleDashed,
  confirmed: Check,
  preparing: ChefHat,
  ready: Package,
  picked_up: ShoppingBag,
  on_the_way: Bike,
  delivered: PackageCheck,
  cancelled: ShieldX,
};

interface OrderStatusTimelineProps {
  order: Pick<Order, "status" | "statusHistory">;
}

export function OrderStatusTimeline({ order }: OrderStatusTimelineProps) {
  const t = useTranslations("Orders.status");
  const locale = useLocale();

  const cancelled = order.status === "cancelled";
  const currentIdx = cancelled ? -1 : STAGE_ORDER.indexOf(order.status);

  const formatter = new Intl.DateTimeFormat(locale === "ar" ? "ar-EG" : "en-US", {
    hour: "2-digit",
    minute: "2-digit",
  });

  const stageHistory = (s: OrderStatus) => order.statusHistory.find((h) => h.status === s);

  if (cancelled) {
    const entry = stageHistory("cancelled");
    return (
      <section
        aria-label={t("cancelled")}
        className="rounded-2xl border border-destructive/30 bg-destructive/5 p-4 text-destructive"
        data-testid="status-cancelled"
      >
        <header className="flex items-center gap-3">
          <span className="inline-flex size-9 items-center justify-center rounded-full bg-destructive text-white">
            <ShieldX aria-hidden className="size-5" />
          </span>
          <div>
            <h2 className="font-bold">{t("cancelled")}</h2>
            {entry ? (
              <p className="text-xs">
                {formatter.format(new Date(entry.timestamp))}
                {entry.note ? ` · ${entry.note}` : ""}
              </p>
            ) : null}
          </div>
        </header>
      </section>
    );
  }

  return (
    <ol
      className="space-y-3 rounded-2xl border bg-card p-4"
      data-testid="status-timeline"
      aria-label="Order status"
    >
      {STAGE_ORDER.map((stage, idx) => {
        const Icon = STAGE_ICONS[stage];
        const reached = currentIdx >= idx;
        const isCurrent = currentIdx === idx;
        const entry = stageHistory(stage);

        return (
          <li
            key={stage}
            className={cn(
              "flex items-center gap-3 rounded-xl p-2",
              isCurrent && "bg-primary/5 ring-1 ring-primary/30",
            )}
            data-testid={`status-stage-${stage}`}
            aria-current={isCurrent ? "step" : undefined}
          >
            <span
              className={cn(
                "inline-flex size-9 shrink-0 items-center justify-center rounded-full transition-colors",
                reached ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground",
              )}
            >
              <Icon aria-hidden className="size-5" />
            </span>
            <div className="flex-1">
              <p
                className={cn(
                  "font-semibold",
                  reached ? "text-foreground" : "text-muted-foreground",
                )}
              >
                {t(stage)}
              </p>
              {entry ? (
                <p className="text-xs text-muted-foreground">
                  {formatter.format(new Date(entry.timestamp))}
                </p>
              ) : null}
            </div>
          </li>
        );
      })}
    </ol>
  );
}
