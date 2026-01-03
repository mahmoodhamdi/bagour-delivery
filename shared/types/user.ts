export type UserRole = 'customer' | 'restaurant' | 'driver' | 'admin';

export interface BaseUser {
  id: string;
  email: string;
  phone: string;
  name: string;
  role: UserRole;
  avatar?: string;
  isActive: boolean;
  isBlocked: boolean;
  isEmailVerified: boolean;
  isPhoneVerified: boolean;
  fcmTokens: string[];
  lastLogin?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface Address {
  label?: string;
  street: string;
  area: string;
  city: string;
  buildingNumber?: string;
  floor?: string;
  apartment?: string;
  landmark?: string;
  isDefault?: boolean;
  location?: {
    type: 'Point';
    coordinates: [number, number]; // [lng, lat]
  };
}

export interface Customer {
  id: string;
  userId: string;
  user?: BaseUser;
  addresses: Address[];
  favoriteRestaurants: string[];
  totalOrders: number;
  totalSpent: number;
  loyaltyPoints: number;
  referralCode: string;
  referredBy?: string;
}
