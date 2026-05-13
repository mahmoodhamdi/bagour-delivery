"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

import type { CreateOrderPayload, OrderListQuery, RateOrderPayload } from "@bagour/api-client";
import type { OrderStatus } from "@bagour/types";

import { useApi } from "@/lib/api-context";

const ordersKey = (q: OrderListQuery) => ["orders", "list", q] as const;
const orderKey = (id: string) => ["orders", "by-id", id] as const;

const ACTIVE_STATUSES: OrderStatus[] = [
  "pending",
  "confirmed",
  "preparing",
  "ready",
  "picked_up",
  "on_the_way",
];

export function useMyOrders(query: OrderListQuery = {}) {
  const api = useApi();
  return useQuery({
    queryKey: ordersKey(query),
    queryFn: () => api.orders.myOrders(query),
    staleTime: 30_000,
  });
}

export function useOrder(id: string | undefined) {
  const api = useApi();
  return useQuery({
    queryKey: orderKey(id ?? ""),
    queryFn: () => api.orders.byId(id!),
    enabled: !!id,
    refetchInterval: (q) => {
      const status = q.state.data?.status;
      // Poll every 15 s while the order is still in motion; stop after delivery/cancellation.
      return status && ACTIVE_STATUSES.includes(status) ? 15_000 : false;
    },
  });
}

export function useCreateOrder() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (payload: CreateOrderPayload) => api.orders.create(payload),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ["orders"] });
    },
  });
}

export function useCancelOrder() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, reason }: { id: string; reason: string }) => api.orders.cancel(id, reason),
    onSuccess: (_, { id }) => {
      void qc.invalidateQueries({ queryKey: ["orders"] });
      void qc.invalidateQueries({ queryKey: orderKey(id) });
    },
  });
}

export function useRateOrder() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, payload }: { id: string; payload: RateOrderPayload }) =>
      api.orders.rate(id, payload),
    onSuccess: (_, { id }) => {
      void qc.invalidateQueries({ queryKey: orderKey(id) });
    },
  });
}

export function useReorder() {
  const api = useApi();
  return useMutation({
    mutationFn: (id: string) => api.orders.reorder(id),
  });
}
