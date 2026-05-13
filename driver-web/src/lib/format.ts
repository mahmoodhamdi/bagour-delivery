/**
 * Locale-aware formatters. Arabic uses Arabic-Indic digits (ar-EG).
 */

export function formatCurrency(amount: number, locale: string, currency = "EGP"): string {
  return new Intl.NumberFormat(locale === "ar" ? "ar-EG" : "en-US", {
    style: "currency",
    currency,
    maximumFractionDigits: 0,
  }).format(amount);
}

export function formatNumber(value: number, locale: string): string {
  return new Intl.NumberFormat(locale === "ar" ? "ar-EG" : "en-US").format(value);
}

export function formatTimeAgo(iso: string, locale: string, now = Date.now()): string {
  const diffSec = Math.max(0, Math.floor((now - new Date(iso).getTime()) / 1000));
  const rtf = new Intl.RelativeTimeFormat(locale === "ar" ? "ar-EG" : "en-US", {
    numeric: "auto",
  });
  if (diffSec < 60) return rtf.format(-diffSec, "second");
  if (diffSec < 3600) return rtf.format(-Math.floor(diffSec / 60), "minute");
  if (diffSec < 86_400) return rtf.format(-Math.floor(diffSec / 3600), "hour");
  return rtf.format(-Math.floor(diffSec / 86_400), "day");
}
