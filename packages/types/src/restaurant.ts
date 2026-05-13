import type { Address } from "./user";

export type RestaurantStatus = "pending" | "approved" | "rejected" | "suspended";

export type DayOfWeek =
  | "sunday"
  | "monday"
  | "tuesday"
  | "wednesday"
  | "thursday"
  | "friday"
  | "saturday";

export interface WorkingHours {
  day: DayOfWeek;
  isOpen: boolean;
  openTime: string; // HH:mm
  closeTime: string; // HH:mm
}

export interface Restaurant {
  id: string;
  userId: string;
  name: string;
  nameEn?: string;
  description?: string;
  descriptionEn?: string;
  email: string;
  phone: string;
  logo?: string;
  coverImage?: string;
  images: string[];
  status: RestaurantStatus;
  isOpen: boolean;
  address: Address;
  cuisineTypes: string[];
  tags: string[];
  workingHours: WorkingHours[];
  rating: number;
  totalReviews: number;
  totalOrders: number;
  minimumOrder: number;
  deliveryTime: { min: number; max: number };
  deliveryFee: number;
  commissionRate: number;
  features: {
    acceptsOnlinePayment: boolean;
    hasDelivery: boolean;
    hasPickup: boolean;
    hasDineIn: boolean;
  };
  createdAt: string;
  updatedAt: string;
}

export interface MenuCategory {
  id: string;
  restaurantId: string;
  name: string;
  nameEn?: string;
  description?: string;
  image?: string;
  order: number;
  isActive: boolean;
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
  required: boolean;
  maxSelections: number;
  choices: { name: string; nameEn?: string; price: number; isDefault?: boolean }[];
}

export interface MenuItem {
  id: string;
  restaurantId: string;
  categoryId: string;
  name: string;
  nameEn?: string;
  description?: string;
  descriptionEn?: string;
  price: number;
  discountPrice?: number;
  image?: string;
  images: string[];
  preparationTime: number; // minutes
  calories?: number;
  isAvailable: boolean;
  isNewItem: boolean;
  isFeatured: boolean;
  addons: MenuAddon[];
  options: MenuOption[];
  tags: string[];
  allergens: string[];
  order: number;
  createdAt: string;
  updatedAt: string;
}
