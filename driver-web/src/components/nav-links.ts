import { DollarSign, Home, Package, User } from "lucide-react";
import type { LucideIcon } from "lucide-react";

import type { Route } from "next";

export interface NavLink {
  href: Route;
  labelKey: string; // i18n key under `Nav.*`
  icon: LucideIcon;
}

export const navLinks: NavLink[] = [
  { href: "/", labelKey: "home", icon: Home },
  { href: "/active", labelKey: "active", icon: Package },
  { href: "/earnings", labelKey: "earnings", icon: DollarSign },
  { href: "/profile", labelKey: "profile", icon: User },
];

export function isActive(pathname: string, href: string): boolean {
  if (href === "/") return pathname === "/";
  return pathname === href || pathname.startsWith(`${href}/`);
}
