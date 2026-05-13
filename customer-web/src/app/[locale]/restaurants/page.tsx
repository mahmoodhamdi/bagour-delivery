import { Utensils } from "lucide-react";
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
  const t = await getTranslations("Restaurants");
  return { title: t("title") };
}

export default async function RestaurantsPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Restaurants");

  return (
    <PlaceholderPage
      title={t("title")}
      subtitle={t("subtitle")}
      icon={<Utensils className="size-10" aria-hidden />}
      testId="restaurants-page"
    />
  );
}
