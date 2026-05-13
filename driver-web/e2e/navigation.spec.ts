import { devices, expect, test } from "@playwright/test";

test.describe("Driver navigation shell — desktop", () => {
  test("header links navigate between protected routes (redirect to login)", async ({ page }) => {
    await page.goto("/");
    // Anonymous user hitting the home page sees marketing hero + Sign in button.
    await expect(page.getByTestId("auth-sign-in")).toBeVisible();

    // Active / earnings / profile are guarded — clicking them redirects to /login.
    await page.getByRole("link", { name: "الطلبات الحالية", exact: true }).first().click();
    await expect(page).toHaveURL(/\/login/);

    await page.goto("/");
    await page.getByRole("link", { name: "أرباحي", exact: true }).first().click();
    await expect(page).toHaveURL(/\/login/);
  });

  test("locale switcher preserves the current route", async ({ page }) => {
    await page.goto("/login");
    await page.getByRole("button", { name: /اللغة|Language/i }).click();
    await page.waitForURL(/\/en\/login$/);
    await expect(page.getByRole("heading", { name: /Welcome back/i })).toBeVisible();
  });
});

test.describe("Driver navigation shell — mobile drawer", () => {
  test.use({ ...devices["Pixel 7"] });

  test("drawer lists driver-specific destinations", async ({ page }) => {
    await page.goto("/");
    await page.getByTestId("open-drawer").click();
    const dialog = page.getByRole("dialog");
    await expect(dialog).toBeVisible();
    await expect(dialog.getByRole("link", { name: "الطلبات الحالية" })).toBeVisible();
    await expect(dialog.getByRole("link", { name: "أرباحي" })).toBeVisible();
    await expect(dialog.getByRole("link", { name: "حسابي" })).toBeVisible();
  });
});
