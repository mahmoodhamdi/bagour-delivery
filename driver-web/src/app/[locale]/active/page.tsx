import { getTranslations, setRequestLocale } from "next-intl/server";
import type { Metadata } from "next";

import { MyOrdersList } from "@/components/orders/my-orders-list";
import { ProtectedRoute } from "@/components/protected-route";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Nav");
  return { title: t("active") };
}

export default async function ActiveOrdersPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations();

  return (
    <ProtectedRoute>
      <main
        id="main"
        className="container mx-auto max-w-3xl px-4 py-8 md:py-12"
        data-testid="active-page"
      >
        <header className="mb-6 space-y-1">
          <h1 className="text-3xl font-bold tracking-tight">{t("Nav.active")}</h1>
          <p className="text-muted-foreground">{t("Orders.activeSubtitle")}</p>
        </header>
        <MyOrdersList />
      </main>
    </ProtectedRoute>
  );
}
