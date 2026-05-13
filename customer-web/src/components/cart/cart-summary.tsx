"use client";

import { useLocale, useTranslations } from "next-intl";

import { formatCurrency } from "@/lib/format";

export interface CartSummaryInput {
  subtotal: number;
  deliveryFee: number;
  serviceFee?: number;
  discount?: number;
  tax?: number;
}

export function computeTotals(input: CartSummaryInput): number {
  return (
    input.subtotal +
    input.deliveryFee +
    (input.serviceFee ?? 0) +
    (input.tax ?? 0) -
    (input.discount ?? 0)
  );
}

export function CartSummary({
  subtotal,
  deliveryFee,
  serviceFee = 0,
  discount = 0,
  tax = 0,
}: CartSummaryInput) {
  const t = useTranslations("Cart");
  const locale = useLocale();
  const total = computeTotals({ subtotal, deliveryFee, serviceFee, discount, tax });

  const row = (label: string, amount: number, options: { negative?: boolean } = {}) => (
    <div className="flex items-center justify-between text-sm">
      <span className="text-muted-foreground">{label}</span>
      <span className="font-medium">
        {options.negative ? "−" : ""}
        {formatCurrency(amount, locale)}
      </span>
    </div>
  );

  return (
    <dl className="space-y-2 rounded-2xl border bg-card p-4" data-testid="cart-summary">
      {row(t("subtotal"), subtotal)}
      {row(t("deliveryFee"), deliveryFee)}
      {serviceFee > 0 ? row(t("serviceFee"), serviceFee) : null}
      {tax > 0 ? row(t("tax"), tax) : null}
      {discount > 0 ? row(t("discount"), discount, { negative: true }) : null}
      <div className="flex items-center justify-between border-t pt-3 text-base font-semibold">
        <span>{t("total")}</span>
        <span data-testid="cart-summary-total">{formatCurrency(total, locale)}</span>
      </div>
    </dl>
  );
}
