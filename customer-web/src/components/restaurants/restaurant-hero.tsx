"use client";

import { Clock, MapPin, Star, Utensils } from "lucide-react";
import { useLocale, useTranslations } from "next-intl";

import type { Restaurant } from "@bagour/types";

import { formatCurrency, formatDeliveryWindow, formatRating } from "@/lib/format";

interface RestaurantHeroProps {
  restaurant: Restaurant;
}

export function RestaurantHero({ restaurant }: RestaurantHeroProps) {
  const locale = useLocale();
  const t = useTranslations("Restaurants");

  const name = locale === "ar" ? restaurant.name : (restaurant.nameEn ?? restaurant.name);
  const description =
    locale === "ar" ? restaurant.description : (restaurant.descriptionEn ?? restaurant.description);

  return (
    <header className="overflow-hidden rounded-2xl border bg-card" data-testid="restaurant-hero">
      <div className="relative aspect-[16/6] bg-muted">
        {restaurant.coverImage ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={restaurant.coverImage}
            alt=""
            loading="eager"
            className="size-full object-cover"
          />
        ) : (
          <div className="flex size-full items-center justify-center text-muted-foreground">
            <Utensils aria-hidden className="size-12" />
          </div>
        )}
        {!restaurant.isOpen ? (
          <span className="absolute end-4 top-4 inline-flex items-center rounded-full bg-destructive px-3 py-1 text-sm font-semibold text-white">
            {t("closedNow")}
          </span>
        ) : null}
      </div>

      <div className="space-y-3 p-5 md:p-6">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <h1 className="text-2xl font-bold md:text-3xl">{name}</h1>
            {description ? (
              <p className="mt-1 max-w-2xl text-sm text-muted-foreground md:text-base">
                {description}
              </p>
            ) : null}
          </div>
          <span
            className="inline-flex items-center gap-1 rounded-full bg-amber-100 px-3 py-1 text-sm font-bold text-amber-900 dark:bg-amber-950 dark:text-amber-100"
            aria-label={`${t("rating")} ${restaurant.rating}`}
          >
            <Star aria-hidden className="size-4 fill-current" />
            {formatRating(restaurant.rating, locale)}
          </span>
        </div>

        <ul className="flex flex-wrap items-center gap-4 text-sm text-muted-foreground">
          <li className="inline-flex items-center gap-1.5">
            <Clock aria-hidden className="size-4" />
            {formatDeliveryWindow(restaurant.deliveryTime.min, restaurant.deliveryTime.max, locale)}
          </li>
          <li>{t("deliveryFee", { fee: formatCurrency(restaurant.deliveryFee, locale) })}</li>
          {restaurant.minimumOrder > 0 ? (
            <li>{t("minOrder", { amount: formatCurrency(restaurant.minimumOrder, locale) })}</li>
          ) : null}
          {restaurant.address.area ? (
            <li className="inline-flex items-center gap-1.5">
              <MapPin aria-hidden className="size-4" />
              {restaurant.address.area}
              {restaurant.address.city ? `، ${restaurant.address.city}` : ""}
            </li>
          ) : null}
        </ul>

        {restaurant.cuisineTypes.length > 0 ? (
          <ul className="flex flex-wrap gap-2 pt-1">
            {restaurant.cuisineTypes.map((c) => (
              <li
                key={c}
                className="rounded-full bg-accent/40 px-3 py-1 text-xs font-medium text-foreground"
              >
                {c}
              </li>
            ))}
          </ul>
        ) : null}
      </div>
    </header>
  );
}
