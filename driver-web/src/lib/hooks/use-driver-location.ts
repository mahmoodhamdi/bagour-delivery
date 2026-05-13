"use client";

import { useCallback, useEffect, useRef, useState } from "react";

import { useApi } from "@/lib/api-context";
import { distanceMeters } from "@/lib/geo";

interface UseDriverLocationOptions {
  /** Stream is only active while this is `true`. */
  enabled: boolean;
  /** Minimum ms between server updates while moving. Default 5 s. */
  minIntervalMs?: number;
  /** Minimum meters since last sent fix before we POST again. Default 25 m. */
  minMeters?: number;
}

interface LocationState {
  lastFix?: GeolocationCoordinates;
  lastSentAt?: number;
  error?: string;
}

/**
 * Foreground-only location stream. Subscribes to `geolocation.watchPosition`
 * while `enabled` is true and pushes debounced + thresholded updates to
 * `api.drivers.updateLocation`.
 *
 * NOTE: Browsers can't background-track without a paid hosted PWA push
 * service. We accept that limitation — driver must keep the tab open.
 */
export function useDriverLocation({
  enabled,
  minIntervalMs = 5_000,
  minMeters = 25,
}: UseDriverLocationOptions) {
  const api = useApi();
  const [state, setState] = useState<LocationState>({});
  const lastSentRef = useRef<{ fix: GeolocationCoordinates; at: number } | null>(null);

  const send = useCallback(
    async (coords: GeolocationCoordinates) => {
      try {
        await api.drivers.updateLocation({
          coordinates: [coords.longitude, coords.latitude],
          heading: coords.heading ?? undefined,
          speed: coords.speed ?? undefined,
          accuracy: coords.accuracy ?? undefined,
        });
        lastSentRef.current = { fix: coords, at: Date.now() };
        setState((s) => ({ ...s, lastSentAt: Date.now(), error: undefined }));
      } catch (err) {
        setState((s) => ({ ...s, error: err instanceof Error ? err.message : "send_failed" }));
      }
    },
    [api],
  );

  useEffect(() => {
    if (!enabled || typeof navigator === "undefined" || !("geolocation" in navigator)) {
      return undefined;
    }

    const onPosition = (pos: GeolocationPosition) => {
      setState((s) => ({ ...s, lastFix: pos.coords }));

      const last = lastSentRef.current;
      const now = Date.now();
      const enoughTime = !last || now - last.at >= minIntervalMs;
      const enoughDistance = !last || distanceMeters(last.fix, pos.coords) >= minMeters;

      if (enoughTime && enoughDistance) {
        void send(pos.coords);
      }
    };

    const onError = (err: GeolocationPositionError) => {
      setState((s) => ({ ...s, error: err.message || `geo_${err.code}` }));
    };

    const watchId = navigator.geolocation.watchPosition(onPosition, onError, {
      enableHighAccuracy: true,
      maximumAge: 5_000,
      timeout: 15_000,
    });

    return () => navigator.geolocation.clearWatch(watchId);
  }, [enabled, minIntervalMs, minMeters, send]);

  return state;
}
