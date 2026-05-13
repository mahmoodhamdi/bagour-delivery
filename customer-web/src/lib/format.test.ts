import { describe, expect, it } from "vitest";

import { formatCurrency, formatDeliveryWindow, formatNumber, formatRating } from "./format";

describe("formatCurrency", () => {
  it("formats EGP for Arabic", () => {
    const out = formatCurrency(35, "ar");
    expect(out).toContain("٣٥");
  });

  it("formats EGP for English", () => {
    expect(formatCurrency(35, "en")).toContain("35");
  });
});

describe("formatNumber", () => {
  it("uses Arabic-Indic digits for Arabic", () => {
    expect(formatNumber(123, "ar")).toContain("١");
  });
  it("uses ASCII digits for English", () => {
    expect(formatNumber(123, "en")).toBe("123");
  });
});

describe("formatDeliveryWindow", () => {
  it("emits the Arabic abbreviation in AR", () => {
    expect(formatDeliveryWindow(20, 35, "ar")).toContain("د");
  });
  it("emits the English abbreviation in EN", () => {
    expect(formatDeliveryWindow(20, 35, "en")).toContain("min");
  });
});

describe("formatRating", () => {
  it("forces a single decimal", () => {
    expect(formatRating(4, "en")).toBe("4.0");
    expect(formatRating(4.56, "en")).toBe("4.6");
  });
});
