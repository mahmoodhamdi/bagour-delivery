"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2 } from "lucide-react";
import { useTranslations } from "next-intl";
import { useEffect, useState, useTransition } from "react";
import { Controller, useForm } from "react-hook-form";
import { toast } from "sonner";

import { ApiError } from "@bagour/api-client";

import { Button } from "@/components/ui/button";
import { Form, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { OtpInput } from "@/components/ui/otp-input";
import { useRouter } from "@/i18n/navigation";
import { useApi } from "@/lib/api-context";
import { otpFormSchema, type OtpFormValues } from "@/lib/auth-schemas";
import { useAuthStore } from "@/stores/auth-store";

interface OtpFormProps {
  email: string;
}

const COOLDOWN_SECONDS = 30;

export function OtpForm({ email }: OtpFormProps) {
  const t = useTranslations();
  const router = useRouter();
  const api = useApi();
  const setSession = useAuthStore((s) => s.setSession);
  const [serverError, setServerError] = useState<string | null>(null);
  const [remaining, setRemaining] = useState(0);
  const [, startTransition] = useTransition();

  useEffect(() => {
    if (remaining <= 0) return undefined;
    const id = window.setInterval(() => {
      setRemaining((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => window.clearInterval(id);
  }, [remaining]);

  const form = useForm<OtpFormValues>({
    resolver: zodResolver(otpFormSchema),
    defaultValues: { otp: "" },
    mode: "onSubmit",
  });

  const onSubmit = async (values: OtpFormValues) => {
    setServerError(null);
    try {
      const { user, tokens } = await api.auth.verifyEmail({ email, otp: values.otp });
      setSession({ user, tokens });
      toast.success(t("Auth.toasts.signedIn"));
      startTransition(() => {
        // New drivers land on /onboarding to complete KYC; existing drivers go home.
        router.push("/onboarding");
      });
    } catch (err) {
      if (err instanceof ApiError) {
        setServerError(err.statusCode === 422 ? t("Auth.errors.otpInvalid") : err.message);
      } else {
        setServerError(t("Common.error"));
      }
    }
  };

  const handleResend = async () => {
    setServerError(null);
    try {
      await api.auth.resendOtp({ email });
      setRemaining(COOLDOWN_SECONDS);
      toast.success(t("Auth.toasts.otpResent"));
    } catch (err) {
      if (err instanceof ApiError) {
        setServerError(err.message);
      } else {
        setServerError(t("Common.error"));
      }
    }
  };

  const canResend = remaining <= 0;

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="space-y-6"
        noValidate
        aria-busy={form.formState.isSubmitting}
      >
        <p className="text-sm text-muted-foreground">
          {t.rich("Auth.otp.sentTo", {
            email,
            b: (chunks) => <strong className="font-semibold text-foreground">{chunks}</strong>,
          })}
        </p>

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
                autoFocus
                disabled={form.formState.isSubmitting}
                invalid={!!form.formState.errors.otp || !!serverError}
              />
              <FormMessage>
                {form.formState.errors.otp?.message
                  ? t(form.formState.errors.otp.message as never)
                  : null}
              </FormMessage>
            </FormItem>
          )}
        />

        {serverError ? (
          <p
            role="alert"
            className="rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-sm font-medium text-destructive"
            data-testid="otp-server-error"
          >
            {serverError}
          </p>
        ) : null}

        <Button
          type="submit"
          size="lg"
          className="w-full"
          disabled={form.formState.isSubmitting}
          data-testid="otp-submit"
        >
          {form.formState.isSubmitting ? (
            <Loader2 aria-hidden className="size-4 animate-spin" />
          ) : null}
          {t("Auth.actions.verify")}
        </Button>

        <Button
          type="button"
          variant="ghost"
          className="w-full"
          onClick={() => void handleResend()}
          disabled={!canResend}
          data-testid="otp-resend"
        >
          {canResend
            ? t("Auth.actions.resendOtp")
            : t("Auth.actions.resendIn", { seconds: remaining })}
        </Button>
      </form>
    </Form>
  );
}
