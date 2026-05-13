import AxeBuilder from "@axe-core/playwright";
import { devices, expect, test } from "@playwright/test";

test.describe("Navigation shell — desktop", () => {
  test("header links navigate between primary routes", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByRole("link", { name: "المطاعم", exact: true })).toBeVisible();

    await page.getByRole("link", { name: "المطاعم", exact: true }).first().click();
    await expect(page).toHaveURL(/\/restaurants$/);
    await expect(page.getByTestId("restaurants-page")).toBeVisible();

    await page.getByRole("link", { name: "طلباتي", exact: true }).first().click();
    await expect(page).toHaveURL(/\/orders$/);
    await expect(page.getByTestId("orders-page")).toBeVisible();

    await page.getByRole("link", { name: "حسابي", exact: true }).first().click();
    await expect(page).toHaveURL(/\/profile$/);
    await expect(page.getByTestId("profile-page")).toBeVisible();
  });

  test("locale switcher preserves the current route", async ({ page }) => {
    await page.goto("/restaurants");
    await page.getByRole("button", { name: /اللغة|Language/i }).click();
    await page.waitForURL(/\/en\/restaurants$/);
    await expect(page.getByTestId("restaurants-page")).toBeVisible();
  });
});

test.describe("Navigation shell — mobile drawer", () => {
  test.use({ ...devices["Pixel 7"] });

  test("drawer opens, lists destinations, navigates", async ({ page }) => {
    await page.goto("/");
    await page.getByTestId("open-drawer").click();
    const dialog = page.getByRole("dialog");
    await expect(dialog).toBeVisible();
    await dialog.getByRole("link", { name: "المطاعم" }).click();
    await expect(page).toHaveURL(/\/restaurants$/);
    await expect(dialog).not.toBeVisible();
  });

  test("bottom-nav highlights the active section", async ({ page }) => {
    await page.goto("/orders");
    const ordersLink = page.getByTestId("bottom-nav-orders");
    await expect(ordersLink).toHaveAttribute("aria-current", "page");
    const home = page.getByTestId("bottom-nav-home");
    await expect(home).not.toHaveAttribute("aria-current", "page");
  });
});

test.describe("Accessibility across primary routes", () => {
  const routes = ["/", "/restaurants", "/orders", "/profile"] as const;
  for (const route of routes) {
    test(`no critical/serious WCAG2 AA violations on ${route}`, async ({ page }) => {
      await page.goto(route);
      const results = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa"]).analyze();
      const critical = results.violations.filter(
        (v) => v.impact === "critical" || v.impact === "serious",
      );
      expect(critical, JSON.stringify(critical, null, 2)).toEqual([]);
    });
  }
});
