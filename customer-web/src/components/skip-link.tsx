"use client";

import { useTranslations } from "next-intl";

export function SkipLink() {
  const t = useTranslations("Common");
  return (
    <a
      href="#main"
      className="sr-only focus-visible:not-sr-only focus-visible:fixed focus-visible:top-3 focus-visible:start-3 focus-visible:z-50 focus-visible:rounded-md focus-visible:bg-primary focus-visible:px-4 focus-visible:py-2 focus-visible:text-primary-foreground"
    >
      {t("skipToContent")}
    </a>
  );
}
