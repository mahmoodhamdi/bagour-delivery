"use client";

import { useQuery } from "@tanstack/react-query";

import { useApi } from "@/lib/api-context";

const statsKey = ["driver", "stats"] as const;
const earningsHistoryKey = ["driver", "earnings", "history"] as const;

export function useDriverStats() {
  const api = useApi();
  return useQuery({
    queryKey: statsKey,
    queryFn: () => api.drivers.stats(),
    staleTime: 60_000,
  });
}

/**
 * Earnings history — derived from delivered orders since the api-client
 * doesn't yet expose a dedicated /driver/earnings/history endpoint. We
 * filter `myOrders` for delivered orders and group by day.
 */
export function useEarningsHistory() {
  const api = useApi();
  return useQuery({
    queryKey: earningsHistoryKey,
    queryFn: async () => {
      const res = await api.drivers.myOrders({ status: "delivered", limit: 100 });
      const orders = res.data;
      const byDay = new Map<
        string,
        { day: string; total: number; count: number; orders: typeof orders }
      >();
      for (const order of orders) {
        const day = (order.actualDeliveryTime ?? order.updatedAt).slice(0, 10);
        const entry = byDay.get(day) ?? { day, total: 0, count: 0, orders: [] };
        entry.total += order.driverEarnings;
        entry.count += 1;
        entry.orders.push(order);
        byDay.set(day, entry);
      }
      return Array.from(byDay.values()).sort((a, b) => (a.day < b.day ? 1 : -1));
    },
    staleTime: 60_000,
  });
}
