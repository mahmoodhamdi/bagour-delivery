import { getTranslations, setRequestLocale } from "next-intl/server";
import type { Metadata } from "next";

import { OnboardingForm } from "@/components/onboarding/onboarding-form";
import { ProtectedRoute } from "@/components/protected-route";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Onboarding");
  return { title: t("title") };
}

export default async function OnboardingPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Onboarding");

  return (
    <ProtectedRoute>
      <main
        id="main"
        className="container mx-auto max-w-2xl px-4 py-8 md:py-12"
        data-testid="onboarding-page"
      >
        <header className="mb-6 space-y-1">
          <h1 className="text-3xl font-bold tracking-tight">{t("title")}</h1>
          <p className="text-muted-foreground">{t("subtitle")}</p>
        </header>
        <OnboardingForm />
      </main>
    </ProtectedRoute>
  );
}
