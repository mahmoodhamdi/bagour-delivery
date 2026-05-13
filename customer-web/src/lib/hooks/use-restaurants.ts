"use client";

import { keepPreviousData, useInfiniteQuery, useQuery } from "@tanstack/react-query";

import type { RestaurantSearchQuery } from "@bagour/api-client";

import { useApi } from "@/lib/api-context";

const restaurantsKey = (q: RestaurantSearchQuery) => ["restaurants", "search", q] as const;
const featuredKey = ["restaurants", "featured"] as const;

export function useFeaturedRestaurants() {
  const api = useApi();
  return useQuery({
    queryKey: featuredKey,
    queryFn: () => api.restaurants.featured(),
    staleTime: 5 * 60_000,
  });
}

export function useRestaurants(query: RestaurantSearchQuery) {
  const api = useApi();
  return useInfiniteQuery({
    queryKey: restaurantsKey(query),
    queryFn: ({ pageParam }) => api.restaurants.search({ ...query, page: pageParam }),
    initialPageParam: 1,
    placeholderData: keepPreviousData,
    getNextPageParam: (last) =>
      last.pagination.hasNextPage ? last.pagination.page + 1 : undefined,
  });
}

export function useRestaurantBySlug(slug: string | undefined) {
  const api = useApi();
  return useQuery({
    queryKey: ["restaurants", "by-slug", slug],
    queryFn: () => api.restaurants.bySlug(slug!),
    enabled: !!slug,
    staleTime: 60_000,
  });
}

export function useRestaurantMenu(slug: string | undefined) {
  const api = useApi();
  return useQuery({
    queryKey: ["restaurants", "menu", slug],
    queryFn: () => api.restaurants.menu(slug!),
    enabled: !!slug,
    staleTime: 60_000,
  });
}
