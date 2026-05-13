"use client";

import { useMutation, useQueryClient } from "@tanstack/react-query";

import { useApi } from "@/lib/api-context";

const driverKey = ["driver", "profile"] as const;

export function useToggleDriverOnline() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (isOnline: boolean) => api.drivers.toggleOnline(isOnline),
    onSuccess: (driver) => {
      qc.setQueryData(driverKey, driver);
    },
  });
}

export function useDriverStats() {
  const api = useApi();
  return useMutation({
    mutationFn: () => api.drivers.stats(),
  });
}
