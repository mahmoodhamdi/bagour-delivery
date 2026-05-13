"use client";

import { useQuery } from "@tanstack/react-query";

import { fetchOsrmRoute } from "@/lib/osrm";

interface UseOsrmRouteOptions {
  from: [number, number] | null;
  to: [number, number] | null;
}

export function useOsrmRoute({ from, to }: UseOsrmRouteOptions) {
  return useQuery({
    queryKey: ["osrm", from?.[0], from?.[1], to?.[0], to?.[1]] as const,
    queryFn: ({ signal }) =>
      from && to ? fetchOsrmRoute(from, to, signal) : Promise.resolve(null),
    enabled: !!from && !!to,
    staleTime: 5 * 60_000,
  });
}
