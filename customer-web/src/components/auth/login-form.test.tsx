import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { ApiError } from "@bagour/api-client";

import messagesEn from "../../../messages/en.json";
import { LoginForm } from "./login-form";

const login = vi.fn();
const push = vi.fn();

vi.mock("@/lib/api-context", () => ({
  useApi: () => ({ auth: { login } }),
}));

vi.mock("@/i18n/navigation", () => ({
  Link: ({ children, href }: React.PropsWithChildren<{ href: string }>) => (
    <a href={href}>{children}</a>
  ),
  useRouter: () => ({ push }),
}));

const setSession = vi.fn();
vi.mock("@/stores/auth-store", () => ({
  useAuthStore: (selector: (s: { setSession: typeof setSession }) => unknown): unknown =>
    selector({ setSession }),
}));

const toastSuccess = vi.fn();
vi.mock("sonner", () => ({
  toast: {
    success: (...args: unknown[]) => {
      toastSuccess(...args);
    },
  },
}));

function renderForm() {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={qc}>
      <NextIntlClientProvider locale="en" messages={messagesEn}>
        <LoginForm />
      </NextIntlClientProvider>
    </QueryClientProvider>,
  );
}

describe("LoginForm", () => {
  beforeEach(() => {
    login.mockReset();
    push.mockReset();
    setSession.mockReset();
    toastSuccess.mockReset();
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it("renders email + password inputs + submit", () => {
    renderForm();
    expect(screen.getByTestId("login-email")).toBeInTheDocument();
    expect(screen.getByTestId("login-password")).toBeInTheDocument();
    expect(screen.getByTestId("login-submit")).toBeInTheDocument();
  });

  it("shows validation errors when fields are empty", async () => {
    const user = userEvent.setup();
    renderForm();
    await user.click(screen.getByTestId("login-submit"));
    await waitFor(() => {
      expect(screen.getByText(messagesEn.Auth.errors.emailRequired)).toBeInTheDocument();
      expect(screen.getByText(messagesEn.Auth.errors.passwordTooShort)).toBeInTheDocument();
    });
    expect(login).not.toHaveBeenCalled();
  });

  it("calls login and routes home on success", async () => {
    login.mockResolvedValueOnce({
      user: { id: "u1", email: "x@b.co", name: "User", role: "customer" },
      tokens: { accessToken: "tok" },
    });

    const user = userEvent.setup();
    renderForm();
    await user.type(screen.getByTestId("login-email"), "x@b.co");
    await user.type(screen.getByTestId("login-password"), "secret123");
    await user.click(screen.getByTestId("login-submit"));

    await waitFor(() => {
      expect(login).toHaveBeenCalledWith({ email: "x@b.co", password: "secret123" });
      expect(setSession).toHaveBeenCalled();
      expect(toastSuccess).toHaveBeenCalledWith(messagesEn.Auth.toasts.signedIn);
      expect(push).toHaveBeenCalledWith("/");
    });
  });

  it("shows the invalid credentials banner on 401", async () => {
    login.mockRejectedValueOnce(new ApiError({ message: "no", statusCode: 401 }));

    const user = userEvent.setup();
    renderForm();
    await user.type(screen.getByTestId("login-email"), "x@b.co");
    await user.type(screen.getByTestId("login-password"), "secret123");
    await user.click(screen.getByTestId("login-submit"));

    await waitFor(() => {
      expect(screen.getByTestId("login-server-error")).toHaveTextContent(
        messagesEn.Auth.errors.invalidCredentials,
      );
    });
    expect(setSession).not.toHaveBeenCalled();
  });

  it("surfaces server field errors on 422", async () => {
    login.mockRejectedValueOnce(
      new ApiError({
        message: "bad",
        statusCode: 422,
        fieldErrors: { email: ["Auth.errors.invalidEmail"] },
      }),
    );

    const user = userEvent.setup();
    renderForm();
    await user.type(screen.getByTestId("login-email"), "x@b.co");
    await user.type(screen.getByTestId("login-password"), "secret123");
    await user.click(screen.getByTestId("login-submit"));

    await waitFor(() => {
      expect(screen.getByText(messagesEn.Auth.errors.invalidEmail)).toBeInTheDocument();
    });
  });
});
