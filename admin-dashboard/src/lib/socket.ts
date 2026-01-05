import { io, Socket } from 'socket.io-client';
import Cookies from 'js-cookie';
import { API_CONFIG, STORAGE_KEYS } from '@/config/constants';

// Socket instance
let socket: Socket | null = null;

// Socket event types for admin
export interface AdminSocketEvents {
  // Order events
  'order:new': (data: OrderEventData) => void;
  'order:status': (data: OrderStatusData) => void;
  'order:status_updated': (data: OrderStatusData) => void;
  'order:cancelled': (data: OrderCancelledData) => void;
  'order:delivered': (data: OrderDeliveredData) => void;

  // Driver events
  'driver:status': (data: DriverStatusData) => void;
  'driver:location_update': (data: DriverLocationData) => void;
  'driver:online': (data: DriverStatusData) => void;
  'driver:offline': (data: DriverStatusData) => void;

  // Restaurant events
  'restaurant:order_received': (data: OrderEventData) => void;
  'restaurant:order_cancelled': (data: OrderCancelledData) => void;

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
  restaurant?: {
    id: string;
    name: string;
  };
  items?: Array<{
    name: string;
    quantity: number;
    total: number;
  }>;
  total: number;
  deliveryAddress?: {
    address: string;
    area: string;
  };
  timestamp: string;
}

interface OrderStatusData {
  orderId: string;
  orderNumber: string;
  status: string;
  previousStatus?: string;
  timestamp: string;
  estimatedDeliveryTime?: string;
}

interface OrderCancelledData {
  orderId: string;
  orderNumber: string;
  cancelledBy: string;
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

interface DriverStatusData {
  driverId: string;
  status: 'online' | 'offline';
  location?: { lat: number; lng: number };
  timestamp: string;
}

interface DriverLocationData {
  driverId: string;
  location: { lat: number; lng: number };
  orderId?: string;
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

// Event callbacks storage
type EventCallback = (...args: unknown[]) => void;
const eventCallbacks: Map<string, Set<EventCallback>> = new Map();

/**
 * Initialize socket connection for admin dashboard
 */
export const initSocket = (): Socket => {
  if (socket?.connected) {
    return socket;
  }

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
    console.log('Admin socket connected:', socket?.id);
    isConnected = true;
    reconnectAttempts = 0;

    // Join admin room
    socket?.emit('join:admin');
  });

  socket.on('disconnect', (reason) => {
    console.log('Admin socket disconnected:', reason);
    isConnected = false;
  });

  socket.on('connect_error', (error) => {
    console.error('Admin socket connection error:', error);
    isConnected = false;
    reconnectAttempts++;
  });

  // Re-register all event callbacks after reconnection
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
    eventCallbacks.clear();
  }
};

/**
 * Add event listener with type safety
 */
export const onSocketEvent = <K extends keyof AdminSocketEvents>(
  event: K,
  callback: AdminSocketEvents[K]
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
export const offSocketEvent = <K extends keyof AdminSocketEvents>(
  event: K,
  callback?: AdminSocketEvents[K]
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
 * Subscribe to driver location updates
 */
export const subscribeToDriverLocation = (driverId: string): void => {
  socket?.emit('driver:subscribe', driverId);
};

/**
 * Unsubscribe from driver location updates
 */
export const unsubscribeFromDriverLocation = (driverId: string): void => {
  socket?.emit('driver:unsubscribe', driverId);
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
 * Emit custom event
 */
export const emitEvent = (event: string, data?: unknown): void => {
  socket?.emit(event, data);
};

/**
 * Reconnect socket manually
 */
export const reconnectSocket = (): void => {
  if (socket) {
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
  DriverStatusData,
  DriverLocationData,
  ChatMessageData,
  NotificationData,
};
