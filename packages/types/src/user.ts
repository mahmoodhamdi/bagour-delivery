export type UserRole = "customer" | "restaurant" | "driver" | "delivery" | "admin";

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
  lastLogin?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Address {
  id?: string;
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
    type: "Point";
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
