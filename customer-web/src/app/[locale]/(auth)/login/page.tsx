import { getTranslations, setRequestLocale } from "next-intl/server";
import type { Metadata } from "next";

import { AuthShell } from "@/components/auth/auth-shell";
import { LoginForm } from "@/components/auth/login-form";
import { Link } from "@/i18n/navigation";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Auth.login");
  return { title: t("title") };
}

export default async function LoginPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations();

  return (
    <AuthShell
      title={t("Auth.login.title")}
      subtitle={t("Auth.login.subtitle")}
      footer={
        <p>
          {t("Auth.login.noAccount")}{" "}
          <Link href="/register" className="font-semibold text-primary hover:underline">
            {t("Auth.login.createAccount")}
          </Link>
        </p>
      }
    >
      <LoginForm />
    </AuthShell>
  );
}
