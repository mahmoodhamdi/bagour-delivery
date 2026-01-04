import { io, Socket } from 'socket.io-client';
import Cookies from 'js-cookie';
import { API_CONFIG, STORAGE_KEYS } from '@/config/constants';
import { useOrdersStore } from '@/stores/orders';

// Socket order type (different from store Order type)
interface SocketOrder {
  _id?: string;
  id?: string;
  orderNumber: string;
  customer?: {
    id: string;
    name: string;
    phone: string;
  };
  items: Array<{
    menuItemId: string;
    name: string;
    nameAr?: string;
    quantity: number;
    price: number;
    addons?: Array<{ name: string; price: number }>;
    specialInstructions?: string;
  }>;
  subtotal: number;
  deliveryFee: number;
  discount: number;
  total: number;
  status: 'pending' | 'confirmed' | 'preparing' | 'ready' | 'picked_up' | 'on_the_way' | 'delivered' | 'cancelled';
  paymentMethod: 'cash' | 'card' | 'wallet';
  paymentStatus: 'pending' | 'paid' | 'failed' | 'refunded';
  deliveryAddress?: {
    address?: string;
    area?: string;
    building?: string;
    floor?: string;
    apartment?: string;
    landmark?: string;
  };
  notes?: string;
  createdAt: string;
  updatedAt: string;
}

let socket: Socket | null = null;

export interface SocketEvents {
  'order:new': (order: SocketOrder) => void;
  'order:status': (data: { orderId: string; status: SocketOrder['status'] }) => void;
  'order:cancelled': (data: { orderId: string; reason?: string }) => void;
  'driver:assigned': (data: { orderId: string; driver: { id: string; name: string; phone: string } }) => void;
}

export const initSocket = (restaurantId: string): Socket => {
  if (socket?.connected) {
    return socket;
  }

  const token = Cookies.get(STORAGE_KEYS.accessToken);

  socket = io(API_CONFIG.socketUrl, {
    auth: { token },
    transports: ['websocket', 'polling'],
    reconnection: true,
    reconnectionAttempts: 5,
    reconnectionDelay: 1000,
  });

  socket.on('connect', () => {
    console.log('Socket connected');
    // Join restaurant room
    socket?.emit('join:restaurant', restaurantId);
  });

  socket.on('disconnect', (reason) => {
    console.log('Socket disconnected:', reason);
  });

  socket.on('connect_error', (error) => {
    console.error('Socket connection error:', error);
  });

  // Listen for new orders
  socket.on('order:new', (order: SocketOrder) => {
    console.log('New order received:', order);
    const { addOrder } = useOrdersStore.getState();
    addOrder({
      id: order._id || order.id || '',
      orderNumber: order.orderNumber,
      customerId: order.customer?.id || '',
      customerName: order.customer?.name || '',
      customerPhone: order.customer?.phone || '',
      items: order.items.map(item => ({
        menuItemId: item.menuItemId,
        name: item.name,
        nameEn: item.nameAr,
        quantity: item.quantity,
        price: item.price,
        addons: item.addons?.map(a => ({ name: a.name, price: a.price })),
        specialInstructions: item.specialInstructions,
      })),
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      discount: order.discount,
      total: order.total,
      status: order.status,
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,
      deliveryAddress: {
        street: order.deliveryAddress?.address || '',
        area: order.deliveryAddress?.area || '',
        buildingNumber: order.deliveryAddress?.building,
        floor: order.deliveryAddress?.floor,
        apartment: order.deliveryAddress?.apartment,
        landmark: order.deliveryAddress?.landmark,
      },
      notes: order.notes,
      createdAt: new Date(order.createdAt),
      updatedAt: new Date(order.updatedAt),
    });

    // Play notification sound
    playNotificationSound();
  });

  // Listen for order status updates
  socket.on('order:status', (data: { orderId: string; status: SocketOrder['status'] }) => {
    console.log('Order status updated:', data);
    const { updateOrder } = useOrdersStore.getState();
    updateOrder(data.orderId, { status: data.status });
  });

  // Listen for cancelled orders
  socket.on('order:cancelled', (data: { orderId: string; reason?: string }) => {
    console.log('Order cancelled:', data);
    const { updateOrder } = useOrdersStore.getState();
    updateOrder(data.orderId, { status: 'cancelled' });
  });

  // Listen for driver assignment
  socket.on('driver:assigned', (data) => {
    console.log('Driver assigned:', data);
    // Could update order with driver info if needed
  });

  return socket;
};

export const disconnectSocket = (): void => {
  if (socket) {
    socket.disconnect();
    socket = null;
  }
};

export const getSocket = (): Socket | null => socket;

// Play notification sound for new orders
const playNotificationSound = (): void => {
  try {
    const audio = new Audio('/sounds/notification.mp3');
    audio.volume = 0.5;
    audio.play().catch(() => {
      // Audio play failed, probably user hasn't interacted with page yet
    });
  } catch {
    // Audio not supported or file not found
  }
};

// Emit events
export const emitOrderAccepted = (orderId: string, estimatedTime?: number): void => {
  socket?.emit('order:accepted', { orderId, estimatedTime });
};

export const emitOrderRejected = (orderId: string, reason: string): void => {
  socket?.emit('order:rejected', { orderId, reason });
};

export const emitOrderStatusUpdate = (orderId: string, status: string): void => {
  socket?.emit('order:status:update', { orderId, status });
};
