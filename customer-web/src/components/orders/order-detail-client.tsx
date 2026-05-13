"use client";

import { Loader2, Repeat, Star } from "lucide-react";
import { useTranslations } from "next-intl";
import { useState } from "react";
import { toast } from "sonner";

import { ApiError } from "@bagour/api-client";

import { Button } from "@/components/ui/button";
import { Link, useRouter } from "@/i18n/navigation";
import { useCancelOrder, useOrder, useReorder } from "@/lib/hooks/use-orders";

import { OrderDetailsCard } from "./order-details-card";
import { OrderStatusTimeline } from "./order-status-timeline";

const CANCELLABLE = new Set(["pending", "confirmed"]);

export function OrderDetailClient({ orderId }: { orderId: string }) {
  const t = useTranslations();
  const router = useRouter();
  const orderQuery = useOrder(orderId);
  const cancel = useCancelOrder();
  const reorder = useReorder();
  const [cancelling, setCancelling] = useState(false);

  if (orderQuery.isLoading) {
    return (
      <div
        className="flex min-h-[40vh] items-center justify-center text-muted-foreground"
        role="status"
      >
        <Loader2 aria-hidden className="size-6 animate-spin" />
      </div>
    );
  }

  if (orderQuery.isError || !orderQuery.data) {
    return (
      <div role="alert" className="space-y-3">
        <p className="rounded-lg border border-destructive/30 bg-destructive/10 p-4 text-sm font-medium text-destructive">
          {t("Common.error")}
        </p>
        <Button asChild variant="outline">
          <Link href="/orders">{t("Orders.backToList")}</Link>
        </Button>
      </div>
    );
  }

  const order = orderQuery.data;
  const canCancel = CANCELLABLE.has(order.status);
  const isFinished = order.status === "delivered" || order.status === "cancelled";
  const hasReview = !!order.rating?.overall;

  const handleCancel = async () => {
    const reason = window.prompt(t("Orders.cancelPrompt"));
    if (!reason) return;
    setCancelling(true);
    try {
      await cancel.mutateAsync({ id: order.id, reason });
      toast.success(t("Orders.toasts.cancelled"));
    } catch (err) {
      if (err instanceof ApiError) {
        toast.error(err.message);
      } else {
        toast.error(t("Common.error"));
      }
    } finally {
      setCancelling(false);
    }
  };

  const handleReorder = async () => {
    try {
      await reorder.mutateAsync(order.id);
      toast.success(t("Orders.toasts.reordered"));
      router.push(`/restaurants/${order.restaurantId}`);
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : t("Common.error"));
    }
  };

  return (
    <div className="grid gap-6 lg:grid-cols-[1fr_360px]">
      <div className="space-y-6">
        <OrderStatusTimeline order={order} />

        {isFinished ? (
          <div className="flex flex-wrap gap-3">
            {order.status === "delivered" && !hasReview ? (
              <Button asChild data-testid="rate-order">
                <Link href={`/orders/${order.id}/review`}>
                  <Star aria-hidden className="size-4" />
                  {t("Reviews.cta.rate")}
                </Link>
              </Button>
            ) : null}
            {order.status === "delivered" && hasReview ? (
              <Button asChild variant="outline">
                <Link href={`/orders/${order.id}/review`}>
                  <Star aria-hidden className="size-4" />
                  {t("Reviews.cta.editReview")}
                </Link>
              </Button>
            ) : null}
            <Button
              variant="outline"
              onClick={() => void handleReorder()}
              disabled={reorder.isPending}
              data-testid="reorder-order"
            >
              {reorder.isPending ? (
                <Loader2 aria-hidden className="size-4 animate-spin" />
              ) : (
                <Repeat aria-hidden className="size-4" />
              )}
              {t("Orders.actions.reorder")}
            </Button>
          </div>
        ) : null}

        {canCancel ? (
          <Button
            variant="outline"
            onClick={() => void handleCancel()}
            disabled={cancelling}
            data-testid="order-cancel"
            className="text-destructive"
          >
            {cancelling ? <Loader2 aria-hidden className="size-4 animate-spin" /> : null}
            {t("Orders.actions.cancelOrder")}
          </Button>
        ) : null}
      </div>

      <OrderDetailsCard order={order} />
    </div>
  );
}
