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
  role?: string;
}

export interface RegisterRequest {
  name: string;
  nameEn?: string;
  email: string;
  phone: string;
  password: string;
  role?: string;
  address: {
    street: string;
    area: string;
    city: string;
  };
  cuisineTypes: string[];
  deliveryFee?: number;
  minimumOrder?: number;
}

export interface GoogleSignInRequest {
  idToken: string;
  role?: string;
}

export interface VerifyEmailRequest {
  email: string;
  otp: string;
}

export interface VerifyOtpRequest {
  email?: string;
  phone?: string;
  otp: string;
  type: 'registration' | 'password_reset';
}

export interface PendingVerificationResponse {
  requiresVerification: boolean;
  email: string;
  message?: string;
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
  login: async (data: LoginRequest): Promise<ApiResponse<AuthResponse | PendingVerificationResponse>> => {
    const response = await api.post<ApiResponse<AuthResponse | PendingVerificationResponse>>(
      API_ENDPOINTS.login,
      { ...data, role: 'restaurant' }
    );
    return response.data;
  },

  register: async (data: RegisterRequest): Promise<ApiResponse<PendingVerificationResponse>> => {
    const response = await api.post<ApiResponse<PendingVerificationResponse>>(
      API_ENDPOINTS.register,
      { ...data, role: 'restaurant' }
    );
    return response.data;
  },

  verifyEmail: async (data: VerifyEmailRequest): Promise<ApiResponse<AuthResponse>> => {
    const response = await api.post<ApiResponse<AuthResponse>>(API_ENDPOINTS.verifyEmail, data);
    return response.data;
  },

  verifyOtp: async (data: VerifyOtpRequest): Promise<ApiResponse<void>> => {
    const response = await api.post<ApiResponse<void>>('/auth/verify-otp', data);
    return response.data;
  },

  resendOtp: async (email: string): Promise<ApiResponse<void>> => {
    const response = await api.post<ApiResponse<void>>(API_ENDPOINTS.resendOtp, { email });
    return response.data;
  },

  signInWithGoogle: async (idToken: string): Promise<ApiResponse<AuthResponse>> => {
    const response = await api.post<ApiResponse<AuthResponse>>(
      API_ENDPOINTS.googleSignIn,
      { idToken, role: 'restaurant' }
    );
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

// Order types
export interface OrderItem {
  menuItemId: string;
  name: string;
  nameAr?: string;
  image?: string;
  quantity: number;
  price: number;
  addons?: {
    name: string;
    nameAr?: string;
    price: number;
    quantity: number;
  }[];
  variations?: {
    name: string;
    nameAr?: string;
    option: string;
    optionAr?: string;
    price: number;
  }[];
  specialInstructions?: string;
}

export interface OrderCustomer {
  id: string;
  name: string;
  phone: string;
}

export interface OrderDriver {
  id: string;
  name: string;
  phone?: string;
  avatar?: string;
}

export interface Order {
  _id: string;
  orderNumber: string;
  customer: OrderCustomer;
  items: OrderItem[];
  subtotal: number;
  deliveryFee: number;
  discount: number;
  total: number;
  status: 'pending' | 'confirmed' | 'preparing' | 'ready' | 'picked_up' | 'on_the_way' | 'delivered' | 'cancelled';
  paymentMethod: 'cash' | 'card' | 'wallet';
  paymentStatus: 'pending' | 'paid' | 'failed' | 'refunded';
  deliveryAddress: {
    name: string;
    address: string;
    area: string;
    city: string;
    building?: string;
    floor?: string;
    apartment?: string;
    landmark?: string;
  };
  driver?: OrderDriver;
  notes?: string;
  cancellationReason?: string;
  estimatedDeliveryTime?: string;
  createdAt: string;
  updatedAt: string;
}

export interface OrdersListResponse {
  orders: Order[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

// Orders API functions
export const ordersApi = {
  getOrders: async (params?: {
    status?: string;
    page?: number;
    limit?: number;
    startDate?: string;
    endDate?: string;
  }): Promise<ApiResponse<OrdersListResponse>> => {
    const response = await api.get<ApiResponse<OrdersListResponse>>(
      API_ENDPOINTS.orders,
      { params }
    );
    return response.data;
  },

  getOrder: async (id: string): Promise<ApiResponse<{ order: Order }>> => {
    const response = await api.get<ApiResponse<{ order: Order }>>(
      API_ENDPOINTS.orderDetails.replace(':id', id)
    );
    return response.data;
  },

  updateOrderStatus: async (
    id: string,
    status: Order['status'],
    estimatedTime?: number
  ): Promise<ApiResponse<{ order: Order }>> => {
    const response = await api.patch<ApiResponse<{ order: Order }>>(
      API_ENDPOINTS.updateOrderStatus.replace(':id', id),
      { status, estimatedTime }
    );
    return response.data;
  },

  acceptOrder: async (
    id: string,
    estimatedTime?: number
  ): Promise<ApiResponse<{ order: Order }>> => {
    const response = await api.post<ApiResponse<{ order: Order }>>(
      API_ENDPOINTS.acceptOrder.replace(':id', id),
      { estimatedTime }
    );
    return response.data;
  },

  rejectOrder: async (
    id: string,
    reason: string
  ): Promise<ApiResponse<{ order: Order }>> => {
    const response = await api.post<ApiResponse<{ order: Order }>>(
      API_ENDPOINTS.rejectOrder.replace(':id', id),
      { reason }
    );
    return response.data;
  },
};

// Earnings types
export interface Transaction {
  _id: string;
  transactionNumber: string;
  type: 'order_payment' | 'restaurant_payout' | 'refund';
  orderId?: {
    _id: string;
    orderNumber: string;
    total: number;
  };
  amount: number;
  fee: number;
  netAmount: number;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  createdAt: string;
  processedAt?: string;
}

export interface PayoutSummary {
  pendingAmount: number;
  processedAmount: number;
  totalTransactions: number;
  recentPayouts: Transaction[];
}

export interface EarningsStats {
  todayEarnings: number;
  weekEarnings: number;
  monthEarnings: number;
  totalEarnings: number;
  todayOrders: number;
  weekOrders: number;
  monthOrders: number;
  totalOrders: number;
  pendingPayout: number;
  averageOrderValue: number;
}

// Earnings API functions
export const earningsApi = {
  getPayoutSummary: async (): Promise<ApiResponse<PayoutSummary>> => {
    const response = await api.get<ApiResponse<PayoutSummary>>(
      '/restaurant/payouts/summary'
    );
    return response.data;
  },

  getTransactions: async (params?: {
    type?: string;
    status?: string;
    startDate?: string;
    endDate?: string;
    page?: number;
    limit?: number;
  }): Promise<ApiResponse<{ data: Transaction[]; pagination: { page: number; pages: number; total: number; limit: number } }>> => {
    const response = await api.get<ApiResponse<{ data: Transaction[]; pagination: { page: number; pages: number; total: number; limit: number } }>>(
      '/restaurant/transactions',
      { params }
    );
    return response.data;
  },

  getEarningsStats: async (params?: {
    startDate?: string;
    endDate?: string;
  }): Promise<ApiResponse<EarningsStats>> => {
    const response = await api.get<ApiResponse<EarningsStats>>(
      '/restaurant/orders/stats',
      { params }
    );
    return response.data;
  },
};

// Review types
export interface Review {
  _id: string;
  orderId: string;
  customerId: string;
  restaurantId: string;
  driverId?: string;
  customer?: {
    name: string;
    avatar?: string;
  };
  restaurantRating: number;
  foodRating: number;
  driverRating?: number;
  comment?: string;
  images: string[];
  restaurantReply?: string;
  repliedAt?: string;
  isVisible: boolean;
  isReported: boolean;
  reportReason?: string;
  createdAt: string;
  updatedAt: string;
}

export interface ReviewStats {
  totalReviews: number;
  averageRestaurantRating: number;
  averageFoodRating: number;
  averageDriverRating: number;
  ratingDistribution: {
    1: number;
    2: number;
    3: number;
    4: number;
    5: number;
  };
  repliedCount: number;
  replyRate: number;
}

export interface ReviewsListResponse {
  reviews: Review[];
  pagination: {
    total: number;
    page: number;
    limit: number;
    pages: number;
  };
}

// Reviews API functions
export const reviewsApi = {
  getReviews: async (params?: {
    page?: number;
    limit?: number;
    rating?: number;
    hasReply?: boolean;
  }): Promise<ApiResponse<ReviewsListResponse>> => {
    const response = await api.get<ApiResponse<ReviewsListResponse>>(
      API_ENDPOINTS.reviews,
      { params }
    );
    return response.data;
  },

  getStats: async (): Promise<ApiResponse<ReviewStats>> => {
    const response = await api.get<ApiResponse<ReviewStats>>(
      API_ENDPOINTS.reviewStats
    );
    return response.data;
  },

  replyToReview: async (reviewId: string, reply: string): Promise<ApiResponse<{ review: Review }>> => {
    const response = await api.post<ApiResponse<{ review: Review }>>(
      API_ENDPOINTS.replyToReview.replace(':id', reviewId),
      { reply }
    );
    return response.data;
  },

  updateReply: async (reviewId: string, reply: string): Promise<ApiResponse<{ review: Review }>> => {
    const response = await api.put<ApiResponse<{ review: Review }>>(
      API_ENDPOINTS.replyToReview.replace(':id', reviewId),
      { reply }
    );
    return response.data;
  },

  deleteReply: async (reviewId: string): Promise<ApiResponse<{ review: Review }>> => {
    const response = await api.delete<ApiResponse<{ review: Review }>>(
      API_ENDPOINTS.replyToReview.replace(':id', reviewId)
    );
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
