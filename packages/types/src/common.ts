export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

export interface ApiErrorBody {
  success: false;
  message: string;
  errors?: Record<string, string[]>;
  statusCode?: number;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPrevPage: boolean;
}

export interface PaginatedResponse<T> {
  success: boolean;
  data: T[];
  pagination: PaginationMeta;
}

export type CouponType = "percentage" | "fixed";
export type CouponApplicableTo = "all" | "restaurants" | "customers";

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
  startDate: string;
  endDate: string;
  isActive: boolean;
  applicableTo: CouponApplicableTo;
  restaurantIds: string[];
  customerIds: string[];
  excludedMenuItems: string[];
  firstOrderOnly: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Zone {
  id: string;
  name: string;
  nameEn?: string;
  polygon: {
    type: "Polygon";
    coordinates: [number, number][][];
  };
  deliveryFee: number;
  minOrderAmount: number;
  estimatedDeliveryTime: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Review {
  id: string;
  orderId: string;
  customerId: string;
  restaurantId?: string;
  driverId?: string;
  type: "restaurant" | "driver";
  rating: number;
  comment?: string;
  images: string[];
  reply?: string;
  repliedAt?: string;
  isVisible: boolean;
  createdAt: string;
  updatedAt: string;
}

export type NotificationType = "order" | "promotion" | "system" | "chat";

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
  readAt?: string;
  createdAt: string;
}

export type TransactionType =
  | "order_payment"
  | "refund"
  | "driver_payout"
  | "restaurant_payout"
  | "commission"
  | "wallet_topup"
  | "wallet_withdrawal";

export type TransactionStatus = "pending" | "completed" | "failed";

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
  createdAt: string;
  updatedAt: string;
}
