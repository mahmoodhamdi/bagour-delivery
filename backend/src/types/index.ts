import { Request } from 'express';
import { Document, Types } from 'mongoose';

// User roles
export type UserRole = 'customer' | 'restaurant' | 'driver' | 'delivery' | 'admin';

// Order status
export type OrderStatus =
  | 'pending'
  | 'confirmed'
  | 'preparing'
  | 'ready'
  | 'picked_up'
  | 'on_the_way'
  | 'delivered'
  | 'cancelled';

// Payment status
export type PaymentStatus = 'pending' | 'paid' | 'failed' | 'refunded';

// Payment method
export type PaymentMethod = 'cash' | 'card' | 'wallet';

// Vehicle type
export type VehicleType = 'motorcycle' | 'car' | 'bicycle';

// Transaction type
export type TransactionType =
  | 'order_payment'
  | 'restaurant_payout'
  | 'driver_payout'
  | 'refund'
  | 'withdrawal'
  | 'bonus';

// Coupon type
export type CouponType = 'percentage' | 'fixed';

// Subscription plan
export type SubscriptionPlan = 'free' | 'silver' | 'gold' | 'platinum';

// Address label
export type AddressLabel = 'home' | 'work' | 'other';

// Location point
export interface ILocation {
  type: 'Point';
  coordinates: [number, number]; // [longitude, latitude]
}

// Polygon for zones
export interface IPolygon {
  type: 'Polygon';
  coordinates: number[][][];
}

// Working hours
export interface IWorkingHours {
  day: number; // 0-6, 0 = Sunday
  isOpen: boolean;
  shifts: {
    open: string; // "09:00"
    close: string; // "23:00"
  }[];
}

// Pagination
export interface IPaginationOptions {
  page: number;
  limit: number;
  sort?: string;
}

export interface IPaginatedResult<T> {
  data: T[];
  pagination: {
    total: number;
    page: number;
    limit: number;
    pages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}

// JWT Payload
export interface IJwtPayload {
  userId: string;
  role: UserRole;
  iat?: number;
  exp?: number;
}

// Authenticated user attached to request
export interface IAuthUser {
  id: string;
  _id?: Types.ObjectId;
  email?: string;
  phone?: string;
  name?: string;
  role: string;
  isActive?: boolean;
}

// Extended Request with user
export interface IAuthRequest extends Request {
  user?: {
    id: string;
    userId: string;
    role: string;
    email?: string;
  };
  customerId?: string;
  restaurantId?: string;
  driverId?: string;
}

// Alias for backward compatibility
export type AuthRequest = IAuthRequest;

// API Response format
export interface IApiResponse<T = unknown> {
  success: boolean;
  message?: string;
  data?: T;
  error?: {
    code: string;
    details?: unknown;
  };
  pagination?: {
    total: number;
    page: number;
    limit: number;
    pages: number;
  };
}

// File upload
export interface IUploadedFile {
  url: string;
  publicId: string;
  width?: number;
  height?: number;
  format?: string;
  size?: number;
}

// Notification data
export interface INotificationData {
  orderId?: string;
  restaurantId?: string;
  action?: string;
  url?: string;
}

