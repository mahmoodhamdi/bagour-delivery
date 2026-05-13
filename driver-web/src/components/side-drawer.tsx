"use client";

import { useLocale, useTranslations } from "next-intl";
import { Menu } from "lucide-react";
import { useState } from "react";

import { Link, usePathname } from "@/i18n/navigation";
import { Button } from "@/components/ui/button";
import {
  Sheet,
  SheetClose,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Separator } from "@/components/ui/separator";
import { cn } from "@/lib/utils";

import { isActive, navLinks } from "./nav-links";

/**
 * Mobile-first side drawer. On md+ we hide the trigger so this is purely
 * a small-screen menu — desktop uses the top header links directly.
 */
export function SideDrawer() {
  const [open, setOpen] = useState(false);
  const pathname = usePathname();
  const locale = useLocale();
  const t = useTranslations();

  const side = locale === "ar" ? "right" : "left";

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>
        <Button
          variant="ghost"
          size="icon"
          className="md:hidden"
          aria-label={t("Nav.menu")}
          data-testid="open-drawer"
        >
          <Menu aria-hidden className="size-5" />
        </Button>
      </SheetTrigger>
      <SheetContent side={side} className="flex flex-col gap-6">
        <SheetHeader>
          <SheetTitle>{t("Brand.name")}</SheetTitle>
          <SheetDescription>{t("Brand.tagline")}</SheetDescription>
        </SheetHeader>
        <Separator />
        <nav aria-label={t("Nav.primary")}>
          <ul className="flex flex-col gap-1">
            {navLinks.map(({ href, labelKey, icon: Icon }) => {
              const active = isActive(pathname, href);
              return (
                <li key={href}>
                  <SheetClose asChild>
                    <Link
                      href={href}
                      aria-current={active ? "page" : undefined}
                      className={cn(
                        "flex h-12 items-center gap-3 rounded-xl px-3 transition-colors",
                        active
                          ? "bg-accent text-accent-foreground font-semibold"
                          : "hover:bg-accent/60",
                      )}
                    >
                      <Icon aria-hidden className="size-5" />
                      <span>{t(`Nav.${labelKey}`)}</span>
                    </Link>
                  </SheetClose>
                </li>
              );
            })}
          </ul>
        </nav>
      </SheetContent>
    </Sheet>
  );
}
