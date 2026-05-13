"use client";

import { useLocale } from "next-intl";

import type { MenuCategory } from "@bagour/types";

import { cn } from "@/lib/utils";

interface MenuCategoryNavProps {
  categories: MenuCategory[];
  activeId: string | null;
  onSelect: (id: string) => void;
}

/**
 * Horizontally scrollable on mobile, sticky vertical list on desktop.
 * Clicking scrolls the target category section into view (the page
 * registers scroll-spy via IntersectionObserver — wired in the parent).
 */
export function MenuCategoryNav({ categories, activeId, onSelect }: MenuCategoryNavProps) {
  const locale = useLocale();
  if (categories.length === 0) return null;

  return (
    <nav
      aria-label="Menu categories"
      className="sticky top-16 -mx-4 overflow-x-auto bg-background/95 px-4 backdrop-blur supports-[backdrop-filter]:bg-background/70 md:top-20 md:mx-0 md:overflow-visible md:px-0"
    >
      <ul
        className="flex w-max gap-2 py-3 md:w-full md:flex-col md:gap-1"
        data-testid="menu-category-nav"
      >
        {categories
          .filter((c) => c.isActive)
          .sort((a, b) => a.order - b.order)
          .map((cat) => {
            const active = activeId === cat.id;
            const label = locale === "ar" ? cat.name : (cat.nameEn ?? cat.name);
            return (
              <li key={cat.id}>
                <button
                  type="button"
                  onClick={() => onSelect(cat.id)}
                  aria-current={active ? "true" : undefined}
                  className={cn(
                    "whitespace-nowrap rounded-full border px-4 py-2 text-sm font-medium transition-colors focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2 md:w-full md:rounded-xl md:text-start",
                    active
                      ? "border-primary bg-primary text-primary-foreground"
                      : "border-transparent bg-card hover:bg-accent",
                  )}
                  data-testid={`menu-cat-${cat.id}`}
                >
                  {label}
                </button>
              </li>
            );
          })}
      </ul>
    </nav>
  );
}
