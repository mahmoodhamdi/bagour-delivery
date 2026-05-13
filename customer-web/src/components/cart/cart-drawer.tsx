"use client";

import { ShoppingBag } from "lucide-react";
import { useTranslations } from "next-intl";

import { Button } from "@/components/ui/button";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Link } from "@/i18n/navigation";
import { selectCartCount, selectCartSubtotal, useCartStore } from "@/stores/cart-store";

import { CartLine } from "./cart-line";
import { CartSummary } from "./cart-summary";

/**
 * Header-mounted cart trigger + slide-over panel.
 * Hidden when the cart is empty unless `alwaysShowTrigger=true`.
 */
export function CartDrawer({ alwaysShowTrigger = true }: { alwaysShowTrigger?: boolean }) {
  const t = useTranslations();
  const count = useCartStore(selectCartCount);
  const subtotal = useCartStore(selectCartSubtotal);
  const lines = useCartStore((s) => s.lines);
  const restaurantName = useCartStore((s) => s.restaurantName);
  const deliveryFee = 0; // populated by the checkout page after address selection

  const showTrigger = alwaysShowTrigger || count > 0;
  if (!showTrigger) return null;

  return (
    <Sheet>
      <SheetTrigger asChild>
        <Button
          variant="outline"
          size="sm"
          aria-label={t("Cart.cartLabel")}
          data-testid="cart-trigger"
          className="relative gap-2"
        >
          <ShoppingBag aria-hidden className="size-4" />
          <span className="hidden md:inline">{t("Cart.cartLabel")}</span>
          {count > 0 ? (
            <span
              className="inline-flex min-w-6 items-center justify-center rounded-full bg-primary px-1.5 text-xs font-bold text-primary-foreground"
              data-testid="cart-count"
              aria-label={t("Cart.itemsCount", { count })}
            >
              {count}
            </span>
          ) : null}
        </Button>
      </SheetTrigger>
      <SheetContent
        side="right"
        className="flex w-full flex-col gap-4 sm:max-w-md"
        data-testid="cart-drawer"
      >
        <SheetHeader>
          <SheetTitle>{t("Cart.cartLabel")}</SheetTitle>
          {restaurantName ? (
            <SheetDescription>
              {t("Cart.fromRestaurant", { name: restaurantName })}
            </SheetDescription>
          ) : (
            <SheetDescription>{t("Cart.empty")}</SheetDescription>
          )}
        </SheetHeader>

        {lines.length === 0 ? (
          <div
            className="flex flex-1 flex-col items-center justify-center gap-3 text-center"
            data-testid="cart-empty-state"
          >
            <ShoppingBag aria-hidden className="size-10 text-muted-foreground" />
            <p className="font-semibold">{t("Cart.empty")}</p>
            <p className="text-sm text-muted-foreground">{t("Cart.emptyDesc")}</p>
            <Button asChild>
              <Link href="/restaurants">{t("Cart.browseRestaurants")}</Link>
            </Button>
          </div>
        ) : (
          <>
            <ul className="flex-1 space-y-2 overflow-y-auto pe-1" data-testid="cart-lines">
              {lines.map((line) => (
                <li key={line.lineId}>
                  <CartLine line={line} />
                </li>
              ))}
            </ul>

            <CartSummary subtotal={subtotal} deliveryFee={deliveryFee} />

            <Button asChild size="lg" data-testid="cart-checkout-cta">
              <Link href="/checkout">{t("Cart.goToCheckout")}</Link>
            </Button>
          </>
        )}
      </SheetContent>
    </Sheet>
  );
}
