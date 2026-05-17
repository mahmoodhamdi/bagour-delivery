"use client";

import { Minus, Plus, Utensils, X } from "lucide-react";
import { useLocale, useTranslations } from "next-intl";
import { useState } from "react";
import { toast } from "sonner";

import type { MenuItem, Restaurant } from "@bagour/types";

import { Button } from "@/components/ui/button";
import { Sheet, SheetContent, SheetHeader, SheetTitle } from "@/components/ui/sheet";
import { formatCurrency } from "@/lib/format";
import {
  computeItemTotal,
  findMissingRequiredOptions,
  type SelectedAddon,
  type SelectedChoice,
} from "@/lib/cart-helpers";
import { useCartStore } from "@/stores/cart-store";

interface MenuItemModalProps {
  item: MenuItem | null;
  restaurant: Pick<Restaurant, "id" | "name" | "nameEn">;
  /** Restaurant slug for cart linkage. */
  restaurantSlug: string;
  onClose: () => void;
}

export function MenuItemModal({ item, restaurant, restaurantSlug, onClose }: MenuItemModalProps) {
  const open = item !== null;

  return (
    <Sheet open={open} onOpenChange={(v) => !v && onClose()}>
      {item ? (
        <ModalBody
          key={item.id}
          item={item}
          restaurant={restaurant}
          restaurantSlug={restaurantSlug}
          onClose={onClose}
        />
      ) : (
        <SheetContent side="bottom" />
      )}
    </Sheet>
  );
}

interface ModalBodyProps {
  item: MenuItem;
  restaurant: Pick<Restaurant, "id" | "name" | "nameEn">;
  restaurantSlug: string;
  onClose: () => void;
}

/**
 * The modal body remounts per item (via React `key`), so state initializes
 * fresh and we avoid the setState-in-effect anti-pattern.
 */
function ModalBody({ item, restaurant, restaurantSlug, onClose }: ModalBodyProps) {
  const t = useTranslations();
  const locale = useLocale();
  const addLine = useCartStore((s) => s.addLine);
  const existingRestaurantId = useCartStore((s) => s.restaurantId);

  const [quantity, setQuantity] = useState(1);
  const [addons, setAddons] = useState<SelectedAddon[]>([]);
  const [options, setOptions] = useState<SelectedChoice[]>(() => {
    const initial: SelectedChoice[] = [];
    for (const o of item.options) {
      const def = o.choices.find((c) => c.isDefault);
      if (def) {
        initial.push({
          variationId: o.id,
          optionId: def.id,
          optionName: o.name,
          choice: def.name,
          price: def.price,
        });
      }
    }
    return initial;
  });
  const [instructions, setInstructions] = useState("");

  const name = locale === "ar" ? item.name : (item.nameEn ?? item.name);
  const description = locale === "ar" ? item.description : (item.descriptionEn ?? item.description);

  const total = computeItemTotal({ menuItem: item, quantity, addons, options });

  const toggleOption = (
    groupName: string,
    choiceName: string,
    price: number,
    variationId: string | undefined,
    optionId: string | undefined,
  ) => {
    setOptions((prev) => {
      const others = prev.filter((p) => p.optionName !== groupName);
      return [...others, { variationId, optionId, optionName: groupName, choice: choiceName, price }];
    });
  };

  const toggleAddon = (addonName: string, price: number, addonId: string | undefined) => {
    setAddons((prev) => {
      const exists = prev.find((a) => a.name === addonName);
      if (exists) return prev.filter((a) => a.name !== addonName);
      return [...prev, { addonId, name: addonName, price, quantity: 1 }];
    });
  };

  const handleAddToCart = () => {
    const missing = findMissingRequiredOptions(item.options, options);
    if (missing.length > 0 && missing[0]) {
      toast.error(t("Menu.errors.missingRequired", { name: missing[0] }));
      return;
    }

    const switching = existingRestaurantId !== null && existingRestaurantId !== restaurant.id;
    const ok = addLine(
      {
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
        restaurantSlug,
        line: {
          menuItemId: item.id,
          name: item.name,
          nameEn: item.nameEn,
          quantity,
          price: item.price,
          discountPrice: item.discountPrice,
          image: item.image,
          addons: addons.map((a) => ({ name: a.name, price: a.price })),
          options: options.map((o) => ({ name: o.optionName, choice: o.choice, price: o.price })),
          selectedAddons: addons
            .filter((a) => !!a.addonId)
            .map((a) => ({ addonId: a.addonId!, quantity: a.quantity ?? 1 })),
          selectedVariations: options
            .filter((o) => o.variationId && o.optionId)
            .map((o) => ({ variationId: o.variationId!, optionId: o.optionId! })),
          specialInstructions: instructions.trim() || undefined,
          itemTotal: total,
        },
      },
      {
        confirmReplace: () =>
          switching ? window.confirm(t("Menu.confirmSwitchRestaurant")) : true,
      },
    );

    if (ok) {
      toast.success(t("Menu.toasts.addedToCart", { name }));
      onClose();
    }
  };

  return (
    <SheetContent
      side="bottom"
      className="max-h-[92vh] overflow-y-auto rounded-t-3xl pb-32 md:max-w-2xl md:rounded-3xl md:pb-6"
      aria-describedby={undefined}
    >
      <SheetHeader>
        <SheetTitle className="sr-only">{name}</SheetTitle>
      </SheetHeader>

      <div
        className="-mx-6 -mt-6 mb-4 aspect-video overflow-hidden bg-muted"
        data-testid="menu-modal-image"
      >
        {item.image ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={item.image} alt="" className="size-full object-cover" />
        ) : (
          <div className="flex size-full items-center justify-center text-muted-foreground">
            <Utensils aria-hidden className="size-12" />
          </div>
        )}
      </div>

      <div className="space-y-5">
        <header className="space-y-1">
          <h2 className="text-2xl font-bold">{name}</h2>
          {description ? <p className="text-sm text-muted-foreground">{description}</p> : null}
          <p className="pt-1 text-lg font-semibold text-primary">
            {formatCurrency(item.discountPrice ?? item.price, locale)}
          </p>
        </header>

        {item.options.length > 0 ? (
          <fieldset className="space-y-3" data-testid="menu-options">
            {item.options.map((group) => (
              <div key={group.name} className="space-y-2 rounded-xl border bg-card p-3">
                <legend className="flex items-center justify-between font-semibold">
                  {group.name}
                  {group.required ? (
                    <span className="text-xs font-medium text-primary">{t("Menu.required")}</span>
                  ) : null}
                </legend>
                <ul className="space-y-2">
                  {group.choices.map((c) => {
                    const id = `${group.name}-${c.name}`;
                    const selected = options.some(
                      (o) => o.optionName === group.name && o.choice === c.name,
                    );
                    return (
                      <li key={id}>
                        <label
                          htmlFor={id}
                          className="flex items-center justify-between gap-2 rounded-lg p-2 hover:bg-accent/40"
                        >
                          <span className="flex items-center gap-2 text-sm">
                            <input
                              type="radio"
                              id={id}
                              name={group.name}
                              checked={selected}
                              onChange={() => toggleOption(group.name, c.name, c.price, group.id, c.id)}
                              className="size-4 accent-primary"
                              data-testid={`option-${group.name}-${c.name}`}
                            />
                            {c.name}
                          </span>
                          {c.price > 0 ? (
                            <span className="text-xs text-muted-foreground">
                              +{formatCurrency(c.price, locale)}
                            </span>
                          ) : null}
                        </label>
                      </li>
                    );
                  })}
                </ul>
              </div>
            ))}
          </fieldset>
        ) : null}

        {item.addons.length > 0 ? (
          <fieldset className="space-y-3" data-testid="menu-addons">
            <legend className="font-semibold">{t("Menu.addons")}</legend>
            <ul className="space-y-2">
              {item.addons.map((a) => {
                const selected = addons.some((s) => s.name === a.name);
                return (
                  <li key={a.name}>
                    <label className="flex items-center justify-between gap-2 rounded-lg border p-3 hover:bg-accent/40">
                      <span className="flex items-center gap-2 text-sm">
                        <input
                          type="checkbox"
                          checked={selected}
                          disabled={!a.isAvailable}
                          onChange={() => toggleAddon(a.name, a.price, a.id)}
                          className="size-4 accent-primary"
                          data-testid={`addon-${a.name}`}
                        />
                        {a.name}
                        {!a.isAvailable ? (
                          <span className="text-xs text-muted-foreground">
                            ({t("Menu.unavailable")})
                          </span>
                        ) : null}
                      </span>
                      <span className="text-xs text-muted-foreground">
                        +{formatCurrency(a.price, locale)}
                      </span>
                    </label>
                  </li>
                );
              })}
            </ul>
          </fieldset>
        ) : null}

        <div className="space-y-2">
          <label htmlFor="instructions" className="block text-sm font-medium">
            {t("Menu.specialInstructions")}
          </label>
          <textarea
            id="instructions"
            value={instructions}
            onChange={(e) => setInstructions(e.target.value)}
            rows={2}
            maxLength={200}
            placeholder={t("Menu.specialInstructionsPlaceholder")}
            data-testid="menu-instructions"
            className="w-full rounded-xl border border-input bg-card px-3 py-2 text-sm shadow-xs focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
          />
        </div>
      </div>

      <div className="fixed inset-x-0 bottom-0 z-10 flex items-center justify-between gap-3 border-t bg-background p-4 md:static md:mt-6 md:rounded-2xl md:border-0 md:bg-transparent md:p-0">
        <div className="inline-flex items-center gap-1 rounded-full border bg-card">
          <button
            type="button"
            onClick={() => setQuantity((q) => Math.max(1, q - 1))}
            aria-label={t("Menu.decreaseQuantity")}
            className="inline-flex size-10 items-center justify-center rounded-full hover:bg-accent"
            data-testid="menu-qty-minus"
          >
            <Minus aria-hidden className="size-4" />
          </button>
          <span aria-live="polite" className="min-w-8 text-center font-semibold">
            {quantity}
          </span>
          <button
            type="button"
            onClick={() => setQuantity((q) => q + 1)}
            aria-label={t("Menu.increaseQuantity")}
            className="inline-flex size-10 items-center justify-center rounded-full hover:bg-accent"
            data-testid="menu-qty-plus"
          >
            <Plus aria-hidden className="size-4" />
          </button>
        </div>

        <Button
          type="button"
          size="lg"
          onClick={handleAddToCart}
          disabled={!item.isAvailable}
          data-testid="menu-add-to-cart"
          className="flex-1 md:flex-none"
        >
          {t("Menu.addToCart", { total: formatCurrency(total, locale) })}
        </Button>

        <button
          type="button"
          onClick={onClose}
          aria-label={t("Menu.closeModal")}
          className="hidden size-10 items-center justify-center rounded-full text-muted-foreground hover:bg-accent md:inline-flex"
        >
          <X aria-hidden className="size-4" />
        </button>
      </div>
    </SheetContent>
  );
}
