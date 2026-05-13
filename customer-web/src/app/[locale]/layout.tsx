import { Cairo } from "next/font/google";
import { hasLocale, NextIntlClientProvider } from "next-intl";
import { getMessages, setRequestLocale } from "next-intl/server";
import { notFound } from "next/navigation";
import type { Metadata, Viewport } from "next";
import type { ReactNode } from "react";

import { routing } from "@/i18n/routing";

const cairo = Cairo({
  subsets: ["arabic", "latin"],
  weight: ["300", "400", "500", "600", "700", "900"],
  display: "swap",
  variable: "--font-sans",
});

export const viewport: Viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#cf6f2c" },
    { media: "(prefers-color-scheme: dark)", color: "#1a1612" },
  ],
  colorScheme: "light dark",
};

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  const isArabic = locale === "ar";

  return {
    metadataBase: new URL(process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000"),
    title: {
      default: isArabic ? "باجور ديليفري" : "Bagour Delivery",
      template: isArabic ? "%s — باجور ديليفري" : "%s — Bagour Delivery",
    },
    description: isArabic
      ? "أكل البلد يوصلك خلال ٣٠ دقيقة من أفضل مطاعم باجور."
      : "Local food delivered hot from Bagour's best restaurants in 30 minutes.",
    applicationName: "Bagour Delivery",
    keywords: ["bagour", "delivery", "monufia", "egypt", "food", "باجور", "توصيل", "المنوفية"],
    authors: [{ name: "Bagour Delivery" }],
    openGraph: {
      type: "website",
      locale: isArabic ? "ar_EG" : "en_US",
      siteName: "Bagour Delivery",
    },
    icons: {
      icon: "/icons/icon-192.png",
      apple: "/icons/icon-192.png",
    },
    appleWebApp: {
      capable: true,
      statusBarStyle: "default",
      title: "Bagour",
    },
    formatDetection: { telephone: false },
  };
}

export default async function LocaleLayout({
  children,
  params,
}: {
  children: ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;

  if (!hasLocale(routing.locales, locale)) {
    notFound();
  }

  setRequestLocale(locale);
  const messages = await getMessages();
  const dir = locale === "ar" ? "rtl" : "ltr";

  return (
    <html lang={locale} dir={dir} className={cairo.variable} suppressHydrationWarning>
      <body className="bg-background text-foreground antialiased min-h-screen">
        <NextIntlClientProvider messages={messages} locale={locale}>
          {children}
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
