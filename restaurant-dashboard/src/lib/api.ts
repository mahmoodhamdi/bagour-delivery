import axios, { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from 'axios';
import Cookies from 'js-cookie';
import { API_CONFIG, STORAGE_KEYS, API_ENDPOINTS } from '@/config/constants';

// Types
export interface ApiResponse<T = unknown> {
  success: boolean;
  message?: string;
  data?: T;
  errors?: Record<string, string[]>;
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
  workingHours?: WorkingHours[];
}

export interface WorkingHours {
  day: string;
  isOpen: boolean;
  openTime: string;
  closeTime: string;
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
  restaurant: Restaurant;
  accessToken: string;
  refreshToken: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  name: string;
  nameEn?: string;
  email: string;
  phone: string;
  password: string;
  address: {
    street: string;
    area: string;
    city: string;
  };
  cuisineTypes: string[];
  deliveryFee?: number;
  minimumOrder?: number;
}

export interface VerifyOtpRequest {
  email?: string;
  phone?: string;
  otp: string;
  type: 'registration' | 'password_reset';
}

export interface ForgotPasswordRequest {
  email: string;
}

export interface ResetPasswordRequest {
  email: string;
  otp: string;
  newPassword: string;
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

// Request interceptor - add auth token
api.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = Cookies.get(STORAGE_KEYS.accessToken);
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor - handle token refresh
api.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

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
        localStorage.removeItem(STORAGE_KEYS.restaurantData);

        if (typeof window !== 'undefined') {
          window.location.href = '/login';
        }
      }
    }

    return Promise.reject(error);
  }
);

// Auth API functions
export const authApi = {
  login: async (data: LoginRequest): Promise<ApiResponse<AuthResponse>> => {
    const response = await api.post<ApiResponse<AuthResponse>>(API_ENDPOINTS.login, data);
    return response.data;
  },

  register: async (data: RegisterRequest): Promise<ApiResponse<AuthResponse>> => {
    const response = await api.post<ApiResponse<AuthResponse>>(API_ENDPOINTS.register, data);
    return response.data;
  },

  verifyOtp: async (data: VerifyOtpRequest): Promise<ApiResponse<void>> => {
    const response = await api.post<ApiResponse<void>>(API_ENDPOINTS.verifyOtp, data);
    return response.data;
  },

  resendOtp: async (data: { email?: string; phone?: string; type: string }): Promise<ApiResponse<void>> => {
    const response = await api.post<ApiResponse<void>>(API_ENDPOINTS.resendOtp, data);
    return response.data;
  },

  forgotPassword: async (data: ForgotPasswordRequest): Promise<ApiResponse<void>> => {
    const response = await api.post<ApiResponse<void>>(API_ENDPOINTS.forgotPassword, data);
    return response.data;
  },

  resetPassword: async (data: ResetPasswordRequest): Promise<ApiResponse<void>> => {
    const response = await api.post<ApiResponse<void>>(API_ENDPOINTS.resetPassword, data);
    return response.data;
  },

  logout: async (fcmToken?: string): Promise<void> => {
    try {
      await api.post(API_ENDPOINTS.logout, fcmToken ? { fcmToken } : undefined);
    } catch {
      // Ignore logout errors
    }
  },

  getProfile: async (): Promise<ApiResponse<{ user: User; restaurant: Restaurant }>> => {
    const response = await api.get<ApiResponse<{ user: User; restaurant: Restaurant }>>(API_ENDPOINTS.profile);
    return response.data;
  },
};

// Restaurant API functions
export interface UpdateProfileRequest {
  name?: string;
  nameAr?: string;
  description?: string;
  descriptionAr?: string;
  phone?: string;
  whatsapp?: string;
  address?: string;
  area?: string;
  categories?: string[];
  tags?: string[];
  priceRange?: number;
}

export interface UpdateLocationRequest {
  address: string;
  area: string;
  coordinates: {
    lat: number;
    lng: number;
  };
}

export interface WorkingHoursDay {
  day: number;
  isOpen: boolean;
  shifts: { open: string; close: string }[];
}

export interface UpdateDeliverySettingsRequest {
  minimumOrder?: number;
  deliveryFee?: number;
  freeDeliveryAbove?: number | null;
  estimatedDeliveryTime?: { min: number; max: number };
  acceptsCash?: boolean;
  acceptsOnlinePayment?: boolean;
  autoAcceptOrders?: boolean;
}

export const restaurantApi = {
  updateProfile: async (data: UpdateProfileRequest): Promise<ApiResponse<{ restaurant: Restaurant }>> => {
    const response = await api.patch<ApiResponse<{ restaurant: Restaurant }>>(
      API_ENDPOINTS.updateProfile,
      data
    );
    return response.data;
  },

  updateLocation: async (data: UpdateLocationRequest): Promise<ApiResponse<{ restaurant: Restaurant }>> => {
    const response = await api.put<ApiResponse<{ restaurant: Restaurant }>>(
      '/restaurants/location',
      data
    );
    return response.data;
  },

  updateWorkingHours: async (workingHours: WorkingHoursDay[]): Promise<ApiResponse<{ restaurant: Restaurant }>> => {
    const response = await api.put<ApiResponse<{ restaurant: Restaurant }>>(
      API_ENDPOINTS.updateWorkingHours,
      { workingHours }
    );
    return response.data;
  },

  updateDeliverySettings: async (data: UpdateDeliverySettingsRequest): Promise<ApiResponse<{ restaurant: Restaurant }>> => {
    const response = await api.put<ApiResponse<{ restaurant: Restaurant }>>(
      '/restaurants/delivery-settings',
      data
    );
    return response.data;
  },

  togglePause: async (isPaused: boolean, pauseReason?: string): Promise<ApiResponse<{ restaurant: Restaurant }>> => {
    const response = await api.post<ApiResponse<{ restaurant: Restaurant }>>(
      '/restaurants/toggle-pause',
      { isPaused, pauseReason }
    );
    return response.data;
  },

  getDashboardStats: async (): Promise<ApiResponse<{
    stats: {
      totalOrders: number;
      totalRevenue: number;
      rating: number;
      totalRatings: number;
      isOpen: boolean;
      isPaused: boolean;
      isApproved: boolean;
      menu: {
        categories: number;
        totalItems: number;
        availableItems: number;
      };
    };
  }>> => {
    const response = await api.get<ApiResponse<{
      stats: {
        totalOrders: number;
        totalRevenue: number;
        rating: number;
        totalRatings: number;
        isOpen: boolean;
        isPaused: boolean;
        isApproved: boolean;
        menu: {
          categories: number;
          totalItems: number;
          availableItems: number;
        };
      };
    }>>('/restaurants/stats');
    return response.data;
  },
};

// Menu types
export interface MenuCategory {
  _id: string;
  restaurantId: string;
  name: string;
  nameAr: string;
  description?: string;
  descriptionAr?: string;
  image?: string;
  sortOrder: number;
  isActive: boolean;
  itemCount?: number;
  createdAt: string;
  updatedAt: string;
}

export interface MenuAddon {
  name: string;
  nameAr: string;
  price: number;
  isAvailable: boolean;
  maxQuantity: number;
}

export interface VariationOption {
  name: string;
  nameAr: string;
  price: number;
}

export interface MenuVariation {
  name: string;
  nameAr: string;
  isRequired: boolean;
  options: VariationOption[];
}

export interface MenuItem {
  _id: string;
  restaurantId: string;
  categoryId: string | { _id: string; name: string; nameAr: string };
  name: string;
  nameAr: string;
  description?: string;
  descriptionAr?: string;
  image?: string;
  price: number;
  discountPrice?: number;
  discountEndsAt?: string;
  preparationTime?: number;
  calories?: number;
  servingSize?: string;
  addons: MenuAddon[];
  variations: MenuVariation[];
  tags: string[];
  isAvailable: boolean;
  isPopular: boolean;
  isNew: boolean;
  sortOrder: number;
  totalOrders: number;
  createdAt: string;
  updatedAt: string;
}

export interface CreateCategoryRequest {
  name: string;
  nameAr: string;
  description?: string;
  descriptionAr?: string;
  sortOrder?: number;
  isActive?: boolean;
}

export interface CreateItemRequest {
  categoryId: string;
  name: string;
  nameAr: string;
  description?: string;
  descriptionAr?: string;
  image?: string;
  price: number;
  discountPrice?: number;
  discountEndsAt?: string;
  preparationTime?: number;
  calories?: number;
  servingSize?: string;
  addons?: MenuAddon[];
  variations?: MenuVariation[];
  tags?: string[];
  isAvailable?: boolean;
  isPopular?: boolean;
  sortOrder?: number;
}

// Menu API functions
export const menuApi = {
  // Categories
  getCategories: async (): Promise<ApiResponse<{ categories: MenuCategory[] }>> => {
    const response = await api.get<ApiResponse<{ categories: MenuCategory[] }>>(
      API_ENDPOINTS.categories
    );
    return response.data;
  },

  createCategory: async (data: CreateCategoryRequest): Promise<ApiResponse<{ category: MenuCategory }>> => {
    const response = await api.post<ApiResponse<{ category: MenuCategory }>>(
      API_ENDPOINTS.categories,
      data
    );
    return response.data;
  },

  updateCategory: async (
    id: string,
    data: Partial<CreateCategoryRequest>
  ): Promise<ApiResponse<{ category: MenuCategory }>> => {
    const response = await api.patch<ApiResponse<{ category: MenuCategory }>>(
      `${API_ENDPOINTS.categories}/${id}`,
      data
    );
    return response.data;
  },

  deleteCategory: async (id: string): Promise<ApiResponse<void>> => {
    const response = await api.delete<ApiResponse<void>>(`${API_ENDPOINTS.categories}/${id}`);
    return response.data;
  },

  reorderCategories: async (
    categories: { id: string; sortOrder: number }[]
  ): Promise<ApiResponse<{ categories: MenuCategory[] }>> => {
    const response = await api.put<ApiResponse<{ categories: MenuCategory[] }>>(
      `${API_ENDPOINTS.categories}/reorder`,
      { categories }
    );
    return response.data;
  },

  // Items
  getItems: async (params?: {
    categoryId?: string;
    isAvailable?: boolean;
    search?: string;
    page?: number;
    limit?: number;
  }): Promise<ApiResponse<{ items: MenuItem[]; pagination: { page: number; pages: number; total: number } }>> => {
    const response = await api.get<ApiResponse<{ items: MenuItem[]; pagination: { page: number; pages: number; total: number } }>>(
      API_ENDPOINTS.menuItems,
      { params }
    );
    return response.data;
  },

  getItem: async (id: string): Promise<ApiResponse<{ item: MenuItem }>> => {
    const response = await api.get<ApiResponse<{ item: MenuItem }>>(
      `${API_ENDPOINTS.menuItems}/${id}`
    );
    return response.data;
  },

  createItem: async (data: CreateItemRequest): Promise<ApiResponse<{ item: MenuItem }>> => {
    const response = await api.post<ApiResponse<{ item: MenuItem }>>(
      API_ENDPOINTS.menuItems,
      data
    );
    return response.data;
  },

  updateItem: async (
    id: string,
    data: Partial<CreateItemRequest>
  ): Promise<ApiResponse<{ item: MenuItem }>> => {
    const response = await api.patch<ApiResponse<{ item: MenuItem }>>(
      `${API_ENDPOINTS.menuItems}/${id}`,
      data
    );
    return response.data;
  },

  deleteItem: async (id: string): Promise<ApiResponse<void>> => {
    const response = await api.delete<ApiResponse<void>>(`${API_ENDPOINTS.menuItems}/${id}`);
    return response.data;
  },

  toggleItemAvailability: async (
    id: string,
    isAvailable: boolean
  ): Promise<ApiResponse<{ item: MenuItem }>> => {
    const response = await api.post<ApiResponse<{ item: MenuItem }>>(
      `${API_ENDPOINTS.menuItems}/${id}/toggle`,
      { isAvailable }
    );
    return response.data;
  },

  duplicateItem: async (id: string): Promise<ApiResponse<{ item: MenuItem }>> => {
    const response = await api.post<ApiResponse<{ item: MenuItem }>>(
      `${API_ENDPOINTS.menuItems}/${id}/duplicate`
    );
    return response.data;
  },

  bulkUpdateItems: async (
    items: { id: string; isAvailable?: boolean; sortOrder?: number }[]
  ): Promise<ApiResponse<void>> => {
    const response = await api.put<ApiResponse<void>>(`${API_ENDPOINTS.menuItems}/bulk`, { items });
    return response.data;
  },
};

// Upload API functions
export const uploadApi = {
  uploadImage: async (file: File, type: 'menu-item' | 'category' | 'logo' | 'cover' = 'menu-item'): Promise<ApiResponse<{ url: string; publicId: string }>> => {
    const formData = new FormData();
    formData.append('image', file);

    const endpoint = type === 'menu-item' ? '/upload/menu-item' :
                     type === 'category' ? '/upload/category' :
                     type === 'logo' ? '/upload/restaurant/logo' : '/upload/restaurant/cover';

    const response = await api.post<ApiResponse<{ url: string; publicId: string }>>(
      endpoint,
      formData,
      { headers: { 'Content-Type': 'multipart/form-data' } }
    );
    return response.data;
  },

  deleteImage: async (publicId: string): Promise<ApiResponse<void>> => {
    const response = await api.delete<ApiResponse<void>>(`/upload/${publicId}`);
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

export default api;
