// User Types
export * from './user';

// Restaurant Types
export * from './restaurant';

// Driver Types
export * from './driver';

// Order Types
export * from './order';

// API Response Types
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

export interface ApiError {
  success: false;
  message: string;
  errors?: Record<string, string[]>;
  statusCode?: number;
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

// Coupon Types
export type CouponType = 'percentage' | 'fixed';
export type CouponApplicableTo = 'all' | 'restaurants' | 'customers';

export interface Coupon {
  id: string;
  code: string;
  description?: string;
  descriptionEn?: string;
  type: CouponType;
  value: number;
  minOrderAmount?: number;
  maxDiscount?: number;
  usageLimit?: number;
  usedCount: number;
  perUserLimit: number;
  startDate: Date;
  endDate: Date;
  isActive: boolean;
  applicableTo: CouponApplicableTo;
  restaurantIds: string[];
  customerIds: string[];
  excludedMenuItems: string[];
  firstOrderOnly: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Zone Types
export interface Zone {
  id: string;
  name: string;
  nameEn?: string;
  polygon: {
    type: 'Polygon';
    coordinates: [number, number][][];
  };
  deliveryFee: number;
  minOrderAmount: number;
  estimatedDeliveryTime: number; // in minutes
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Review Types
export interface Review {
  id: string;
  orderId: string;
  customerId: string;
  restaurantId?: string;
  driverId?: string;
  type: 'restaurant' | 'driver';
  rating: number;
  comment?: string;
  images: string[];
  reply?: string;
  repliedAt?: Date;
  isVisible: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Notification Types
export type NotificationType = 'order' | 'promotion' | 'system' | 'chat';

export interface Notification {
  id: string;
  userId: string;
  type: NotificationType;
  title: string;
  titleEn?: string;
  body: string;
  bodyEn?: string;
  data?: Record<string, unknown>;
  isRead: boolean;
  readAt?: Date;
  createdAt: Date;
}

// Transaction Types
export type TransactionType =
  | 'order_payment'
  | 'refund'
  | 'driver_payout'
  | 'restaurant_payout'
  | 'commission'
  | 'wallet_topup'
  | 'wallet_withdrawal';

export type TransactionStatus = 'pending' | 'completed' | 'failed';

export interface Transaction {
  id: string;
  type: TransactionType;
  amount: number;
  fee?: number;
  netAmount: number;
  orderId?: string;
  userId?: string;
  restaurantId?: string;
  driverId?: string;
  status: TransactionStatus;
  paymentMethod?: string;
  paymentReference?: string;
  description?: string;
  createdAt: Date;
  updatedAt: Date;
}

// Settings Types
export interface AppSettings {
  general: {
    appName: string;
    appNameEn: string;
    supportEmail: string;
    supportPhone: string;
    currency: string;
    currencySymbol: string;
    timezone: string;
    defaultLanguage: 'ar' | 'en';
  };
  delivery: {
    baseDeliveryFee: number;
    perKmFee: number;
    freeDeliveryThreshold: number;
    maxDeliveryDistance: number;
    serviceFeePercentage: number;
  };
  commission: {
    restaurantCommission: number;
    driverCommission: number;
  };
  order: {
    minOrderAmount: number;
    maxOrderItems: number;
    orderAcceptTimeout: number; // seconds
    preparationBuffer: number; // minutes
  };
  payment: {
    enableCashOnDelivery: boolean;
    enableCardPayment: boolean;
    enableWalletPayment: boolean;
    paymobApiKey?: string;
  };
  notifications: {
    enablePush: boolean;
    enableEmail: boolean;
    enableSms: boolean;
  };
  maintenance: {
    isMaintenanceMode: boolean;
    maintenanceMessage?: string;
  };
}
