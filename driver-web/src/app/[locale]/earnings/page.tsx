import { getTranslations, setRequestLocale } from "next-intl/server";
import type { Metadata } from "next";

import { EarningsHistory } from "@/components/earnings/earnings-history";
import { EarningsSummary } from "@/components/earnings/earnings-summary";
import { ProtectedRoute } from "@/components/protected-route";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Earnings");
  return { title: t("title") };
}

export default async function EarningsPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Earnings");

  return (
    <ProtectedRoute>
      <main
        id="main"
        className="container mx-auto max-w-3xl px-4 py-8 md:py-12"
        data-testid="earnings-page"
      >
        <header className="mb-6 space-y-1">
          <h1 className="text-3xl font-bold tracking-tight">{t("title")}</h1>
          <p className="text-muted-foreground">{t("subtitle")}</p>
        </header>

        <EarningsSummary />

        <section className="mt-8 space-y-3">
          <h2 className="text-xl font-semibold">{t("historyTitle")}</h2>
          <EarningsHistory />
        </section>
      </main>
    </ProtectedRoute>
  );
}
