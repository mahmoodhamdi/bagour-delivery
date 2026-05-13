import { render, screen, waitFor } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { beforeEach, describe, expect, it, vi } from "vitest";

import messagesEn from "../../messages/en.json";
import { useAuthStore } from "@/stores/auth-store";

const replace = vi.fn();

vi.mock("@/i18n/navigation", () => ({
  useRouter: () => ({ replace }),
}));

import { ProtectedRoute } from "./protected-route";

function setup() {
  return render(
    <NextIntlClientProvider locale="en" messages={messagesEn}>
      <ProtectedRoute>
        <p data-testid="children">Protected content</p>
      </ProtectedRoute>
    </NextIntlClientProvider>,
  );
}

describe("ProtectedRoute", () => {
  beforeEach(() => {
    replace.mockReset();
    useAuthStore.setState({ user: null, accessToken: null, issuedAt: null, hydrated: false });
  });

  it("shows a loading state until hydrated", () => {
    setup();
    expect(screen.getByTestId("protected-loading")).toBeInTheDocument();
    expect(screen.queryByTestId("children")).not.toBeInTheDocument();
    expect(replace).not.toHaveBeenCalled();
  });

  it("redirects when hydrated + signed out", async () => {
    useAuthStore.setState({ hydrated: true });
    setup();
    await waitFor(() => {
      expect(replace).toHaveBeenCalledWith("/login");
    });
  });

  it("renders children when hydrated + signed in", () => {
    useAuthStore.setState({
      hydrated: true,
      user: {
        id: "u1",
        email: "x@b.co",
        name: "Test",
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
    expect(screen.getByTestId("children")).toBeInTheDocument();
    expect(replace).not.toHaveBeenCalled();
  });
});
