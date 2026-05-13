import { http, HttpResponse } from "msw";
import { setupServer } from "msw/node";
import { afterAll, afterEach, beforeAll, describe, expect, it, vi } from "vitest";

import { createApiClient } from "./index";
import type { AuthTokenStore } from "./client";
import { ApiError } from "./errors";
import { createDefaultHandlers } from "./test/handlers";

const BASE_URL = "http://localhost:5000";

function makeTokenStore(initial: string | null = "initial-access"): AuthTokenStore & {
  current: { access: string | null; refresh: string | null };
  signOuts: number;
  refreshCalls: number;
} {
  const state: { access: string | null; refresh: string | null } = {
    access: initial,
    refresh: "initial-refresh",
  };
  return {
    current: state,
    signOuts: 0,
    refreshCalls: 0,
    getAccessToken: () => state.access,
    getRefreshToken: () => state.refresh,
    setTokens: ({ accessToken, refreshToken }) => {
      state.access = accessToken;
      if (refreshToken) state.refresh = refreshToken;
    },
    clear: function () {
      state.access = null;
      state.refresh = null;
      this.signOuts += 1;
    },
  };
}

describe("createApiClient", () => {
  const server = setupServer(...createDefaultHandlers(BASE_URL));

  beforeAll(() => server.listen({ onUnhandledRequest: "error" }));
  afterEach(() => server.resetHandlers(...createDefaultHandlers(BASE_URL)));
  afterAll(() => server.close());

  it("binds all endpoint namespaces", () => {
    const api = createApiClient({ baseURL: BASE_URL, auth: null });
    expect(api.auth).toBeDefined();
    expect(api.customer).toBeDefined();
    expect(api.restaurants).toBeDefined();
    expect(api.orders).toBeDefined();
    expect(api.drivers).toBeDefined();
    expect(api.coupons).toBeDefined();
    expect(api.notifications).toBeDefined();
    expect(api.reviews).toBeDefined();
    expect(api.uploads).toBeDefined();
  });

  it("login returns user + tokens", async () => {
    const api = createApiClient({ baseURL: BASE_URL, auth: null });
    const result = await api.auth.login({ email: "a@b.co", password: "secret123" });
    expect(result.user.email).toMatch(/@bagour\.test$/);
    expect(result.tokens.accessToken).toBe("test-access-token");
  });

  it("injects bearer token from AuthTokenStore", async () => {
    const tokens = makeTokenStore("the-token");
    const api = createApiClient({ baseURL: BASE_URL, auth: tokens });

    let seenAuth: string | null = null;
    server.use(
      http.get(`${BASE_URL}/api/v1/auth/me`, ({ request }) => {
        seenAuth = request.headers.get("authorization");
        return HttpResponse.json({ success: true, data: { id: "u1" } });
      }),
    );

    await api.auth.me();
    expect(seenAuth).toBe("Bearer the-token");
  });

  it("refreshes once on 401 and retries the original request", async () => {
    const tokens = makeTokenStore("expired");
    const onSignOut = vi.fn();
    const api = createApiClient({ baseURL: BASE_URL, auth: tokens, onSignOut });

    let attempts = 0;
    server.use(
      http.get(`${BASE_URL}/api/v1/auth/me`, ({ request }) => {
        attempts += 1;
        const auth = request.headers.get("authorization");
        if (auth === "Bearer expired") {
          return HttpResponse.json(
            { success: false, message: "Unauthorized" },
            { status: 401 },
          );
        }
        return HttpResponse.json({ success: true, data: { id: "u1", email: "x@y.z" } });
      }),
      http.post(`${BASE_URL}/api/v1/auth/refresh-token`, () => {
        tokens.refreshCalls += 1;
        return HttpResponse.json({
          success: true,
          data: { accessToken: "fresh", refreshToken: "fresh-refresh" },
        });
      }),
    );

    const me = await api.auth.me();
    expect(me).toBeDefined();
    expect(attempts).toBe(2);
    expect(tokens.refreshCalls).toBe(1);
    expect(tokens.current.access).toBe("fresh");
    expect(onSignOut).not.toHaveBeenCalled();
  });

  it("signs out when refresh itself fails", async () => {
    const tokens = makeTokenStore("expired");
    const onSignOut = vi.fn();
    const api = createApiClient({ baseURL: BASE_URL, auth: tokens, onSignOut });

    server.use(
      http.get(`${BASE_URL}/api/v1/auth/me`, () =>
        HttpResponse.json({ success: false, message: "Unauthorized" }, { status: 401 }),
      ),
      http.post(`${BASE_URL}/api/v1/auth/refresh-token`, () =>
        HttpResponse.json({ success: false, message: "Invalid refresh" }, { status: 401 }),
      ),
    );

    await expect(api.auth.me()).rejects.toBeInstanceOf(ApiError);
    expect(tokens.signOuts).toBe(1);
    expect(onSignOut).toHaveBeenCalledOnce();
    expect(tokens.current.access).toBeNull();
  });

  it("normalizes 4xx errors into ApiError with fieldErrors", async () => {
    const api = createApiClient({ baseURL: BASE_URL, auth: null });

    server.use(
      http.post(`${BASE_URL}/api/v1/auth/login`, () =>
        HttpResponse.json(
          {
            success: false,
            message: "Validation failed",
            errors: { email: ["invalid_email"], password: ["password_too_short"] },
            statusCode: 422,
          },
          { status: 422 },
        ),
      ),
    );

    try {
      await api.auth.login({ email: "bad", password: "x" });
      throw new Error("should have thrown");
    } catch (e) {
      expect(e).toBeInstanceOf(ApiError);
      const err = e as ApiError;
      expect(err.statusCode).toBe(422);
      expect(err.message).toBe("Validation failed");
      expect(err.fieldErrors?.email).toContain("invalid_email");
      expect(err.isAuthError).toBe(false);
      expect(err.isRetryable).toBe(false);
    }
  });

  it("flags 5xx as retryable", async () => {
    const api = createApiClient({ baseURL: BASE_URL, auth: null });
    server.use(
      http.get(`${BASE_URL}/api/v1/auth/me`, () =>
        HttpResponse.json({ success: false, message: "boom" }, { status: 503 }),
      ),
    );

    await expect(api.auth.me()).rejects.toMatchObject({
      statusCode: 503,
      isRetryable: true,
    });
  });

  it("does not attempt refresh when auth store is null", async () => {
    const api = createApiClient({ baseURL: BASE_URL, auth: null });

    server.use(
      http.get(`${BASE_URL}/api/v1/auth/me`, () =>
        HttpResponse.json({ success: false, message: "no" }, { status: 401 }),
      ),
    );

    await expect(api.auth.me()).rejects.toMatchObject({ statusCode: 401, isAuthError: true });
  });

  it("forwards default headers", async () => {
    const api = createApiClient({
      baseURL: BASE_URL,
      auth: null,
      defaultHeaders: { "x-app-version": "2026.05" },
    });

    let seen: string | null = null;
    server.use(
      http.get(`${BASE_URL}/api/v1/auth/me`, ({ request }) => {
        seen = request.headers.get("x-app-version");
        return HttpResponse.json({ success: true, data: { id: "u" } });
      }),
    );

    await api.auth.me();
    expect(seen).toBe("2026.05");
  });
});
