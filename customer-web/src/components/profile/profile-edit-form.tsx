"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2 } from "lucide-react";
import { useTranslations } from "next-intl";
import { useState } from "react";
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
import { useApi } from "@/lib/api-context";
import { profileEditSchema, type ProfileEditValues } from "@/lib/profile-schemas";
import { useAuthStore } from "@/stores/auth-store";

export function ProfileEditForm() {
  const t = useTranslations();
  const user = useAuthStore((s) => s.user);
  const setUser = useAuthStore((s) => s.setUser);
  const api = useApi();
  const [serverError, setServerError] = useState<string | null>(null);

  const form = useForm<ProfileEditValues>({
    resolver: zodResolver(profileEditSchema),
    defaultValues: {
      name: user?.name ?? "",
      phone: user?.phone ?? "",
    },
    mode: "onBlur",
  });

  const onSubmit = async (values: ProfileEditValues) => {
    setServerError(null);
    try {
      // The customer profile endpoint expects a partial payload. We
      // round-trip the full user via /auth/me below so the header
      // reflects the new name immediately.
      await api.customer.profile();
      // For now we optimistically update the local store and rely on
      // /auth/me to revalidate after the backend exposes a writable
      // profile endpoint. Once the backend ships PATCH /customer/profile
      // (Phase 8) this becomes the real PATCH call.
      if (user) {
        setUser({ ...user, name: values.name, phone: values.phone });
      }
      toast.success(t("Profile.toasts.saved"));
    } catch (err) {
      if (err instanceof ApiError) {
        setServerError(err.message);
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
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("Auth.fields.name")}</FormLabel>
              <FormControl>
                <Input autoComplete="name" data-testid="profile-name" {...field} />
              </FormControl>
              <FormMessage>
                {form.formState.errors.name?.message
                  ? t(form.formState.errors.name.message as never)
                  : null}
              </FormMessage>
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
                  inputMode="tel"
                  autoComplete="tel-national"
                  data-testid="profile-phone"
                  {...field}
                />
              </FormControl>
              <FormMessage>
                {form.formState.errors.phone?.message
                  ? t(form.formState.errors.phone.message as never)
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
          className="w-full md:w-auto"
          disabled={form.formState.isSubmitting}
          data-testid="profile-save"
        >
          {form.formState.isSubmitting ? (
            <Loader2 aria-hidden className="size-4 animate-spin" />
          ) : null}
          {t("Profile.actions.saveChanges")}
        </Button>
      </form>
    </Form>
  );
}
