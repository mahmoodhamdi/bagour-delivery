"use client";

import { AlertTriangle, RefreshCw } from "lucide-react";
import { useTranslations } from "next-intl";
import { useEffect } from "react";

import { Button } from "@/components/ui/button";

export default function LocaleError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  const t = useTranslations("Common");

  useEffect(() => {
    console.error("[locale-error]", error);
  }, [error]);

  return (
    <main
      id="main"
      role="alert"
      className="container mx-auto flex max-w-md flex-col items-center gap-4 px-4 py-16 text-center"
    >
      <AlertTriangle aria-hidden className="size-10 text-destructive" />
      <h1 className="text-2xl font-semibold">{t("error")}</h1>
      <p className="text-sm text-muted-foreground">
        {error.digest ? `Reference: ${error.digest}` : null}
      </p>
      <Button onClick={reset}>
        <RefreshCw aria-hidden className="size-4" />
        {t("retry")}
      </Button>
    </main>
  );
}
