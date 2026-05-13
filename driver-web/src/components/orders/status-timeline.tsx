"use client";

import type { OrderStatus } from "@bagour/types";
import { CheckCheck, ChefHat, MapPin, PackageCheck, ThumbsUp, X } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { useTranslations } from "next-intl";

import { cn } from "@/lib/utils";

const STAGES: { status: OrderStatus; icon: LucideIcon }[] = [
  { status: "confirmed", icon: ThumbsUp },
  { status: "preparing", icon: ChefHat },
  { status: "ready", icon: PackageCheck },
  { status: "picked_up", icon: PackageCheck },
  { status: "on_the_way", icon: MapPin },
  { status: "delivered", icon: CheckCheck },
];

interface StatusTimelineProps {
  current: OrderStatus;
}

const ORDER: Record<OrderStatus, number> = {
  pending: 0,
  confirmed: 1,
  preparing: 2,
  ready: 3,
  picked_up: 4,
  on_the_way: 5,
  delivered: 6,
  cancelled: 99,
};

export function StatusTimeline({ current }: StatusTimelineProps) {
  const t = useTranslations("Orders.status");

  if (current === "cancelled") {
    return (
      <div className="flex items-center gap-2 rounded-2xl border border-destructive/30 bg-destructive/10 p-3 text-sm font-medium text-destructive">
        <X aria-hidden className="size-4" />
        {t("cancelled")}
      </div>
    );
  }

  const currentIndex = ORDER[current];

  return (
    <ol className="grid grid-cols-6 gap-1.5" aria-label="Order status timeline">
      {STAGES.map(({ status, icon: Icon }, i) => {
        const reached = ORDER[status] <= currentIndex;
        const active = ORDER[status] === currentIndex;
        return (
          <li key={status} className="flex flex-col items-center text-center">
            <span
              className={cn(
                "inline-flex size-9 items-center justify-center rounded-full border transition-colors",
                reached
                  ? "border-primary bg-primary text-primary-foreground"
                  : "border-input bg-card text-muted-foreground",
                active && "ring-2 ring-primary ring-offset-2 ring-offset-background",
              )}
              aria-current={active ? "step" : undefined}
              data-testid={`timeline-${status}`}
            >
              <Icon aria-hidden className="size-4" />
              <span className="sr-only">{i + 1}.</span>
            </span>
            <span
              className={cn(
                "mt-1 text-[10px] font-medium md:text-xs",
                reached ? "text-foreground" : "text-muted-foreground",
              )}
            >
              {t(status)}
            </span>
          </li>
        );
      })}
    </ol>
  );
}

export const __test__ = { ORDER, STAGES };
