"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

import { useApi } from "@/lib/api-context";

import { orderKey } from "./use-driver-orders";

const ACTIVE_STATUSES = ["confirmed", "preparing", "ready", "picked_up", "on_the_way"] as const;

/**
 * Pulls a single driver order. Polls every 10 s while the order is still
 * in motion so the restaurant's status updates (e.g. preparing → ready)
 * show up without a manual refresh.
 */
export function useDriverOrder(id: string | undefined) {
  const api = useApi();
  return useQuery({
    queryKey: orderKey(id ?? ""),
    queryFn: async () => {
      // The api-client doesn't expose /driver/orders/{id} directly, so we
      // fall back to filtering myOrders. Backend ETA: include a dedicated
      // GET-by-id once it lands.
      const list = await api.drivers.myOrders({});
      const found = list.data.find((o) => o.id === id);
      if (!found) {
        throw new Error("not_found");
      }
      return found;
    },
    enabled: !!id,
    refetchInterval: (q) => {
      const status = q.state.data?.status;
      return status && ACTIVE_STATUSES.includes(status as (typeof ACTIVE_STATUSES)[number])
        ? 10_000
        : false;
    },
    staleTime: 0,
  });
}

export function useMarkPickedUp() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.drivers.markPickedUp(id),
    onSuccess: (order) => {
      qc.setQueryData(orderKey(order.id), order);
      void qc.invalidateQueries({ queryKey: ["driver", "orders"] });
    },
  });
}

export function useMarkOnTheWay() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.drivers.markOnTheWay(id),
    onSuccess: (order) => {
      qc.setQueryData(orderKey(order.id), order);
      void qc.invalidateQueries({ queryKey: ["driver", "orders"] });
    },
  });
}

export function useMarkDelivered() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, proofUrl, note }: { id: string; proofUrl?: string; note?: string }) =>
      api.drivers.markDelivered(id, proofUrl || note ? { proofUrl, note } : undefined),
    onSuccess: (order) => {
      qc.setQueryData(orderKey(order.id), order);
      void qc.invalidateQueries({ queryKey: ["driver", "orders"] });
    },
  });
}

export function useUploadDeliveryProof() {
  const api = useApi();
  return useMutation({
    mutationFn: (file: File) => api.uploads.upload("delivery-proof", file),
  });
}
