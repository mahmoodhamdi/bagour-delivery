import { describe, expect, it } from "vitest";

import { isActive, navLinks } from "./nav-links";

describe("navLinks", () => {
  it("exposes the four expected top-level destinations", () => {
    expect(navLinks.map((n) => n.href)).toEqual(["/", "/restaurants", "/orders", "/profile"]);
  });

  it("each link has an i18n key and an icon", () => {
    for (const link of navLinks) {
      expect(link.labelKey).toBeTruthy();
      expect(link.icon).toBeTypeOf("object");
    }
  });
});

describe("isActive", () => {
  it("home is only active at exactly /", () => {
    expect(isActive("/", "/")).toBe(true);
    expect(isActive("/restaurants", "/")).toBe(false);
    expect(isActive("/orders/123", "/")).toBe(false);
  });

  it("non-home matches the prefix", () => {
    expect(isActive("/restaurants", "/restaurants")).toBe(true);
    expect(isActive("/restaurants/koshary-bagour", "/restaurants")).toBe(true);
    expect(isActive("/orders", "/restaurants")).toBe(false);
  });

  it("does not match a sibling whose path starts with the same string", () => {
    // /orders should NOT match /order even with startsWith — our impl uses
    // `pathname === href || pathname.startsWith(href + '/')` so we require the
    // trailing slash to differentiate.
    expect(isActive("/orders-x", "/orders")).toBe(false);
    expect(isActive("/order", "/orders")).toBe(false);
  });
});
