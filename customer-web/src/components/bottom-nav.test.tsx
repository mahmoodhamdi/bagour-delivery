import { render, screen } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { describe, expect, it, vi } from "vitest";

import { BottomNav } from "./bottom-nav";

const usePathnameMock = vi.fn<() => string>(() => "/");

vi.mock("@/i18n/navigation", () => ({
  Link: ({ children, href, ...rest }: React.PropsWithChildren<{ href: string }>) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
  usePathname: () => usePathnameMock(),
}));

const messages = {
  Nav: {
    primary: "Primary navigation",
    menu: "Menu",
    home: "Home",
    restaurants: "Restaurants",
    orders: "Orders",
    profile: "Profile",
  },
};

function setup(pathname: string) {
  usePathnameMock.mockReturnValue(pathname);
  return render(
    <NextIntlClientProvider locale="en" messages={messages}>
      <BottomNav />
    </NextIntlClientProvider>,
  );
}

describe("BottomNav", () => {
  it("renders all four destinations", () => {
    setup("/");
    expect(screen.getByTestId("bottom-nav-home")).toBeInTheDocument();
    expect(screen.getByTestId("bottom-nav-restaurants")).toBeInTheDocument();
    expect(screen.getByTestId("bottom-nav-orders")).toBeInTheDocument();
    expect(screen.getByTestId("bottom-nav-profile")).toBeInTheDocument();
  });

  it("marks the home link as the current page when pathname is /", () => {
    setup("/");
    expect(screen.getByTestId("bottom-nav-home")).toHaveAttribute("aria-current", "page");
    expect(screen.getByTestId("bottom-nav-orders")).not.toHaveAttribute("aria-current");
  });

  it("marks the restaurants link as current under /restaurants/:slug", () => {
    setup("/restaurants/koshary-bagour");
    expect(screen.getByTestId("bottom-nav-restaurants")).toHaveAttribute("aria-current", "page");
    expect(screen.getByTestId("bottom-nav-home")).not.toHaveAttribute("aria-current");
  });

  it("exposes a labeled nav landmark", () => {
    setup("/");
    expect(screen.getByRole("navigation", { name: /primary/i })).toBeInTheDocument();
  });
});
