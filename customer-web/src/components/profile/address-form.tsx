"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2 } from "lucide-react";
import { useTranslations } from "next-intl";
import { useState, useTransition } from "react";
import { useForm } from "react-hook-form";
import { toast } from "sonner";

import type { Address } from "@bagour/types";
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
import { Constants } from "@bagour/types";
import { useRouter } from "@/i18n/navigation";
import { useAddAddress, useUpdateAddress } from "@/lib/hooks/use-customer";
import { addressFormSchema, type AddressFormValues } from "@/lib/profile-schemas";

interface AddressFormProps {
  /** When provided, edit instead of create. */
  initial?: Address & { id: string };
}

const BAGOUR_LAT = Constants.BAGOUR_LOCATION.lat;
const BAGOUR_LNG = Constants.BAGOUR_LOCATION.lng;

function addressToValues(address: Address | undefined): AddressFormValues {
  return {
    label: address?.label ?? "",
    street: address?.street ?? "",
    area: address?.area ?? Constants.BAGOUR_LOCATION.name,
    city: address?.city ?? Constants.BAGOUR_LOCATION.governorate,
    buildingNumber: address?.buildingNumber ?? "",
    floor: address?.floor ?? "",
    apartment: address?.apartment ?? "",
    landmark: address?.landmark ?? "",
    isDefault: address?.isDefault ?? false,
    lat: address?.location?.coordinates[1] ?? BAGOUR_LAT,
    lng: address?.location?.coordinates[0] ?? BAGOUR_LNG,
  };
}

function valuesToPayload(values: AddressFormValues): Omit<Address, "id"> {
  const { lat, lng, ...rest } = values;
  const payload: Omit<Address, "id"> = { ...rest };
  if (typeof lat === "number" && typeof lng === "number") {
    payload.location = { type: "Point", coordinates: [lng, lat] };
  }
  return payload;
}

export function AddressForm({ initial }: AddressFormProps) {
  const t = useTranslations();
  const router = useRouter();
  const add = useAddAddress();
  const update = useUpdateAddress();
  const [serverError, setServerError] = useState<string | null>(null);
  const [, startTransition] = useTransition();

  const form = useForm<AddressFormValues>({
    resolver: zodResolver(addressFormSchema),
    defaultValues: addressToValues(initial),
    mode: "onBlur",
  });

  const onSubmit = async (values: AddressFormValues) => {
    setServerError(null);
    try {
      if (initial?.id) {
        await update.mutateAsync({ id: initial.id, payload: valuesToPayload(values) });
        toast.success(t("Profile.toasts.addressUpdated"));
      } else {
        await add.mutateAsync(valuesToPayload(values));
        toast.success(t("Profile.toasts.addressAdded"));
      }
      startTransition(() => {
        router.push("/profile/addresses");
      });
    } catch (err) {
      if (err instanceof ApiError) {
        setServerError(err.message);
      } else {
        setServerError(t("Common.error"));
      }
    }
  };

  const text = (key: keyof AddressFormValues): string | null => {
    const msg = form.formState.errors[key]?.message;
    return msg ? t(msg as never) : null;
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-5" noValidate>
        <FormField
          control={form.control}
          name="label"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("Profile.fields.addressLabel")}</FormLabel>
              <FormControl>
                <Input
                  placeholder={t("Profile.placeholders.addressLabel")}
                  data-testid="address-label"
                  {...field}
                />
              </FormControl>
              <FormMessage>{text("label")}</FormMessage>
            </FormItem>
          )}
        />

        <div className="grid gap-5 md:grid-cols-2">
          <FormField
            control={form.control}
            name="street"
            render={({ field }) => (
              <FormItem>
                <FormLabel>{t("Profile.fields.street")}</FormLabel>
                <FormControl>
                  <Input data-testid="address-street" {...field} />
                </FormControl>
                <FormMessage>{text("street")}</FormMessage>
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="area"
            render={({ field }) => (
              <FormItem>
                <FormLabel>{t("Profile.fields.area")}</FormLabel>
                <FormControl>
                  <Input data-testid="address-area" {...field} />
                </FormControl>
                <FormMessage>{text("area")}</FormMessage>
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="city"
            render={({ field }) => (
              <FormItem>
                <FormLabel>{t("Profile.fields.city")}</FormLabel>
                <FormControl>
                  <Input data-testid="address-city" {...field} />
                </FormControl>
                <FormMessage>{text("city")}</FormMessage>
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="buildingNumber"
            render={({ field }) => (
              <FormItem>
                <FormLabel>{t("Profile.fields.buildingNumber")}</FormLabel>
                <FormControl>
                  <Input data-testid="address-building" {...field} />
                </FormControl>
                <FormMessage>{text("buildingNumber")}</FormMessage>
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="floor"
            render={({ field }) => (
              <FormItem>
                <FormLabel>{t("Profile.fields.floor")}</FormLabel>
                <FormControl>
                  <Input data-testid="address-floor" {...field} />
                </FormControl>
                <FormMessage>{text("floor")}</FormMessage>
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="apartment"
            render={({ field }) => (
              <FormItem>
                <FormLabel>{t("Profile.fields.apartment")}</FormLabel>
                <FormControl>
                  <Input data-testid="address-apartment" {...field} />
                </FormControl>
                <FormMessage>{text("apartment")}</FormMessage>
              </FormItem>
            )}
          />
        </div>

        <FormField
          control={form.control}
          name="landmark"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("Profile.fields.landmark")}</FormLabel>
              <FormControl>
                <Input
                  placeholder={t("Profile.placeholders.landmark")}
                  data-testid="address-landmark"
                  {...field}
                />
              </FormControl>
              <FormMessage>{text("landmark")}</FormMessage>
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="isDefault"
          render={({ field }) => (
            <FormItem>
              <label className="flex items-center gap-2 text-sm">
                <input
                  type="checkbox"
                  className="size-4 accent-primary"
                  checked={!!field.value}
                  onChange={(e) => field.onChange(e.target.checked)}
                  data-testid="address-default"
                />
                <span>{t("Profile.fields.isDefault")}</span>
              </label>
              <FormMessage />
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

        <div className="flex flex-wrap gap-3">
          <Button
            type="submit"
            size="lg"
            disabled={form.formState.isSubmitting}
            data-testid="address-submit"
          >
            {form.formState.isSubmitting ? (
              <Loader2 aria-hidden className="size-4 animate-spin" />
            ) : null}
            {initial ? t("Profile.actions.saveAddress") : t("Profile.actions.addAddress")}
          </Button>
          <Button type="button" variant="ghost" size="lg" onClick={() => router.back()}>
            {t("Profile.actions.cancel")}
          </Button>
        </div>
      </form>
    </Form>
  );
}
