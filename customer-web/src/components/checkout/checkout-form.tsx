"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { Banknote, CreditCard, Loader2, MapPin, ShoppingBag, Tag } from "lucide-react";
import { useLocale, useTranslations } from "next-intl";
import { useEffect, useState, useTransition } from "react";
import { useForm } from "react-hook-form";
import { toast } from "sonner";

import type { CouponValidation, CreateOrderPayload } from "@bagour/api-client";
import { ApiError } from "@bagour/api-client";

import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import { Link, useRouter } from "@/i18n/navigation";
import { useApi } from "@/lib/api-context";
import { useAddresses } from "@/lib/hooks/use-customer";
import { checkoutFormSchema, type CheckoutFormValues } from "@/lib/checkout-schemas";
import { formatCurrency } from "@/lib/format";
import { cn } from "@/lib/utils";
import { useCartStore } from "@/stores/cart-store";

import { CartSummary, computeTotals } from "@/components/cart/cart-summary";

const DEFAULT_DELIVERY_FEE = 15;

export function CheckoutForm() {
  const t = useTranslations();
  const locale = useLocale();
  const router = useRouter();
  const api = useApi();
  const addressesQuery = useAddresses();
  const lines = useCartStore((s) => s.lines);
  const restaurantId = useCartStore((s) => s.restaurantId);
  const subtotal = useCartStore((s) => s.lines.reduce((sum, l) => sum + l.itemTotal, 0));
  const clearCart = useCartStore((s) => s.clear);

  const [coupon, setCoupon] = useState<CouponValidation | null>(null);
  const [serverError, setServerError] = useState<string | null>(null);
  const [, startTransition] = useTransition();

  const form = useForm<CheckoutFormValues>({
    resolver: zodResolver(checkoutFormSchema),
    defaultValues: {
      addressId: "",
      paymentMethod: "cash",
      notes: "",
      deliveryInstructions: "",
      couponCode: "",
      tip: 0,
    },
    mode: "onSubmit",
  });

  // Seed default address as soon as addresses load.
  useEffect(() => {
    if (!form.getValues("addressId") && addressesQuery.data && addressesQuery.data.length > 0) {
      const def =
        addressesQuery.data.find((a) => a.isDefault && a.id) ??
        addressesQuery.data.find((a) => a.id);
      if (def?.id) {
        form.setValue("addressId", def.id, { shouldDirty: false });
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [addressesQuery.data]);

  const discount = coupon?.isValid ? coupon.discount : 0;
  const total = computeTotals({ subtotal, deliveryFee: DEFAULT_DELIVERY_FEE, discount });

  const handleApplyCoupon = async () => {
    const code = form.getValues("couponCode")?.trim();
    if (!code) return;
    setServerError(null);
    try {
      const result = await api.coupons.validate({
        code,
        restaurantId: restaurantId ?? undefined,
        subtotal,
      });
      setCoupon(result);
      if (result.isValid) {
        toast.success(t("Checkout.toasts.couponApplied"));
      } else {
        toast.error(result.reason ?? t("Checkout.errors.couponInvalid"));
      }
    } catch (err) {
      if (err instanceof ApiError) {
        toast.error(err.message);
      }
    }
  };

  const onSubmit = async (values: CheckoutFormValues) => {
    setServerError(null);
    if (lines.length === 0 || !restaurantId) {
      setServerError(t("Checkout.errors.cartEmpty"));
      return;
    }

    const payload: CreateOrderPayload = {
      restaurantId,
      items: lines.map((l) => ({
        menuItemId: l.menuItemId,
        quantity: l.quantity,
        addons: l.addons,
        options: l.options,
        specialInstructions: l.specialInstructions,
      })),
      addressId: values.addressId,
      paymentMethod: values.paymentMethod,
      couponCode: coupon?.isValid ? values.couponCode : undefined,
      notes: values.notes ?? undefined,
      deliveryInstructions: values.deliveryInstructions ?? undefined,
      tip: values.tip ?? 0,
    };

    try {
      const order = await api.orders.create(payload);
      clearCart();
      toast.success(t("Checkout.toasts.orderPlaced", { orderNumber: order.orderNumber }));
      startTransition(() => {
        router.push(`/orders/${order.id}`);
      });
    } catch (err) {
      if (err instanceof ApiError) {
        setServerError(err.message);
      } else {
        setServerError(t("Common.error"));
      }
    }
  };

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="grid gap-6 lg:grid-cols-[1fr_360px]"
        noValidate
      >
        <div className="space-y-6">
          {/* Address picker */}
          <FormField
            control={form.control}
            name="addressId"
            render={({ field }) => (
              <FormItem>
                <FormLabel className="text-base font-bold">
                  <MapPin aria-hidden className="me-1 inline size-4" />
                  {t("Checkout.deliverTo")}
                </FormLabel>
                <FormControl>
                  <fieldset className="space-y-2" data-testid="checkout-addresses">
                    <legend className="sr-only">{t("Checkout.deliverTo")}</legend>
                    {addressesQuery.isLoading ? (
                      <Skeleton className="h-20 w-full rounded-2xl" />
                    ) : addressesQuery.data && addressesQuery.data.length > 0 ? (
                      addressesQuery.data
                        .filter((a) => a.id)
                        .map((a) => (
                          <label
                            key={a.id}
                            htmlFor={`addr-${a.id}`}
                            className={cn(
                              "flex cursor-pointer items-start gap-3 rounded-2xl border bg-card p-3 transition-colors",
                              field.value === a.id
                                ? "border-primary ring-2 ring-primary/40"
                                : "hover:bg-accent/40",
                            )}
                            data-testid={`checkout-address-${a.id}`}
                          >
                            <input
                              id={`addr-${a.id}`}
                              type="radio"
                              name="addressId"
                              value={a.id}
                              checked={field.value === a.id}
                              onChange={() => field.onChange(a.id)}
                              className="mt-1 size-4 accent-primary"
                            />
                            <div className="min-w-0 flex-1">
                              <p className="font-semibold">
                                {a.label ?? t("Profile.address")}
                                {a.isDefault ? (
                                  <span className="ms-2 rounded-full bg-primary/10 px-2 py-0.5 text-xs font-semibold text-primary">
                                    {t("Profile.defaultAddressBadge")}
                                  </span>
                                ) : null}
                              </p>
                              <p className="text-sm text-muted-foreground">
                                {[a.street, a.area, a.city].filter(Boolean).join("، ")}
                              </p>
                            </div>
                          </label>
                        ))
                    ) : (
                      <div className="rounded-2xl border-2 border-dashed p-6 text-center text-sm text-muted-foreground">
                        {t("Checkout.noAddresses")}{" "}
                        <Link
                          href="/profile/addresses/new"
                          className="font-semibold text-primary hover:underline"
                        >
                          {t("Checkout.addAddress")}
                        </Link>
                      </div>
                    )}
                  </fieldset>
                </FormControl>
                <FormMessage>
                  {form.formState.errors.addressId?.message
                    ? t(form.formState.errors.addressId.message as never)
                    : null}
                </FormMessage>
              </FormItem>
            )}
          />

          {/* Payment method */}
          <FormField
            control={form.control}
            name="paymentMethod"
            render={({ field }) => (
              <FormItem>
                <FormLabel className="text-base font-bold">{t("Checkout.payment")}</FormLabel>
                <FormControl>
                  <fieldset
                    className="grid grid-cols-1 gap-2 sm:grid-cols-2"
                    data-testid="checkout-payment"
                  >
                    <legend className="sr-only">{t("Checkout.payment")}</legend>
                    {[
                      {
                        value: "cash" as const,
                        label: t("Checkout.payCash"),
                        icon: <Banknote aria-hidden className="size-5" />,
                      },
                      {
                        value: "card" as const,
                        label: t("Checkout.payCard"),
                        icon: <CreditCard aria-hidden className="size-5" />,
                      },
                    ].map((opt) => {
                      const selected = field.value === opt.value;
                      return (
                        <label
                          key={opt.value}
                          htmlFor={`pay-${opt.value}`}
                          className={cn(
                            "flex cursor-pointer items-center gap-3 rounded-2xl border bg-card p-3",
                            selected
                              ? "border-primary ring-2 ring-primary/40"
                              : "hover:bg-accent/40",
                          )}
                          data-testid={`payment-${opt.value}`}
                        >
                          <input
                            id={`pay-${opt.value}`}
                            type="radio"
                            name="paymentMethod"
                            value={opt.value}
                            checked={selected}
                            onChange={() => field.onChange(opt.value)}
                            className="size-4 accent-primary"
                          />
                          {opt.icon}
                          <span className="font-semibold">{opt.label}</span>
                        </label>
                      );
                    })}
                  </fieldset>
                </FormControl>
              </FormItem>
            )}
          />

          {/* Coupon */}
          <FormItem>
            <FormLabel className="text-base font-bold">
              <Tag aria-hidden className="me-1 inline size-4" />
              {t("Checkout.coupon")}
            </FormLabel>
            <div className="flex gap-2">
              <Input
                type="text"
                placeholder={t("Checkout.couponPlaceholder")}
                data-testid="checkout-coupon"
                {...form.register("couponCode")}
              />
              <Button
                type="button"
                variant="outline"
                onClick={() => void handleApplyCoupon()}
                disabled={form.formState.isSubmitting}
                data-testid="checkout-apply-coupon"
              >
                {t("Checkout.applyCoupon")}
              </Button>
            </div>
            {coupon?.isValid ? (
              <p className="text-sm text-primary">
                {t("Checkout.couponActive", { amount: formatCurrency(coupon.discount, locale) })}
              </p>
            ) : null}
          </FormItem>

          {/* Notes */}
          <FormField
            control={form.control}
            name="notes"
            render={({ field }) => (
              <FormItem>
                <FormLabel>{t("Checkout.notes")}</FormLabel>
                <FormControl>
                  <textarea
                    rows={2}
                    maxLength={300}
                    placeholder={t("Checkout.notesPlaceholder")}
                    data-testid="checkout-notes"
                    className="w-full rounded-xl border border-input bg-card px-3 py-2 text-sm shadow-xs focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
                    {...field}
                  />
                </FormControl>
              </FormItem>
            )}
          />
        </div>

        <aside className="space-y-4">
          <header className="flex items-center gap-2 text-sm font-semibold">
            <ShoppingBag aria-hidden className="size-4" />
            {t("Checkout.orderSummary")}
          </header>
          <CartSummary subtotal={subtotal} deliveryFee={DEFAULT_DELIVERY_FEE} discount={discount} />

          {serverError ? (
            <p
              role="alert"
              className="rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-sm font-medium text-destructive"
            >
              {serverError}
            </p>
          ) : null}

          <Button
            type="submit"
            size="lg"
            className="w-full"
            disabled={form.formState.isSubmitting || lines.length === 0}
            data-testid="checkout-submit"
          >
            {form.formState.isSubmitting ? (
              <Loader2 aria-hidden className="size-4 animate-spin" />
            ) : null}
            {t("Checkout.placeOrder", { total: formatCurrency(total, locale) })}
          </Button>

          <p className="text-center text-xs text-muted-foreground">{t("Checkout.disclaimer")}</p>
        </aside>
      </form>
    </Form>
  );
}
