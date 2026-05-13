import { Construction } from "lucide-react";

interface PlaceholderPageProps {
  title: string;
  subtitle: string;
  body: string;
}

export function PlaceholderPage({ title, subtitle, body }: PlaceholderPageProps) {
  return (
    <main
      id="main"
      className="container mx-auto flex max-w-2xl flex-col items-center gap-4 px-4 py-16 text-center md:py-24"
    >
      <Construction aria-hidden className="size-10 text-primary" />
      <h1 className="text-3xl font-bold tracking-tight">{title}</h1>
      <p className="text-muted-foreground">{subtitle}</p>
      <p className="text-sm text-muted-foreground">{body}</p>
    </main>
  );
}
