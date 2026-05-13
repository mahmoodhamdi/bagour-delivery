import type { AuthTokens, BaseUser } from "@bagour/types";
import { create } from "zustand";
import { persist, createJSONStorage, type PersistOptions } from "zustand/middleware";

interface AuthState {
  /** Active access token kept in memory only. */
  accessToken: string | null;
  /** Lightweight user snapshot — full driver profile fetched on demand. */
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
 * Driver auth session store. Same shape as customer-web — separate localStorage
 * key (`bagour-driver-auth`) keeps the two PWAs from clobbering each other
 * when running side by side on the same machine.
 */
const persistOptions: PersistOptions<AuthStore, Pick<AuthStore, "user" | "issuedAt">> = {
  name: "bagour-driver-auth",
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

export const selectIsAuthed = (s: AuthStore) => s.user !== null;
export const selectUser = (s: AuthStore) => s.user;
export const selectAccessToken = (s: AuthStore) => s.accessToken;
