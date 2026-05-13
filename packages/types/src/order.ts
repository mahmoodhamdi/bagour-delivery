import type { Address } from "./user";

export type OrderStatus =
  | "pending"
  | "confirmed"
  | "preparing"
  | "ready"
  | "picked_up"
  | "on_the_way"
  | "delivered"
  | "cancelled";

export type PaymentMethod = "cash" | "card" | "wallet";
export type PaymentStatus = "pending" | "paid" | "failed" | "refunded";

export interface OrderItemAddon {
  name: string;
  price: number;
}

export interface OrderItemOption {
  name: string;
  choice: string;
  price: number;
}

export interface OrderItem {
  menuItemId: string;
  name: string;
  nameEn?: string;
  quantity: number;
  price: number;
  discountPrice?: number;
  image?: string;
  addons: OrderItemAddon[];
  options: OrderItemOption[];
  specialInstructions?: string;
  itemTotal: number;
}

export interface OrderStatusHistoryEntry {
  status: OrderStatus;
  timestamp: string;
  note?: string;
  updatedBy?: string;
}

export interface OrderRating {
  restaurant?: number;
  driver?: number;
  food?: number;
  overall?: number;
  comment?: string;
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
  statusHistory: OrderStatusHistoryEntry[];
  paymentMethod: PaymentMethod;
  paymentStatus: PaymentStatus;
  paymentReference?: string;
  deliveryAddress: Address;
  deliveryLocation: {
    type: "Point";
    coordinates: [number, number];
  };
  deliveryInstructions?: string;
  estimatedDeliveryTime?: string;
  actualDeliveryTime?: string;
  estimatedPickupTime?: string;
  actualPickupTime?: string;
  couponId?: string;
  couponCode?: string;
  notes?: string;
  cancelReason?: string;
  cancelledBy?: "customer" | "restaurant" | "driver" | "admin";
  rating?: OrderRating;
  isScheduled: boolean;
  scheduledFor?: string;
  createdAt: string;
  updatedAt: string;
}
