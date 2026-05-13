"use client";

import { useCallback, useEffect, useRef, useState } from "react";

/**
 * Screen Wake Lock — keeps the device screen on while the driver is
 * actively delivering. Wake Lock requires a user gesture in some browsers,
 * so `request()` should be called from a button click rather than
 * automatically on mount.
 *
 * Re-acquires the lock when the page becomes visible again (browsers
 * automatically release it on tab hide).
 */
export function useWakeLock() {
  const lockRef = useRef<WakeLockSentinel | null>(null);
  const [isHeld, setIsHeld] = useState(false);
  // Lazy init avoids the "setState inside useEffect" anti-pattern. `navigator`
  // is `undefined` during SSR, which is handled by the typeof guard.
  const [isSupported] = useState<boolean>(() =>
    typeof navigator !== "undefined" && "wakeLock" in navigator,
  );

  const release = useCallback(async () => {
    if (lockRef.current) {
      try {
        await lockRef.current.release();
      } catch {
        // Ignore — browser may have already released it.
      }
      lockRef.current = null;
    }
    setIsHeld(false);
  }, []);

  const request = useCallback(async (): Promise<boolean> => {
    if (!isSupported) return false;
    if (lockRef.current) return true;
    try {
      const lock = await navigator.wakeLock.request("screen");
      lock.addEventListener("release", () => {
        if (lockRef.current === lock) {
          lockRef.current = null;
          setIsHeld(false);
        }
      });
      lockRef.current = lock;
      setIsHeld(true);
      return true;
    } catch {
      return false;
    }
  }, [isSupported]);

  // Browsers auto-release on tab hide. Re-acquire when visible again so the
  // screen doesn't fall asleep mid-delivery.
  useEffect(() => {
    if (!isSupported) return undefined;
    const handler = () => {
      if (document.visibilityState === "visible" && isHeld && !lockRef.current) {
        void request();
      }
    };
    document.addEventListener("visibilitychange", handler);
    return () => document.removeEventListener("visibilitychange", handler);
  }, [isHeld, isSupported, request]);

  // Always release on unmount.
  useEffect(() => {
    return () => {
      void release();
    };
  }, [release]);

  return { request, release, isHeld, isSupported };
}
