/**
 * Locale-aware formatters that respect Arabic-Indic numerals when in AR.
 */

export function formatCurrency(amount: number, locale: string, currency = "EGP"): string {
  return new Intl.NumberFormat(locale === "ar" ? "ar-EG" : "en-US", {
    style: "currency",
    currency,
    maximumFractionDigits: 2,
  }).format(amount);
}

export function formatNumber(value: number, locale: string): string {
  return new Intl.NumberFormat(locale === "ar" ? "ar-EG" : "en-US").format(value);
}

export function formatDeliveryWindow(min: number, max: number, locale: string): string {
  const lo = formatNumber(min, locale);
  const hi = formatNumber(max, locale);
  return locale === "ar" ? `${lo}-${hi} د` : `${lo}-${hi} min`;
}

export function formatRating(value: number, locale: string): string {
  return new Intl.NumberFormat(locale === "ar" ? "ar-EG" : "en-US", {
    minimumFractionDigits: 1,
    maximumFractionDigits: 1,
  }).format(value);
}
