import AxeBuilder from "@axe-core/playwright";
import { expect, test } from "@playwright/test";

test.describe("Login page (Arabic)", () => {
  test("loads with validation, brand, and switcher", async ({ page }) => {
    await page.goto("/login");
    await expect(page.getByRole("heading", { level: 1, name: /أهلاً بيك تاني/ })).toBeVisible();
    await expect(page.getByTestId("login-email")).toBeVisible();
    await expect(page.getByTestId("login-password")).toBeVisible();
    await expect(page.getByTestId("login-submit")).toBeVisible();

    // Submit empty → both fields error.
    await page.getByTestId("login-submit").click();
    await expect(page.getByText("البريد الإلكتروني مطلوب")).toBeVisible();
    await expect(page.getByText("كلمة السر لازم تكون ٨ حروف على الأقل")).toBeVisible();
  });

  test("password visibility toggle works", async ({ page }) => {
    await page.goto("/login");
    const password = page.getByTestId("login-password");
    await password.fill("secret123");
    await expect(password).toHaveAttribute("type", "password");
    await page.getByRole("button", { name: /عرض كلمة السر/ }).click();
    await expect(password).toHaveAttribute("type", "text");
  });

  test("no critical/serious a11y violations", async ({ page }) => {
    await page.goto("/login");
    const results = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa"]).analyze();
    const critical = results.violations.filter(
      (v) => v.impact === "critical" || v.impact === "serious",
    );
    expect(critical, JSON.stringify(critical, null, 2)).toEqual([]);
  });
});

test.describe("Register page (English)", () => {
  test("renders all fields + checkbox", async ({ page }) => {
    await page.goto("/en/register");
    await expect(
      page.getByRole("heading", { level: 1, name: /Create your account/ }),
    ).toBeVisible();
    await expect(page.getByTestId("register-name")).toBeVisible();
    await expect(page.getByTestId("register-email")).toBeVisible();
    await expect(page.getByTestId("register-phone")).toBeVisible();
    await expect(page.getByTestId("register-password")).toBeVisible();
    await expect(page.getByTestId("register-confirm-password")).toBeVisible();
    await expect(page.getByTestId("register-accept-terms")).toBeVisible();
  });

  test("rejects mismatched passwords client-side", async ({ page }) => {
    await page.goto("/en/register");
    await page.getByTestId("register-name").fill("Mahmoud");
    await page.getByTestId("register-email").fill("m@b.co");
    await page.getByTestId("register-phone").fill("01012345678");
    await page.getByTestId("register-password").fill("secret123");
    await page.getByTestId("register-confirm-password").fill("different1");
    await page.getByTestId("register-accept-terms").check();
    await page.getByTestId("register-submit").click();
    await expect(page.getByText("Passwords don't match")).toBeVisible();
  });

  test("no critical/serious a11y violations", async ({ page }) => {
    await page.goto("/en/register");
    const results = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa"]).analyze();
    const critical = results.violations.filter(
      (v) => v.impact === "critical" || v.impact === "serious",
    );
    expect(critical, JSON.stringify(critical, null, 2)).toEqual([]);
  });
});

test.describe("Forgot + Reset flow", () => {
  test("forgot page links back to login", async ({ page }) => {
    await page.goto("/forgot-password");
    await expect(page.getByRole("link", { name: /الرجوع لتسجيل الدخول/ })).toHaveAttribute(
      "href",
      /\/login$/,
    );
  });

  test("verify-otp 404s without an email param", async ({ page }) => {
    const res = await page.goto("/verify-otp");
    // notFound() renders the locale's not-found page with a 404 status.
    expect(res?.status()).toBe(404);
  });
});
