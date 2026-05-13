"use client";

import * as Dialog from "@radix-ui/react-dialog";
import { Bike, Check, Loader2, X } from "lucide-react";
import { useLocale, useTranslations } from "next-intl";
import { useEffect, useState } from "react";
import { toast } from "sonner";

import type { Order } from "@bagour/types";
import { ApiError } from "@bagour/api-client";

import { Button } from "@/components/ui/button";
import { useAcceptOrder, useRejectOrder } from "@/lib/hooks/use-driver-orders";
import { formatCurrency } from "@/lib/format";
import { useRouter } from "@/i18n/navigation";

const COUNTDOWN_SECONDS = 30;

interface AcceptOrderModalProps {
  order: Order;
  onClose: () => void;
}

/**
 * Acceptance dialog. 30-second countdown with vibration + sound.
 * Tapping accept POSTs to the backend and routes to /active/{id}; tapping
 * pass dismisses (and optionally posts a reject so this driver isn't
 * offered the same order again immediately).
 *
 * When the countdown hits zero we auto-pass silently.
 */
export function AcceptOrderModal({ order, onClose }: AcceptOrderModalProps) {
  const t = useTranslations("Orders");
  const locale = useLocale();
  const router = useRouter();
  const accept = useAcceptOrder();
  const reject = useRejectOrder();
  const [remaining, setRemaining] = useState(COUNTDOWN_SECONDS);

  // Vibrate + countdown.
  useEffect(() => {
    if (typeof navigator !== "undefined" && "vibrate" in navigator) {
      navigator.vibrate([300, 150, 300]);
    }

    const id = window.setInterval(() => {
      setRemaining((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => window.clearInterval(id);
  }, []);

  // Auto-pass when timer runs out.
  useEffect(() => {
    if (remaining === 0) {
      onClose();
    }
  }, [remaining, onClose]);

  const handleAccept = async () => {
    try {
      const taken = await accept.mutateAsync(order.id);
      toast.success(t("toasts.accepted", { orderNumber: taken.orderNumber }));
      onClose();
      router.push(`/active/${taken.id}`);
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : t("toasts.acceptFailed"));
    }
  };

  const handlePass = async () => {
    try {
      await reject.mutateAsync({ id: order.id, reason: "driver_passed" });
    } catch {
      // Silent — pass is best-effort.
    }
    onClose();
  };

  return (
    <Dialog.Root open onOpenChange={(open) => !open && onClose()}>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 z-50 bg-black/60 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0" />
        <Dialog.Content
          className="fixed inset-x-4 top-1/2 z-50 mx-auto max-w-md -translate-y-1/2 rounded-3xl border bg-background p-6 shadow-2xl data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0"
          data-testid="accept-modal"
        >
          <Dialog.Close
            className="absolute end-4 top-4 rounded-md opacity-70 hover:opacity-100 focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
            aria-label={t("actions.close")}
          >
            <X aria-hidden className="size-5" />
          </Dialog.Close>

          <div className="flex items-center gap-3">
            <span className="inline-flex size-12 items-center justify-center rounded-full bg-primary/10 text-primary">
              <Bike aria-hidden className="size-6" />
            </span>
            <div>
              <Dialog.Title className="text-xl font-bold">{t("modalTitle")}</Dialog.Title>
              <Dialog.Description className="text-sm text-muted-foreground">
                {t("modalSubtitle", { orderNumber: order.orderNumber })}
              </Dialog.Description>
            </div>
          </div>

          <dl className="mt-6 grid grid-cols-2 gap-4 text-sm">
            <div>
              <dt className="text-xs font-medium uppercase tracking-widest text-muted-foreground">
                {t("modal.earnings")}
              </dt>
              <dd className="text-xl font-bold text-emerald-700 dark:text-emerald-300">
                {formatCurrency(order.driverEarnings, locale)}
              </dd>
            </div>
            <div>
              <dt className="text-xs font-medium uppercase tracking-widest text-muted-foreground">
                {t("modal.area")}
              </dt>
              <dd className="text-base font-semibold">
                {order.deliveryAddress.area} · {order.deliveryAddress.city}
              </dd>
            </div>
            <div>
              <dt className="text-xs font-medium uppercase tracking-widest text-muted-foreground">
                {t("modal.items")}
              </dt>
              <dd className="text-base font-semibold">
                {t("itemsCount", { count: order.items.length })}
              </dd>
            </div>
            <div>
              <dt className="text-xs font-medium uppercase tracking-widest text-muted-foreground">
                {t("modal.payment")}
              </dt>
              <dd className="text-base font-semibold">{t(`payment.${order.paymentMethod}`)}</dd>
            </div>
          </dl>

          <div className="mt-6">
            <div className="h-2 w-full overflow-hidden rounded-full bg-muted">
              <div
                className="h-full bg-primary transition-all duration-1000 ease-linear"
                style={{ width: `${(remaining / COUNTDOWN_SECONDS) * 100}%` }}
                aria-hidden
              />
            </div>
            <p className="mt-2 text-xs text-muted-foreground" aria-live="polite">
              {t("modal.expiresIn", { seconds: remaining })}
            </p>
          </div>

          <div className="mt-6 flex gap-3">
            <Button
              type="button"
              variant="outline"
              className="flex-1"
              onClick={() => void handlePass()}
              disabled={reject.isPending}
              data-testid="accept-modal-pass"
            >
              {reject.isPending ? (
                <Loader2 aria-hidden className="size-4 animate-spin" />
              ) : null}
              {t("actions.pass")}
            </Button>
            <Button
              type="button"
              variant="success"
              className="flex-1"
              onClick={() => void handleAccept()}
              disabled={accept.isPending}
              data-testid="accept-modal-accept"
            >
              {accept.isPending ? (
                <Loader2 aria-hidden className="size-4 animate-spin" />
              ) : (
                <Check aria-hidden className="size-4" />
              )}
              {t("actions.accept")}
            </Button>
          </div>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
