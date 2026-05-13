import { Bike, Clock, ShieldCheck } from "lucide-react";
import { getTranslations, setRequestLocale } from "next-intl/server";

import { Link } from "@/i18n/navigation";

export default async function HomePage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations();

  return (
    <main id="main" className="flex flex-col">
      <section className="flex flex-1 flex-col items-center justify-center px-4 py-12 text-center md:py-20">
        <div className="max-w-2xl space-y-6">
          <h1 className="text-balance text-4xl font-bold tracking-tight md:text-5xl">
            {t("Home.heroTitle")}
          </h1>
          <p className="text-balance text-lg text-muted-foreground md:text-xl">
            {t("Home.heroSubtitle")}
          </p>
          <div className="flex flex-wrap items-center justify-center gap-3 pt-4">
            <Link
              href="/restaurants"
              className="inline-flex h-12 items-center justify-center rounded-xl bg-primary px-6 font-semibold text-primary-foreground shadow-sm transition hover:opacity-90 focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
            >
              {t("Home.browseRestaurants")}
            </Link>
            <Link
              href="/orders"
              className="inline-flex h-12 items-center justify-center rounded-xl border border-input bg-card px-6 font-semibold transition hover:bg-accent hover:text-accent-foreground focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
            >
              {t("Home.trackOrder")}
            </Link>
          </div>
        </div>

        <ul className="mt-16 grid w-full max-w-4xl grid-cols-1 gap-4 md:grid-cols-3">
          <li className="rounded-2xl border bg-card p-6 text-start">
            <Clock aria-hidden className="mb-3 size-6 text-primary" />
            <h2 className="text-lg font-semibold">{t("Home.highlights.fast")}</h2>
            <p className="mt-1 text-sm text-muted-foreground">{t("Home.highlights.fastDesc")}</p>
          </li>
          <li className="rounded-2xl border bg-card p-6 text-start">
            <Bike aria-hidden className="mb-3 size-6 text-primary" />
            <h2 className="text-lg font-semibold">{t("Home.highlights.local")}</h2>
            <p className="mt-1 text-sm text-muted-foreground">{t("Home.highlights.localDesc")}</p>
          </li>
          <li className="rounded-2xl border bg-card p-6 text-start">
            <ShieldCheck aria-hidden className="mb-3 size-6 text-primary" />
            <h2 className="text-lg font-semibold">{t("Home.highlights.transparent")}</h2>
            <p className="mt-1 text-sm text-muted-foreground">
              {t("Home.highlights.transparentDesc")}
            </p>
          </li>
        </ul>
      </section>
    </main>
  );
}
