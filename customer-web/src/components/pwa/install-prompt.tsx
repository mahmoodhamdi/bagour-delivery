"use client";

import { Download, X } from "lucide-react";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

import { Button } from "@/components/ui/button";

interface BeforeInstallPromptEvent extends Event {
  readonly platforms: string[];
  readonly userChoice: Promise<{ outcome: "accepted" | "dismissed"; platform: string }>;
  prompt(): Promise<void>;
}

const DISMISS_KEY = "bagour-pwa-install-dismissed";
const DISMISS_DAYS = 14;

/**
 * Native PWA install prompt with a dismissable banner.
 *
 * We listen for `beforeinstallprompt` (Chromium-based browsers), store
 * the event, and show our own UI when the user hasn't dismissed recently.
 * iOS Safari doesn't fire this event — for iOS we'd need a separate
 * "Add to Home Screen" tooltip; out of scope for v1.
 */
export function InstallPrompt() {
  const t = useTranslations("Pwa");
  const [deferred, setDeferred] = useState<BeforeInstallPromptEvent | null>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const dismissedAt = Number(localStorage.getItem(DISMISS_KEY) ?? "0");
    const cutoff = Date.now() - DISMISS_DAYS * 24 * 60 * 60 * 1000;
    if (dismissedAt > cutoff) return;

    const handler = (e: Event) => {
      e.preventDefault();
      setDeferred(e as BeforeInstallPromptEvent);
      setVisible(true);
    };
    window.addEventListener("beforeinstallprompt", handler);

    const installed = () => {
      setVisible(false);
      setDeferred(null);
    };
    window.addEventListener("appinstalled", installed);

    return () => {
      window.removeEventListener("beforeinstallprompt", handler);
      window.removeEventListener("appinstalled", installed);
    };
  }, []);

  const handleInstall = async () => {
    if (!deferred) return;
    await deferred.prompt();
    const choice = await deferred.userChoice;
    if (choice.outcome === "accepted") {
      setVisible(false);
      setDeferred(null);
    } else {
      handleDismiss();
    }
  };

  const handleDismiss = () => {
    localStorage.setItem(DISMISS_KEY, String(Date.now()));
    setVisible(false);
  };

  if (!visible || !deferred) return null;

  return (
    <div
      role="dialog"
      aria-labelledby="pwa-install-title"
      className="fixed bottom-24 inset-x-4 z-40 mx-auto max-w-md rounded-2xl border bg-card p-4 shadow-2xl md:bottom-6 md:start-6 md:inset-x-auto"
      data-testid="pwa-install-prompt"
    >
      <div className="flex items-start gap-3">
        <span
          aria-hidden
          className="inline-flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary"
        >
          <Download className="size-5" />
        </span>
        <div className="flex-1 space-y-2">
          <p id="pwa-install-title" className="text-sm font-semibold">
            {t("installPrompt")}
          </p>
          <div className="flex items-center gap-2">
            <Button
              size="sm"
              onClick={() => void handleInstall()}
              data-testid="pwa-install-accept"
            >
              {t("installButton")}
            </Button>
            <Button
              variant="ghost"
              size="sm"
              onClick={handleDismiss}
              data-testid="pwa-install-dismiss"
            >
              {t("dismiss")}
            </Button>
          </div>
        </div>
        <button
          type="button"
          onClick={handleDismiss}
          aria-label={t("dismiss")}
          className="rounded-md p-1 text-muted-foreground hover:text-foreground focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
        >
          <X aria-hidden className="size-4" />
        </button>
      </div>
    </div>
  );
}
