"use client";

import { Loader2, Utensils } from "lucide-react";
import { useTranslations } from "next-intl";
import { useState } from "react";

import type { RestaurantSearchQuery } from "@bagour/api-client";

import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { useRestaurants } from "@/lib/hooks/use-restaurants";

import { CuisinePills } from "./cuisine-pills";
import { RestaurantCard } from "./restaurant-card";
import { RestaurantsSearch } from "./restaurants-search";

export function RestaurantList() {
  const t = useTranslations();
  const [search, setSearch] = useState("");
  const [cuisine, setCuisine] = useState<string | undefined>(undefined);
  const [sort, setSort] = useState<RestaurantSearchQuery["sort"]>("rating");

  const query: RestaurantSearchQuery = {
    q: search || undefined,
    cuisine,
    sort,
    limit: 12,
  };
  const { data, isLoading, isError, isFetchingNextPage, fetchNextPage, hasNextPage } =
    useRestaurants(query);

  const restaurants = data?.pages.flatMap((p) => p.data) ?? [];
  const showEmpty = !isLoading && restaurants.length === 0;

  return (
    <section className="space-y-5" data-testid="restaurants-section">
      <div className="grid gap-3 md:grid-cols-[1fr_auto] md:items-center">
        <RestaurantsSearch value={search} onChange={setSearch} />
        <div className="flex items-center gap-2">
          <label className="text-sm font-medium" htmlFor="restaurants-sort">
            {t("Restaurants.sortLabel")}
          </label>
          <select
            id="restaurants-sort"
            value={sort}
            onChange={(e) => setSort(e.target.value as typeof sort)}
            data-testid="restaurants-sort"
            className="h-10 rounded-xl border border-input bg-card px-3 text-sm shadow-xs focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
          >
            <option value="rating">{t("Restaurants.sort.rating")}</option>
            <option value="deliveryTime">{t("Restaurants.sort.deliveryTime")}</option>
            <option value="deliveryFee">{t("Restaurants.sort.deliveryFee")}</option>
            <option value="popularity">{t("Restaurants.sort.popularity")}</option>
          </select>
        </div>
      </div>

      <CuisinePills
        selected={cuisine}
        onChange={setCuisine}
        allLabel={t("Restaurants.allCuisines")}
      />

      {isLoading ? (
        <ul
          id="restaurants-grid"
          aria-busy="true"
          className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3"
        >
          {Array.from({ length: 6 }).map((_, i) => (
            <li key={i}>
              <Skeleton className="h-64 w-full rounded-2xl" />
            </li>
          ))}
        </ul>
      ) : isError ? (
        <p
          role="alert"
          className="rounded-lg border border-destructive/30 bg-destructive/10 p-4 text-sm font-medium text-destructive"
          data-testid="restaurants-error"
        >
          {t("Common.error")}
        </p>
      ) : showEmpty ? (
        <div
          className="flex flex-col items-center gap-3 rounded-2xl border-2 border-dashed bg-card p-10 text-center"
          data-testid="restaurants-empty"
        >
          <Utensils aria-hidden className="size-10 text-muted-foreground" />
          <p className="font-semibold">{t("Restaurants.noResults")}</p>
          <p className="text-sm text-muted-foreground">{t("Restaurants.noResultsDesc")}</p>
        </div>
      ) : (
        <>
          <ul
            id="restaurants-grid"
            className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3"
            data-testid="restaurants-grid"
          >
            {restaurants.map((r) => (
              <li key={r.id}>
                <RestaurantCard restaurant={r} />
              </li>
            ))}
          </ul>

          {hasNextPage ? (
            <div className="flex justify-center pt-4">
              <Button
                variant="outline"
                onClick={() => void fetchNextPage()}
                disabled={isFetchingNextPage}
                data-testid="restaurants-load-more"
              >
                {isFetchingNextPage ? (
                  <Loader2 aria-hidden className="size-4 animate-spin" />
                ) : null}
                {t("Restaurants.loadMore")}
              </Button>
            </div>
          ) : null}
        </>
      )}
    </section>
  );
}
