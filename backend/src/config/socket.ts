import { Server as HttpServer } from 'http';
import { Server as SocketServer, Socket } from 'socket.io';
import { config } from './index';
import { logger } from '../utils/logger';

let io: SocketServer | null = null;

export const initializeSocket = (httpServer: HttpServer): SocketServer => {
  io = new SocketServer(httpServer, {
    cors: {
      origin: config.corsOrigins,
      methods: ['GET', 'POST'],
      credentials: true,
    },
    pingTimeout: 60000,
    pingInterval: 25000,
  });

  io.on('connection', (socket: Socket) => {
    logger.info(`Client connected: ${socket.id}`);

    // Join user to their personal room (for targeted notifications)
    socket.on('join:user', (userId: string) => {
      socket.join(`user:${userId}`);
      logger.debug(`User ${userId} joined their room`);
    });

    // Join restaurant room (for order notifications)
    socket.on('join:restaurant', (restaurantId: string) => {
      socket.join(`restaurant:${restaurantId}`);
      logger.debug(`Restaurant ${restaurantId} joined their room`);
    });

    // Join driver room
    socket.on('join:driver', (driverId: string) => {
      socket.join(`driver:${driverId}`);
      logger.debug(`Driver ${driverId} joined their room`);
    });

    // Subscribe to order updates
    socket.on('order:subscribe', (orderId: string) => {
      socket.join(`order:${orderId}`);
      logger.debug(`Subscribed to order ${orderId}`);
    });

    // Unsubscribe from order updates
    socket.on('order:unsubscribe', (orderId: string) => {
      socket.leave(`order:${orderId}`);
      logger.debug(`Unsubscribed from order ${orderId}`);
    });

    // Driver location update
    socket.on('driver:location', (data: { driverId: string; orderId: string; location: { lat: number; lng: number } }) => {
      io?.to(`order:${data.orderId}`).emit('order:driver_location', {
        driverId: data.driverId,
        location: data.location,
        timestamp: new Date(),
      });
    });

    socket.on('disconnect', (reason) => {
      logger.info(`Client disconnected: ${socket.id}, reason: ${reason}`);
    });

    socket.on('error', (error) => {
      logger.error(`Socket error: ${error}`);
    });
  });

  logger.info('Socket.io initialized');
  return io;
};

export const getIO = (): SocketServer | null => io;

// Helper functions for emitting events
export const emitToUser = (userId: string, event: string, data: unknown): void => {
  io?.to(`user:${userId}`).emit(event, data);
};

export const emitToRestaurant = (restaurantId: string, event: string, data: unknown): void => {
  io?.to(`restaurant:${restaurantId}`).emit(event, data);
};

export const emitToDriver = (driverId: string, event: string, data: unknown): void => {
  io?.to(`driver:${driverId}`).emit(event, data);
};

export const emitToOrder = (orderId: string, event: string, data: unknown): void => {
  io?.to(`order:${orderId}`).emit(event, data);
};

export default initializeSocket;
