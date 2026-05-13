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
import { useRouter } from "@/i18n/navigation";
import { useApi } from "@/lib/api-context";
import { forgotPasswordFormSchema, type ForgotPasswordFormValues } from "@/lib/auth-schemas";

export function ForgotPasswordForm() {
  const t = useTranslations();
  const router = useRouter();
  const api = useApi();
  const [serverError, setServerError] = useState<string | null>(null);
  const [, startTransition] = useTransition();

  const form = useForm<ForgotPasswordFormValues>({
    resolver: zodResolver(forgotPasswordFormSchema),
    defaultValues: { email: "" },
    mode: "onBlur",
  });

  const onSubmit = async (values: ForgotPasswordFormValues) => {
    setServerError(null);
    try {
      await api.auth.forgotPassword(values);
      toast.success(t("Auth.toasts.otpSent"));
      startTransition(() => {
        router.push({ pathname: "/reset-password", query: { email: values.email } });
      });
    } catch (err) {
      if (err instanceof ApiError) {
        // Don't reveal whether the email exists; behave the same on 404.
        toast.success(t("Auth.toasts.otpSent"));
        startTransition(() => {
          router.push({ pathname: "/reset-password", query: { email: values.email } });
        });
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
                <Input type="email" autoComplete="email" data-testid="forgot-email" {...field} />
              </FormControl>
              <FormMessage>
                {form.formState.errors.email?.message
                  ? t(form.formState.errors.email.message as never)
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
          data-testid="forgot-submit"
        >
          {form.formState.isSubmitting ? (
            <Loader2 aria-hidden className="size-4 animate-spin" />
          ) : null}
          {t("Auth.actions.sendResetCode")}
        </Button>
      </form>
    </Form>
  );
}
