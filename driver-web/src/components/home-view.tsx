"use client";

import { Clock, DollarSign, LifeBuoy } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { useTranslations } from "next-intl";

import { useAuthStore } from "@/stores/auth-store";

import { DriverHome } from "./online/driver-home";
import { Skeleton } from "./ui/skeleton";

interface Highlight {
  icon: LucideIcon;
  titleKey: string;
  descKey: string;
}

const HIGHLIGHTS: Highlight[] = [
  { icon: Clock, titleKey: "Home.highlights.flexible", descKey: "Home.highlights.flexibleDesc" },
  {
    icon: DollarSign,
    titleKey: "Home.highlights.earnings",
    descKey: "Home.highlights.earningsDesc",
  },
  { icon: LifeBuoy, titleKey: "Home.highlights.support", descKey: "Home.highlights.supportDesc" },
];

/**
 * Home page body. Anonymous users see the marketing hero; signed-in
 * drivers see the live online toggle. Skeleton while the auth store
 * hydrates so neither variant flashes on cold reload.
 */
export function HomeView() {
  const t = useTranslations();
  const hydrated = useAuthStore((s) => s.hydrated);
  const user = useAuthStore((s) => s.user);

  if (!hydrated) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-24 w-full" />
        <Skeleton className="h-12 w-1/2" />
      </div>
    );
  }

  if (user) {
    return <DriverHome />;
  }

  return (
    <section className="flex flex-col items-center px-2 py-12 text-center md:py-20">
      <div className="max-w-2xl space-y-6">
        <p className="text-sm font-semibold uppercase tracking-widest text-primary">
          {t("Brand.tagline")}
        </p>
        <h1 className="text-balance text-4xl font-bold tracking-tight md:text-5xl">
          {t("Home.heroTitle")}
        </h1>
        <p className="text-balance text-lg text-muted-foreground md:text-xl">
          {t("Home.heroSubtitle")}
        </p>
        <p className="text-sm text-muted-foreground">{t("Placeholder.comingSoonBody")}</p>
      </div>

      <ul className="mt-16 grid w-full max-w-4xl grid-cols-1 gap-4 md:grid-cols-3">
        {HIGHLIGHTS.map(({ icon: Icon, titleKey, descKey }) => (
          <li key={titleKey} className="rounded-2xl border bg-card p-6 text-start">
            <Icon aria-hidden className="mb-3 size-6 text-primary" />
            <h2 className="text-lg font-semibold">{t(titleKey as never)}</h2>
            <p className="mt-1 text-sm text-muted-foreground">{t(descKey as never)}</p>
          </li>
        ))}
      </ul>
    </section>
  );
}
