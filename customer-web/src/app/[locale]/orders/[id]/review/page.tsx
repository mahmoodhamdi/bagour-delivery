import { setRequestLocale, getTranslations } from "next-intl/server";
import type { Metadata } from "next";

import { ReviewForm } from "@/components/orders/review-form";
import { ProtectedRoute } from "@/components/protected-route";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Reviews");
  return { title: t("title") };
}

export default async function ReviewPage({
  params,
}: {
  params: Promise<{ locale: string; id: string }>;
}) {
  const { locale, id } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Reviews");

  return (
    <ProtectedRoute>
      <main
        id="main"
        className="container mx-auto max-w-2xl px-4 py-8 md:py-12"
        data-testid="review-page"
      >
        <header className="mb-6 space-y-1">
          <h1 className="text-3xl font-bold tracking-tight">{t("title")}</h1>
          <p className="text-muted-foreground">{t("subtitle")}</p>
        </header>

        <ReviewForm orderId={id} />
      </main>
    </ProtectedRoute>
  );
}
