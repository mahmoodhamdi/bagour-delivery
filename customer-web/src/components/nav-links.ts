import { Home, Package, ShoppingBag, User } from "lucide-react";
import type { LucideIcon } from "lucide-react";

import type { Route } from "next";

export interface NavLink {
  href: Route;
  labelKey: string; // i18n key under `Nav.*`
  icon: LucideIcon;
}

export const navLinks: NavLink[] = [
  { href: "/", labelKey: "home", icon: Home },
  { href: "/restaurants", labelKey: "restaurants", icon: ShoppingBag },
  { href: "/orders", labelKey: "orders", icon: Package },
  { href: "/profile", labelKey: "profile", icon: User },
];

/**
 * True when `pathname` belongs to the link's section.
 * Home matches only the root path; other routes match the prefix.
 */
export function isActive(pathname: string, href: string): boolean {
  if (href === "/") return pathname === "/";
  return pathname === href || pathname.startsWith(`${href}/`);
}
