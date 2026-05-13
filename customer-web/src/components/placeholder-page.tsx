import { useTranslations } from "next-intl";

interface PlaceholderPageProps {
  title: string;
  subtitle: string;
  icon?: React.ReactNode;
  /** Unique id for E2E selectors and the skip-link target. */
  testId?: string;
}

/**
 * Generic placeholder page used while a feature is in progress. Each
 * page passes a localized title + subtitle so the layout stays consistent
 * and Lighthouse a11y stays green.
 */
export function PlaceholderPage({ title, subtitle, icon, testId }: PlaceholderPageProps) {
  const t = useTranslations("Placeholder");

  return (
    <main
      id="main"
      className="container mx-auto flex flex-col gap-6 px-4 py-12"
      data-testid={testId}
    >
      <header className="space-y-2">
        <h1 className="text-3xl font-bold tracking-tight md:text-4xl">{title}</h1>
        <p className="text-muted-foreground md:text-lg">{subtitle}</p>
      </header>

      <section className="rounded-2xl border bg-card p-8 md:p-12">
        <div className="flex flex-col items-start gap-4 md:flex-row md:items-center">
          {icon ? <div className="text-primary">{icon}</div> : null}
          <div className="space-y-1">
            <h2 className="text-xl font-semibold">{t("comingSoon")}</h2>
            <p className="text-sm text-muted-foreground md:text-base">{t("comingSoonBody")}</p>
          </div>
        </div>
      </section>
    </main>
  );
}
