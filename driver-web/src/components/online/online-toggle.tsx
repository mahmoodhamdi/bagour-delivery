"use client";

import { Loader2, MapPin, Power, PowerOff, Wifi, WifiOff } from "lucide-react";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";
import { toast } from "sonner";

import type { Driver } from "@bagour/types";
import { ApiError } from "@bagour/api-client";

import { Button } from "@/components/ui/button";
import { useDriverLocation } from "@/lib/hooks/use-driver-location";
import { useToggleDriverOnline } from "@/lib/hooks/use-driver-online";
import { useWakeLock } from "@/lib/hooks/use-wake-lock";
import { cn } from "@/lib/utils";

interface OnlineToggleProps {
  driver: Driver;
}

/**
 * Big toggle on the driver home screen. When the driver goes online:
 *   1. POST /drivers/online → backend marks them online
 *   2. Request screen Wake Lock so the screen doesn't sleep mid-shift
 *   3. Subscribe to geolocation.watchPosition and push updates upstream
 * When they go offline, all three are reversed.
 */
export function OnlineToggle({ driver }: OnlineToggleProps) {
  const t = useTranslations("Online");
  const toggle = useToggleDriverOnline();
  const wakeLock = useWakeLock();

  // Derive directly from the server snapshot — TanStack Query updates the
  // cache via `onSuccess`, which re-renders this component with the new
  // `driver.isOnline`. No local state needed.
  const isOnline = driver.isOnline;
  const location = useDriverLocation({ enabled: isOnline });

  const handleToggle = async () => {
    const next = !isOnline;
    try {
      await toggle.mutateAsync(next);
      if (next) {
        toast.success(t("toasts.online"));
        const granted = await wakeLock.request();
        if (!granted && wakeLock.isSupported) {
          toast.info(t("toasts.wakeLockDenied"));
        }
      } else {
        toast.success(t("toasts.offline"));
        await wakeLock.release();
      }
    } catch (err) {
      toast.error(err instanceof ApiError ? err.message : t("toasts.toggleFailed"));
    }
  };

  // Re-render every second so "last update" stays accurate without
  // recomputing inside useMemo (which would be impure).
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    if (!isOnline) return undefined;
    const id = window.setInterval(() => setNow(Date.now()), 1000);
    return () => window.clearInterval(id);
  }, [isOnline]);

  const lastUpdate = location.lastSentAt
    ? (() => {
        const seconds = Math.max(0, Math.floor((now - location.lastSentAt) / 1000));
        return seconds < 60 ? `${seconds}s` : `${Math.floor(seconds / 60)}m`;
      })()
    : null;

  const isApproved = driver.status === "approved";

  if (!isApproved) {
    return (
      <div
        role="status"
        className="rounded-2xl border border-amber-300 bg-amber-50 p-5 text-amber-900 dark:border-amber-800 dark:bg-amber-950/40 dark:text-amber-100"
        data-testid="online-toggle-blocked"
      >
        <p className="text-sm font-medium">{t("notApprovedYet")}</p>
      </div>
    );
  }

  return (
    <div
      className={cn(
        "flex flex-col gap-4 rounded-3xl border p-5 transition-colors md:flex-row md:items-center md:gap-6",
        isOnline
          ? "border-emerald-500/40 bg-emerald-50 dark:bg-emerald-950/30"
          : "border-input bg-card",
      )}
      data-testid="online-toggle"
      data-state={isOnline ? "online" : "offline"}
    >
      <div className="flex-1 space-y-1">
        <p
          className={cn(
            "text-xs font-semibold uppercase tracking-widest",
            isOnline ? "text-emerald-600 dark:text-emerald-300" : "text-muted-foreground",
          )}
        >
          {isOnline ? t("statusOnline") : t("statusOffline")}
        </p>
        <h2 className="text-2xl font-bold">
          {isOnline ? t("headlineOnline") : t("headlineOffline")}
        </h2>
        <p className="text-sm text-muted-foreground">
          {isOnline ? t("descOnline") : t("descOffline")}
        </p>

        {isOnline ? (
          <ul className="mt-3 flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
            <li className="inline-flex items-center gap-1.5">
              <MapPin aria-hidden className="size-3.5" />
              {location.lastFix
                ? t("locationTracking", {
                    lat: location.lastFix.latitude.toFixed(4),
                    lng: location.lastFix.longitude.toFixed(4),
                  })
                : t("locationWaiting")}
            </li>
            {wakeLock.isSupported ? (
              <li className="inline-flex items-center gap-1.5">
                {wakeLock.isHeld ? (
                  <Wifi aria-hidden className="size-3.5" />
                ) : (
                  <WifiOff aria-hidden className="size-3.5" />
                )}
                {wakeLock.isHeld ? t("wakeLockHeld") : t("wakeLockOff")}
              </li>
            ) : null}
            {lastUpdate ? (
              <li className="inline-flex items-center gap-1.5">
                {t("lastUpdate", { ago: lastUpdate })}
              </li>
            ) : null}
          </ul>
        ) : null}

        {location.error && isOnline ? (
          <p role="alert" className="mt-2 text-xs font-medium text-destructive">
            {t("locationError", { error: location.error })}
          </p>
        ) : null}
      </div>

      <Button
        type="button"
        size="lg"
        variant={isOnline ? "destructive" : "success"}
        className="min-w-44"
        onClick={() => void handleToggle()}
        disabled={toggle.isPending}
        data-testid="online-toggle-button"
      >
        {toggle.isPending ? (
          <Loader2 aria-hidden className="size-5 animate-spin" />
        ) : isOnline ? (
          <PowerOff aria-hidden className="size-5" />
        ) : (
          <Power aria-hidden className="size-5" />
        )}
        {isOnline ? t("actions.goOffline") : t("actions.goOnline")}
      </Button>
    </div>
  );
}
