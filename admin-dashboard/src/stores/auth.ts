import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import Cookies from 'js-cookie';
import { STORAGE_KEYS } from '@/config/constants';

export interface Admin {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'super_admin';
  avatar?: string;
  permissions: string[];
}

interface AuthState {
  admin: Admin | null;
  isAuthenticated: boolean;
  isLoading: boolean;

  // Actions
  setAdmin: (admin: Admin) => void;
  setAuthenticated: (isAuthenticated: boolean) => void;
  setLoading: (isLoading: boolean) => void;
  updateAdmin: (updates: Partial<Admin>) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      admin: null,
      isAuthenticated: false,
      isLoading: true,

      setAdmin: (admin) =>
        set({ admin, isAuthenticated: true, isLoading: false }),

      setAuthenticated: (isAuthenticated) => set({ isAuthenticated }),

      setLoading: (isLoading) => set({ isLoading }),

      updateAdmin: (updates) =>
        set((state) => ({
          admin: state.admin ? { ...state.admin, ...updates } : null,
        })),

      logout: () => {
        Cookies.remove(STORAGE_KEYS.accessToken);
        Cookies.remove(STORAGE_KEYS.refreshToken);
        set({ admin: null, isAuthenticated: false, isLoading: false });
      },
    }),
    {
      name: STORAGE_KEYS.adminData,
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        admin: state.admin,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
