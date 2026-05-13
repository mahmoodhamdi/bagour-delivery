import { setRequestLocale } from "next-intl/server";

import { MenuPageClient } from "@/components/restaurants/menu-page-client";

export default async function RestaurantDetailPage({
  params,
}: {
  params: Promise<{ slug: string; locale: string }>;
}) {
  const { slug, locale } = await params;
  setRequestLocale(locale);

  return (
    <main
      id="main"
      className="container mx-auto px-4 py-6 md:py-10"
      data-testid="restaurant-detail-page"
    >
      <MenuPageClient slug={slug} />
    </main>
  );
}
