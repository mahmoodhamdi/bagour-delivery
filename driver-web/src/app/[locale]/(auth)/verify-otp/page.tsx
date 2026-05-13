import { getTranslations, setRequestLocale } from "next-intl/server";
import { notFound } from "next/navigation";
import type { Metadata } from "next";

import { AuthShell } from "@/components/auth/auth-shell";
import { OtpForm } from "@/components/auth/otp-form";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Auth.verifyOtp");
  return { title: t("title") };
}

export default async function VerifyOtpPage({
  params,
  searchParams,
}: {
  params: Promise<{ locale: string }>;
  searchParams: Promise<{ email?: string }>;
}) {
  const { locale } = await params;
  const { email } = await searchParams;
  setRequestLocale(locale);
  const t = await getTranslations("Auth.verifyOtp");

  if (!email) {
    notFound();
  }

  return (
    <AuthShell title={t("title")} subtitle={t("subtitle")}>
      <OtpForm email={email} />
    </AuthShell>
  );
}
