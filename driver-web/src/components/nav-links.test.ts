import { describe, expect, it } from "vitest";

import { isActive, navLinks } from "./nav-links";

describe("driver navLinks", () => {
  it("exposes exactly home/active/earnings/profile", () => {
    expect(navLinks.map((l) => l.labelKey)).toEqual(["home", "active", "earnings", "profile"]);
  });
});

describe("isActive()", () => {
  it("home only matches exact root", () => {
    expect(isActive("/", "/")).toBe(true);
    expect(isActive("/active", "/")).toBe(false);
  });

  it("non-home matches prefix", () => {
    expect(isActive("/active", "/active")).toBe(true);
    expect(isActive("/active/123", "/active")).toBe(true);
    expect(isActive("/earnings", "/active")).toBe(false);
  });
});
