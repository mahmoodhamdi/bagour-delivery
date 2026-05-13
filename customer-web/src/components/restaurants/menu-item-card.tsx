"use client";

import { Plus, Utensils } from "lucide-react";
import { useLocale, useTranslations } from "next-intl";

import type { MenuItem } from "@bagour/types";

import { cn } from "@/lib/utils";
import { formatCurrency } from "@/lib/format";

interface MenuItemCardProps {
  item: MenuItem;
  onClick: () => void;
}

export function MenuItemCard({ item, onClick }: MenuItemCardProps) {
  const locale = useLocale();
  const t = useTranslations("Menu");

  const name = locale === "ar" ? item.name : (item.nameEn ?? item.name);
  const description = locale === "ar" ? item.description : (item.descriptionEn ?? item.description);

  const hasDiscount = typeof item.discountPrice === "number" && item.discountPrice < item.price;

  return (
    <button
      type="button"
      onClick={onClick}
      disabled={!item.isAvailable}
      data-testid={`menu-item-${item.id}`}
      aria-label={t("openItem", { name })}
      className={cn(
        "flex w-full items-stretch gap-3 rounded-2xl border bg-card p-3 text-start transition-all hover:shadow-md disabled:cursor-not-allowed disabled:opacity-60 focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2 md:items-center",
      )}
    >
      <div className="size-20 shrink-0 overflow-hidden rounded-xl bg-muted md:size-24">
        {item.image ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={item.image} alt="" loading="lazy" className="size-full object-cover" />
        ) : (
          <div className="flex size-full items-center justify-center text-muted-foreground">
            <Utensils aria-hidden className="size-6" />
          </div>
        )}
      </div>

      <div className="flex min-w-0 flex-1 flex-col">
        <div className="flex items-start justify-between gap-2">
          <h3 className="font-semibold leading-tight">{name}</h3>
          {item.isFeatured ? (
            <span className="rounded-full bg-primary/10 px-2 py-0.5 text-xs font-semibold text-primary">
              {t("featured")}
            </span>
          ) : null}
        </div>
        {description ? (
          <p className="mt-1 line-clamp-2 text-sm text-muted-foreground">{description}</p>
        ) : null}

        <footer className="mt-auto flex items-end justify-between gap-2 pt-2">
          <div className="text-sm">
            {hasDiscount ? (
              <>
                <span className="font-bold text-primary">
                  {formatCurrency(item.discountPrice!, locale)}
                </span>
                <span className="ms-2 text-xs text-muted-foreground line-through">
                  {formatCurrency(item.price, locale)}
                </span>
              </>
            ) : (
              <span className="font-bold">{formatCurrency(item.price, locale)}</span>
            )}
          </div>
          {item.isAvailable ? (
            <span className="inline-flex size-9 items-center justify-center rounded-full bg-primary text-primary-foreground">
              <Plus aria-hidden className="size-4" />
            </span>
          ) : (
            <span className="rounded-full bg-muted px-3 py-1 text-xs font-medium text-muted-foreground">
              {t("unavailable")}
            </span>
          )}
        </footer>
      </div>
    </button>
  );
}
