import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

describe("env validation", () => {
  const original = { ...process.env };

  beforeEach(() => {
    vi.resetModules();
  });

  afterEach(() => {
    process.env = { ...original };
  });

  it("parses defaults when nothing is set", async () => {
    delete process.env.NEXT_PUBLIC_API_URL;
    delete process.env.NEXT_PUBLIC_APP_URL;
    delete process.env.NEXT_PUBLIC_DEFAULT_LOCALE;
    const mod = await import("./env");
    expect(mod.env.NEXT_PUBLIC_API_URL).toBe("http://localhost:5000");
    expect(mod.env.NEXT_PUBLIC_APP_URL).toBe("http://localhost:3000");
    expect(mod.env.NEXT_PUBLIC_DEFAULT_LOCALE).toBe("ar");
  });

  it("accepts a valid backend URL", async () => {
    process.env.NEXT_PUBLIC_API_URL = "https://api.bagour.eg";
    const mod = await import("./env");
    expect(mod.env.NEXT_PUBLIC_API_URL).toBe("https://api.bagour.eg");
  });

  it("rejects an invalid API URL by throwing at module init", async () => {
    process.env.NEXT_PUBLIC_API_URL = "not-a-url";
    await expect(import("./env")).rejects.toThrow(/Invalid environment/);
  });

  it("rejects an unknown locale", async () => {
    process.env.NEXT_PUBLIC_DEFAULT_LOCALE = "fr";
    await expect(import("./env")).rejects.toThrow(/Invalid environment/);
  });
});
