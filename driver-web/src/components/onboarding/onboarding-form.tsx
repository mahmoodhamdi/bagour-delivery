"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { CheckCircle2, Loader2 } from "lucide-react";
import { useTranslations } from "next-intl";
import { useState, useTransition } from "react";
import { useForm } from "react-hook-form";
import { toast } from "sonner";

import type { DriverDocuments } from "@bagour/types";
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
import { Skeleton } from "@/components/ui/skeleton";
import { useRouter } from "@/i18n/navigation";
import {
  useDriverProfile,
  useUpdateDriverDocuments,
  useUpdateDriverProfile,
} from "@/lib/hooks/use-driver";
import {
  vehicleInfoSchema,
  type VehicleInfoValues,
} from "@/lib/onboarding-schemas";

import { DocumentUpload } from "./document-upload";

const REQUIRED_DOCS = [
  "nationalIdFront",
  "nationalIdBack",
  "driverLicenseFront",
  "driverLicenseBack",
] as const;
type RequiredDoc = (typeof REQUIRED_DOCS)[number];

export function OnboardingForm() {
  const t = useTranslations();
  const router = useRouter();
  const profile = useDriverProfile();
  const updateProfile = useUpdateDriverProfile();
  const updateDocuments = useUpdateDriverDocuments();
  const [docs, setDocs] = useState<DriverDocuments>({});
  const [serverError, setServerError] = useState<string | null>(null);
  const [, startTransition] = useTransition();

  const form = useForm<VehicleInfoValues>({
    resolver: zodResolver(vehicleInfoSchema),
    defaultValues: {
      vehicleModel: profile.data?.vehicleModel ?? "",
      vehicleColor: profile.data?.vehicleColor ?? "",
      vehiclePlateNumber: profile.data?.vehiclePlateNumber ?? "",
    },
    mode: "onBlur",
    values: profile.data
      ? {
          vehicleModel: profile.data.vehicleModel ?? "",
          vehicleColor: profile.data.vehicleColor ?? "",
          vehiclePlateNumber: profile.data.vehiclePlateNumber ?? "",
        }
      : undefined,
  });

  const existingDocs = profile.data?.documents ?? {};
  const allUploaded = REQUIRED_DOCS.every(
    (k) => docs[k] ?? existingDocs[k],
  );

  const handleDocChange = (key: RequiredDoc) => (url: string | undefined) => {
    setDocs((prev) => ({ ...prev, [key]: url }));
  };

  const onSubmit = async (values: VehicleInfoValues) => {
    setServerError(null);
    try {
      await updateProfile.mutateAsync(values);

      // Merge any newly uploaded docs with whatever the server already has.
      const merged: Partial<DriverDocuments> = {};
      for (const key of REQUIRED_DOCS) {
        const v = docs[key] ?? existingDocs[key];
        if (v) merged[key] = v;
      }
      if (Object.keys(merged).length > 0) {
        await updateDocuments.mutateAsync(merged);
      }

      toast.success(t("Onboarding.toasts.submitted"));
      startTransition(() => {
        router.push("/");
      });
    } catch (err) {
      setServerError(err instanceof ApiError ? err.message : t("Common.error"));
    }
  };

  if (profile.isLoading) {
    return (
      <div className="space-y-3">
        <Skeleton className="h-24 w-full" />
        <Skeleton className="h-24 w-full" />
        <Skeleton className="h-24 w-full" />
      </div>
    );
  }

  const isApproved = profile.data?.status === "approved";

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8" noValidate>
        {isApproved ? (
          <div
            role="status"
            className="flex items-center gap-3 rounded-2xl border border-emerald-300 bg-emerald-50 p-4 text-emerald-900 dark:border-emerald-800 dark:bg-emerald-950/40 dark:text-emerald-100"
          >
            <CheckCircle2 aria-hidden className="size-6 shrink-0" />
            <p className="text-sm font-medium">{t("Onboarding.alreadyApproved")}</p>
          </div>
        ) : (
          <div
            role="status"
            className="rounded-2xl border border-amber-300 bg-amber-50 p-4 text-amber-900 dark:border-amber-800 dark:bg-amber-950/40 dark:text-amber-100"
          >
            <p className="text-sm font-medium">{t("Onboarding.pendingNote")}</p>
          </div>
        )}

        <section className="space-y-4">
          <h2 className="text-xl font-semibold">{t("Onboarding.vehicleSection")}</h2>
          <p className="text-sm text-muted-foreground">{t("Onboarding.vehicleHint")}</p>

          <FormField
            control={form.control}
            name="vehicleModel"
            render={({ field }) => (
              <FormItem>
                <FormLabel>{t("Onboarding.fields.vehicleModel")}</FormLabel>
                <FormControl>
                  <Input data-testid="vehicle-model" {...field} />
                </FormControl>
                <FormMessage>
                  {form.formState.errors.vehicleModel?.message
                    ? t(form.formState.errors.vehicleModel.message as never)
                    : null}
                </FormMessage>
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="vehicleColor"
            render={({ field }) => (
              <FormItem>
                <FormLabel>{t("Onboarding.fields.vehicleColor")}</FormLabel>
                <FormControl>
                  <Input data-testid="vehicle-color" {...field} />
                </FormControl>
                <FormMessage>
                  {form.formState.errors.vehicleColor?.message
                    ? t(form.formState.errors.vehicleColor.message as never)
                    : null}
                </FormMessage>
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="vehiclePlateNumber"
            render={({ field }) => (
              <FormItem>
                <FormLabel>{t("Onboarding.fields.vehiclePlateNumber")}</FormLabel>
                <FormControl>
                  <Input data-testid="vehicle-plate" {...field} />
                </FormControl>
                <FormMessage>
                  {form.formState.errors.vehiclePlateNumber?.message
                    ? t(form.formState.errors.vehiclePlateNumber.message as never)
                    : null}
                </FormMessage>
              </FormItem>
            )}
          />
        </section>

        <section className="space-y-4">
          <h2 className="text-xl font-semibold">{t("Onboarding.documentsSection")}</h2>
          <p className="text-sm text-muted-foreground">{t("Onboarding.documentsHint")}</p>

          <DocumentUpload
            label={t("Onboarding.documents.nationalIdFront")}
            description={t("Onboarding.documents.nationalIdDesc")}
            value={docs.nationalIdFront ?? existingDocs.nationalIdFront}
            onChange={handleDocChange("nationalIdFront")}
          />
          <DocumentUpload
            label={t("Onboarding.documents.nationalIdBack")}
            value={docs.nationalIdBack ?? existingDocs.nationalIdBack}
            onChange={handleDocChange("nationalIdBack")}
          />
          <DocumentUpload
            label={t("Onboarding.documents.driverLicenseFront")}
            description={t("Onboarding.documents.driverLicenseDesc")}
            value={docs.driverLicenseFront ?? existingDocs.driverLicenseFront}
            onChange={handleDocChange("driverLicenseFront")}
          />
          <DocumentUpload
            label={t("Onboarding.documents.driverLicenseBack")}
            value={docs.driverLicenseBack ?? existingDocs.driverLicenseBack}
            onChange={handleDocChange("driverLicenseBack")}
          />
        </section>

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
          disabled={form.formState.isSubmitting || !allUploaded}
          data-testid="onboarding-submit"
        >
          {form.formState.isSubmitting ? (
            <Loader2 aria-hidden className="size-4 animate-spin" />
          ) : null}
          {t("Onboarding.actions.submit")}
        </Button>
      </form>
    </Form>
  );
}
