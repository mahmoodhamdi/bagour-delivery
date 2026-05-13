"use client";

import { useTranslations } from "next-intl";

import { Link, usePathname } from "@/i18n/navigation";
import { cn } from "@/lib/utils";

import { AuthSlot } from "./auth/auth-slot";
import { CartDrawer } from "./cart/cart-drawer";
import { isActive, navLinks } from "./nav-links";
import { LocaleSwitcher } from "./locale-switcher";
import { SideDrawer } from "./side-drawer";

export function Header() {
  const t = useTranslations();
  const pathname = usePathname();

  return (
    <header className="sticky top-0 z-30 border-b bg-background/80 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container mx-auto flex h-16 items-center gap-4 px-4">
        <SideDrawer />

        <Link
          href="/"
          className="flex items-center gap-2 focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2 rounded-lg"
        >
          <span
            aria-hidden
            className="inline-flex h-9 w-9 items-center justify-center rounded-full bg-primary text-primary-foreground font-bold"
          >
            ب
          </span>
          <strong className="text-lg font-bold">{t("Brand.name")}</strong>
        </Link>

        <nav
          aria-label={t("Nav.primary")}
          className="hidden md:flex md:items-center md:gap-1 md:ms-4"
        >
          {navLinks.map(({ href, labelKey }) => {
            const active = isActive(pathname, href);
            return (
              <Link
                key={href}
                href={href}
                aria-current={active ? "page" : undefined}
                className={cn(
                  "rounded-lg px-3 py-2 text-sm font-medium transition-colors",
                  active
                    ? "bg-accent text-accent-foreground"
                    : "text-muted-foreground hover:bg-accent/60 hover:text-foreground",
                )}
              >
                {t(`Nav.${labelKey}`)}
              </Link>
            );
          })}
        </nav>

        <div className="ms-auto flex items-center gap-2">
          <LocaleSwitcher />
          <CartDrawer alwaysShowTrigger={false} />
          <AuthSlot />
        </div>
      </div>
    </header>
  );
}
