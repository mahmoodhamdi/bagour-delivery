import { Clock, DollarSign, LifeBuoy } from "lucide-react";
import { getTranslations, setRequestLocale } from "next-intl/server";

import { LocaleSwitcher } from "@/components/locale-switcher";

export default async function HomePage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations();

  return (
    <main id="main" className="flex flex-col">
      <header className="flex items-center justify-between border-b px-4 py-3">
        <span className="text-lg font-bold tracking-tight">{t("Brand.name")}</span>
        <LocaleSwitcher />
      </header>
      <section className="flex flex-1 flex-col items-center justify-center px-4 py-12 text-center md:py-20">
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
          <li className="rounded-2xl border bg-card p-6 text-start">
            <Clock aria-hidden className="mb-3 size-6 text-primary" />
            <h2 className="text-lg font-semibold">{t("Home.highlights.flexible")}</h2>
            <p className="mt-1 text-sm text-muted-foreground">
              {t("Home.highlights.flexibleDesc")}
            </p>
          </li>
          <li className="rounded-2xl border bg-card p-6 text-start">
            <DollarSign aria-hidden className="mb-3 size-6 text-primary" />
            <h2 className="text-lg font-semibold">{t("Home.highlights.earnings")}</h2>
            <p className="mt-1 text-sm text-muted-foreground">
              {t("Home.highlights.earningsDesc")}
            </p>
          </li>
          <li className="rounded-2xl border bg-card p-6 text-start">
            <LifeBuoy aria-hidden className="mb-3 size-6 text-primary" />
            <h2 className="text-lg font-semibold">{t("Home.highlights.support")}</h2>
            <p className="mt-1 text-sm text-muted-foreground">{t("Home.highlights.supportDesc")}</p>
          </li>
        </ul>
      </section>
    </main>
  );
}
