import { io, Socket } from 'socket.io-client';
import Cookies from 'js-cookie';
import { API_CONFIG, STORAGE_KEYS } from '@/config/constants';

let socket: Socket | null = null;

export const initializeSocket = (): Socket => {
  if (socket?.connected) {
    return socket;
  }

  const token = Cookies.get(STORAGE_KEYS.accessToken);

  socket = io(API_CONFIG.socketUrl, {
    auth: {
      token,
    },
    transports: ['websocket', 'polling'],
    autoConnect: true,
    reconnection: true,
    reconnectionAttempts: 5,
    reconnectionDelay: 1000,
  });

  socket.on('connect', () => {
    console.log('Socket connected:', socket?.id);
  });

  socket.on('disconnect', (reason) => {
    console.log('Socket disconnected:', reason);
  });

  socket.on('connect_error', (error) => {
    console.error('Socket connection error:', error);
  });

  return socket;
};

export const getSocket = (): Socket | null => {
  return socket;
};

export const disconnectSocket = (): void => {
  if (socket) {
    socket.disconnect();
    socket = null;
  }
};

export const joinRestaurantRoom = (restaurantId: string): void => {
  if (socket?.connected) {
    socket.emit('join:restaurant', restaurantId);
  }
};

export const leaveRestaurantRoom = (restaurantId: string): void => {
  if (socket?.connected) {
    socket.emit('leave:restaurant', restaurantId);
  }
};

// Socket event types
export type SocketEvents = {
  'order:new': (data: { orderId: string; orderNumber: string }) => void;
  'order:updated': (data: { orderId: string; status: string }) => void;
  'order:cancelled': (data: { orderId: string; reason: string }) => void;
  'restaurant:toggle': (data: { isOpen: boolean }) => void;
};

// Helper to add event listener with type safety
export const onSocketEvent = <K extends keyof SocketEvents>(
  event: K,
  callback: SocketEvents[K]
): void => {
  if (socket) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    socket.on(event, callback as any);
  }
};

// Helper to remove event listener
export const offSocketEvent = <K extends keyof SocketEvents>(
  event: K,
  callback?: SocketEvents[K]
): void => {
  if (socket) {
    if (callback) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      socket.off(event, callback as any);
    } else {
      socket.off(event);
    }
  }
};
