import type { Address } from './user';

export type OrderStatus =
  | 'pending'
  | 'confirmed'
  | 'preparing'
  | 'ready'
  | 'picked_up'
  | 'on_the_way'
  | 'delivered'
  | 'cancelled';

export type PaymentMethod = 'cash' | 'card' | 'wallet';
export type PaymentStatus = 'pending' | 'paid' | 'failed' | 'refunded';

export interface OrderItem {
  menuItemId: string;
  name: string;
  nameEn?: string;
  quantity: number;
  price: number;
  discountPrice?: number;
  image?: string;
  addons: {
    name: string;
    price: number;
  }[];
  options: {
    name: string;
    choice: string;
    price: number;
  }[];
  specialInstructions?: string;
  itemTotal: number;
}

export interface OrderStatusHistory {
  status: OrderStatus;
  timestamp: Date;
  note?: string;
  updatedBy?: string;
}

export interface Order {
  id: string;
  orderNumber: string;
  customerId: string;
  restaurantId: string;
  driverId?: string;
  items: OrderItem[];
  subtotal: number;
  deliveryFee: number;
  serviceFee: number;
  tax: number;
  discount: number;
  tip: number;
  total: number;
  commission: number;
  restaurantEarnings: number;
  driverEarnings: number;
  status: OrderStatus;
  statusHistory: OrderStatusHistory[];
  paymentMethod: PaymentMethod;
  paymentStatus: PaymentStatus;
  paymentReference?: string;
  deliveryAddress: Address;
  deliveryLocation: {
    type: 'Point';
    coordinates: [number, number];
  };
  deliveryInstructions?: string;
  estimatedDeliveryTime?: Date;
  actualDeliveryTime?: Date;
  estimatedPickupTime?: Date;
  actualPickupTime?: Date;
  couponId?: string;
  couponCode?: string;
  notes?: string;
  cancelReason?: string;
  cancelledBy?: 'customer' | 'restaurant' | 'driver' | 'admin';
  rating?: {
    restaurant?: number;
    driver?: number;
    food?: number;
    overall?: number;
    comment?: string;
  };
  isScheduled: boolean;
  scheduledFor?: Date;
  createdAt: Date;
  updatedAt: Date;
}
