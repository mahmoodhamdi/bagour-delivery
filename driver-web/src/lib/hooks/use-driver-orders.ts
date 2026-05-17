"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

import { useApi } from "@/lib/api-context";

const availableKey = ["driver", "orders", "available"] as const;
const myOrdersKey = (status?: string) => ["driver", "orders", "my", status ?? "all"] as const;
const orderKey = (id: string) => ["driver", "orders", "by-id", id] as const;

interface UseAvailableOrdersOptions {
  /** Only poll while the driver is online. */
  enabled: boolean;
  /** Driver's current geolocation — backend filters orders by proximity. */
  location: { lat: number; lng: number } | null;
  /** Default 8 s — feels fresh without hammering the backend. */
  refetchIntervalMs?: number;
}

export function useAvailableOrders({
  enabled,
  location,
  refetchIntervalMs = 8_000,
}: UseAvailableOrdersOptions) {
  const api = useApi();
  // Quantize location to ~10 m so micro-jitter doesn't bust the query cache.
  const lat = location ? Math.round(location.lat * 10_000) / 10_000 : null;
  const lng = location ? Math.round(location.lng * 10_000) / 10_000 : null;
  return useQuery({
    queryKey: [...availableKey, lat, lng] as const,
    queryFn: () => api.drivers.availableOrders({ lat: lat!, lng: lng! }),
    enabled: enabled && lat !== null && lng !== null,
    refetchInterval: enabled ? refetchIntervalMs : false,
    refetchOnWindowFocus: enabled,
    staleTime: 0,
  });
}

export function useDriverMyOrders(status?: string) {
  const api = useApi();
  return useQuery({
    queryKey: myOrdersKey(status),
    queryFn: () => api.drivers.myOrders({ status }),
    staleTime: 15_000,
  });
}

export function useAcceptOrder() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.drivers.acceptOrder(id),
    onSuccess: (order) => {
      qc.setQueryData(orderKey(order.id), order);
      void qc.invalidateQueries({ queryKey: ["driver", "orders"] });
    },
  });
}

export function useRejectOrder() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, reason }: { id: string; reason?: string }) =>
      api.drivers.rejectOrder(id, reason),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: availableKey });
    },
  });
}

export { availableKey, myOrdersKey, orderKey };
