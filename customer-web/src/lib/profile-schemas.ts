import { z } from "zod";

export const profileEditSchema = z.object({
  name: z.string().min(2, "Auth.errors.nameTooShort").max(50, "Auth.errors.nameTooLong"),
  phone: z.string().regex(/^01[0125][0-9]{8}$/, "Auth.errors.invalidPhone"),
});

export const changePasswordSchema = z
  .object({
    currentPassword: z.string().min(1, "Auth.errors.passwordTooShort"),
    newPassword: z.string().min(8, "Auth.errors.passwordTooShort"),
    confirmPassword: z.string().min(1, "Auth.errors.confirmPasswordRequired"),
  })
  .refine((d) => d.newPassword === d.confirmPassword, {
    path: ["confirmPassword"],
    message: "Auth.errors.passwordsDontMatch",
  })
  .refine((d) => d.currentPassword !== d.newPassword, {
    path: ["newPassword"],
    message: "Profile.errors.newPasswordMustDiffer",
  });

export const addressFormSchema = z.object({
  label: z.string().optional(),
  street: z.string().min(2, "Profile.errors.streetRequired"),
  area: z.string().min(2, "Profile.errors.areaRequired"),
  city: z.string().min(2, "Profile.errors.cityRequired"),
  buildingNumber: z.string().optional(),
  floor: z.string().optional(),
  apartment: z.string().optional(),
  landmark: z.string().optional(),
  isDefault: z.boolean().optional(),
  lat: z.number().min(-90).max(90).optional(),
  lng: z.number().min(-180).max(180).optional(),
});

export type ProfileEditValues = z.infer<typeof profileEditSchema>;
export type ChangePasswordValues = z.infer<typeof changePasswordSchema>;
export type AddressFormValues = z.infer<typeof addressFormSchema>;
