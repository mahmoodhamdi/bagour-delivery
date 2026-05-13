import { describe, expect, it } from "vitest";

import { distanceMeters } from "./geo";

describe("distanceMeters()", () => {
  it("returns ~0 for identical points", () => {
    const p = { latitude: 30.45, longitude: 30.95 };
    expect(distanceMeters(p, p)).toBeCloseTo(0, 0);
  });

  it("returns ~111 km for one degree of latitude", () => {
    const d = distanceMeters(
      { latitude: 0, longitude: 0 },
      { latitude: 1, longitude: 0 },
    );
    expect(d).toBeGreaterThan(110_000);
    expect(d).toBeLessThan(112_000);
  });

  it("is symmetric", () => {
    const a = { latitude: 30.45, longitude: 30.95 };
    const b = { latitude: 30.46, longitude: 30.96 };
    expect(distanceMeters(a, b)).toBeCloseTo(distanceMeters(b, a), 2);
  });

  it("a few-meter shift returns < 50 m", () => {
    const d = distanceMeters(
      { latitude: 30.45, longitude: 30.95 },
      { latitude: 30.45001, longitude: 30.95001 },
    );
    expect(d).toBeLessThan(50);
  });
});
