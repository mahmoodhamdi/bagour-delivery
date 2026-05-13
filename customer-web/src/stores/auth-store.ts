import type { AuthTokens, BaseUser } from "@bagour/types";
import { create } from "zustand";
import { persist, createJSONStorage, type PersistOptions } from "zustand/middleware";

interface AuthState {
  /** Active access token kept in memory only. */
  accessToken: string | null;
  /** Lightweight user snapshot — full record fetched on demand via `api.auth.me()`. */
  user: BaseUser | null;
  /** Epoch ms — when the access token was issued. */
  issuedAt: number | null;
  /** True after we've hydrated the persisted snapshot from storage. */
  hydrated: boolean;
}

interface AuthActions {
  setSession: (input: { user: BaseUser; tokens: AuthTokens }) => void;
  setUser: (user: BaseUser) => void;
  setAccessToken: (token: string | null) => void;
  clear: () => void;
  markHydrated: () => void;
}

export type AuthStore = AuthState & AuthActions;

const initialState: AuthState = {
  accessToken: null,
  user: null,
  issuedAt: null,
  hydrated: false,
};

/**
 * Auth session store.
 *
 *  - **Access token** is kept ONLY in memory. We never write it to localStorage
 *    or cookies — the api-client refresh interceptor re-issues it from the
 *    httpOnly refresh cookie on cold reload.
 *  - **User snapshot** is persisted to localStorage so the header doesn't
 *    flash an anonymous state on cold reload while we wait for /auth/me.
 *  - **issuedAt** is persisted so we can decide whether to refresh proactively
 *    (Phase 1.5 polish).
 */
const persistOptions: PersistOptions<AuthStore, Pick<AuthStore, "user" | "issuedAt">> = {
  name: "bagour-auth",
  storage: createJSONStorage(() => localStorage),
  partialize: (state) => ({ user: state.user, issuedAt: state.issuedAt }),
  onRehydrateStorage: () => (state) => {
    state?.markHydrated();
  },
};

export const useAuthStore = create<AuthStore>()(
  persist<AuthStore, [], [], Pick<AuthStore, "user" | "issuedAt">>(
    (set) => ({
      ...initialState,
      setSession: ({ user, tokens }) =>
        set({
          user,
          accessToken: tokens.accessToken,
          issuedAt: Date.now(),
        }),
      setUser: (user) => set({ user }),
      setAccessToken: (accessToken) => set({ accessToken }),
      clear: () => set({ ...initialState, hydrated: true }),
      markHydrated: () => set({ hydrated: true }),
    }),
    persistOptions,
  ),
);

/** Selector helpers — prefer these over `useAuthStore.getState()` in components. */
export const selectIsAuthed = (s: AuthStore) => s.user !== null;
export const selectUser = (s: AuthStore) => s.user;
export const selectAccessToken = (s: AuthStore) => s.accessToken;
