"use client";

import { Minus, Plus, Trash2 } from "lucide-react";
import { useLocale, useTranslations } from "next-intl";

import type { CartLine as CartLineType } from "@/stores/cart-store";
import { formatCurrency } from "@/lib/format";
import { useCartStore } from "@/stores/cart-store";

interface CartLineProps {
  line: CartLineType;
}

export function CartLine({ line }: CartLineProps) {
  const t = useTranslations();
  const locale = useLocale();
  const updateLineQuantity = useCartStore((s) => s.updateLineQuantity);
  const removeLine = useCartStore((s) => s.removeLine);

  const name = locale === "ar" ? line.name : (line.nameEn ?? line.name);
  const extras: string[] = [];
  if (line.options.length > 0) {
    extras.push(line.options.map((o) => `${o.name}: ${o.choice}`).join(" · "));
  }
  if (line.addons.length > 0) {
    extras.push(line.addons.map((a) => a.name).join(" · "));
  }

  return (
    <article
      data-testid={`cart-line-${line.lineId}`}
      className="flex items-start gap-3 rounded-2xl border bg-card p-3"
    >
      <div className="size-16 shrink-0 overflow-hidden rounded-xl bg-muted">
        {line.image ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={line.image} alt="" loading="lazy" className="size-full object-cover" />
        ) : null}
      </div>

      <div className="min-w-0 flex-1 space-y-1">
        <header className="flex items-start justify-between gap-2">
          <h3 className="font-semibold leading-tight">{name}</h3>
          <span className="font-semibold text-foreground">
            {formatCurrency(line.itemTotal, locale)}
          </span>
        </header>
        {extras.length > 0 ? (
          <p className="text-xs text-muted-foreground">{extras.join(" · ")}</p>
        ) : null}
        {line.specialInstructions ? (
          <p className="text-xs italic text-muted-foreground">{line.specialInstructions}</p>
        ) : null}

        <div className="flex items-center justify-between gap-2 pt-1">
          <div className="inline-flex items-center gap-1 rounded-full border bg-background">
            <button
              type="button"
              onClick={() => updateLineQuantity(line.lineId, line.quantity - 1)}
              aria-label={t("Menu.decreaseQuantity")}
              data-testid={`cart-line-minus-${line.lineId}`}
              className="inline-flex size-8 items-center justify-center rounded-full hover:bg-accent"
            >
              <Minus aria-hidden className="size-3" />
            </button>
            <span aria-live="polite" className="min-w-6 text-center text-sm font-semibold">
              {line.quantity}
            </span>
            <button
              type="button"
              onClick={() => updateLineQuantity(line.lineId, line.quantity + 1)}
              aria-label={t("Menu.increaseQuantity")}
              data-testid={`cart-line-plus-${line.lineId}`}
              className="inline-flex size-8 items-center justify-center rounded-full hover:bg-accent"
            >
              <Plus aria-hidden className="size-3" />
            </button>
          </div>

          <button
            type="button"
            onClick={() => removeLine(line.lineId)}
            aria-label={t("Cart.removeItem")}
            data-testid={`cart-line-remove-${line.lineId}`}
            className="inline-flex items-center gap-1 rounded-lg px-2 py-1 text-xs text-destructive hover:bg-destructive/10"
          >
            <Trash2 aria-hidden className="size-3" />
            {t("Cart.remove")}
          </button>
        </div>
      </div>
    </article>
  );
}
