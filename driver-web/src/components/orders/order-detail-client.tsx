"use client";

import { AlertTriangle, ArrowLeft, Camera, Loader2, MapPin, Phone, Receipt } from "lucide-react";
import { useLocale, useTranslations } from "next-intl";
import { use, useRef, useState } from "react";
import { toast } from "sonner";

import type { Order } from "@bagour/types";
import { ApiError } from "@bagour/api-client";

import { RouteMap } from "@/components/maps/route-map";
import { ProtectedRoute } from "@/components/protected-route";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Link } from "@/i18n/navigation";
import { useCurrentPosition } from "@/lib/hooks/use-current-position";
import { useDriverOrder, useMarkDelivered, useMarkOnTheWay, useMarkPickedUp, useUploadDeliveryProof } from "@/lib/hooks/use-driver-order";
import { useOsrmRoute } from "@/lib/hooks/use-osrm-route";
import { formatCurrency, formatTimeAgo } from "@/lib/format";

import { StatusTimeline } from "./status-timeline";

interface OrderDetailClientProps {
  params: Promise<{ id: string }>;
}

export function OrderDetailClient({ params }: OrderDetailClientProps) {
  const { id } = use(params);
  const t = useTranslations();
  const locale = useLocale();
  const order = useDriverOrder(id);
  const pickup = useMarkPickedUp();
  const onTheWay = useMarkOnTheWay();
  const deliver = useMarkDelivered();
  const upload = useUploadDeliveryProof();
  const fileRef = useRef<HTMLInputElement>(null);
  const [proofUrl, setProofUrl] = useState<string | undefined>(undefined);
  const myPos = useCurrentPosition();
  const dest: [number, number] | null = order.data
    ? order.data.deliveryLocation.coordinates
    : null;
  const from: [number, number] | null = myPos.position
    ? [myPos.position.longitude, myPos.position.latitude]
    : null;
  const routeQuery = useOsrmRoute({ from, to: dest });

  if (order.isLoading) {
    return (
      <ProtectedRoute>
        <main className="container mx-auto max-w-2xl px-4 py-8">
          <Skeleton className="h-12 w-1/2" />
          <Skeleton className="mt-4 h-40 w-full" />
        </main>
      </ProtectedRoute>
    );
  }

  if (order.isError || !order.data) {
    return (
      <ProtectedRoute>
        <main className="container mx-auto max-w-2xl px-4 py-8">
          <div
            role="alert"
            className="flex items-center gap-2 rounded-2xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive"
          >
            <AlertTriangle aria-hidden className="size-4" />
            {t("Orders.loadError")}
          </div>
          <Link href="/active" className="mt-4 inline-flex text-sm font-medium underline">
            <ArrowLeft aria-hidden className="me-2 size-4 rtl:rotate-180" />
            {t("Orders.backToActive")}
          </Link>
        </main>
      </ProtectedRoute>
    );
  }

  const o: Order = order.data;

  const handleProofPick = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    e.target.value = "";
    if (!file) return;
    try {
      const res = await upload.mutateAsync(file);
      setProofUrl(res.url);
      toast.success(t("Orders.toasts.proofUploaded"));
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : t("Orders.toasts.proofFailed"));
    }
  };

  const runAction = async (
    action: "pickup" | "onTheWay" | "delivered",
  ) => {
    try {
      if (action === "pickup") {
        await pickup.mutateAsync(o.id);
        toast.success(t("Orders.toasts.pickedUp"));
      } else if (action === "onTheWay") {
        await onTheWay.mutateAsync(o.id);
        toast.success(t("Orders.toasts.onTheWay"));
      } else {
        await deliver.mutateAsync({ id: o.id, proofUrl });
        toast.success(t("Orders.toasts.delivered"));
      }
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : t("Common.error"));
    }
  };

  const nextActionLabel = (() => {
    switch (o.status) {
      case "ready":
      case "confirmed":
      case "preparing":
        return t("Orders.actions.pickup");
      case "picked_up":
        return t("Orders.actions.onTheWay");
      case "on_the_way":
        return t("Orders.actions.delivered");
      default:
        return null;
    }
  })();

  const handleNext = () => {
    switch (o.status) {
      case "ready":
      case "confirmed":
      case "preparing":
        return void runAction("pickup");
      case "picked_up":
        return void runAction("onTheWay");
      case "on_the_way":
        return void runAction("delivered");
      default:
        return undefined;
    }
  };

  const canPickUp = o.status === "ready";
  const canDeliver = o.status === "on_the_way" && !!proofUrl;
  const nextDisabled =
    pickup.isPending || onTheWay.isPending || deliver.isPending || upload.isPending;

  return (
    <ProtectedRoute>
      <main
        id="main"
        className="container mx-auto max-w-2xl px-4 py-6 md:py-10"
        data-testid="order-detail"
      >
        <Link
          href="/active"
          className="mb-4 inline-flex items-center gap-1 text-sm font-medium text-muted-foreground hover:text-foreground"
        >
          <ArrowLeft aria-hidden className="size-4 rtl:rotate-180" />
          {t("Orders.backToActive")}
        </Link>

        <header className="mb-6 space-y-1">
          <h1 className="text-2xl font-bold tracking-tight">#{o.orderNumber}</h1>
          <p className="text-sm text-muted-foreground">
            {formatTimeAgo(o.createdAt, locale)} · {t(`Orders.payment.${o.paymentMethod}`)}
          </p>
        </header>

        <StatusTimeline current={o.status} />

        <div className="mt-6">
          <RouteMap
            from={from}
            to={dest}
            route={routeQuery.data?.geometry ?? null}
            ariaLabel={t("Orders.detail.mapLabel")}
          />
          {routeQuery.data ? (
            <p className="mt-2 text-xs text-muted-foreground">
              {t("Orders.detail.routeStats", {
                km: (routeQuery.data.distance / 1000).toFixed(1),
                mins: Math.round(routeQuery.data.duration / 60),
              })}
            </p>
          ) : null}
        </div>

        <section className="mt-6 space-y-4">
          <div className="rounded-2xl border bg-card p-4">
            <h2 className="text-sm font-semibold uppercase tracking-widest text-muted-foreground">
              {t("Orders.detail.deliveryAddress")}
            </h2>
            <p className="mt-2 inline-flex items-start gap-2 text-base">
              <MapPin aria-hidden className="mt-0.5 size-4 text-primary" />
              <span>
                {o.deliveryAddress.street}, {o.deliveryAddress.area}, {o.deliveryAddress.city}
                {o.deliveryAddress.buildingNumber
                  ? ` · ${t("Orders.detail.buildingShort")} ${o.deliveryAddress.buildingNumber}`
                  : null}
              </span>
            </p>
            {o.deliveryInstructions ? (
              <p className="mt-2 text-sm text-muted-foreground">{o.deliveryInstructions}</p>
            ) : null}
          </div>

          <div className="rounded-2xl border bg-card p-4">
            <h2 className="mb-2 flex items-center gap-2 text-sm font-semibold uppercase tracking-widest text-muted-foreground">
              <Receipt aria-hidden className="size-4" />
              {t("Orders.detail.items")}
            </h2>
            <ul className="divide-y">
              {o.items.map((item, idx) => (
                <li key={`${item.menuItemId}-${idx}`} className="flex items-start gap-3 py-2">
                  <span className="text-sm font-medium text-muted-foreground">×{item.quantity}</span>
                  <div className="flex-1">
                    <p className="text-sm font-medium">{item.name}</p>
                    {item.specialInstructions ? (
                      <p className="text-xs text-muted-foreground">{item.specialInstructions}</p>
                    ) : null}
                  </div>
                  <span className="text-sm font-medium">{formatCurrency(item.itemTotal, locale)}</span>
                </li>
              ))}
            </ul>
            <dl className="mt-3 space-y-1 border-t pt-3 text-sm">
              <div className="flex items-center justify-between text-muted-foreground">
                <dt>{t("Orders.detail.subtotal")}</dt>
                <dd>{formatCurrency(o.subtotal, locale)}</dd>
              </div>
              <div className="flex items-center justify-between text-muted-foreground">
                <dt>{t("Orders.detail.deliveryFee")}</dt>
                <dd>{formatCurrency(o.deliveryFee, locale)}</dd>
              </div>
              <div className="flex items-center justify-between font-semibold">
                <dt>{t("Orders.detail.total")}</dt>
                <dd>{formatCurrency(o.total, locale)}</dd>
              </div>
              <div className="mt-2 flex items-center justify-between border-t pt-2 text-emerald-700 dark:text-emerald-300">
                <dt className="font-semibold">{t("Orders.detail.yourEarnings")}</dt>
                <dd className="font-bold">{formatCurrency(o.driverEarnings, locale)}</dd>
              </div>
            </dl>
          </div>

          {o.status === "on_the_way" ? (
            <div className="rounded-2xl border bg-card p-4">
              <h2 className="mb-2 flex items-center gap-2 text-sm font-semibold uppercase tracking-widest text-muted-foreground">
                <Camera aria-hidden className="size-4" />
                {t("Orders.detail.deliveryProof")}
              </h2>
              <p className="text-sm text-muted-foreground">{t("Orders.detail.proofHint")}</p>
              <input
                ref={fileRef}
                type="file"
                accept="image/jpeg,image/png,image/webp"
                capture="environment"
                className="sr-only"
                onChange={(e) => void handleProofPick(e)}
              />
              <div className="mt-3 flex items-center gap-2">
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={() => fileRef.current?.click()}
                  disabled={upload.isPending}
                  data-testid="proof-upload"
                >
                  {upload.isPending ? (
                    <Loader2 aria-hidden className="size-4 animate-spin" />
                  ) : (
                    <Camera aria-hidden className="size-4" />
                  )}
                  {proofUrl ? t("Orders.actions.replaceProof") : t("Orders.actions.takeProof")}
                </Button>
                {proofUrl ? (
                  <span className="text-xs font-medium text-emerald-700 dark:text-emerald-300">
                    {t("Orders.detail.proofReady")}
                  </span>
                ) : null}
              </div>
            </div>
          ) : null}
        </section>

        {nextActionLabel ? (
          <div className="sticky bottom-20 z-10 mt-6 md:bottom-6">
            <Button
              type="button"
              size="lg"
              variant={canDeliver || canPickUp || o.status === "picked_up" ? "success" : "default"}
              className="w-full"
              onClick={handleNext}
              disabled={
                nextDisabled ||
                (o.status === "on_the_way" && !canDeliver) ||
                (o.status !== "ready" &&
                  o.status !== "picked_up" &&
                  o.status !== "on_the_way" &&
                  !canPickUp)
              }
              data-testid="next-action"
            >
              {nextDisabled ? <Loader2 aria-hidden className="size-4 animate-spin" /> : null}
              {nextActionLabel}
            </Button>
            {o.status !== "ready" && o.status !== "picked_up" && o.status !== "on_the_way" ? (
              <p className="mt-2 inline-flex items-center justify-center gap-2 text-center text-xs text-muted-foreground">
                <Phone aria-hidden className="size-3.5" />
                {t("Orders.detail.waitingRestaurant")}
              </p>
            ) : null}
          </div>
        ) : null}
      </main>
    </ProtectedRoute>
  );
}
