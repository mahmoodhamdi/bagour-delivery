export default function LocaleLoading() {
  return (
    <main
      id="main"
      role="status"
      aria-live="polite"
      className="flex min-h-[40vh] items-center justify-center text-muted-foreground"
    >
      <div className="size-8 animate-spin rounded-full border-2 border-current border-t-transparent" />
      <span className="sr-only">Loading…</span>
    </main>
  );
}
