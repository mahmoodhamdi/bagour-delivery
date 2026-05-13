import { render, screen } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { beforeEach, describe, expect, it, vi } from "vitest";

import messagesEn from "../../../messages/en.json";
import { useAuthStore } from "@/stores/auth-store";

vi.mock("@/lib/api-context", () => ({
  useApi: () => ({ auth: { logout: () => Promise.resolve({ message: "ok" }) } }),
}));

vi.mock("@/i18n/navigation", () => ({
  Link: ({
    children,
    href,
    ...rest
  }: React.PropsWithChildren<{ href: string } & React.AnchorHTMLAttributes<HTMLAnchorElement>>) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
  useRouter: () => ({ push: () => undefined }),
}));

// Imported after mocks so the file uses them.
import { AuthSlot } from "./auth-slot";

function setup() {
  return render(
    <NextIntlClientProvider locale="en" messages={messagesEn}>
      <AuthSlot />
    </NextIntlClientProvider>,
  );
}

describe("AuthSlot", () => {
  beforeEach(() => {
    useAuthStore.setState({ user: null, accessToken: null, issuedAt: null, hydrated: false });
  });

  it("shows a skeleton placeholder before hydration", () => {
    setup();
    // Skeleton is the only [aria-hidden='true'] element in this tree.
    expect(document.querySelector("[aria-hidden='true']")).toBeInTheDocument();
    expect(screen.queryByTestId("auth-sign-in")).not.toBeInTheDocument();
  });

  it("shows the Sign in CTA when hydrated + signed out", () => {
    useAuthStore.setState({ hydrated: true });
    setup();
    expect(screen.getByTestId("auth-sign-in")).toBeInTheDocument();
  });

  it("renders the avatar dropdown trigger when signed in", () => {
    useAuthStore.setState({
      hydrated: true,
      user: {
        id: "u1",
        email: "x@b.co",
        name: "Mahmoud Hamdy",
        phone: "01012345678",
        role: "customer",
        isActive: true,
        isBlocked: false,
        isEmailVerified: true,
        isPhoneVerified: true,
        fcmTokens: [],
        createdAt: "2026-05-13T00:00:00.000Z",
        updatedAt: "2026-05-13T00:00:00.000Z",
      },
    });
    setup();
    expect(screen.getByTestId("auth-avatar")).toBeInTheDocument();
    // initials derived from name "Mahmoud Hamdy"
    expect(screen.getByText("MH")).toBeInTheDocument();
  });
});
