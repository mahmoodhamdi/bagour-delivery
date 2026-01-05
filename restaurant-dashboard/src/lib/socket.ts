import { io, Socket } from 'socket.io-client';
import Cookies from 'js-cookie';
import { API_CONFIG, STORAGE_KEYS } from '@/config/constants';
import { useOrdersStore } from '@/stores/orders';

// Socket instance
let socket: Socket | null = null;

// Socket event types for restaurant dashboard
export interface RestaurantSocketEvents {
  // Order events
  'order:new': (data: OrderEventData) => void;
  'order:status': (data: OrderStatusData) => void;
  'order:status_updated': (data: OrderStatusData) => void;
  'order:cancelled': (data: OrderCancelledData) => void;
  'order:delivered': (data: OrderDeliveredData) => void;
  'restaurant:order_received': (data: OrderEventData) => void;
  'restaurant:order_cancelled': (data: OrderCancelledData) => void;

  // Driver events
  'order:driver_assigned': (data: DriverAssignedData) => void;
  'order:driver_location': (data: DriverLocationData) => void;

  // Chat events
  'chat:message': (data: ChatMessageData) => void;
  'chat:new_message': (data: ChatMessageData) => void;

  // Notification events
  'notification': (data: NotificationData) => void;
  'notification:new': (data: NotificationData) => void;
}

// Event data types
interface OrderEventData {
  orderId: string;
  orderNumber: string;
  customer?: {
    id: string;
    name: string;
    phone?: string;
  };
  items: Array<{
    menuItemId?: string;
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
  timestamp?: string;
}

interface OrderStatusData {
  orderId: string;
  orderNumber?: string;
  status: 'pending' | 'confirmed' | 'preparing' | 'ready' | 'picked_up' | 'on_the_way' | 'delivered' | 'cancelled';
  previousStatus?: string;
  timestamp: string;
  estimatedDeliveryTime?: string;
}

interface OrderCancelledData {
  orderId: string;
  orderNumber?: string;
  cancelledBy?: string;
  reason?: string;
  timestamp: string;
}

interface OrderDeliveredData {
  orderId: string;
  orderNumber: string;
  deliveredAt: string;
  total: number;
  timestamp: string;
}

interface DriverAssignedData {
  orderId: string;
  orderNumber?: string;
  driver: {
    id: string;
    name: string;
    phone?: string;
    vehicleType?: string;
    vehicleColor?: string;
    vehiclePlate?: string;
  };
  timestamp: string;
}

interface DriverLocationData {
  driverId: string;
  orderId: string;
  location: { lat: number; lng: number };
  timestamp: string;
}

interface ChatMessageData {
  chatId: string;
  senderId: string;
  senderName: string;
  message: string;
  messageType: 'text' | 'image' | 'system';
  timestamp: string;
}

interface NotificationData {
  title: string;
  titleAr: string;
  body: string;
  bodyAr: string;
  type: string;
  data?: Record<string, unknown>;
  timestamp: string;
}

// Connection state
let isConnected = false;
let reconnectAttempts = 0;
const MAX_RECONNECT_ATTEMPTS = 5;
let restaurantId: string | null = null;

// Event callbacks storage for reconnection
type EventCallback = (...args: unknown[]) => void;
const eventCallbacks: Map<string, Set<EventCallback>> = new Map();

/**
 * Play notification sound for new orders
 */
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

/**
 * Initialize socket connection for restaurant dashboard
 */
export const initSocket = (restId: string): Socket => {
  if (socket?.connected) {
    return socket;
  }

  restaurantId = restId;
  const token = Cookies.get(STORAGE_KEYS.accessToken);

  socket = io(API_CONFIG.socketUrl, {
    auth: { token },
    transports: ['websocket', 'polling'],
    reconnection: true,
    reconnectionAttempts: MAX_RECONNECT_ATTEMPTS,
    reconnectionDelay: 1000,
    reconnectionDelayMax: 5000,
  });

  // Connection events
  socket.on('connect', () => {
    console.log('Restaurant socket connected:', socket?.id);
    isConnected = true;
    reconnectAttempts = 0;

    // Join restaurant room
    if (restaurantId) {
      socket?.emit('join:restaurant', restaurantId);
    }
  });

  socket.on('disconnect', (reason) => {
    console.log('Restaurant socket disconnected:', reason);
    isConnected = false;
  });

  socket.on('connect_error', (error) => {
    console.error('Restaurant socket connection error:', error);
    isConnected = false;
    reconnectAttempts++;
  });

  // Setup default event handlers
  setupDefaultEventHandlers();

  // Re-register custom event callbacks after reconnection
  socket.on('connect', () => {
    eventCallbacks.forEach((callbacks, event) => {
      callbacks.forEach((callback) => {
        socket?.on(event, callback);
      });
    });
  });

  return socket;
};

/**
 * Setup default event handlers for order management
 */
const setupDefaultEventHandlers = (): void => {
  if (!socket) return;

  // Listen for new orders
  socket.on('order:new', (order: OrderEventData) => {
    console.log('New order received:', order);
    handleNewOrder(order);
  });

  socket.on('restaurant:order_received', (order: OrderEventData) => {
    console.log('Restaurant order received:', order);
    handleNewOrder(order);
  });

  // Listen for order status updates
  socket.on('order:status', (data: OrderStatusData) => {
    console.log('Order status updated:', data);
    const { updateOrder } = useOrdersStore.getState();
    updateOrder(data.orderId, { status: data.status });
  });

  socket.on('order:status_updated', (data: OrderStatusData) => {
    console.log('Order status updated:', data);
    const { updateOrder } = useOrdersStore.getState();
    updateOrder(data.orderId, { status: data.status });
  });

  // Listen for cancelled orders
  socket.on('order:cancelled', (data: OrderCancelledData) => {
    console.log('Order cancelled:', data);
    const { updateOrder } = useOrdersStore.getState();
    updateOrder(data.orderId, { status: 'cancelled' });
  });

  socket.on('restaurant:order_cancelled', (data: OrderCancelledData) => {
    console.log('Restaurant order cancelled:', data);
    const { updateOrder } = useOrdersStore.getState();
    updateOrder(data.orderId, { status: 'cancelled' });
  });

  // Listen for driver assignment
  socket.on('order:driver_assigned', (data: DriverAssignedData) => {
    console.log('Driver assigned:', data);
    // Could update order with driver info if needed
  });

  // Listen for order delivered
  socket.on('order:delivered', (data: OrderDeliveredData) => {
    console.log('Order delivered:', data);
    const { updateOrder } = useOrdersStore.getState();
    updateOrder(data.orderId, { status: 'delivered' });
  });
};

/**
 * Handle new order event
 */
const handleNewOrder = (order: OrderEventData): void => {
  const { addOrder } = useOrdersStore.getState();

  // Transform socket order data to store format
  addOrder({
    id: order.orderId || '',
    orderNumber: order.orderNumber,
    customerId: order.customer?.id || '',
    customerName: order.customer?.name || '',
    customerPhone: order.customer?.phone || '',
    items: order.items.map(item => ({
      menuItemId: item.menuItemId || '',
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
};

/**
 * Get current socket instance
 */
export const getSocket = (): Socket | null => socket;

/**
 * Check if socket is connected
 */
export const isSocketConnected = (): boolean => isConnected;

/**
 * Disconnect socket
 */
export const disconnectSocket = (): void => {
  if (socket) {
    socket.disconnect();
    socket = null;
    isConnected = false;
    restaurantId = null;
    eventCallbacks.clear();
  }
};

/**
 * Add event listener with type safety
 */
export const onSocketEvent = <K extends keyof RestaurantSocketEvents>(
  event: K,
  callback: RestaurantSocketEvents[K]
): void => {
  if (!socket) {
    console.warn('Socket not initialized. Call initSocket() first.');
    return;
  }

  // Store callback for reconnection
  if (!eventCallbacks.has(event)) {
    eventCallbacks.set(event, new Set());
  }
  eventCallbacks.get(event)?.add(callback as EventCallback);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  socket.on(event, callback as any);
};

/**
 * Remove event listener
 */
export const offSocketEvent = <K extends keyof RestaurantSocketEvents>(
  event: K,
  callback?: RestaurantSocketEvents[K]
): void => {
  if (!socket) return;

  if (callback) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    socket.off(event, callback as any);
    eventCallbacks.get(event)?.delete(callback as EventCallback);
  } else {
    socket.off(event);
    eventCallbacks.delete(event);
  }
};

/**
 * Subscribe to order updates
 */
export const subscribeToOrder = (orderId: string): void => {
  socket?.emit('order:subscribe', orderId);
};

/**
 * Unsubscribe from order updates
 */
export const unsubscribeFromOrder = (orderId: string): void => {
  socket?.emit('order:unsubscribe', orderId);
};

/**
 * Emit order accepted event
 */
export const emitOrderAccepted = (orderId: string, estimatedTime?: number): void => {
  socket?.emit('order:accepted', { orderId, estimatedTime });
};

/**
 * Emit order rejected event
 */
export const emitOrderRejected = (orderId: string, reason: string): void => {
  socket?.emit('order:rejected', { orderId, reason });
};

/**
 * Emit order status update
 */
export const emitOrderStatusUpdate = (orderId: string, status: string): void => {
  socket?.emit('order:status:update', { orderId, status });
};

/**
 * Join a chat room
 */
export const joinChatRoom = (chatId: string): void => {
  socket?.emit('chat:join', chatId);
};

/**
 * Leave a chat room
 */
export const leaveChatRoom = (chatId: string): void => {
  socket?.emit('chat:leave', chatId);
};

/**
 * Send a chat message
 */
export const sendChatMessage = (
  chatId: string,
  message: string,
  messageType: 'text' | 'image' = 'text'
): void => {
  socket?.emit('chat:send_message', {
    chatId,
    message,
    messageType,
    timestamp: new Date().toISOString(),
  });
};

/**
 * Mark chat as read
 */
export const markChatAsRead = (chatId: string): void => {
  socket?.emit('chat:mark_read', chatId);
};

/**
 * Emit custom event
 */
export const emitEvent = (event: string, data?: unknown): void => {
  socket?.emit(event, data);
};

/**
 * Reconnect socket manually
 */
export const reconnectSocket = (): void => {
  if (socket && restaurantId) {
    socket.disconnect();
    socket.connect();
  }
};

// Export types
export type {
  OrderEventData,
  OrderStatusData,
  OrderCancelledData,
  OrderDeliveredData,
  DriverAssignedData,
  DriverLocationData,
  ChatMessageData,
  NotificationData,
};
