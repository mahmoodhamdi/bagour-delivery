"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2 } from "lucide-react";
import { useTranslations } from "next-intl";
import { useState, useTransition } from "react";
import { useForm } from "react-hook-form";
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
import { PasswordInput } from "@/components/ui/password-input";
import { useRouter } from "@/i18n/navigation";
import { useApi } from "@/lib/api-context";
import { changePasswordSchema, type ChangePasswordValues } from "@/lib/profile-schemas";

export function ChangePasswordForm() {
  const t = useTranslations();
  const router = useRouter();
  const api = useApi();
  const [serverError, setServerError] = useState<string | null>(null);
  const [, startTransition] = useTransition();

  const form = useForm<ChangePasswordValues>({
    resolver: zodResolver(changePasswordSchema),
    defaultValues: { currentPassword: "", newPassword: "", confirmPassword: "" },
    mode: "onBlur",
  });

  const onSubmit = async (values: ChangePasswordValues) => {
    setServerError(null);
    try {
      await api.auth.changePassword({
        currentPassword: values.currentPassword,
        newPassword: values.newPassword,
      });
      toast.success(t("Profile.toasts.passwordChanged"));
      startTransition(() => {
        router.push("/profile");
      });
    } catch (err) {
      if (err instanceof ApiError) {
        if (err.statusCode === 401) {
          form.setError("currentPassword", { message: "Profile.errors.currentPasswordWrong" });
        } else {
          setServerError(err.message);
        }
      } else {
        setServerError(t("Common.error"));
      }
    }
  };

  const fieldError = (key: keyof ChangePasswordValues): string | null => {
    const msg = form.formState.errors[key]?.message;
    return msg ? t(msg as never) : null;
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-5" noValidate>
        <FormField
          control={form.control}
          name="currentPassword"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("Profile.fields.currentPassword")}</FormLabel>
              <FormControl>
                <PasswordInput
                  autoComplete="current-password"
                  data-testid="change-password-current"
                  showLabel={t("Auth.actions.showPassword")}
                  hideLabel={t("Auth.actions.hidePassword")}
                  {...field}
                />
              </FormControl>
              <FormMessage>{fieldError("currentPassword")}</FormMessage>
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
                  data-testid="change-password-new"
                  showLabel={t("Auth.actions.showPassword")}
                  hideLabel={t("Auth.actions.hidePassword")}
                  {...field}
                />
              </FormControl>
              <FormMessage>{fieldError("newPassword")}</FormMessage>
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
                  data-testid="change-password-confirm"
                  showLabel={t("Auth.actions.showPassword")}
                  hideLabel={t("Auth.actions.hidePassword")}
                  {...field}
                />
              </FormControl>
              <FormMessage>{fieldError("confirmPassword")}</FormMessage>
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
          className="w-full md:w-auto"
          disabled={form.formState.isSubmitting}
          data-testid="change-password-submit"
        >
          {form.formState.isSubmitting ? (
            <Loader2 aria-hidden className="size-4 animate-spin" />
          ) : null}
          {t("Profile.actions.changePassword")}
        </Button>
      </form>
    </Form>
  );
}
