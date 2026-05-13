import { Package } from "lucide-react";
import { getTranslations, setRequestLocale } from "next-intl/server";
import type { Metadata } from "next";

import { PlaceholderPage } from "@/components/placeholder-page";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Orders");
  return { title: t("title") };
}

export default async function OrdersPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Orders");

  return (
    <PlaceholderPage
      title={t("title")}
      subtitle={t("subtitle")}
      icon={<Package className="size-10" aria-hidden />}
      testId="orders-page"
    />
  );
}
