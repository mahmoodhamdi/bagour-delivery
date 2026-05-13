"use client";

import { Search, X } from "lucide-react";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";

import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";

interface RestaurantsSearchProps {
  value: string;
  onChange: (value: string) => void;
  /** Debounce delay in ms. Default 300. */
  debounce?: number;
}

export function RestaurantsSearch({ value, onChange, debounce = 300 }: RestaurantsSearchProps) {
  const t = useTranslations("Restaurants");
  // Local state is seeded from the prop only; for an external reset the
  // parent should remount us with a fresh `key`. That avoids the
  // setState-in-effect anti-pattern.
  const [local, setLocal] = useState(value);

  // Debounce upward.
  useEffect(() => {
    if (local === value) return undefined;
    const id = window.setTimeout(() => onChange(local), debounce);
    return () => window.clearTimeout(id);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [local, debounce]);

  return (
    <div className="relative">
      <Search
        aria-hidden
        className="pointer-events-none absolute start-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground"
      />
      <Input
        type="search"
        value={local}
        onChange={(e) => setLocal(e.target.value)}
        placeholder={t("searchPlaceholder")}
        aria-label={t("searchPlaceholder")}
        className={cn("ps-9 pe-9")}
        data-testid="restaurants-search"
        inputMode="search"
      />
      {local ? (
        <button
          type="button"
          onClick={() => {
            setLocal("");
            onChange("");
          }}
          aria-label={t("clearSearch")}
          data-testid="restaurants-search-clear"
          className="absolute end-1 top-1 inline-flex size-9 items-center justify-center rounded-lg text-muted-foreground hover:text-foreground focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
        >
          <X aria-hidden className="size-4" />
        </button>
      ) : null}
    </div>
  );
}
