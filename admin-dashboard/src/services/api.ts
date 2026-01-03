import axios, { AxiosError, InternalAxiosRequestConfig } from 'axios';
import Cookies from 'js-cookie';
import { API_CONFIG, STORAGE_KEYS } from '@/config/constants';

const api = axios.create({
  baseURL: API_CONFIG.baseUrl,
  timeout: API_CONFIG.timeout,
  headers: {
    'Content-Type': 'application/json',
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

        const response = await axios.post(
          `${API_CONFIG.baseUrl}/auth/refresh-token`,
          { refreshToken }
        );

        const { accessToken, refreshToken: newRefreshToken } = response.data;

        Cookies.set(STORAGE_KEYS.accessToken, accessToken, { expires: 7 });
        Cookies.set(STORAGE_KEYS.refreshToken, newRefreshToken, { expires: 30 });

        if (originalRequest.headers) {
          originalRequest.headers.Authorization = `Bearer ${accessToken}`;
        }

        return api(originalRequest);
      } catch (refreshError) {
        // Clear tokens and redirect to login
        Cookies.remove(STORAGE_KEYS.accessToken);
        Cookies.remove(STORAGE_KEYS.refreshToken);
        Cookies.remove(STORAGE_KEYS.adminData);

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

// Helper functions
export const apiHelpers = {
  get: <T>(url: string, params?: Record<string, unknown>) =>
    api.get<T>(url, { params }),

  post: <T>(url: string, data?: unknown) => api.post<T>(url, data),

  put: <T>(url: string, data?: unknown) => api.put<T>(url, data),

  patch: <T>(url: string, data?: unknown) => api.patch<T>(url, data),

  delete: <T>(url: string) => api.delete<T>(url),
};
