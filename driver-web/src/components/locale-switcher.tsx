"use client";

import { useLocale, useTranslations } from "next-intl";
import { Globe } from "lucide-react";
import { useTransition } from "react";

import { usePathname, useRouter } from "@/i18n/navigation";
import { routing, type AppLocale } from "@/i18n/routing";

export function LocaleSwitcher() {
  const router = useRouter();
  const pathname = usePathname();
  const currentLocale = useLocale() as AppLocale;
  const t = useTranslations("Common");
  const [isPending, startTransition] = useTransition();

  const nextLocale: AppLocale = currentLocale === "ar" ? "en" : "ar";
  const label = nextLocale === "ar" ? t("switchToArabic") : t("switchToEnglish");

  return (
    <button
      type="button"
      onClick={() => {
        startTransition(() => {
          router.replace(pathname, { locale: nextLocale });
        });
      }}
      disabled={isPending}
      className="inline-flex h-10 items-center gap-2 rounded-full border border-input bg-card px-4 text-sm font-medium hover:bg-accent hover:text-accent-foreground transition disabled:opacity-50 focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
      aria-label={t("language")}
    >
      <Globe aria-hidden className="h-4 w-4" />
      <span>{label}</span>
      <span className="sr-only">
        ({routing.locales.filter((l) => l !== currentLocale).join(", ")})
      </span>
    </button>
  );
}
