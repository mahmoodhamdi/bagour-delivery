"use client";

import { useEffect, useState } from "react";

interface Position {
  longitude: number;
  latitude: number;
  accuracy: number;
}

interface PositionState {
  position: Position | null;
  error: string | null;
  isLoading: boolean;
}

/**
 * One-shot geolocation reader for views that only need the driver's
 * current position (e.g. for plotting on a static map). Not a stream —
 * use `useDriverLocation` for the streaming case.
 *
 * Lazy-init the state once based on geolocation availability so we
 * don't `setState` inside the effect body (React 19 anti-pattern).
 */
export function useCurrentPosition(): PositionState {
  const supported =
    typeof navigator !== "undefined" && "geolocation" in navigator;
  const [state, setState] = useState<PositionState>(() => ({
    position: null,
    error: supported ? null : "unsupported",
    isLoading: supported,
  }));

  useEffect(() => {
    if (!supported) return;

    let cancelled = false;
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        if (cancelled) return;
        setState({
          position: {
            longitude: pos.coords.longitude,
            latitude: pos.coords.latitude,
            accuracy: pos.coords.accuracy,
          },
          error: null,
          isLoading: false,
        });
      },
      (err) => {
        if (cancelled) return;
        setState({
          position: null,
          error: err.message || `geo_${err.code}`,
          isLoading: false,
        });
      },
      { enableHighAccuracy: true, timeout: 10_000, maximumAge: 30_000 },
    );

    return () => {
      cancelled = true;
    };
  }, [supported]);

  return state;
}
