import { setRequestLocale } from "next-intl/server";

import { HomeView } from "@/components/home-view";

export default async function HomePage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);

  return (
    <main id="main" className="container mx-auto px-4 py-8 md:py-12">
      <HomeView />
    </main>
  );
}
