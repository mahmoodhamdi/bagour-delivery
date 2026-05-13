import { z } from "zod";

/**
 * Driver-side Zod schemas. Bake i18n message keys instead of English so
 * react-hook-form errors flow through the same `t()` call as the rest of
 * the page.
 */

export const loginFormSchema = z.object({
  email: z.string().min(1, "Auth.errors.emailRequired").email("Auth.errors.invalidEmail"),
  password: z.string().min(8, "Auth.errors.passwordTooShort"),
});

export const registerFormSchema = z
  .object({
    name: z.string().min(2, "Auth.errors.nameTooShort").max(50, "Auth.errors.nameTooLong"),
    email: z.string().min(1, "Auth.errors.emailRequired").email("Auth.errors.invalidEmail"),
    phone: z.string().regex(/^01[0125][0-9]{8}$/, "Auth.errors.invalidPhone"),
    password: z.string().min(8, "Auth.errors.passwordTooShort"),
    confirmPassword: z.string().min(1, "Auth.errors.confirmPasswordRequired"),
    acceptTerms: z
      .boolean()
      .refine((v) => v === true, { message: "Auth.errors.acceptTermsRequired" }),
  })
  .refine((data) => data.password === data.confirmPassword, {
    path: ["confirmPassword"],
    message: "Auth.errors.passwordsDontMatch",
  });

export const otpFormSchema = z.object({
  otp: z
    .string()
    .length(6, "Auth.errors.otpInvalid")
    .regex(/^\d{6}$/, "Auth.errors.otpInvalid"),
});

export const forgotPasswordFormSchema = z.object({
  email: z.string().min(1, "Auth.errors.emailRequired").email("Auth.errors.invalidEmail"),
});

export const resetPasswordFormSchema = z
  .object({
    email: z.string().email("Auth.errors.invalidEmail"),
    otp: z
      .string()
      .length(6, "Auth.errors.otpInvalid")
      .regex(/^\d{6}$/, "Auth.errors.otpInvalid"),
    newPassword: z.string().min(8, "Auth.errors.passwordTooShort"),
    confirmPassword: z.string().min(1, "Auth.errors.confirmPasswordRequired"),
  })
  .refine((data) => data.newPassword === data.confirmPassword, {
    path: ["confirmPassword"],
    message: "Auth.errors.passwordsDontMatch",
  });

export type LoginFormValues = z.infer<typeof loginFormSchema>;
export type RegisterFormValues = z.infer<typeof registerFormSchema>;
export type OtpFormValues = z.infer<typeof otpFormSchema>;
export type ForgotPasswordFormValues = z.infer<typeof forgotPasswordFormSchema>;
export type ResetPasswordFormValues = z.infer<typeof resetPasswordFormSchema>;
