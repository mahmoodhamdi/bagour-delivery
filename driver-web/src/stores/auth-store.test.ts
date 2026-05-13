import type { AuthTokens, BaseUser } from "@bagour/types";
import { beforeEach, describe, expect, it } from "vitest";

import { selectIsAuthed, useAuthStore } from "./auth-store";

const fakeUser: BaseUser = {
  id: "u-1",
  name: "Captain Test",
  email: "captain@test.com",
  phone: "01010101010",
  role: "driver",
  isActive: true,
  isBlocked: false,
  isEmailVerified: true,
  isPhoneVerified: true,
  fcmTokens: [],
  createdAt: "2026-01-01T00:00:00.000Z",
  updatedAt: "2026-01-01T00:00:00.000Z",
};

const fakeTokens: AuthTokens = {
  accessToken: "access-1",
  refreshToken: "refresh-1",
};

describe("driver auth store", () => {
  beforeEach(() => {
    useAuthStore.setState({
      accessToken: null,
      user: null,
      issuedAt: null,
      hydrated: false,
    });
  });

  it("setSession stores user + access token + issuedAt", () => {
    useAuthStore.getState().setSession({ user: fakeUser, tokens: fakeTokens });
    const s = useAuthStore.getState();
    expect(s.user).toEqual(fakeUser);
    expect(s.accessToken).toBe("access-1");
    expect(s.issuedAt).toBeGreaterThan(0);
  });

  it("clear wipes state but keeps hydrated=true so the UI doesn't flash", () => {
    useAuthStore.getState().setSession({ user: fakeUser, tokens: fakeTokens });
    useAuthStore.getState().clear();
    const s = useAuthStore.getState();
    expect(s.user).toBeNull();
    expect(s.accessToken).toBeNull();
    expect(s.hydrated).toBe(true);
  });

  it("selectIsAuthed reflects whether a user is set", () => {
    expect(selectIsAuthed(useAuthStore.getState())).toBe(false);
    useAuthStore.getState().setSession({ user: fakeUser, tokens: fakeTokens });
    expect(selectIsAuthed(useAuthStore.getState())).toBe(true);
  });
});
