"use client";

import type { Driver, DriverDocuments } from "@bagour/types";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

import { useApi } from "@/lib/api-context";

const driverKey = ["driver", "profile"] as const;

export function useDriverProfile() {
  const api = useApi();
  return useQuery({
    queryKey: driverKey,
    queryFn: () => api.drivers.profile(),
    staleTime: 60_000,
  });
}

export function useUpdateDriverProfile() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (payload: Partial<Pick<Driver, "vehicleModel" | "vehicleColor" | "vehiclePlateNumber">>) =>
      api.drivers.updateProfile(payload),
    onSuccess: (driver) => {
      qc.setQueryData(driverKey, driver);
    },
  });
}

export function useUpdateDriverDocuments() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (documents: Partial<DriverDocuments>) => api.drivers.updateDocuments(documents),
    onSuccess: (driver) => {
      qc.setQueryData(driverKey, driver);
    },
  });
}

export function useUploadDriverDocument() {
  const api = useApi();
  return useMutation({
    mutationFn: (file: File) => api.uploads.upload("driver-document", file),
  });
}
