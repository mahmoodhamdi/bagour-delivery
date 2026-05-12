import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import Cookies from 'js-cookie';
import { STORAGE_KEYS } from '@/config/constants';
import { authApi } from '@/lib/api';

export interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: string;
  isVerified: boolean;
}

export interface Restaurant {
  id: string;
  name: string;
  nameEn?: string;
  email: string;
  phone: string;
  logo?: string;
  coverImage?: string;
  status: 'pending' | 'approved' | 'rejected' | 'suspended';
  isOpen: boolean;
  address: {
    street: string;
    area: string;
    city: string;
    coordinates?: {
      lat: number;
      lng: number;
    };
  };
  cuisineTypes: string[];
  rating: number;
  totalOrders: number;
  deliveryFee?: number;
  minimumOrder?: number;
  averageDeliveryTime?: number;
}

interface AuthState {
  user: User | null;
  restaurant: Restaurant | null;
  isAuthenticated: boolean;
  isLoading: boolean;

  // Actions
  setUser: (user: User) => void;
  setRestaurant: (restaurant: Restaurant) => void;
  setAuth: (user: User, restaurant: Restaurant) => void;
  setAuthenticated: (isAuthenticated: boolean) => void;
  setLoading: (isLoading: boolean) => void;
  updateRestaurant: (updates: Partial<Restaurant>) => void;
  checkAuth: () => Promise<void>;
  logout: () => Promise<void>;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      restaurant: null,
      isAuthenticated: false,
      // isLoading stays true on first render so the dashboard layout's auth
      // check waits for persist's rehydration before deciding whether to
      // bounce to /login. onRehydrateStorage in the persist config below
      // flips it to false once localStorage has finished loading.
      isLoading: true,

      setUser: (user) => set({ user }),

      setRestaurant: (restaurant) =>
        set({ restaurant, isAuthenticated: true, isLoading: false }),

      setAuth: (user, restaurant) =>
        set({ user, restaurant, isAuthenticated: true, isLoading: false }),

      setAuthenticated: (isAuthenticated) => set({ isAuthenticated }),

      setLoading: (isLoading) => set({ isLoading }),

      updateRestaurant: (updates) =>
        set((state) => ({
          restaurant: state.restaurant
            ? { ...state.restaurant, ...updates }
            : null,
        })),

      checkAuth: async () => {
        const token = Cookies.get(STORAGE_KEYS.accessToken);

        if (!token) {
          set({ user: null, restaurant: null, isAuthenticated: false, isLoading: false });
          return;
        }

        try {
          const response = await authApi.getProfile();
          if (response.success && response.data) {
            set({
              user: response.data.user,
              restaurant: response.data.restaurant,
              isAuthenticated: true,
              isLoading: false,
            });
          } else {
            set({ user: null, restaurant: null, isAuthenticated: false, isLoading: false });
          }
        } catch {
          set({ user: null, restaurant: null, isAuthenticated: false, isLoading: false });
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
          set({ user: null, restaurant: null, isAuthenticated: false, isLoading: false });
        }
      },
    }),
    {
      name: STORAGE_KEYS.restaurantData,
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        user: state.user,
        restaurant: state.restaurant,
        isAuthenticated: state.isAuthenticated,
      }),
      // Without this the persist middleware loads user/restaurant/
      // isAuthenticated from localStorage but never touches isLoading, so
      // the dashboard layout sees `isLoading: true` forever and the
      // useEffect that bounces unauthenticated users never fires for
      // authenticated ones either. Flip isLoading off as soon as
      // rehydration finishes — success or failure.
      onRehydrateStorage: () => (state) => {
        if (state) state.isLoading = false;
      },
    }
  )
);
