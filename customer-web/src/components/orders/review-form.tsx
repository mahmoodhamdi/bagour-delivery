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
import { useRouter } from "@/i18n/navigation";
import { useRateOrder } from "@/lib/hooks/use-orders";
import { reviewFormSchema, type ReviewFormValues } from "@/lib/review-schemas";

import { StarRating } from "./star-rating";

interface ReviewFormProps {
  orderId: string;
  initial?: Partial<ReviewFormValues>;
}

export function ReviewForm({ orderId, initial }: ReviewFormProps) {
  const t = useTranslations();
  const router = useRouter();
  const rate = useRateOrder();
  const [serverError, setServerError] = useState<string | null>(null);
  const [, startTransition] = useTransition();

  const form = useForm<ReviewFormValues>({
    resolver: zodResolver(reviewFormSchema),
    defaultValues: {
      restaurant: initial?.restaurant ?? 0,
      driver: initial?.driver ?? 0,
      food: initial?.food ?? 0,
      overall: initial?.overall ?? 0,
      comment: initial?.comment ?? "",
    },
    mode: "onSubmit",
  });

  const onSubmit = async (values: ReviewFormValues) => {
    setServerError(null);
    try {
      await rate.mutateAsync({ id: orderId, payload: values });
      toast.success(t("Reviews.toasts.submitted"));
      startTransition(() => {
        router.push(`/orders/${orderId}`);
      });
    } catch (err) {
      setServerError(err instanceof ApiError ? err.message : t("Common.error"));
    }
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6" noValidate>
        <FormField
          control={form.control}
          name="overall"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("Reviews.fields.overall")}</FormLabel>
              <FormControl>
                <StarRating
                  value={field.value}
                  onChange={field.onChange}
                  ariaLabel={t("Reviews.fields.overall")}
                  size="lg"
                />
              </FormControl>
              <FormMessage>
                {form.formState.errors.overall ? t("Reviews.errors.required") : null}
              </FormMessage>
            </FormItem>
          )}
        />

        <div className="grid gap-6 md:grid-cols-3">
          <FormField
            control={form.control}
            name="restaurant"
            render={({ field }) => (
              <FormItem>
                <FormLabel>{t("Reviews.fields.restaurant")}</FormLabel>
                <FormControl>
                  <StarRating
                    value={field.value}
                    onChange={field.onChange}
                    ariaLabel={t("Reviews.fields.restaurant")}
                  />
                </FormControl>
                <FormMessage>
                  {form.formState.errors.restaurant ? t("Reviews.errors.required") : null}
                </FormMessage>
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="food"
            render={({ field }) => (
              <FormItem>
                <FormLabel>{t("Reviews.fields.food")}</FormLabel>
                <FormControl>
                  <StarRating
                    value={field.value}
                    onChange={field.onChange}
                    ariaLabel={t("Reviews.fields.food")}
                  />
                </FormControl>
                <FormMessage>
                  {form.formState.errors.food ? t("Reviews.errors.required") : null}
                </FormMessage>
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="driver"
            render={({ field }) => (
              <FormItem>
                <FormLabel>{t("Reviews.fields.driver")}</FormLabel>
                <FormControl>
                  <StarRating
                    value={field.value}
                    onChange={field.onChange}
                    ariaLabel={t("Reviews.fields.driver")}
                  />
                </FormControl>
                <FormMessage>
                  {form.formState.errors.driver ? t("Reviews.errors.required") : null}
                </FormMessage>
              </FormItem>
            )}
          />
        </div>

        <FormField
          control={form.control}
          name="comment"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("Reviews.fields.comment")}</FormLabel>
              <FormControl>
                <textarea
                  {...field}
                  rows={4}
                  maxLength={500}
                  placeholder={t("Reviews.placeholders.comment")}
                  className="flex w-full rounded-xl border border-input bg-card px-3 py-2 text-sm shadow-xs transition-colors placeholder:text-muted-foreground focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
                  data-testid="review-comment"
                />
              </FormControl>
              <FormMessage>
                {form.formState.errors.comment?.message
                  ? t(form.formState.errors.comment.message as never)
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

        <div className="flex gap-3">
          <Button
            type="button"
            variant="outline"
            className="flex-1"
            onClick={() => router.push(`/orders/${orderId}`)}
          >
            {t("Reviews.actions.cancel")}
          </Button>
          <Button
            type="submit"
            className="flex-1"
            disabled={form.formState.isSubmitting}
            data-testid="review-submit"
          >
            {form.formState.isSubmitting ? (
              <Loader2 aria-hidden className="size-4 animate-spin" />
            ) : null}
            {t("Reviews.actions.submit")}
          </Button>
        </div>
      </form>
    </Form>
  );
}
