import { expect, test } from "@playwright/test";

const ROUTES = ["/active", "/earnings", "/profile", "/onboarding"];

test.describe("ProtectedRoute behaviour", () => {
  for (const path of ROUTES) {
    test(`anonymous visit to ${path} redirects to /login`, async ({ page }) => {
      await page.goto(path);
      await page.waitForURL(/\/login/, { timeout: 5_000 });
      await expect(page.getByTestId("login-email")).toBeVisible();
    });
  }
});
