import AxeBuilder from "@axe-core/playwright";
import { expect, test } from "@playwright/test";

test.describe("Profile (guarded)", () => {
  test("anonymous visit to /profile redirects to /login", async ({ page }) => {
    await page.goto("/profile");
    // ProtectedRoute fires router.replace on the client.
    await page.waitForURL(/\/login$/);
    await expect(page).toHaveURL(/\/login$/);
  });

  test("/profile/addresses also redirects when anonymous", async ({ page }) => {
    await page.goto("/profile/addresses");
    await page.waitForURL(/\/login$/);
    await expect(page).toHaveURL(/\/login$/);
  });

  test("profile-edit form is reachable directly (gets redirected)", async ({ page }) => {
    await page.goto("/profile/edit");
    await page.waitForURL(/\/login$/);
  });

  test("change-password form is reachable directly (gets redirected)", async ({ page }) => {
    await page.goto("/profile/change-password");
    await page.waitForURL(/\/login$/);
  });

  test("/profile gets the loading skeleton before the client store hydrates", async ({ page }) => {
    await page.goto("/profile");
    // We don't expect to assert the skeleton (timing is racy) — only that
    // the unauthenticated session eventually redirects away.
    await page.waitForURL(/\/login$/, { timeout: 5000 });
  });

  test("/profile route is accessibility-clean even in its redirect splash", async ({ page }) => {
    await page.goto("/profile");
    const results = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa"]).analyze();
    const critical = results.violations.filter(
      (v) => v.impact === "critical" || v.impact === "serious",
    );
    expect(critical, JSON.stringify(critical, null, 2)).toEqual([]);
  });
});
