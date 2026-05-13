"use client";

import { Loader2 } from "lucide-react";
import { useTranslations } from "next-intl";
import { useMemo, useState } from "react";

import type { MenuCategory, MenuItem } from "@bagour/types";

import { useRestaurantBySlug, useRestaurantMenu } from "@/lib/hooks/use-restaurants";

import { MenuCategoryNav } from "./menu-category-nav";
import { MenuItemCard } from "./menu-item-card";
import { MenuItemModal } from "./menu-item-modal";
import { RestaurantHero } from "./restaurant-hero";

interface MenuPageClientProps {
  slug: string;
}

interface MenuSection {
  category: MenuCategory;
  items: MenuItem[];
}

export function MenuPageClient({ slug }: MenuPageClientProps) {
  const t = useTranslations();
  const restaurant = useRestaurantBySlug(slug);
  const menu = useRestaurantMenu(slug);

  const sections = useMemo<MenuSection[]>(() => {
    if (!menu.data) return [];
    const byCat = new Map<string, MenuItem[]>();
    for (const item of menu.data.items) {
      const list = byCat.get(item.categoryId) ?? [];
      list.push(item);
      byCat.set(item.categoryId, list);
    }
    return menu.data.categories
      .filter((c) => c.isActive)
      .sort((a, b) => a.order - b.order)
      .map((cat) => ({
        category: cat,
        items: (byCat.get(cat.id) ?? []).sort((a, b) => a.order - b.order),
      }));
  }, [menu.data]);

  const [activeCategoryId, setActiveCategoryId] = useState<string | null>(null);
  const [selectedItem, setSelectedItem] = useState<MenuItem | null>(null);

  if (restaurant.isLoading || menu.isLoading) {
    return (
      <div
        role="status"
        aria-live="polite"
        className="flex min-h-[40vh] flex-col items-center justify-center gap-3 text-muted-foreground"
        data-testid="menu-loading"
      >
        <Loader2 aria-hidden className="size-8 animate-spin" />
        <span>{t("Common.loading")}</span>
      </div>
    );
  }

  if (restaurant.isError || !restaurant.data) {
    return (
      <p
        role="alert"
        className="rounded-lg border border-destructive/30 bg-destructive/10 p-4 text-sm font-medium text-destructive"
      >
        {t("Common.error")}
      </p>
    );
  }

  const scrollToCategory = (id: string) => {
    setActiveCategoryId(id);
    const el = document.getElementById(`category-${id}`);
    if (el) el.scrollIntoView({ behavior: "smooth", block: "start" });
  };

  return (
    <div className="space-y-6">
      <RestaurantHero restaurant={restaurant.data} />

      <div className="grid gap-6 md:grid-cols-[260px_1fr]">
        <aside className="md:pt-2">
          <MenuCategoryNav
            categories={sections.map((s) => s.category)}
            activeId={activeCategoryId ?? sections[0]?.category.id ?? null}
            onSelect={scrollToCategory}
          />
        </aside>

        <div className="space-y-8" data-testid="menu-sections">
          {sections.length === 0 ? (
            <p className="rounded-2xl border-2 border-dashed bg-card p-10 text-center text-muted-foreground">
              {t("Menu.noItems")}
            </p>
          ) : (
            sections.map(({ category, items }) => (
              <section
                key={category.id}
                id={`category-${category.id}`}
                aria-labelledby={`category-${category.id}-title`}
                className="scroll-mt-32 space-y-3"
              >
                <h2 id={`category-${category.id}-title`} className="text-xl font-bold">
                  {category.name}
                </h2>
                {items.length === 0 ? (
                  <p className="text-sm text-muted-foreground">{t("Menu.emptyCategory")}</p>
                ) : (
                  <ul className="grid gap-3 sm:grid-cols-2">
                    {items.map((item) => (
                      <li key={item.id}>
                        <MenuItemCard item={item} onClick={() => setSelectedItem(item)} />
                      </li>
                    ))}
                  </ul>
                )}
              </section>
            ))
          )}
        </div>
      </div>

      <MenuItemModal
        item={selectedItem}
        restaurant={restaurant.data}
        restaurantSlug={slug}
        onClose={() => setSelectedItem(null)}
      />
    </div>
  );
}
