import { getTranslations, setRequestLocale } from "next-intl/server";
import type { Metadata } from "next";

import { AuthShell } from "@/components/auth/auth-shell";
import { ForgotPasswordForm } from "@/components/auth/forgot-password-form";
import { Link } from "@/i18n/navigation";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Auth.forgotPassword");
  return { title: t("title") };
}

export default async function ForgotPasswordPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations();

  return (
    <AuthShell
      title={t("Auth.forgotPassword.title")}
      subtitle={t("Auth.forgotPassword.subtitle")}
      footer={
        <Link href="/login" className="font-semibold text-primary hover:underline">
          {t("Auth.forgotPassword.backToLogin")}
        </Link>
      }
    >
      <ForgotPasswordForm />
    </AuthShell>
  );
}
