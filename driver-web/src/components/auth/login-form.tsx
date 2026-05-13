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
import { Link, useRouter } from "@/i18n/navigation";
import { useApi } from "@/lib/api-context";
import { loginFormSchema, type LoginFormValues } from "@/lib/auth-schemas";
import { useAuthStore } from "@/stores/auth-store";

interface LoginFormProps {
  redirectTo?: string;
}

export function LoginForm({ redirectTo = "/" }: LoginFormProps) {
  const t = useTranslations();
  const router = useRouter();
  const api = useApi();
  const setSession = useAuthStore((s) => s.setSession);
  const [serverError, setServerError] = useState<string | null>(null);
  const [, startTransition] = useTransition();

  const form = useForm<LoginFormValues>({
    resolver: zodResolver(loginFormSchema),
    defaultValues: { email: "", password: "" },
    mode: "onBlur",
  });

  const onSubmit = async (values: LoginFormValues) => {
    setServerError(null);
    try {
      const { user, tokens } = await api.auth.login(values);
      if (user.role !== "driver") {
        setServerError(t("Auth.errors.notADriver"));
        return;
      }
      setSession({ user, tokens });
      toast.success(t("Auth.toasts.signedIn"));
      startTransition(() => {
        router.push(redirectTo);
      });
    } catch (err) {
      if (err instanceof ApiError) {
        if (err.statusCode === 401 || err.statusCode === 403) {
          setServerError(t("Auth.errors.invalidCredentials"));
        } else if (err.fieldErrors) {
          for (const [field, messages] of Object.entries(err.fieldErrors)) {
            const m = messages[0];
            if (m && (field === "email" || field === "password")) {
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
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("Auth.fields.email")}</FormLabel>
              <FormControl>
                <Input
                  type="email"
                  autoComplete="email"
                  inputMode="email"
                  data-testid="login-email"
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

        <FormField
          control={form.control}
          name="password"
          render={({ field }) => (
            <FormItem>
              <div className="flex items-center justify-between gap-2">
                <FormLabel>{t("Auth.fields.password")}</FormLabel>
                <Link
                  href="/forgot-password"
                  className="text-sm font-medium text-primary hover:underline"
                >
                  {t("Auth.actions.forgotPassword")}
                </Link>
              </div>
              <FormControl>
                <PasswordInput
                  autoComplete="current-password"
                  data-testid="login-password"
                  showLabel={t("Auth.actions.showPassword")}
                  hideLabel={t("Auth.actions.hidePassword")}
                  {...field}
                />
              </FormControl>
              <FormMessage>
                {form.formState.errors.password?.message
                  ? t(form.formState.errors.password.message as never)
                  : null}
              </FormMessage>
            </FormItem>
          )}
        />

        {serverError ? (
          <p
            role="alert"
            className="rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-sm font-medium text-destructive"
            data-testid="login-server-error"
          >
            {serverError}
          </p>
        ) : null}

        <Button
          type="submit"
          size="lg"
          className="w-full"
          disabled={form.formState.isSubmitting}
          data-testid="login-submit"
        >
          {form.formState.isSubmitting ? (
            <Loader2 aria-hidden className="size-4 animate-spin" />
          ) : null}
          {t("Auth.actions.signIn")}
        </Button>
      </form>
    </Form>
  );
}
