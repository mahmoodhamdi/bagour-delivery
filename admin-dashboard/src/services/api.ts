import axios, { AxiosError, AxiosInstance, InternalAxiosRequestConfig } from 'axios';
import Cookies from 'js-cookie';
import { API_CONFIG, STORAGE_KEYS, API_ENDPOINTS } from '@/config/constants';

// Types
export interface ApiResponse<T = unknown> {
  success: boolean;
  message?: string;
  data?: T;
  errors?: Record<string, string[]>;
}

export interface Admin {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'super_admin';
  avatar?: string;
  permissions: string[];
}

export interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: string;
  isVerified: boolean;
}

export interface AuthResponse {
  user: User;
  admin: Admin;
  accessToken: string;
  refreshToken: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

// Create axios instance
const api: AxiosInstance = axios.create({
  baseURL: API_CONFIG.baseUrl,
  timeout: API_CONFIG.timeout,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = Cookies.get(STORAGE_KEYS.accessToken);
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle token refresh
api.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & {
      _retry?: boolean;
    };

    // If the error is 401 and we haven't already retried
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = Cookies.get(STORAGE_KEYS.refreshToken);
        if (!refreshToken) {
          throw new Error('No refresh token');
        }

        const response = await axios.post<ApiResponse<{ accessToken: string; refreshToken: string }>>(
          `${API_CONFIG.baseUrl}${API_ENDPOINTS.refreshToken}`,
          { refreshToken }
        );

        if (response.data.success && response.data.data) {
          const { accessToken, refreshToken: newRefreshToken } = response.data.data;

          Cookies.set(STORAGE_KEYS.accessToken, accessToken, { expires: 7 });
          Cookies.set(STORAGE_KEYS.refreshToken, newRefreshToken, { expires: 30 });

          if (originalRequest.headers) {
            originalRequest.headers.Authorization = `Bearer ${accessToken}`;
          }

          return api(originalRequest);
        }
      } catch (refreshError) {
        // Clear tokens and redirect to login
        Cookies.remove(STORAGE_KEYS.accessToken);
        Cookies.remove(STORAGE_KEYS.refreshToken);
        localStorage.removeItem(STORAGE_KEYS.adminData);

        if (typeof window !== 'undefined') {
          window.location.href = '/login';
        }

        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default api;

// Auth API functions
export const authApi = {
  login: async (data: LoginRequest): Promise<ApiResponse<AuthResponse>> => {
    const response = await api.post<ApiResponse<AuthResponse>>(API_ENDPOINTS.login, data);
    return response.data;
  },

  logout: async (): Promise<void> => {
    try {
      await api.post(API_ENDPOINTS.logout);
    } catch {
      // Ignore logout errors
    }
  },

  getProfile: async (): Promise<ApiResponse<{ user: User; admin: Admin }>> => {
    const response = await api.get<ApiResponse<{ user: User; admin: Admin }>>('/admin/profile');
    return response.data;
  },
};

// Types for admin API
export interface DashboardStats {
  totalUsers: number;
  totalRestaurants: number;
  totalDrivers: number;
  totalOrders: number;
  todayOrders: number;
  activeOrders: number;
  todayRevenue: number;
  weekRevenue: number;
  monthlyRevenue: number;
  pendingRestaurants: number;
  pendingDrivers: number;
  onlineDrivers: number;
  deliveredToday: number;
  cancelledToday: number;
}

export interface RevenueData {
  date: string;
  revenue: number;
  orders: number;
  commission: number;
}

export interface RecentOrder {
  _id: string;
  orderNumber: string;
  status: string;
  totalAmount: number;
  createdAt: string;
  customerId?: { name: string; phone: string };
  restaurantId?: { name: string; logo?: string };
  driverId?: { name: string; phone: string };
}

export interface TopRestaurant {
  _id: string;
  name: string;
  logo?: string;
  totalOrders: number;
  totalRevenue: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    total: number;
    page: number;
    limit: number;
    pages: number;
  };
}

export interface Restaurant {
  _id: string;
  name: string;
  slug: string;
  description?: string;
  logo?: string;
  coverImage?: string;
  phone: string;
  email?: string;
  status: 'pending' | 'approved' | 'rejected' | 'suspended';
  isOpen: boolean;
  rating: number;
  totalRatings: number;
  address: {
    street?: string;
    city?: string;
    area?: string;
    coordinates?: { lat: number; lng: number };
  };
  ownerId?: { _id: string; name: string; email: string; phone: string };
  createdAt: string;
  approvedAt?: string;
  rejectionReason?: string;
  suspensionReason?: string;
}

export interface Driver {
  _id: string;
  userId?: { _id: string; name: string; email: string; phone: string };
  name?: string;
  phone?: string;
  avatar?: string;
  vehicleType: 'motorcycle' | 'car' | 'bicycle';
  vehiclePlate?: string;
  status: 'pending' | 'approved' | 'rejected' | 'suspended';
  isOnline: boolean;
  isAvailable: boolean;
  rating: number;
  totalDeliveries: number;
  totalEarnings: number;
  currentLocation?: { lat: number; lng: number };
  createdAt: string;
  approvedAt?: string;
  rejectionReason?: string;
  suspensionReason?: string;
}

export interface Customer {
  _id: string;
  name: string;
  email: string;
  phone: string;
  avatar?: string;
  role: string;
  isVerified: boolean;
  isBlocked: boolean;
  createdAt: string;
  lastLoginAt?: string;
}

export interface Order {
  _id: string;
  orderNumber: string;
  customerId: { _id: string; name: string; phone: string };
  restaurantId: { _id: string; name: string; logo?: string };
  driverId?: { _id: string; name: string; phone: string };
  items: Array<{
    menuItemId: string;
    name: string;
    quantity: number;
    price: number;
    options?: Array<{ name: string; price: number }>;
  }>;
  status: string;
  subtotal: number;
  deliveryFee: number;
  discount: number;
  totalAmount: number;
  paymentMethod: string;
  paymentStatus: string;
  deliveryAddress: {
    label?: string;
    street?: string;
    city?: string;
    coordinates?: { lat: number; lng: number };
  };
  notes?: string;
  createdAt: string;
  confirmedAt?: string;
  deliveredAt?: string;
  cancelledAt?: string;
  cancellationReason?: string;
}

export interface Zone {
  _id: string;
  name: string;
  nameAr: string;
  deliveryFee: number;
  minOrderAmount: number;
  isActive: boolean;
  coordinates?: {
    type: 'Polygon';
    coordinates: number[][][];
  };
  createdAt: string;
}

export interface AppSettings {
  _id?: string;
  appName?: string;
  appNameAr?: string;
  supportEmail?: string;
  supportPhone?: string;
  defaultDeliveryFee?: number;
  minOrderAmount?: number;
  platformFeePercentage?: number;
  driverCommissionPercentage?: number;
  maxDeliveryRadius?: number;
  orderCancellationTimeout?: number;
  maintenanceMode?: boolean;
  maintenanceMessage?: string;
  socialLinks?: {
    facebook?: string;
    twitter?: string;
    instagram?: string;
    whatsapp?: string;
  };
  paymentSettings?: {
    cashOnDelivery?: boolean;
    onlinePayment?: boolean;
    walletPayment?: boolean;
  };
  notificationSettings?: {
    emailNotifications?: boolean;
    pushNotifications?: boolean;
    smsNotifications?: boolean;
  };
}

export interface FinancialSummary {
  revenue: {
    totalRevenue: number;
    totalDeliveryFees: number;
    totalPlatformFees: number;
    orderCount: number;
  };
  transactions: Array<{
    _id: string;
    total: number;
    count: number;
  }>;
}

// Dashboard API
export const dashboardApi = {
  getStats: async (): Promise<ApiResponse<DashboardStats>> => {
    const response = await api.get<ApiResponse<DashboardStats>>(API_ENDPOINTS.dashboardStats);
    return response.data;
  },

  getRevenueChart: async (days: number = 30): Promise<ApiResponse<RevenueData[]>> => {
    const response = await api.get<ApiResponse<RevenueData[]>>(API_ENDPOINTS.revenueReport, {
      params: { days },
    });
    return response.data;
  },

  getRecentOrders: async (limit: number = 10): Promise<ApiResponse<RecentOrder[]>> => {
    const response = await api.get<ApiResponse<RecentOrder[]>>('/admin/dashboard/recent-orders', {
      params: { limit },
    });
    return response.data;
  },

  getTopRestaurants: async (limit: number = 5): Promise<ApiResponse<TopRestaurant[]>> => {
    const response = await api.get<ApiResponse<TopRestaurant[]>>('/admin/dashboard/top-restaurants', {
      params: { limit },
    });
    return response.data;
  },
};

// Users API
export const usersApi = {
  getUsers: async (params?: {
    page?: number;
    limit?: number;
    search?: string;
    role?: string;
    status?: 'active' | 'blocked';
  }): Promise<ApiResponse<PaginatedResponse<Customer>>> => {
    const response = await api.get<ApiResponse<PaginatedResponse<Customer>>>(API_ENDPOINTS.users, { params });
    return response.data;
  },

  getUserById: async (id: string): Promise<ApiResponse<Customer>> => {
    const response = await api.get<ApiResponse<Customer>>(`${API_ENDPOINTS.users}/${id}`);
    return response.data;
  },

  blockUser: async (id: string): Promise<ApiResponse<Customer>> => {
    const response = await api.put<ApiResponse<Customer>>(`${API_ENDPOINTS.users}/${id}/block`);
    return response.data;
  },

  unblockUser: async (id: string): Promise<ApiResponse<Customer>> => {
    const response = await api.put<ApiResponse<Customer>>(`${API_ENDPOINTS.users}/${id}/unblock`);
    return response.data;
  },

  deleteUser: async (id: string): Promise<ApiResponse<null>> => {
    const response = await api.delete<ApiResponse<null>>(`${API_ENDPOINTS.users}/${id}`);
    return response.data;
  },
};

// Restaurants API
export const restaurantsApi = {
  getRestaurants: async (params?: {
    page?: number;
    limit?: number;
    search?: string;
    status?: 'pending' | 'approved' | 'rejected' | 'suspended';
  }): Promise<ApiResponse<PaginatedResponse<Restaurant>>> => {
    const response = await api.get<ApiResponse<PaginatedResponse<Restaurant>>>(API_ENDPOINTS.restaurants, { params });
    return response.data;
  },

  getRestaurantById: async (id: string): Promise<ApiResponse<Restaurant>> => {
    const response = await api.get<ApiResponse<Restaurant>>(`${API_ENDPOINTS.restaurants}/${id}`);
    return response.data;
  },

  approveRestaurant: async (id: string): Promise<ApiResponse<Restaurant>> => {
    const response = await api.put<ApiResponse<Restaurant>>(`${API_ENDPOINTS.restaurants}/${id}/approve`);
    return response.data;
  },

  rejectRestaurant: async (id: string, reason: string): Promise<ApiResponse<Restaurant>> => {
    const response = await api.put<ApiResponse<Restaurant>>(`${API_ENDPOINTS.restaurants}/${id}/reject`, { reason });
    return response.data;
  },

  suspendRestaurant: async (id: string, reason: string): Promise<ApiResponse<Restaurant>> => {
    const response = await api.put<ApiResponse<Restaurant>>(`${API_ENDPOINTS.restaurants}/${id}/suspend`, { reason });
    return response.data;
  },

  activateRestaurant: async (id: string): Promise<ApiResponse<Restaurant>> => {
    const response = await api.put<ApiResponse<Restaurant>>(`${API_ENDPOINTS.restaurants}/${id}/activate`);
    return response.data;
  },
};

// Drivers API
export const driversApi = {
  getDrivers: async (params?: {
    page?: number;
    limit?: number;
    search?: string;
    status?: 'pending' | 'approved' | 'rejected' | 'suspended';
    isOnline?: string;
  }): Promise<ApiResponse<PaginatedResponse<Driver>>> => {
    const response = await api.get<ApiResponse<PaginatedResponse<Driver>>>(API_ENDPOINTS.drivers, { params });
    return response.data;
  },

  getDriverById: async (id: string): Promise<ApiResponse<Driver>> => {
    const response = await api.get<ApiResponse<Driver>>(`${API_ENDPOINTS.drivers}/${id}`);
    return response.data;
  },

  approveDriver: async (id: string): Promise<ApiResponse<Driver>> => {
    const response = await api.put<ApiResponse<Driver>>(`${API_ENDPOINTS.drivers}/${id}/approve`);
    return response.data;
  },

  rejectDriver: async (id: string, reason: string): Promise<ApiResponse<Driver>> => {
    const response = await api.put<ApiResponse<Driver>>(`${API_ENDPOINTS.drivers}/${id}/reject`, { reason });
    return response.data;
  },

  suspendDriver: async (id: string, reason: string): Promise<ApiResponse<Driver>> => {
    const response = await api.put<ApiResponse<Driver>>(`${API_ENDPOINTS.drivers}/${id}/suspend`, { reason });
    return response.data;
  },

  activateDriver: async (id: string): Promise<ApiResponse<Driver>> => {
    const response = await api.put<ApiResponse<Driver>>(`${API_ENDPOINTS.drivers}/${id}/activate`);
    return response.data;
  },
};

// Orders API
export const ordersApi = {
  getOrders: async (params?: {
    page?: number;
    limit?: number;
    status?: string;
    startDate?: string;
    endDate?: string;
  }): Promise<ApiResponse<PaginatedResponse<Order>>> => {
    const response = await api.get<ApiResponse<PaginatedResponse<Order>>>(API_ENDPOINTS.orders, { params });
    return response.data;
  },

  getOrderById: async (id: string): Promise<ApiResponse<Order>> => {
    const response = await api.get<ApiResponse<Order>>(`${API_ENDPOINTS.orders}/${id}`);
    return response.data;
  },
};

// Zones API
export const zonesApi = {
  getZones: async (): Promise<ApiResponse<Zone[]>> => {
    const response = await api.get<ApiResponse<Zone[]>>(API_ENDPOINTS.zones);
    return response.data;
  },

  getZoneById: async (id: string): Promise<ApiResponse<Zone>> => {
    const response = await api.get<ApiResponse<Zone>>(`${API_ENDPOINTS.zones}/${id}`);
    return response.data;
  },

  createZone: async (data: Omit<Zone, '_id' | 'createdAt'>): Promise<ApiResponse<Zone>> => {
    const response = await api.post<ApiResponse<Zone>>(API_ENDPOINTS.zones, data);
    return response.data;
  },

  updateZone: async (id: string, data: Partial<Zone>): Promise<ApiResponse<Zone>> => {
    const response = await api.put<ApiResponse<Zone>>(`${API_ENDPOINTS.zones}/${id}`, data);
    return response.data;
  },

  deleteZone: async (id: string): Promise<ApiResponse<null>> => {
    const response = await api.delete<ApiResponse<null>>(`${API_ENDPOINTS.zones}/${id}`);
    return response.data;
  },
};

// Settings API
export const settingsApi = {
  getSettings: async (): Promise<ApiResponse<AppSettings>> => {
    const response = await api.get<ApiResponse<AppSettings>>(API_ENDPOINTS.settings);
    return response.data;
  },

  updateSettings: async (data: Partial<AppSettings>): Promise<ApiResponse<AppSettings>> => {
    const response = await api.put<ApiResponse<AppSettings>>(API_ENDPOINTS.settings, data);
    return response.data;
  },
};

// Analytics API
export const analyticsApi = {
  getOrdersAnalytics: async (params?: {
    startDate?: string;
    endDate?: string;
  }): Promise<ApiResponse<Array<{ _id: string; count: number; totalAmount: number }>>> => {
    const response = await api.get<ApiResponse<Array<{ _id: string; count: number; totalAmount: number }>>>(
      '/admin/analytics/orders',
      { params }
    );
    return response.data;
  },

  getPopularItems: async (limit: number = 10): Promise<ApiResponse<Array<{
    _id: string;
    name: string;
    orderCount: number;
    revenue: number;
  }>>> => {
    const response = await api.get<ApiResponse<Array<{
      _id: string;
      name: string;
      orderCount: number;
      revenue: number;
    }>>>('/admin/analytics/popular-items', { params: { limit } });
    return response.data;
  },

  getCustomerStats: async (): Promise<ApiResponse<{
    totalCustomers: number;
    newToday: number;
    newThisMonth: number;
    activeCustomers: number;
  }>> => {
    const response = await api.get<ApiResponse<{
      totalCustomers: number;
      newToday: number;
      newThisMonth: number;
      activeCustomers: number;
    }>>('/admin/analytics/customers');
    return response.data;
  },

  getFinancialSummary: async (params?: {
    startDate?: string;
    endDate?: string;
  }): Promise<ApiResponse<FinancialSummary>> => {
    const response = await api.get<ApiResponse<FinancialSummary>>('/admin/analytics/financial', { params });
    return response.data;
  },
};

// Coupons API
export const couponsApi = {
  getCoupons: async (params?: {
    page?: number;
    limit?: number;
    isActive?: boolean;
  }): Promise<ApiResponse<PaginatedResponse<{
    _id: string;
    code: string;
    discountType: 'percentage' | 'fixed';
    discountValue: number;
    minOrderAmount?: number;
    maxDiscount?: number;
    usageLimit?: number;
    usedCount: number;
    startDate: string;
    endDate: string;
    isActive: boolean;
    createdAt: string;
  }>>> => {
    const response = await api.get(API_ENDPOINTS.coupons, { params });
    return response.data;
  },

  createCoupon: async (data: {
    code: string;
    discountType: 'percentage' | 'fixed';
    discountValue: number;
    minOrderAmount?: number;
    maxDiscount?: number;
    usageLimit?: number;
    startDate: string;
    endDate: string;
  }): Promise<ApiResponse<unknown>> => {
    const response = await api.post(API_ENDPOINTS.coupons, data);
    return response.data;
  },

  updateCoupon: async (id: string, data: Partial<{
    code: string;
    discountType: 'percentage' | 'fixed';
    discountValue: number;
    minOrderAmount?: number;
    maxDiscount?: number;
    usageLimit?: number;
    startDate: string;
    endDate: string;
    isActive: boolean;
  }>): Promise<ApiResponse<unknown>> => {
    const response = await api.put(`${API_ENDPOINTS.coupons}/${id}`, data);
    return response.data;
  },

  deleteCoupon: async (id: string): Promise<ApiResponse<null>> => {
    const response = await api.delete(`${API_ENDPOINTS.coupons}/${id}`);
    return response.data;
  },
};

// Error handling helper
export const getErrorMessage = (error: unknown): string => {
  if (axios.isAxiosError(error)) {
    const axiosError = error as AxiosError<ApiResponse>;
    if (axiosError.response?.data?.message) {
      return axiosError.response.data.message;
    }
    if (axiosError.response?.data?.errors) {
      const firstError = Object.values(axiosError.response.data.errors)[0];
      if (firstError && firstError.length > 0) {
        return firstError[0];
      }
    }
    switch (axiosError.code) {
      case 'ECONNABORTED':
        return 'انتهت مهلة الاتصال';
      case 'ERR_NETWORK':
        return 'لا يوجد اتصال بالإنترنت';
      default:
        return 'حدث خطأ ما';
    }
  }
  if (error instanceof Error) {
    return error.message;
  }
  return 'حدث خطأ غير متوقع';
};

// Helper functions
export const apiHelpers = {
  get: <T>(url: string, params?: Record<string, unknown>) =>
    api.get<T>(url, { params }),

  post: <T>(url: string, data?: unknown) => api.post<T>(url, data),

  put: <T>(url: string, data?: unknown) => api.put<T>(url, data),

  patch: <T>(url: string, data?: unknown) => api.patch<T>(url, data),

  delete: <T>(url: string) => api.delete<T>(url),
};
