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

// User Types
export interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: 'customer' | 'restaurant' | 'driver' | 'admin';
  isActive: boolean;
  isBlocked: boolean;
  avatar?: string;
  createdAt: Date;
  lastLogin?: Date;
}

export interface Customer extends User {
  role: 'customer';
  totalOrders: number;
  totalSpent: number;
  addresses: Address[];
  favoriteRestaurants: string[];
}

export interface Restaurant {
  id: string;
  userId: string;
  name: string;
  nameEn?: string;
  email: string;
  phone: string;
  logo?: string;
  coverImage?: string;
  status: 'pending' | 'approved' | 'rejected' | 'suspended';
  isOpen: boolean;
  address: Address;
  cuisineTypes: string[];
  rating: number;
  totalOrders: number;
  totalRevenue: number;
  commissionRate: number;
  createdAt: Date;
}

export interface Driver {
  id: string;
  userId: string;
  name: string;
  email: string;
  phone: string;
  avatar?: string;
  status: 'pending' | 'approved' | 'rejected' | 'suspended';
  isOnline: boolean;
  isAvailable: boolean;
  vehicleType: 'motorcycle' | 'bicycle' | 'car';
  vehicleNumber: string;
  nationalId: string;
  licenseNumber: string;
  documents: {
    nationalIdImage?: string;
    licenseImage?: string;
    vehicleImage?: string;
  };
  rating: number;
  totalDeliveries: number;
  totalEarnings: number;
  currentLocation?: {
    lat: number;
    lng: number;
    updatedAt: Date;
  };
  createdAt: Date;
}

export interface Address {
  street: string;
  area: string;
  city: string;
  buildingNumber?: string;
  floor?: string;
  apartment?: string;
  landmark?: string;
  location?: {
    lat: number;
    lng: number;
  };
}

// Order Types
export interface Order {
  id: string;
  orderNumber: string;
  customerId: string;
  customerName: string;
  customerPhone: string;
  restaurantId: string;
  restaurantName: string;
  driverId?: string;
  driverName?: string;
  items: OrderItem[];
  subtotal: number;
  deliveryFee: number;
  serviceFee: number;
  discount: number;
  total: number;
  commission: number;
  status: OrderStatus;
  paymentMethod: 'cash' | 'card' | 'wallet';
  paymentStatus: 'pending' | 'paid' | 'failed' | 'refunded';
  deliveryAddress: Address;
  notes?: string;
  cancelReason?: string;
  estimatedDeliveryTime?: Date;
  actualDeliveryTime?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface OrderItem {
  menuItemId: string;
  name: string;
  quantity: number;
  price: number;
  addons?: { name: string; price: number }[];
  specialInstructions?: string;
}

export type OrderStatus =
  | 'pending'
  | 'confirmed'
  | 'preparing'
  | 'ready'
  | 'picked_up'
  | 'on_the_way'
  | 'delivered'
  | 'cancelled';

// Coupon Types
export interface Coupon {
  id: string;
  code: string;
  description?: string;
  type: 'percentage' | 'fixed';
  value: number;
  minOrderAmount?: number;
  maxDiscount?: number;
  usageLimit?: number;
  usedCount: number;
  startDate: Date;
  endDate: Date;
  isActive: boolean;
  applicableTo: 'all' | 'restaurants' | 'customers';
  restaurantIds?: string[];
  customerIds?: string[];
  createdAt: Date;
}

// Zone Types
export interface Zone {
  id: string;
  name: string;
  nameEn?: string;
  polygon: { lat: number; lng: number }[];
  deliveryFee: number;
  minOrderAmount: number;
  isActive: boolean;
  estimatedDeliveryTime: number; // in minutes
  createdAt: Date;
}

// Transaction Types
export interface Transaction {
  id: string;
  type:
    | 'order_payment'
    | 'refund'
    | 'driver_payout'
    | 'restaurant_payout'
    | 'commission';
  amount: number;
  orderId?: string;
  userId?: string;
  restaurantId?: string;
  driverId?: string;
  status: 'pending' | 'completed' | 'failed';
  paymentMethod?: string;
  reference?: string;
  createdAt: Date;
}

// Settings Types
export interface AppSettings {
  general: {
    appName: string;
    supportEmail: string;
    supportPhone: string;
    currency: string;
    timezone: string;
  };
  delivery: {
    baseDeliveryFee: number;
    perKmFee: number;
    freeDeliveryThreshold: number;
    maxDeliveryDistance: number;
  };
  commission: {
    restaurantCommission: number;
    driverCommission: number;
  };
  order: {
    minOrderAmount: number;
    maxOrderItems: number;
    orderTimeout: number;
  };
  notifications: {
    enablePush: boolean;
    enableEmail: boolean;
    enableSms: boolean;
  };
}
