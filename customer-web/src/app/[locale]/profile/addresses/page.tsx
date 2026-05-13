import { getTranslations, setRequestLocale } from "next-intl/server";
import type { Metadata } from "next";

import { AddressList } from "@/components/profile/address-list";
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
  return { title: t("addresses") };
}

export default async function AddressesPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Profile");

  return (
    <ProtectedRoute>
      <main
        id="main"
        className="container mx-auto max-w-3xl px-4 py-8 md:py-12"
        data-testid="addresses-page"
      >
        <nav aria-label="breadcrumb" className="mb-4 text-sm text-muted-foreground">
          <Link href="/profile" className="hover:underline">
            {t("title")}
          </Link>
          <span aria-hidden> / </span>
          <span aria-current="page">{t("addresses")}</span>
        </nav>
        <AddressList />
      </main>
    </ProtectedRoute>
  );
}
