import { Server as HttpServer } from 'http';
import { Server as SocketServer, Socket } from 'socket.io';
import { ExtendedError } from 'socket.io/dist/namespace';
import { config } from './index';
import { logger } from '../utils/logger';
import { authService } from '../services/auth.service';

let io: SocketServer | null = null;

// Extended socket with user data
interface AuthenticatedSocket extends Socket {
  user?: {
    userId: string;
    role: string;
  };
}

// Socket authentication middleware
const authenticateSocket = async (
  socket: AuthenticatedSocket,
  next: (err?: ExtendedError) => void
) => {
  try {
    const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.replace('Bearer ', '');

    if (!token) {
      // Allow anonymous connections but don't set user
      logger.debug(`Anonymous socket connection: ${socket.id}`);
      return next();
    }

    try {
      const decoded = authService.verifyAccessToken(token);
      socket.user = {
        userId: decoded.userId,
        role: decoded.role,
      };
      logger.debug(`Authenticated socket connection: ${socket.id}, user: ${decoded.userId}`);
      next();
    } catch (error) {
      // Allow connection but don't authenticate
      logger.debug(`Socket authentication failed: ${socket.id}`);
      next();
    }
  } catch (error) {
    logger.error('Socket auth middleware error:', error);
    next();
  }
};

export const initializeSocket = (httpServer: HttpServer): SocketServer => {
  io = new SocketServer(httpServer, {
    cors: {
      origin: config.corsOrigins,
      methods: ['GET', 'POST'],
      credentials: true,
    },
    pingTimeout: 60000,
    pingInterval: 25000,
    transports: ['websocket', 'polling'],
  });

  // Apply authentication middleware
  io.use(authenticateSocket);

  io.on('connection', (socket: AuthenticatedSocket) => {
    logger.info(`Client connected: ${socket.id}${socket.user ? `, user: ${socket.user.userId}` : ' (anonymous)'}`);

    // Auto-join user room if authenticated
    if (socket.user) {
      socket.join(`user:${socket.user.userId}`);
      logger.debug(`User ${socket.user.userId} auto-joined their room`);
    }

    // Join user to their personal room (for targeted notifications)
    socket.on('join:user', (userId: string) => {
      // Only allow joining own room if authenticated
      if (socket.user && socket.user.userId === userId) {
        socket.join(`user:${userId}`);
        logger.debug(`User ${userId} joined their room`);
      } else if (!socket.user) {
        // Allow for backwards compatibility
        socket.join(`user:${userId}`);
        logger.debug(`User ${userId} joined their room (unauthenticated)`);
      }
    });

    // Join restaurant room (for order notifications)
    socket.on('join:restaurant', (restaurantId: string) => {
      // Allow restaurants to join their room
      if (socket.user?.role === 'restaurant' || socket.user?.role === 'admin' || !socket.user) {
        socket.join(`restaurant:${restaurantId}`);
        logger.debug(`Restaurant ${restaurantId} joined their room`);
      }
    });

    // Join driver room
    socket.on('join:driver', (driverId: string) => {
      // Allow drivers to join their room
      if (socket.user?.role === 'driver' || socket.user?.role === 'delivery' || socket.user?.role === 'admin' || !socket.user) {
        socket.join(`driver:${driverId}`);
        logger.debug(`Driver ${driverId} joined their room`);
      }
    });

    // Join online drivers room (for available order notifications)
    socket.on('driver:online', (data?: { location?: { lat: number; lng: number } }) => {
      if (socket.user?.role === 'driver' || socket.user?.role === 'delivery') {
        socket.join('drivers:online');
        logger.debug(`Driver ${socket.user.userId} is now online`);

        // Broadcast driver online status
        io?.emit('driver:status', {
          driverId: socket.user.userId,
          status: 'online',
          location: data?.location,
          timestamp: new Date(),
        });
      }
    });

    // Leave online drivers room
    socket.on('driver:offline', () => {
      if (socket.user?.role === 'driver' || socket.user?.role === 'delivery') {
        socket.leave('drivers:online');
        logger.debug(`Driver ${socket.user.userId} is now offline`);

        // Broadcast driver offline status
        io?.emit('driver:status', {
          driverId: socket.user.userId,
          status: 'offline',
          timestamp: new Date(),
        });
      }
    });

    // Subscribe to order updates
    socket.on('order:subscribe', (orderId: string) => {
      socket.join(`order:${orderId}`);
      logger.debug(`Socket ${socket.id} subscribed to order ${orderId}`);
    });

    // Unsubscribe from order updates
    socket.on('order:unsubscribe', (orderId: string) => {
      socket.leave(`order:${orderId}`);
      logger.debug(`Socket ${socket.id} unsubscribed from order ${orderId}`);
    });

    // Driver location update
    socket.on('driver:location', (data: { orderId?: string; location: { lat: number; lng: number } }) => {
      if (!socket.user) return;

      const driverId = socket.user.userId;

      // If there's an active order, broadcast to order room
      if (data.orderId) {
        io?.to(`order:${data.orderId}`).emit('order:driver_location', {
          driverId,
          orderId: data.orderId,
          location: data.location,
          timestamp: new Date(),
        });
      }

      // Also broadcast to admin (for monitoring)
      io?.to('admin').emit('driver:location_update', {
        driverId,
        location: data.location,
        orderId: data.orderId,
        timestamp: new Date(),
      });
    });

    // Admin room join
    socket.on('join:admin', () => {
      if (socket.user?.role === 'admin') {
        socket.join('admin');
        logger.debug(`Admin ${socket.user.userId} joined admin room`);
      }
    });

    // Handle disconnect
    socket.on('disconnect', (reason) => {
      logger.info(`Client disconnected: ${socket.id}, reason: ${reason}`);

      // If driver was online, mark as offline
      if (socket.user?.role === 'driver' || socket.user?.role === 'delivery') {
        io?.emit('driver:status', {
          driverId: socket.user.userId,
          status: 'offline',
          timestamp: new Date(),
        });
      }
    });

    socket.on('error', (error) => {
      logger.error(`Socket error for ${socket.id}:`, error);
    });
  });

  logger.info('Socket.io initialized with authentication');
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
