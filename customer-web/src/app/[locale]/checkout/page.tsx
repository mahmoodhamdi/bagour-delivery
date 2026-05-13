import { getTranslations, setRequestLocale } from "next-intl/server";
import type { Metadata } from "next";

import { CheckoutForm } from "@/components/checkout/checkout-form";
import { ProtectedRoute } from "@/components/protected-route";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Checkout");
  return { title: t("title") };
}

export default async function CheckoutPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Checkout");

  return (
    <ProtectedRoute>
      <main
        id="main"
        className="container mx-auto max-w-5xl px-4 py-8 md:py-12"
        data-testid="checkout-page"
      >
        <header className="mb-6 space-y-1">
          <h1 className="text-3xl font-bold tracking-tight">{t("title")}</h1>
          <p className="text-muted-foreground">{t("subtitle")}</p>
        </header>
        <CheckoutForm />
      </main>
    </ProtectedRoute>
  );
}
