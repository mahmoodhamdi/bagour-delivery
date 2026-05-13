import { afterEach, beforeEach, describe, expect, it } from "vitest";

import { selectIsAuthed, selectUser, useAuthStore } from "./auth-store";

const fakeUser = {
  id: "u_1",
  email: "x@bagour.test",
  phone: "01012345678",
  name: "Tester",
  role: "customer" as const,
  isActive: true,
  isBlocked: false,
  isEmailVerified: true,
  isPhoneVerified: true,
  fcmTokens: [],
  createdAt: "2026-05-13T00:00:00.000Z",
  updatedAt: "2026-05-13T00:00:00.000Z",
};

const fakeTokens = { accessToken: "tok_a", refreshToken: "tok_r", expiresIn: 3600 };

describe("auth-store", () => {
  beforeEach(() => {
    localStorage.clear();
    useAuthStore.setState({ user: null, accessToken: null, issuedAt: null, hydrated: false });
  });

  afterEach(() => {
    localStorage.clear();
  });

  it("starts unauthenticated", () => {
    const s = useAuthStore.getState();
    expect(selectIsAuthed(s)).toBe(false);
    expect(selectUser(s)).toBeNull();
    expect(s.accessToken).toBeNull();
  });

  it("setSession stores the user + access token + issuedAt", () => {
    useAuthStore.getState().setSession({ user: fakeUser, tokens: fakeTokens });
    const s = useAuthStore.getState();
    expect(s.user).toEqual(fakeUser);
    expect(s.accessToken).toBe("tok_a");
    expect(s.issuedAt).toBeGreaterThan(0);
    expect(selectIsAuthed(s)).toBe(true);
  });

  it("setAccessToken updates the in-memory token without touching the user", () => {
    useAuthStore.getState().setSession({ user: fakeUser, tokens: fakeTokens });
    useAuthStore.getState().setAccessToken("fresh");
    expect(useAuthStore.getState().accessToken).toBe("fresh");
    expect(useAuthStore.getState().user).toEqual(fakeUser);
  });

  it("clear() resets all session fields and marks hydrated", () => {
    useAuthStore.getState().setSession({ user: fakeUser, tokens: fakeTokens });
    useAuthStore.getState().clear();
    const s = useAuthStore.getState();
    expect(s.user).toBeNull();
    expect(s.accessToken).toBeNull();
    expect(s.issuedAt).toBeNull();
    expect(s.hydrated).toBe(true);
  });

  it("persists ONLY user + issuedAt (never the access token)", () => {
    useAuthStore.getState().setSession({ user: fakeUser, tokens: fakeTokens });
    const persisted = JSON.parse(localStorage.getItem("bagour-auth") ?? "{}") as {
      state: Record<string, unknown>;
    };
    expect(persisted.state.user).toEqual(fakeUser);
    expect(persisted.state.issuedAt).toBeTypeOf("number");
    expect(persisted.state).not.toHaveProperty("accessToken");
  });

  it("setUser updates the snapshot without changing tokens", () => {
    useAuthStore.getState().setSession({ user: fakeUser, tokens: fakeTokens });
    const renamed = { ...fakeUser, name: "Renamed" };
    useAuthStore.getState().setUser(renamed);
    expect(useAuthStore.getState().user?.name).toBe("Renamed");
    expect(useAuthStore.getState().accessToken).toBe("tok_a");
  });
});
