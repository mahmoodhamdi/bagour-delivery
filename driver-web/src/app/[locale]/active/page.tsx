import { getTranslations, setRequestLocale } from "next-intl/server";
import type { Metadata } from "next";

import { PlaceholderPage } from "@/components/placeholder-page";
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
      <PlaceholderPage
        title={t("Nav.active")}
        subtitle={t("Placeholder.comingSoon")}
        body={t("Placeholder.comingSoonBody")}
      />
    </ProtectedRoute>
  );
}
