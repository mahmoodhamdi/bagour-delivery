import { getTranslations, setRequestLocale } from "next-intl/server";
import { Bike, Clock, ShieldCheck } from "lucide-react";

import { Link } from "@/i18n/navigation";
import { LocaleSwitcher } from "@/components/locale-switcher";

export default async function HomePage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations();

  return (
    <main id="main" className="min-h-screen flex flex-col">
      <header className="border-b bg-background/80 backdrop-blur sticky top-0 z-30">
        <div className="container mx-auto flex h-16 items-center justify-between px-4">
          <div className="flex items-center gap-2">
            <span
              aria-hidden
              className="inline-flex h-9 w-9 items-center justify-center rounded-full bg-primary text-primary-foreground font-bold"
            >
              ب
            </span>
            <strong className="text-lg font-bold">{t("Brand.name")}</strong>
          </div>
          <LocaleSwitcher />
        </div>
      </header>

      <section className="flex-1 flex flex-col items-center justify-center px-4 py-16 text-center">
        <div className="max-w-2xl space-y-6">
          <h1 className="text-4xl md:text-5xl font-bold tracking-tight text-balance">
            {t("Home.heroTitle")}
          </h1>
          <p className="text-lg md:text-xl text-muted-foreground text-balance">
            {t("Home.heroSubtitle")}
          </p>
          <div className="flex flex-wrap items-center justify-center gap-3 pt-4">
            <Link
              href="/restaurants"
              className="inline-flex h-12 items-center justify-center rounded-xl bg-primary px-6 font-semibold text-primary-foreground shadow-sm hover:opacity-90 transition focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
            >
              {t("Home.browseRestaurants")}
            </Link>
            <Link
              href="/orders"
              className="inline-flex h-12 items-center justify-center rounded-xl border border-input bg-card px-6 font-semibold hover:bg-accent hover:text-accent-foreground transition focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
            >
              {t("Home.trackOrder")}
            </Link>
          </div>
        </div>

        <ul className="grid grid-cols-1 md:grid-cols-3 gap-4 max-w-4xl w-full mt-16">
          <li className="rounded-2xl border bg-card p-6 text-start">
            <Clock aria-hidden className="h-6 w-6 mb-3 text-primary" />
            <h2 className="font-semibold text-lg">{t("Home.highlights.fast")}</h2>
            <p className="text-sm text-muted-foreground mt-1">{t("Home.highlights.fastDesc")}</p>
          </li>
          <li className="rounded-2xl border bg-card p-6 text-start">
            <Bike aria-hidden className="h-6 w-6 mb-3 text-primary" />
            <h2 className="font-semibold text-lg">{t("Home.highlights.local")}</h2>
            <p className="text-sm text-muted-foreground mt-1">{t("Home.highlights.localDesc")}</p>
          </li>
          <li className="rounded-2xl border bg-card p-6 text-start">
            <ShieldCheck aria-hidden className="h-6 w-6 mb-3 text-primary" />
            <h2 className="font-semibold text-lg">{t("Home.highlights.transparent")}</h2>
            <p className="text-sm text-muted-foreground mt-1">
              {t("Home.highlights.transparentDesc")}
            </p>
          </li>
        </ul>
      </section>

      <footer className="border-t py-6 text-center text-sm text-muted-foreground">
        © {new Date().getFullYear()} {t("Brand.name")} · {t("Brand.tagline")}
      </footer>
    </main>
  );
}
