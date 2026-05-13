import { User } from "lucide-react";
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
  const t = await getTranslations("Profile");
  return { title: t("title") };
}

export default async function ProfilePage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Profile");

  return (
    <PlaceholderPage
      title={t("title")}
      subtitle={t("subtitle")}
      icon={<User className="size-10" aria-hidden />}
      testId="profile-page"
    />
  );
}
