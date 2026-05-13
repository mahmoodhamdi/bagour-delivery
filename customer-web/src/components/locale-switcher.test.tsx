import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { NextIntlClientProvider } from "next-intl";
import { describe, expect, it, vi } from "vitest";

import { LocaleSwitcher } from "./locale-switcher";

const replace = vi.fn();

vi.mock("@/i18n/navigation", () => ({
  usePathname: () => "/",
  useRouter: () => ({ replace }),
}));

const messages = {
  Common: {
    language: "Language",
    switchToEnglish: "English",
    switchToArabic: "العربية",
  },
};

function renderWithLocale(locale: "ar" | "en") {
  return render(
    <NextIntlClientProvider locale={locale} messages={messages}>
      <LocaleSwitcher />
    </NextIntlClientProvider>,
  );
}

describe("LocaleSwitcher", () => {
  it("offers the opposite locale (EN when on AR)", () => {
    renderWithLocale("ar");
    expect(screen.getByRole("button", { name: /language/i })).toBeInTheDocument();
    expect(screen.getByText("English")).toBeInTheDocument();
  });

  it("offers the opposite locale (AR when on EN)", () => {
    renderWithLocale("en");
    expect(screen.getByText("العربية")).toBeInTheDocument();
  });

  it("calls router.replace with the next locale on click", async () => {
    const user = userEvent.setup();
    renderWithLocale("ar");
    await user.click(screen.getByRole("button", { name: /language/i }));
    expect(replace).toHaveBeenCalledWith("/", { locale: "en" });
  });
});
