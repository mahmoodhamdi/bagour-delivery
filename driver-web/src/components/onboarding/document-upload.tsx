"use client";

import { Check, ImagePlus, Loader2, X } from "lucide-react";
import { useTranslations } from "next-intl";
import { useId, useState } from "react";

import { ApiError } from "@bagour/api-client";

import { Button } from "@/components/ui/button";
import { useUploadDriverDocument } from "@/lib/hooks/use-driver";

interface DocumentUploadProps {
  label: string;
  description?: string;
  value: string | undefined;
  onChange: (url: string | undefined) => void;
}

const MAX_BYTES = 5 * 1024 * 1024;
const ACCEPT = "image/jpeg,image/png,image/webp,application/pdf";

/**
 * Tiny upload widget: file picker → POST to /upload/driver-document →
 * stores the Cloudinary URL via `onChange`. Caller is responsible for
 * persisting the URL via `useUpdateDriverDocuments`.
 */
export function DocumentUpload({ label, description, value, onChange }: DocumentUploadProps) {
  const t = useTranslations("Onboarding");
  const id = useId();
  const upload = useUploadDriverDocument();
  const [error, setError] = useState<string | null>(null);

  const handleChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    setError(null);
    const file = e.target.files?.[0];
    e.target.value = ""; // allow re-selecting the same file
    if (!file) return;

    if (file.size > MAX_BYTES) {
      setError(t("errors.fileTooLarge"));
      return;
    }

    try {
      const { url } = await upload.mutateAsync(file);
      onChange(url);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t("errors.uploadFailed"));
    }
  };

  return (
    <div className="rounded-2xl border bg-card p-4">
      <div className="flex items-start justify-between gap-3">
        <div>
          <label htmlFor={id} className="text-sm font-semibold">
            {label}
          </label>
          {description ? (
            <p className="mt-1 text-xs text-muted-foreground">{description}</p>
          ) : null}
        </div>
        {value ? (
          <Check aria-hidden className="size-5 text-emerald-600" />
        ) : (
          <ImagePlus aria-hidden className="size-5 text-muted-foreground" />
        )}
      </div>

      <div className="mt-3 flex items-center gap-2">
        <Button asChild variant="outline" size="sm" disabled={upload.isPending}>
          <label htmlFor={id} className="cursor-pointer">
            {upload.isPending ? (
              <Loader2 aria-hidden className="size-4 animate-spin" />
            ) : null}
            {value ? t("actions.replace") : t("actions.upload")}
          </label>
        </Button>
        {value ? (
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={() => onChange(undefined)}
            aria-label={t("actions.remove")}
          >
            <X aria-hidden className="size-4" />
            {t("actions.remove")}
          </Button>
        ) : null}
        <input
          id={id}
          type="file"
          accept={ACCEPT}
          className="sr-only"
          onChange={(e) => void handleChange(e)}
          disabled={upload.isPending}
        />
      </div>

      {error ? (
        <p role="alert" className="mt-2 text-xs font-medium text-destructive">
          {error}
        </p>
      ) : null}
    </div>
  );
}
