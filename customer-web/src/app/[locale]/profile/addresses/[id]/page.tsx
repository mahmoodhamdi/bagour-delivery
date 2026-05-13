"use client";

import { useTranslations } from "next-intl";
import { use } from "react";

import { AddressForm } from "@/components/profile/address-form";
import { ProtectedRoute } from "@/components/protected-route";
import { Link, useRouter } from "@/i18n/navigation";
import { useAddresses } from "@/lib/hooks/use-customer";

import { Skeleton } from "@/components/ui/skeleton";

export default function EditAddressPage({
  params,
}: {
  params: Promise<{ id: string; locale: string }>;
}) {
  const { id } = use(params);
  const t = useTranslations("Profile");
  const router = useRouter();
  const { data, isLoading } = useAddresses();

  return (
    <ProtectedRoute>
      <main
        id="main"
        className="container mx-auto max-w-2xl px-4 py-8 md:py-12"
        data-testid="edit-address-page"
      >
        <nav aria-label="breadcrumb" className="mb-4 text-sm text-muted-foreground">
          <Link href="/profile/addresses" className="hover:underline">
            {t("addresses")}
          </Link>
          <span aria-hidden> / </span>
          <span aria-current="page">{t("editAddress")}</span>
        </nav>
        <header className="mb-6 space-y-1">
          <h1 className="text-3xl font-bold tracking-tight">{t("editAddress")}</h1>
          <p className="text-muted-foreground">{t("editAddressDesc")}</p>
        </header>

        {isLoading ? (
          <Skeleton className="h-96 w-full rounded-2xl" />
        ) : (
          (() => {
            const initial = data?.find((a) => a.id === id) as
              | (Parameters<typeof AddressForm>[0]["initial"] & { id: string })
              | undefined;
            if (!initial) {
              // Address vanished — bounce back to the list.
              if (typeof window !== "undefined") {
                router.replace("/profile/addresses");
              }
              return (
                <p className="text-muted-foreground" role="status">
                  {t("addressNotFound")}
                </p>
              );
            }
            return <AddressForm initial={initial} />;
          })()
        )}
      </main>
    </ProtectedRoute>
  );
}
