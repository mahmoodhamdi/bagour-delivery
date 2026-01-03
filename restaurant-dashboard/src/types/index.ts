// API Response Types
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

export interface PaginatedResponse<T> {
  success: boolean;
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasNextPage: boolean;
    hasPrevPage: boolean;
  };
}

export interface ApiError {
  success: false;
  message: string;
  errors?: Record<string, string[]>;
}

// Auth Types
export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  name: string;
  nameEn?: string;
  email: string;
  password: string;
  phone: string;
  address: {
    street: string;
    area: string;
    city: string;
  };
  cuisineTypes: string[];
}

export interface AuthResponse {
  user: {
    id: string;
    email: string;
    role: string;
  };
  restaurant: {
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
  };
  accessToken: string;
  refreshToken: string;
}

// Menu Types
export interface MenuCategory {
  id: string;
  name: string;
  nameEn?: string;
  description?: string;
  image?: string;
  order: number;
  isActive: boolean;
  itemCount: number;
}

export interface MenuItem {
  id: string;
  categoryId: string;
  name: string;
  nameEn?: string;
  description?: string;
  descriptionEn?: string;
  price: number;
  discountPrice?: number;
  image?: string;
  images?: string[];
  preparationTime: number;
  calories?: number;
  isAvailable: boolean;
  isNewItem: boolean;
  isFeatured: boolean;
  addons?: MenuAddon[];
  options?: MenuOption[];
}

export interface MenuAddon {
  name: string;
  nameEn?: string;
  price: number;
  isAvailable: boolean;
}

export interface MenuOption {
  name: string;
  nameEn?: string;
  choices: {
    name: string;
    nameEn?: string;
    price: number;
    isDefault?: boolean;
  }[];
  required: boolean;
  maxSelections: number;
}

// Analytics Types
export interface DashboardStats {
  todayOrders: number;
  todayRevenue: number;
  pendingOrders: number;
  completedOrders: number;
  averageRating: number;
  totalReviews: number;
}

export interface RevenueData {
  date: string;
  revenue: number;
  orders: number;
}

export interface OrdersAnalytics {
  period: string;
  data: {
    date: string;
    orders: number;
    completed: number;
    cancelled: number;
  }[];
}

export interface TopItem {
  id: string;
  name: string;
  image?: string;
  ordersCount: number;
  revenue: number;
}

// Working Hours Types
export interface WorkingHours {
  day: string;
  isOpen: boolean;
  openTime: string;
  closeTime: string;
}

// Notification Types
export interface Notification {
  id: string;
  type: 'order' | 'review' | 'system' | 'promotion';
  title: string;
  body: string;
  data?: Record<string, unknown>;
  isRead: boolean;
  createdAt: Date;
}
