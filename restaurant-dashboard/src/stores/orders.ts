import { create } from 'zustand';

export interface OrderItem {
  menuItemId: string;
  name: string;
  nameEn?: string;
  quantity: number;
  price: number;
  addons?: {
    name: string;
    price: number;
  }[];
  specialInstructions?: string;
}

export interface Order {
  id: string;
  orderNumber: string;
  customerId: string;
  customerName: string;
  customerPhone: string;
  items: OrderItem[];
  subtotal: number;
  deliveryFee: number;
  discount: number;
  total: number;
  status:
    | 'pending'
    | 'confirmed'
    | 'preparing'
    | 'ready'
    | 'picked_up'
    | 'on_the_way'
    | 'delivered'
    | 'cancelled';
  paymentMethod: 'cash' | 'card' | 'wallet';
  paymentStatus: 'pending' | 'paid' | 'failed' | 'refunded';
  deliveryAddress: {
    street: string;
    area: string;
    buildingNumber?: string;
    floor?: string;
    apartment?: string;
    landmark?: string;
  };
  notes?: string;
  estimatedDeliveryTime?: Date;
  createdAt: Date;
  updatedAt: Date;
}

interface OrdersState {
  orders: Order[];
  activeOrders: Order[];
  selectedOrder: Order | null;
  isLoading: boolean;
  error: string | null;

  // Statistics
  todayOrdersCount: number;
  pendingOrdersCount: number;

  // Actions
  setOrders: (orders: Order[]) => void;
  addOrder: (order: Order) => void;
  updateOrder: (orderId: string, updates: Partial<Order>) => void;
  removeOrder: (orderId: string) => void;
  setSelectedOrder: (order: Order | null) => void;
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
  clearOrders: () => void;
}

export const useOrdersStore = create<OrdersState>((set, get) => ({
  orders: [],
  activeOrders: [],
  selectedOrder: null,
  isLoading: false,
  error: null,
  todayOrdersCount: 0,
  pendingOrdersCount: 0,

  setOrders: (orders) => {
    const activeOrders = orders.filter(
      (order) =>
        !['delivered', 'cancelled'].includes(order.status)
    );
    const pendingOrdersCount = orders.filter(
      (order) => order.status === 'pending'
    ).length;

    set({
      orders,
      activeOrders,
      pendingOrdersCount,
      todayOrdersCount: orders.length,
    });
  },

  addOrder: (order) => {
    const { orders, activeOrders } = get();
    const newOrders = [order, ...orders];
    const newActiveOrders = !['delivered', 'cancelled'].includes(order.status)
      ? [order, ...activeOrders]
      : activeOrders;

    set({
      orders: newOrders,
      activeOrders: newActiveOrders,
      todayOrdersCount: newOrders.length,
      pendingOrdersCount:
        order.status === 'pending'
          ? get().pendingOrdersCount + 1
          : get().pendingOrdersCount,
    });
  },

  updateOrder: (orderId, updates) => {
    const { orders, activeOrders, selectedOrder } = get();

    const updateOrderInList = (list: Order[]) =>
      list.map((order) =>
        order.id === orderId ? { ...order, ...updates } : order
      );

    const updatedOrders = updateOrderInList(orders);
    const updatedActiveOrders = updatedOrders.filter(
      (order) => !['delivered', 'cancelled'].includes(order.status)
    );

    set({
      orders: updatedOrders,
      activeOrders: updatedActiveOrders,
      selectedOrder:
        selectedOrder?.id === orderId
          ? { ...selectedOrder, ...updates }
          : selectedOrder,
      pendingOrdersCount: updatedOrders.filter((o) => o.status === 'pending')
        .length,
    });
  },

  removeOrder: (orderId) => {
    const { orders, activeOrders, selectedOrder } = get();

    set({
      orders: orders.filter((order) => order.id !== orderId),
      activeOrders: activeOrders.filter((order) => order.id !== orderId),
      selectedOrder: selectedOrder?.id === orderId ? null : selectedOrder,
    });
  },

  setSelectedOrder: (order) => set({ selectedOrder: order }),

  setLoading: (isLoading) => set({ isLoading }),

  setError: (error) => set({ error }),

  clearOrders: () =>
    set({
      orders: [],
      activeOrders: [],
      selectedOrder: null,
      todayOrdersCount: 0,
      pendingOrdersCount: 0,
    }),
}));
