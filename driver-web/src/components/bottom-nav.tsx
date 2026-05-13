"use client";

import { useTranslations } from "next-intl";

import { Link, usePathname } from "@/i18n/navigation";
import { cn } from "@/lib/utils";

import { isActive, navLinks } from "./nav-links";

export function BottomNav() {
  const pathname = usePathname();
  const t = useTranslations("Nav");

  return (
    <nav
      aria-label={t("primary")}
      className="fixed inset-x-0 bottom-0 z-30 border-t bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/80 md:hidden"
    >
      <ul className="grid grid-cols-4">
        {navLinks.map(({ href, labelKey, icon: Icon }) => {
          const active = isActive(pathname, href);
          return (
            <li key={href}>
              <Link
                href={href}
                aria-current={active ? "page" : undefined}
                className={cn(
                  "flex h-16 flex-col items-center justify-center gap-1 text-xs transition-colors focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-[-4px]",
                  active ? "text-primary" : "text-muted-foreground hover:text-foreground",
                )}
                data-testid={`bottom-nav-${labelKey}`}
              >
                <Icon aria-hidden className="size-5" />
                <span>{t(labelKey)}</span>
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
