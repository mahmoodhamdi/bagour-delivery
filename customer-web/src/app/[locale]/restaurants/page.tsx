import { getTranslations, setRequestLocale } from "next-intl/server";
import type { Metadata } from "next";

import { FeaturedRow } from "@/components/restaurants/featured-row";
import { RestaurantList } from "@/components/restaurants/restaurant-list";

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
    <main
      id="main"
      className="container mx-auto flex flex-col gap-8 px-4 py-6 md:py-10"
      data-testid="restaurants-page"
    >
      <header className="space-y-1">
        <h1 className="text-3xl font-bold tracking-tight md:text-4xl">{t("title")}</h1>
        <p className="text-muted-foreground md:text-lg">{t("subtitle")}</p>
      </header>
      <FeaturedRow />
      <RestaurantList />
    </main>
  );
}
