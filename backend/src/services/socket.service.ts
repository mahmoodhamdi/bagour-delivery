import { IOrder } from '../models/Order';
import { getIO, emitToUser, emitToRestaurant, emitToDriver, emitToOrder } from '../config/socket';
import { logger } from '../utils/logger';

// Event types for type safety
export const SOCKET_EVENTS = {
  // Order events
  ORDER_NEW: 'order:new',
  ORDER_STATUS_UPDATED: 'order:status_updated',
  ORDER_DRIVER_ASSIGNED: 'order:driver_assigned',
  ORDER_DRIVER_LOCATION: 'order:driver_location',
  ORDER_CANCELLED: 'order:cancelled',
  ORDER_DELIVERED: 'order:delivered',

  // Driver events
  DRIVER_ONLINE: 'driver:online',
  DRIVER_OFFLINE: 'driver:offline',
  DRIVER_LOCATION: 'driver:location',
  DRIVER_AVAILABLE_ORDER: 'driver:available_order',

  // Restaurant events
  RESTAURANT_ORDER_RECEIVED: 'restaurant:order_received',
  RESTAURANT_ORDER_CANCELLED: 'restaurant:order_cancelled',

  // Notification events
  NOTIFICATION: 'notification',
} as const;

interface OrderStatusPayload {
  orderId: string;
  orderNumber: string;
  status: string;
  previousStatus?: string;
  timestamp: Date;
  note?: string;
  estimatedDeliveryTime?: Date;
}

interface DriverLocationPayload {
  driverId: string;
  orderId: string;
  location: {
    lat: number;
    lng: number;
  };
  timestamp: Date;
}

interface DriverAssignedPayload {
  orderId: string;
  orderNumber: string;
  driver: {
    id: string;
    name: string;
    phone?: string;
    vehicleType?: string;
    vehicleColor?: string;
    vehiclePlate?: string;
  };
  timestamp: Date;
}

interface NewOrderPayload {
  orderId: string;
  orderNumber: string;
  customer: {
    id: string;
    name: string;
    phone?: string;
  };
  items: Array<{
    name: string;
    quantity: number;
    total: number;
  }>;
  total: number;
  deliveryAddress: {
    address: string;
    area: string;
  };
  timestamp: Date;
}

class SocketService {
  /**
   * Notify restaurant of a new order
   */
  notifyNewOrder(order: IOrder, restaurantId: string): void {
    try {
      const payload: NewOrderPayload = {
        orderId: order._id.toString(),
        orderNumber: order.orderNumber,
        customer: {
          id: order.customerId.toString(),
          name: (order as any).customer?.name || 'عميل',
          phone: (order as any).customer?.phone,
        },
        items: order.items.map((item) => ({
          name: item.nameAr || item.name,
          quantity: item.quantity,
          total: item.itemTotal,
        })),
        total: order.total,
        deliveryAddress: {
          address: order.deliveryAddress.address,
          area: order.deliveryAddress.area,
        },
        timestamp: new Date(),
      };

      // Emit to restaurant room
      emitToRestaurant(restaurantId, SOCKET_EVENTS.ORDER_NEW, payload);
      emitToRestaurant(restaurantId, SOCKET_EVENTS.RESTAURANT_ORDER_RECEIVED, payload);

      logger.info(`New order notification sent to restaurant: ${restaurantId}`);
    } catch (error) {
      logger.error('Error sending new order notification:', error);
    }
  }

  /**
   * Notify all parties of order status update
   */
  notifyOrderStatusUpdate(
    order: IOrder,
    previousStatus: string,
    customerId: string,
    restaurantId: string,
    driverId?: string
  ): void {
    try {
      const payload: OrderStatusPayload = {
        orderId: order._id.toString(),
        orderNumber: order.orderNumber,
        status: order.status,
        previousStatus,
        timestamp: new Date(),
        estimatedDeliveryTime: order.estimatedDeliveryTime,
      };

      // Emit to order room (anyone subscribed to this order)
      emitToOrder(order._id.toString(), SOCKET_EVENTS.ORDER_STATUS_UPDATED, payload);

      // Emit to customer
      emitToUser(customerId, SOCKET_EVENTS.ORDER_STATUS_UPDATED, payload);

      // Emit to restaurant
      emitToRestaurant(restaurantId, SOCKET_EVENTS.ORDER_STATUS_UPDATED, payload);

      // Emit to driver if assigned
      if (driverId) {
        emitToDriver(driverId, SOCKET_EVENTS.ORDER_STATUS_UPDATED, payload);
      }

      logger.info(`Order status update notification sent: ${order._id} -> ${order.status}`);
    } catch (error) {
      logger.error('Error sending order status update:', error);
    }
  }

  /**
   * Notify customer when driver is assigned
   */
  notifyDriverAssigned(
    order: IOrder,
    customerId: string,
    driver: { id: string; name: string; phone?: string; vehicleType?: string; vehicleColor?: string; vehiclePlate?: string }
  ): void {
    try {
      const payload: DriverAssignedPayload = {
        orderId: order._id.toString(),
        orderNumber: order.orderNumber,
        driver: {
          id: driver.id,
          name: driver.name,
          phone: driver.phone,
          vehicleType: driver.vehicleType,
          vehicleColor: driver.vehicleColor,
          vehiclePlate: driver.vehiclePlate,
        },
        timestamp: new Date(),
      };

      // Emit to customer
      emitToUser(customerId, SOCKET_EVENTS.ORDER_DRIVER_ASSIGNED, payload);

      // Emit to order room
      emitToOrder(order._id.toString(), SOCKET_EVENTS.ORDER_DRIVER_ASSIGNED, payload);

      logger.info(`Driver assigned notification sent: ${order._id}`);
    } catch (error) {
      logger.error('Error sending driver assigned notification:', error);
    }
  }

  /**
   * Broadcast driver location to order subscribers
   */
  broadcastDriverLocation(
    orderId: string,
    driverId: string,
    location: { lat: number; lng: number }
  ): void {
    try {
      const payload: DriverLocationPayload = {
        driverId,
        orderId,
        location,
        timestamp: new Date(),
      };

      // Emit to order room
      emitToOrder(orderId, SOCKET_EVENTS.ORDER_DRIVER_LOCATION, payload);

      logger.debug(`Driver location broadcast: ${orderId}`);
    } catch (error) {
      logger.error('Error broadcasting driver location:', error);
    }
  }

  /**
   * Notify all parties of order cancellation
   */
  notifyOrderCancelled(
    order: IOrder,
    customerId: string,
    restaurantId: string,
    cancelledBy: string,
    reason: string,
    driverId?: string
  ): void {
    try {
      const payload = {
        orderId: order._id.toString(),
        orderNumber: order.orderNumber,
        cancelledBy,
        reason,
        timestamp: new Date(),
      };

      // Emit to order room
      emitToOrder(order._id.toString(), SOCKET_EVENTS.ORDER_CANCELLED, payload);

      // Emit to customer
      emitToUser(customerId, SOCKET_EVENTS.ORDER_CANCELLED, payload);

      // Emit to restaurant
      emitToRestaurant(restaurantId, SOCKET_EVENTS.RESTAURANT_ORDER_CANCELLED, payload);

      // Emit to driver if assigned
      if (driverId) {
        emitToDriver(driverId, SOCKET_EVENTS.ORDER_CANCELLED, payload);
      }

      logger.info(`Order cancellation notification sent: ${order._id}`);
    } catch (error) {
      logger.error('Error sending order cancellation notification:', error);
    }
  }

  /**
   * Notify customer of successful delivery
   */
  notifyOrderDelivered(order: IOrder, customerId: string, restaurantId: string): void {
    try {
      const payload = {
        orderId: order._id.toString(),
        orderNumber: order.orderNumber,
        deliveredAt: order.deliveredAt,
        total: order.total,
        timestamp: new Date(),
      };

      // Emit to customer
      emitToUser(customerId, SOCKET_EVENTS.ORDER_DELIVERED, payload);

      // Emit to restaurant
      emitToRestaurant(restaurantId, SOCKET_EVENTS.ORDER_DELIVERED, payload);

      // Emit to order room
      emitToOrder(order._id.toString(), SOCKET_EVENTS.ORDER_DELIVERED, payload);

      logger.info(`Order delivered notification sent: ${order._id}`);
    } catch (error) {
      logger.error('Error sending order delivered notification:', error);
    }
  }

  /**
   * Notify available drivers of a new order ready for pickup
   */
  notifyDriversOfAvailableOrder(
    order: IOrder,
    restaurant: { name: string; address: string; location: { lat: number; lng: number } }
  ): void {
    try {
      const io = getIO();
      if (!io) return;

      const payload = {
        orderId: order._id.toString(),
        orderNumber: order.orderNumber,
        restaurant: {
          name: restaurant.name,
          address: restaurant.address,
          location: restaurant.location,
        },
        deliveryAddress: {
          address: order.deliveryAddress.address,
          area: order.deliveryAddress.area,
          location: order.deliveryAddress.location?.coordinates
            ? {
                lat: order.deliveryAddress.location.coordinates[1],
                lng: order.deliveryAddress.location.coordinates[0],
              }
            : null,
        },
        total: order.total,
        deliveryFee: order.deliveryFee,
        timestamp: new Date(),
      };

      // Broadcast to all online drivers room
      io.to('drivers:online').emit(SOCKET_EVENTS.DRIVER_AVAILABLE_ORDER, payload);

      logger.info(`Available order notification broadcasted: ${order._id}`);
    } catch (error) {
      logger.error('Error broadcasting available order:', error);
    }
  }

  /**
   * Send a notification to a specific user
   */
  sendNotification(
    userId: string,
    notification: {
      title: string;
      titleAr: string;
      body: string;
      bodyAr: string;
      type: string;
      data?: Record<string, unknown>;
    }
  ): void {
    try {
      emitToUser(userId, SOCKET_EVENTS.NOTIFICATION, {
        ...notification,
        timestamp: new Date(),
      });

      logger.debug(`Notification sent to user: ${userId}`);
    } catch (error) {
      logger.error('Error sending notification:', error);
    }
  }

  /**
   * Broadcast driver online status
   */
  broadcastDriverOnline(driverId: string, location: { lat: number; lng: number }): void {
    try {
      const io = getIO();
      if (!io) return;

      io.emit(SOCKET_EVENTS.DRIVER_ONLINE, {
        driverId,
        location,
        timestamp: new Date(),
      });

      logger.debug(`Driver online broadcast: ${driverId}`);
    } catch (error) {
      logger.error('Error broadcasting driver online:', error);
    }
  }

  /**
   * Broadcast driver offline status
   */
  broadcastDriverOffline(driverId: string): void {
    try {
      const io = getIO();
      if (!io) return;

      io.emit(SOCKET_EVENTS.DRIVER_OFFLINE, {
        driverId,
        timestamp: new Date(),
      });

      logger.debug(`Driver offline broadcast: ${driverId}`);
    } catch (error) {
      logger.error('Error broadcasting driver offline:', error);
    }
  }

  /**
   * Get connected socket count
   */
  getConnectedCount(): number {
    const io = getIO();
    return io?.engine?.clientsCount || 0;
  }

  /**
   * Get room member count
   */
  getRoomMemberCount(room: string): number {
    const io = getIO();
    return io?.sockets?.adapter?.rooms?.get(room)?.size || 0;
  }
}

export const socketService = new SocketService();
export default socketService;
