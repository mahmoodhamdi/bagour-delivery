import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import Cookies from 'js-cookie';
import { STORAGE_KEYS } from '@/config/constants';
import { authApi } from '@/services/api';

export interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: string;
  isVerified: boolean;
}

export interface Admin {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'super_admin';
  avatar?: string;
  permissions: string[];
}

interface AuthState {
  user: User | null;
  admin: Admin | null;
  isAuthenticated: boolean;
  isLoading: boolean;

  // Actions
  setUser: (user: User) => void;
  setAdmin: (admin: Admin) => void;
  setAuth: (user: User, admin: Admin) => void;
  setAuthenticated: (isAuthenticated: boolean) => void;
  setLoading: (isLoading: boolean) => void;
  updateAdmin: (updates: Partial<Admin>) => void;
  checkAuth: () => Promise<void>;
  logout: () => Promise<void>;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      admin: null,
      isAuthenticated: false,
      isLoading: true,

      setUser: (user) => set({ user }),

      setAdmin: (admin) =>
        set({ admin, isAuthenticated: true, isLoading: false }),

      setAuth: (user, admin) =>
        set({ user, admin, isAuthenticated: true, isLoading: false }),

      setAuthenticated: (isAuthenticated) => set({ isAuthenticated }),

      setLoading: (isLoading) => set({ isLoading }),

      updateAdmin: (updates) =>
        set((state) => ({
          admin: state.admin ? { ...state.admin, ...updates } : null,
        })),

      checkAuth: async () => {
        const token = Cookies.get(STORAGE_KEYS.accessToken);

        if (!token) {
          set({ user: null, admin: null, isAuthenticated: false, isLoading: false });
          return;
        }

        try {
          const response = await authApi.getProfile();
          if (response.success && response.data) {
            set({
              user: response.data.user,
              admin: response.data.admin,
              isAuthenticated: true,
              isLoading: false,
            });
          } else {
            set({ user: null, admin: null, isAuthenticated: false, isLoading: false });
          }
        } catch {
          set({ user: null, admin: null, isAuthenticated: false, isLoading: false });
        }
      },

      logout: async () => {
        try {
          await authApi.logout();
        } catch {
          // Ignore logout errors
        } finally {
          Cookies.remove(STORAGE_KEYS.accessToken);
          Cookies.remove(STORAGE_KEYS.refreshToken);
          set({ user: null, admin: null, isAuthenticated: false, isLoading: false });
        }
      },
    }),
    {
      name: STORAGE_KEYS.adminData,
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        user: state.user,
        admin: state.admin,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
