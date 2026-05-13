"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2 } from "lucide-react";
import { useTranslations } from "next-intl";
import { useState, useTransition } from "react";
import { Controller, useForm } from "react-hook-form";
import { toast } from "sonner";

import { ApiError } from "@bagour/api-client";

import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { OtpInput } from "@/components/ui/otp-input";
import { PasswordInput } from "@/components/ui/password-input";
import { useRouter } from "@/i18n/navigation";
import { useApi } from "@/lib/api-context";
import { resetPasswordFormSchema, type ResetPasswordFormValues } from "@/lib/auth-schemas";

interface ResetPasswordFormProps {
  email?: string;
}

export function ResetPasswordForm({ email = "" }: ResetPasswordFormProps) {
  const t = useTranslations();
  const router = useRouter();
  const api = useApi();
  const [serverError, setServerError] = useState<string | null>(null);
  const [, startTransition] = useTransition();

  const form = useForm<ResetPasswordFormValues>({
    resolver: zodResolver(resetPasswordFormSchema),
    defaultValues: { email, otp: "", newPassword: "", confirmPassword: "" },
    mode: "onBlur",
  });

  const onSubmit = async (values: ResetPasswordFormValues) => {
    setServerError(null);
    try {
      await api.auth.resetPassword({
        email: values.email,
        otp: values.otp,
        newPassword: values.newPassword,
      });
      toast.success(t("Auth.toasts.passwordReset"));
      startTransition(() => {
        router.push("/login");
      });
    } catch (err) {
      if (err instanceof ApiError) {
        setServerError(err.statusCode === 422 ? t("Auth.errors.otpInvalid") : err.message);
      } else {
        setServerError(t("Common.error"));
      }
    }
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-5" noValidate>
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("Auth.fields.email")}</FormLabel>
              <FormControl>
                <Input
                  type="email"
                  autoComplete="email"
                  data-testid="reset-email"
                  readOnly={!!email}
                  {...field}
                />
              </FormControl>
              <FormMessage>
                {form.formState.errors.email?.message
                  ? t(form.formState.errors.email.message as never)
                  : null}
              </FormMessage>
            </FormItem>
          )}
        />

        <Controller
          control={form.control}
          name="otp"
          render={({ field }) => (
            <FormItem>
              <FormLabel htmlFor={undefined}>{t("Auth.fields.otp")}</FormLabel>
              <OtpInput
                value={field.value}
                onChange={field.onChange}
                ariaLabel={t("Auth.fields.otp")}
                disabled={form.formState.isSubmitting}
                invalid={!!form.formState.errors.otp}
              />
              <FormMessage>
                {form.formState.errors.otp?.message
                  ? t(form.formState.errors.otp.message as never)
                  : null}
              </FormMessage>
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="newPassword"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("Auth.fields.newPassword")}</FormLabel>
              <FormControl>
                <PasswordInput
                  autoComplete="new-password"
                  data-testid="reset-new-password"
                  showLabel={t("Auth.actions.showPassword")}
                  hideLabel={t("Auth.actions.hidePassword")}
                  {...field}
                />
              </FormControl>
              <FormMessage>
                {form.formState.errors.newPassword?.message
                  ? t(form.formState.errors.newPassword.message as never)
                  : null}
              </FormMessage>
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="confirmPassword"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("Auth.fields.confirmPassword")}</FormLabel>
              <FormControl>
                <PasswordInput
                  autoComplete="new-password"
                  data-testid="reset-confirm-password"
                  showLabel={t("Auth.actions.showPassword")}
                  hideLabel={t("Auth.actions.hidePassword")}
                  {...field}
                />
              </FormControl>
              <FormMessage>
                {form.formState.errors.confirmPassword?.message
                  ? t(form.formState.errors.confirmPassword.message as never)
                  : null}
              </FormMessage>
            </FormItem>
          )}
        />

        {serverError ? (
          <p
            role="alert"
            className="rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-sm font-medium text-destructive"
          >
            {serverError}
          </p>
        ) : null}

        <Button
          type="submit"
          size="lg"
          className="w-full"
          disabled={form.formState.isSubmitting}
          data-testid="reset-submit"
        >
          {form.formState.isSubmitting ? (
            <Loader2 aria-hidden className="size-4 animate-spin" />
          ) : null}
          {t("Auth.actions.resetPassword")}
        </Button>
      </form>
    </Form>
  );
}
