import { create } from 'zustand';

export interface DashboardStats {
  totalUsers: number;
  totalRestaurants: number;
  totalDrivers: number;
  totalOrders: number;
  todayOrders: number;
  todayRevenue: number;
  pendingRestaurants: number;
  pendingDrivers: number;
  activeOrders: number;
  monthlyRevenue: number;
}

export interface RevenueData {
  date: string;
  revenue: number;
  orders: number;
  commission: number;
}

export interface TopRestaurant {
  id: string;
  name: string;
  logo?: string;
  ordersCount: number;
  revenue: number;
  rating: number;
}

export interface TopDriver {
  id: string;
  name: string;
  avatar?: string;
  deliveriesCount: number;
  rating: number;
  earnings: number;
}

interface DashboardState {
  stats: DashboardStats | null;
  revenueData: RevenueData[];
  topRestaurants: TopRestaurant[];
  topDrivers: TopDriver[];
  isLoading: boolean;
  error: string | null;

  // Actions
  setStats: (stats: DashboardStats) => void;
  setRevenueData: (data: RevenueData[]) => void;
  setTopRestaurants: (restaurants: TopRestaurant[]) => void;
  setTopDrivers: (drivers: TopDriver[]) => void;
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
}

export const useDashboardStore = create<DashboardState>((set) => ({
  stats: null,
  revenueData: [],
  topRestaurants: [],
  topDrivers: [],
  isLoading: false,
  error: null,

  setStats: (stats) => set({ stats }),
  setRevenueData: (revenueData) => set({ revenueData }),
  setTopRestaurants: (topRestaurants) => set({ topRestaurants }),
  setTopDrivers: (topDrivers) => set({ topDrivers }),
  setLoading: (isLoading) => set({ isLoading }),
  setError: (error) => set({ error }),
}));
