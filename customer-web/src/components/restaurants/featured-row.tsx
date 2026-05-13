"use client";

import { useTranslations } from "next-intl";

import { Skeleton } from "@/components/ui/skeleton";
import { useFeaturedRestaurants } from "@/lib/hooks/use-restaurants";

import { RestaurantCard } from "./restaurant-card";

export function FeaturedRow() {
  const t = useTranslations("Restaurants");
  const { data, isLoading } = useFeaturedRestaurants();

  if (!isLoading && (!data || data.length === 0)) return null;

  return (
    <section aria-labelledby="featured-row-title" className="space-y-3">
      <h2 id="featured-row-title" className="text-lg font-bold">
        {t("featured")}
      </h2>
      {isLoading ? (
        <ul className="-mx-4 flex gap-3 overflow-x-auto px-4 pb-2">
          {Array.from({ length: 3 }).map((_, i) => (
            <li key={i} className="min-w-[260px]">
              <Skeleton className="h-56 w-full rounded-2xl" />
            </li>
          ))}
        </ul>
      ) : (
        <ul
          className="-mx-4 flex gap-3 overflow-x-auto px-4 pb-2"
          data-testid="featured-restaurants"
        >
          {data?.map((r) => (
            <li key={r.id} className="min-w-[260px] max-w-[320px]">
              <RestaurantCard restaurant={r} />
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
