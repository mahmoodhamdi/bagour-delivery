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
