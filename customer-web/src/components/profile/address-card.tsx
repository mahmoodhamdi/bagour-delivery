"use client";

import { Loader2, MapPin, MoreVertical, Pencil, Star, Trash2 } from "lucide-react";
import { useTranslations } from "next-intl";
import { useState, useTransition } from "react";
import { toast } from "sonner";

import type { Address } from "@bagour/types";
import { ApiError } from "@bagour/api-client";

import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Link } from "@/i18n/navigation";
import { useDeleteAddress, useSetDefaultAddress } from "@/lib/hooks/use-customer";

interface AddressCardProps {
  address: Address & { id: string };
}

export function AddressCard({ address }: AddressCardProps) {
  const t = useTranslations();
  const del = useDeleteAddress();
  const setDefault = useSetDefaultAddress();
  const [busy, setBusy] = useState<"delete" | "default" | null>(null);
  const [, startTransition] = useTransition();

  const lines = [
    address.street,
    address.area,
    address.city,
    [address.buildingNumber, address.floor, address.apartment].filter(Boolean).join(" · "),
  ].filter(Boolean);

  const handleDelete = async () => {
    if (!window.confirm(t("Profile.confirmDeleteAddress"))) return;
    setBusy("delete");
    try {
      await del.mutateAsync(address.id);
      toast.success(t("Profile.toasts.addressDeleted"));
    } catch (err) {
      if (err instanceof ApiError) {
        toast.error(err.message);
      } else {
        toast.error(t("Common.error"));
      }
    } finally {
      setBusy(null);
    }
  };

  const handleSetDefault = () => {
    if (address.isDefault) return;
    setBusy("default");
    startTransition(() => {
      void (async () => {
        try {
          await setDefault.mutateAsync(address.id);
          toast.success(t("Profile.toasts.addressDefaultUpdated"));
        } catch (err) {
          if (err instanceof ApiError) {
            toast.error(err.message);
          } else {
            toast.error(t("Common.error"));
          }
        } finally {
          setBusy(null);
        }
      })();
    });
  };

  return (
    <article
      className="flex items-start gap-3 rounded-2xl border bg-card p-4 transition-colors"
      data-testid={`address-card-${address.id}`}
      aria-label={address.label ?? t("Profile.address")}
    >
      <div className="rounded-xl bg-accent/40 p-2 text-primary">
        <MapPin aria-hidden className="size-5" />
      </div>

      <div className="min-w-0 flex-1">
        <header className="flex items-center gap-2">
          <h3 className="font-semibold">{address.label ?? t("Profile.address")}</h3>
          {address.isDefault ? (
            <span
              className="inline-flex items-center gap-1 rounded-full bg-primary/10 px-2 py-0.5 text-xs font-semibold text-primary"
              aria-label={t("Profile.defaultAddressBadge")}
              data-testid={`address-default-badge-${address.id}`}
            >
              <Star aria-hidden className="size-3 fill-current" />
              {t("Profile.defaultAddressBadge")}
            </span>
          ) : null}
        </header>
        <p className="mt-1 text-sm text-muted-foreground">{lines.join("، ")}</p>
        {address.landmark ? (
          <p className="mt-1 text-xs text-muted-foreground">{address.landmark}</p>
        ) : null}
      </div>

      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button
            variant="ghost"
            size="icon"
            aria-label={t("Profile.actions.addressMenu")}
            data-testid={`address-menu-${address.id}`}
          >
            {busy ? (
              <Loader2 className="size-4 animate-spin" />
            ) : (
              <MoreVertical aria-hidden className="size-4" />
            )}
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem asChild>
            <Link href={`/profile/addresses/${address.id}`}>
              <Pencil aria-hidden />
              {t("Profile.actions.editAddress")}
            </Link>
          </DropdownMenuItem>
          <DropdownMenuItem
            onClick={handleSetDefault}
            disabled={address.isDefault ?? busy === "default"}
          >
            <Star aria-hidden />
            {t("Profile.actions.setAsDefault")}
          </DropdownMenuItem>
          <DropdownMenuSeparator />
          <DropdownMenuItem
            onClick={() => void handleDelete()}
            className="text-destructive focus:text-destructive"
            disabled={busy === "delete"}
            data-testid={`address-delete-${address.id}`}
          >
            <Trash2 aria-hidden />
            {t("Profile.actions.deleteAddress")}
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </article>
  );
}
