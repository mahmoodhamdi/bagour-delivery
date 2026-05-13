import { z } from "zod";

/**
 * Onboarding forms. We only collect the subset of Driver fields the
 * existing backend `updateProfile` endpoint accepts — the rest
 * (national ID, license number, etc.) are populated server-side at
 * register time or via the admin tools.
 */

export const vehicleInfoSchema = z.object({
  vehicleModel: z
    .string()
    .min(2, "Onboarding.errors.vehicleModelRequired")
    .max(100, "Onboarding.errors.vehicleModelTooLong"),
  vehicleColor: z
    .string()
    .min(2, "Onboarding.errors.vehicleColorRequired")
    .max(50, "Onboarding.errors.vehicleColorTooLong"),
  vehiclePlateNumber: z
    .string()
    .min(2, "Onboarding.errors.vehiclePlateRequired")
    .max(20, "Onboarding.errors.vehiclePlateTooLong"),
});

export type VehicleInfoValues = z.infer<typeof vehicleInfoSchema>;
