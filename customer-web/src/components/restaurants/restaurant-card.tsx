"use client";

import { Clock, Star, Utensils } from "lucide-react";
import { useLocale, useTranslations } from "next-intl";

import type { Restaurant } from "@bagour/types";

import { Link } from "@/i18n/navigation";
import { cn } from "@/lib/utils";
import { formatCurrency, formatDeliveryWindow, formatRating } from "@/lib/format";

interface RestaurantCardProps {
  restaurant: Restaurant & { slug?: string };
  priority?: boolean;
}

/**
 * Compact restaurant tile used in lists, search results, and the featured
 * row. Honours `isOpen` by greying out and showing a "Closed now" badge.
 */
export function RestaurantCard({ restaurant }: RestaurantCardProps) {
  const t = useTranslations();
  const locale = useLocale();

  const name = locale === "ar" ? restaurant.name : (restaurant.nameEn ?? restaurant.name);
  const description =
    locale === "ar" ? restaurant.description : (restaurant.descriptionEn ?? restaurant.description);
  const slug = restaurant.slug ?? restaurant.id;
  const cuisines = restaurant.cuisineTypes.slice(0, 3).join(" · ");

  return (
    <Link
      href={`/restaurants/${encodeURIComponent(slug)}`}
      className={cn(
        "group flex flex-col overflow-hidden rounded-2xl border bg-card transition-all hover:shadow-md focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2",
        !restaurant.isOpen && "opacity-70",
      )}
      data-testid={`restaurant-card-${restaurant.id}`}
      aria-label={`${name} — ${restaurant.rating} ${t("Restaurants.starsLabel")}`}
    >
      <div className="relative aspect-[16/9] overflow-hidden bg-muted">
        {restaurant.coverImage ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={restaurant.coverImage}
            alt=""
            loading="lazy"
            className="size-full object-cover transition-transform group-hover:scale-105"
          />
        ) : (
          <div className="flex size-full items-center justify-center text-muted-foreground">
            <Utensils aria-hidden className="size-10" />
          </div>
        )}
        {!restaurant.isOpen ? (
          <span className="absolute end-3 top-3 inline-flex items-center rounded-full bg-destructive px-2 py-0.5 text-xs font-semibold text-white">
            {t("Restaurants.closedNow")}
          </span>
        ) : null}
      </div>

      <div className="flex flex-1 flex-col gap-2 p-4">
        <header className="flex items-start justify-between gap-2">
          <h3 className="text-base font-semibold leading-tight">{name}</h3>
          <span
            className="inline-flex shrink-0 items-center gap-1 rounded-full bg-amber-100 px-2 py-0.5 text-xs font-bold text-amber-900 dark:bg-amber-950 dark:text-amber-100"
            aria-label={`${t("Restaurants.rating")} ${restaurant.rating}`}
          >
            <Star aria-hidden className="size-3 fill-current" />
            {formatRating(restaurant.rating, locale)}
          </span>
        </header>

        {cuisines ? (
          <p className="text-xs text-muted-foreground" data-testid="restaurant-card-cuisines">
            {cuisines}
          </p>
        ) : null}

        {description ? (
          <p className="line-clamp-2 text-sm text-muted-foreground">{description}</p>
        ) : null}

        <footer className="mt-auto flex items-center gap-3 pt-2 text-xs text-muted-foreground">
          <span className="inline-flex items-center gap-1">
            <Clock aria-hidden className="size-3" />
            {formatDeliveryWindow(restaurant.deliveryTime.min, restaurant.deliveryTime.max, locale)}
          </span>
          <span aria-hidden>·</span>
          <span data-testid="restaurant-card-fee">
            {t("Restaurants.deliveryFee", {
              fee: formatCurrency(restaurant.deliveryFee, locale),
            })}
          </span>
          {restaurant.minimumOrder > 0 ? (
            <>
              <span aria-hidden>·</span>
              <span>
                {t("Restaurants.minOrder", {
                  amount: formatCurrency(restaurant.minimumOrder, locale),
                })}
              </span>
            </>
          ) : null}
        </footer>
      </div>
    </Link>
  );
}
