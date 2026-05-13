"use client";

import { useLocale } from "next-intl";

import { Constants } from "@bagour/types";

import { cn } from "@/lib/utils";

interface CuisinePillsProps {
  selected?: string;
  onChange: (key: string | undefined) => void;
  allLabel: string;
}

const cuisineKeys = Constants.CUISINE_TYPES;

export function CuisinePills({ selected, onChange, allLabel }: CuisinePillsProps) {
  const locale = useLocale();

  const pills: { key: string | undefined; label: string }[] = [
    { key: undefined, label: allLabel },
    ...cuisineKeys.map((c) => ({
      key: c.key,
      label: locale === "ar" ? c.label : c.labelEn,
    })),
  ];

  return (
    <div className="-mx-4 overflow-x-auto px-4" role="tablist" aria-label="Cuisine filters">
      <ul className="flex w-max gap-2 pb-2">
        {pills.map((pill) => {
          const active = pill.key === selected;
          return (
            <li key={pill.key ?? "all"}>
              <button
                type="button"
                role="tab"
                aria-selected={active}
                aria-controls="restaurants-grid"
                onClick={() => onChange(pill.key)}
                data-testid={`cuisine-pill-${pill.key ?? "all"}`}
                className={cn(
                  "rounded-full border px-4 py-2 text-sm font-medium transition-colors focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2",
                  active
                    ? "border-primary bg-primary text-primary-foreground"
                    : "border-input bg-card hover:bg-accent",
                )}
              >
                {pill.label}
              </button>
            </li>
          );
        })}
      </ul>
    </div>
  );
}
