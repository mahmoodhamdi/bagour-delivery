import AxeBuilder from "@axe-core/playwright";
import { expect, test } from "@playwright/test";

test.describe("Driver auth pages", () => {
  test("login page renders form + register link + forgot link", async ({ page }) => {
    await page.goto("/login");
    await expect(page.getByTestId("login-email")).toBeVisible();
    await expect(page.getByTestId("login-password")).toBeVisible();
    await expect(page.getByTestId("login-submit")).toBeVisible();
    await expect(page.getByRole("link", { name: /سجّل كسائق جديد|Register as a driver/ })).toBeVisible();
  });

  test("register page collects driver fields and accepts terms", async ({ page }) => {
    await page.goto("/register");
    await expect(page.getByTestId("register-name")).toBeVisible();
    await expect(page.getByTestId("register-email")).toBeVisible();
    await expect(page.getByTestId("register-phone")).toBeVisible();
    await expect(page.getByTestId("register-password")).toBeVisible();
    await expect(page.getByTestId("register-confirm-password")).toBeVisible();
    await expect(page.getByTestId("register-accept-terms")).toBeVisible();
  });

  test("login form rejects an invalid email client-side", async ({ page }) => {
    await page.goto("/login");
    await page.getByTestId("login-email").fill("not-an-email");
    await page.getByTestId("login-password").fill("short");
    await page.getByTestId("login-submit").click();
    await expect(page.getByText(/Email looks invalid|البريد الإلكتروني غير صالح/)).toBeVisible();
  });

  test("forgot password page renders and has back-to-login link", async ({ page }) => {
    await page.goto("/forgot-password");
    await expect(page.getByTestId("forgot-email")).toBeVisible();
    await expect(page.getByRole("link", { name: /Back to sign in|رجوع لتسجيل الدخول/ })).toBeVisible();
  });

  test("login page has no critical/serious accessibility violations", async ({ page }) => {
    await page.goto("/login");
    const results = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa"]).analyze();
    const critical = results.violations.filter(
      (v) => v.impact === "critical" || v.impact === "serious",
    );
    expect(critical, JSON.stringify(critical, null, 2)).toEqual([]);
  });
});
