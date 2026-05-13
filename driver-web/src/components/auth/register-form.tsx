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
import { Input } from "@/components/ui/input";
import { PasswordInput } from "@/components/ui/password-input";
import { useRouter } from "@/i18n/navigation";
import { useApi } from "@/lib/api-context";
import { registerFormSchema, type RegisterFormValues } from "@/lib/auth-schemas";

const REGISTER_FIELDS = ["name", "email", "phone", "password", "confirmPassword"] as const;
type RegisterFieldName = (typeof REGISTER_FIELDS)[number];

function isRegisterField(value: string): value is RegisterFieldName {
  return (REGISTER_FIELDS as readonly string[]).includes(value);
}

export function RegisterForm() {
  const t = useTranslations();
  const router = useRouter();
  const api = useApi();
  const [serverError, setServerError] = useState<string | null>(null);
  const [, startTransition] = useTransition();

  const form = useForm<RegisterFormValues>({
    resolver: zodResolver(registerFormSchema),
    defaultValues: {
      name: "",
      email: "",
      phone: "",
      password: "",
      confirmPassword: "",
      acceptTerms: false,
    },
    mode: "onBlur",
  });

  const onSubmit = async (values: RegisterFormValues) => {
    setServerError(null);
    try {
      await api.auth.register({
        name: values.name,
        email: values.email,
        phone: values.phone,
        password: values.password,
        role: "driver",
      });
      toast.success(t("Auth.toasts.otpSent"));
      startTransition(() => {
        router.push({
          pathname: "/verify-otp",
          query: { email: values.email },
        });
      });
    } catch (err) {
      if (err instanceof ApiError) {
        if (err.fieldErrors) {
          for (const [field, messages] of Object.entries(err.fieldErrors)) {
            const m = messages[0];
            if (m && isRegisterField(field)) {
              form.setError(field, { message: m });
            }
          }
        } else {
          setServerError(err.message);
        }
      } else {
        setServerError(t("Common.error"));
      }
    }
  };

  const fieldError = (key: RegisterFieldName) =>
    form.formState.errors[key]?.message ? t(form.formState.errors[key].message as never) : null;

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="space-y-5"
        noValidate
        aria-busy={form.formState.isSubmitting}
      >
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("Auth.fields.name")}</FormLabel>
              <FormControl>
                <Input autoComplete="name" data-testid="register-name" {...field} />
              </FormControl>
              <FormMessage>{fieldError("name")}</FormMessage>
            </FormItem>
          )}
        />

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
                  inputMode="email"
                  data-testid="register-email"
                  {...field}
                />
              </FormControl>
              <FormMessage>{fieldError("email")}</FormMessage>
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="phone"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("Auth.fields.phone")}</FormLabel>
              <FormControl>
                <Input
                  type="tel"
                  autoComplete="tel-national"
                  inputMode="tel"
                  placeholder="01012345678"
                  data-testid="register-phone"
                  {...field}
                />
              </FormControl>
              <FormMessage>{fieldError("phone")}</FormMessage>
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="password"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("Auth.fields.password")}</FormLabel>
              <FormControl>
                <PasswordInput
                  autoComplete="new-password"
                  data-testid="register-password"
                  showLabel={t("Auth.actions.showPassword")}
                  hideLabel={t("Auth.actions.hidePassword")}
                  {...field}
                />
              </FormControl>
              <FormMessage>{fieldError("password")}</FormMessage>
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
                  data-testid="register-confirm-password"
                  showLabel={t("Auth.actions.showPassword")}
                  hideLabel={t("Auth.actions.hidePassword")}
                  {...field}
                />
              </FormControl>
              <FormMessage>{fieldError("confirmPassword")}</FormMessage>
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="acceptTerms"
          render={({ field }) => (
            <FormItem>
              <label className="flex items-start gap-2 text-sm">
                <input
                  type="checkbox"
                  className="mt-1 size-4 accent-primary"
                  checked={!!field.value}
                  onChange={(e) => field.onChange(e.target.checked)}
                  data-testid="register-accept-terms"
                  aria-invalid={!!form.formState.errors.acceptTerms || undefined}
                />
                <span>{t("Auth.fields.acceptTerms")}</span>
              </label>
              <FormMessage>
                {form.formState.errors.acceptTerms?.message
                  ? t(form.formState.errors.acceptTerms.message as never)
                  : null}
              </FormMessage>
            </FormItem>
          )}
        />

        {serverError ? (
          <p
            role="alert"
            className="rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-sm font-medium text-destructive"
            data-testid="register-server-error"
          >
            {serverError}
          </p>
        ) : null}

        <Button
          type="submit"
          size="lg"
          className="w-full"
          disabled={form.formState.isSubmitting}
          data-testid="register-submit"
        >
          {form.formState.isSubmitting ? (
            <Loader2 aria-hidden className="size-4 animate-spin" />
          ) : null}
          {t("Auth.actions.createAccount")}
        </Button>
      </form>
    </Form>
  );
}
