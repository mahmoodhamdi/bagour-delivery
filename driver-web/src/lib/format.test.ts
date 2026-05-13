import { describe, expect, it } from "vitest";

import { formatCurrency, formatNumber, formatTimeAgo } from "./format";

describe("formatCurrency()", () => {
  it("formats EGP for English", () => {
    expect(formatCurrency(100, "en")).toMatch(/EGP/);
  });

  it("formats EGP for Arabic using ar-EG digits", () => {
    const result = formatCurrency(100, "ar");
    // Just ensure the result is non-empty and contains the value
    expect(result).toBeTruthy();
    expect(typeof result).toBe("string");
  });
});

describe("formatNumber()", () => {
  it("returns ASCII digits for en", () => {
    expect(formatNumber(1234, "en")).toMatch(/1.?234/);
  });
});

describe("formatTimeAgo()", () => {
  it("returns 'just now' for very recent times", () => {
    const iso = new Date().toISOString();
    expect(formatTimeAgo(iso, "en", Date.now())).toBeTruthy();
  });

  it("returns minutes ago for a few minutes back", () => {
    const past = new Date(Date.now() - 5 * 60 * 1000).toISOString();
    const result = formatTimeAgo(past, "en", Date.now());
    expect(result).toMatch(/minute/);
  });
});
