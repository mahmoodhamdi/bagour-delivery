import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import Cookies from 'js-cookie';
import { STORAGE_KEYS } from '@/config/constants';

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
  };
  cuisineTypes: string[];
  rating: number;
  totalOrders: number;
}

interface AuthState {
  restaurant: Restaurant | null;
  isAuthenticated: boolean;
  isLoading: boolean;

  // Actions
  setRestaurant: (restaurant: Restaurant) => void;
  setAuthenticated: (isAuthenticated: boolean) => void;
  setLoading: (isLoading: boolean) => void;
  updateRestaurant: (updates: Partial<Restaurant>) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      restaurant: null,
      isAuthenticated: false,
      isLoading: true,

      setRestaurant: (restaurant) =>
        set({ restaurant, isAuthenticated: true, isLoading: false }),

      setAuthenticated: (isAuthenticated) => set({ isAuthenticated }),

      setLoading: (isLoading) => set({ isLoading }),

      updateRestaurant: (updates) =>
        set((state) => ({
          restaurant: state.restaurant
            ? { ...state.restaurant, ...updates }
            : null,
        })),

      logout: () => {
        Cookies.remove(STORAGE_KEYS.accessToken);
        Cookies.remove(STORAGE_KEYS.refreshToken);
        set({ restaurant: null, isAuthenticated: false, isLoading: false });
      },
    }),
    {
      name: STORAGE_KEYS.restaurantData,
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        restaurant: state.restaurant,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
