import { getTranslations, setRequestLocale } from "next-intl/server";
import type { Metadata } from "next";

import { AuthShell } from "@/components/auth/auth-shell";
import { RegisterForm } from "@/components/auth/register-form";
import { Link } from "@/i18n/navigation";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Auth.register");
  return { title: t("title") };
}

export default async function RegisterPage({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations();

  return (
    <AuthShell
      title={t("Auth.register.title")}
      subtitle={t("Auth.register.subtitle")}
      footer={
        <p>
          {t("Auth.register.haveAccount")}{" "}
          <Link href="/login" className="font-semibold text-primary hover:underline">
            {t("Auth.register.signIn")}
          </Link>
        </p>
      }
    >
      <RegisterForm />
    </AuthShell>
  );
}
