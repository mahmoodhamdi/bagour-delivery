"use client";

import { MapPinned, Plus } from "lucide-react";
import { useTranslations } from "next-intl";

import type { Address } from "@bagour/types";

import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Link } from "@/i18n/navigation";
import { useAddresses } from "@/lib/hooks/use-customer";

import { AddressCard } from "./address-card";

export function AddressList() {
  const t = useTranslations();
  const { data, isLoading, error } = useAddresses();

  return (
    <section className="space-y-5" data-testid="address-list">
      <header className="flex items-center justify-between gap-3">
        <div>
          <h2 className="text-xl font-bold">{t("Profile.addresses")}</h2>
          <p className="text-sm text-muted-foreground">{t("Profile.addressesDesc")}</p>
        </div>
        <Button asChild size="sm" data-testid="add-address-cta">
          <Link href="/profile/addresses/new">
            <Plus aria-hidden />
            {t("Profile.actions.addAddress")}
          </Link>
        </Button>
      </header>

      {isLoading ? (
        <ul className="space-y-3" aria-busy="true">
          {[0, 1].map((i) => (
            <li key={i}>
              <Skeleton className="h-24 w-full rounded-2xl" />
            </li>
          ))}
        </ul>
      ) : error ? (
        <p
          role="alert"
          className="rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-sm font-medium text-destructive"
        >
          {t("Common.error")}
        </p>
      ) : data && data.length > 0 ? (
        <ul className="space-y-3">
          {(data as (Address & { id: string })[])
            .filter((a) => a.id)
            .map((addr) => (
              <li key={addr.id}>
                <AddressCard address={addr} />
              </li>
            ))}
        </ul>
      ) : (
        <div
          className="flex flex-col items-center gap-3 rounded-2xl border-2 border-dashed bg-card p-10 text-center"
          data-testid="address-empty-state"
        >
          <MapPinned aria-hidden className="size-10 text-muted-foreground" />
          <p className="font-semibold">{t("Profile.noAddresses")}</p>
          <p className="text-sm text-muted-foreground">{t("Profile.noAddressesDesc")}</p>
          <Button asChild>
            <Link href="/profile/addresses/new">{t("Profile.actions.addFirstAddress")}</Link>
          </Button>
        </div>
      )}
    </section>
  );
}
