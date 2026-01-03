import type { Address } from './user';

export type RestaurantStatus = 'pending' | 'approved' | 'rejected' | 'suspended';

export interface WorkingHours {
  day: 'sunday' | 'monday' | 'tuesday' | 'wednesday' | 'thursday' | 'friday' | 'saturday';
  isOpen: boolean;
  openTime: string; // HH:mm format
  closeTime: string; // HH:mm format
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
  deliveryTime: {
    min: number;
    max: number;
  };
  deliveryFee: number;
  commissionRate: number;
  bankDetails?: {
    bankName: string;
    accountNumber: string;
    accountHolderName: string;
  };
  features: {
    acceptsOnlinePayment: boolean;
    hasDelivery: boolean;
    hasPickup: boolean;
    hasDineIn: boolean;
  };
  createdAt: Date;
  updatedAt: Date;
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
  choices: {
    name: string;
    nameEn?: string;
    price: number;
    isDefault?: boolean;
  }[];
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
  preparationTime: number; // in minutes
  calories?: number;
  isAvailable: boolean;
  isNewItem: boolean;
  isFeatured: boolean;
  addons: MenuAddon[];
  options: MenuOption[];
  tags: string[];
  allergens: string[];
  order: number;
  createdAt: Date;
  updatedAt: Date;
}
