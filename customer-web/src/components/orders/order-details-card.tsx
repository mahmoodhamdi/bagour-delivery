"use client";

import { useLocale, useTranslations } from "next-intl";

import type { Order } from "@bagour/types";

import { formatCurrency } from "@/lib/format";

import { CartSummary } from "@/components/cart/cart-summary";

interface OrderDetailsCardProps {
  order: Order;
}

export function OrderDetailsCard({ order }: OrderDetailsCardProps) {
  const t = useTranslations("Orders");
  const locale = useLocale();

  return (
    <section className="space-y-3" data-testid="order-details">
      <header className="space-y-1">
        <p className="text-sm text-muted-foreground">{t("orderNumber")}</p>
        <h2 className="text-xl font-bold">{order.orderNumber}</h2>
      </header>

      <ul className="space-y-2 rounded-2xl border bg-card p-4">
        {order.items.map((item, i) => {
          const name = locale === "ar" ? item.name : (item.nameEn ?? item.name);
          return (
            <li
              key={`${item.menuItemId}-${i}`}
              className="flex items-start justify-between gap-2 text-sm"
            >
              <div className="min-w-0 flex-1">
                <p className="font-semibold">
                  <span className="me-1 text-muted-foreground">×{item.quantity}</span>
                  {name}
                </p>
                {item.options.length > 0 ? (
                  <p className="text-xs text-muted-foreground">
                    {item.options.map((o) => `${o.name}: ${o.choice}`).join(" · ")}
                  </p>
                ) : null}
                {item.addons.length > 0 ? (
                  <p className="text-xs text-muted-foreground">
                    {item.addons.map((a) => a.name).join(" · ")}
                  </p>
                ) : null}
                {item.specialInstructions ? (
                  <p className="text-xs italic text-muted-foreground">{item.specialInstructions}</p>
                ) : null}
              </div>
              <span className="font-medium">{formatCurrency(item.itemTotal, locale)}</span>
            </li>
          );
        })}
      </ul>

      <CartSummary
        subtotal={order.subtotal}
        deliveryFee={order.deliveryFee}
        serviceFee={order.serviceFee}
        tax={order.tax}
        discount={order.discount}
      />

      <div className="rounded-2xl border bg-card p-4 text-sm">
        <p className="font-semibold">{t("deliveryAddress")}</p>
        <p className="mt-1 text-muted-foreground">
          {[order.deliveryAddress.street, order.deliveryAddress.area, order.deliveryAddress.city]
            .filter(Boolean)
            .join("، ")}
        </p>
        {order.deliveryInstructions ? (
          <p className="mt-2 text-xs italic text-muted-foreground">{order.deliveryInstructions}</p>
        ) : null}
      </div>
    </section>
  );
}
