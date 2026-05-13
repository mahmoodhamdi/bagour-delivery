import AxeBuilder from "@axe-core/playwright";
import { expect, test } from "@playwright/test";

test.describe("Home page — Arabic (default)", () => {
  test("renders the hero in Arabic + RTL", async ({ page }) => {
    await page.goto("/");

    // Locale resolves to AR and html sets dir=rtl.
    await expect(page.locator("html")).toHaveAttribute("lang", "ar");
    await expect(page.locator("html")).toHaveAttribute("dir", "rtl");

    // Brand + hero copy visible.
    await expect(page.getByText("باجور ديليفري").first()).toBeVisible();
    await expect(page.getByRole("heading", { level: 1 })).toContainText("اطلب");
  });

  test("primary CTAs lead to the right routes", async ({ page }) => {
    await page.goto("/");
    const browseLink = page.getByRole("link", { name: "تصفح المطاعم" });
    await expect(browseLink).toHaveAttribute("href", /\/restaurants$/);
    const trackLink = page.getByRole("link", { name: "تتبع طلبك" });
    await expect(trackLink).toHaveAttribute("href", /\/orders$/);
  });

  test("language switcher swaps to English and applies LTR", async ({ page }) => {
    await page.goto("/");
    await page.getByRole("button", { name: /اللغة|Language/i }).click();
    await page.waitForURL(/\/en/);
    await expect(page.locator("html")).toHaveAttribute("lang", "en");
    await expect(page.locator("html")).toHaveAttribute("dir", "ltr");
    await expect(page.getByRole("heading", { level: 1 })).toContainText("Order from Bagour");
  });

  test("manifest is served and shipping the right name", async ({ page, baseURL }) => {
    const res = await page.request.get(`${baseURL!}/manifest.webmanifest`);
    expect(res.ok()).toBeTruthy();
    const json = (await res.json()) as { name: string; theme_color: string };
    expect(json.name).toContain("Bagour");
    expect(json.theme_color).toBe("#cf6f2c");
  });

  test("home page has no critical/serious accessibility violations", async ({ page }) => {
    await page.goto("/");
    const results = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa"]).analyze();
    const critical = results.violations.filter(
      (v) => v.impact === "critical" || v.impact === "serious",
    );
    expect(critical, JSON.stringify(critical, null, 2)).toEqual([]);
  });
});
