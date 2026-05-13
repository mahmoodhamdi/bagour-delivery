import { getTranslations, setRequestLocale } from "next-intl/server";
import type { Metadata } from "next";

import { ProfileEditForm } from "@/components/profile/profile-edit-form";
import { ProtectedRoute } from "@/components/protected-route";
import { Link } from "@/i18n/navigation";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Profile");
  return { title: t("editProfile") };
}

export default async function ProfileEditPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Profile");

  return (
    <ProtectedRoute>
      <main
        id="main"
        className="container mx-auto max-w-2xl px-4 py-8 md:py-12"
        data-testid="profile-edit-page"
      >
        <nav aria-label="breadcrumb" className="mb-4 text-sm text-muted-foreground">
          <Link href="/profile" className="hover:underline">
            {t("title")}
          </Link>
          <span aria-hidden> / </span>
          <span aria-current="page">{t("editProfile")}</span>
        </nav>
        <header className="mb-6 space-y-1">
          <h1 className="text-3xl font-bold tracking-tight">{t("editProfile")}</h1>
          <p className="text-muted-foreground">{t("editProfileSubtitle")}</p>
        </header>
        <ProfileEditForm />
      </main>
    </ProtectedRoute>
  );
}
