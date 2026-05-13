"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

import type { Address } from "@bagour/types";

import { useApi } from "@/lib/api-context";

const customerKey = ["customer", "profile"] as const;
const addressesKey = ["customer", "addresses"] as const;

export function useCustomer() {
  const api = useApi();
  return useQuery({ queryKey: customerKey, queryFn: () => api.customer.profile() });
}

export function useAddresses() {
  const api = useApi();
  return useQuery({ queryKey: addressesKey, queryFn: () => api.customer.addresses() });
}

export function useAddAddress() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (payload: Omit<Address, "id">) => api.customer.addAddress(payload),
    onSuccess: () => qc.invalidateQueries({ queryKey: addressesKey }),
  });
}

export function useUpdateAddress() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, payload }: { id: string; payload: Partial<Omit<Address, "id">> }) =>
      api.customer.updateAddress(id, payload),
    onSuccess: () => qc.invalidateQueries({ queryKey: addressesKey }),
  });
}

export function useDeleteAddress() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.customer.deleteAddress(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: addressesKey }),
  });
}

export function useSetDefaultAddress() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => api.customer.setDefaultAddress(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: addressesKey }),
  });
}
