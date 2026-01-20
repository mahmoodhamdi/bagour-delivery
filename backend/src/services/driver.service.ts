import { Types } from 'mongoose';
import { Driver, IDriver } from '../models/Driver';
import { User } from '../models/User';
import { Zone } from '../models/Zone';
import { Order, IOrder } from '../models/Order';
import { NotFoundError, BadRequestError, ForbiddenError } from '../utils/errors';
import { ILocation } from '../types';
import { getIO, emitToRestaurant } from '../config/socket';
import { notificationService } from './notification.service';

interface UpdateDriverProfileInput {
  vehicleColor?: string;
  vehicleModel?: string;
  vehicleImage?: string;
  preferredZones?: string[];
}

interface UpdateLocationInput {
  latitude: number;
  longitude: number;
}

interface DriverStats {
  totalDeliveries: number;
  totalEarnings: number;
  currentBalance: number;
  rating: number;
  totalRatings: number;
  todayDeliveries: number;
  todayEarnings: number;
  weeklyDeliveries: number;
  weeklyEarnings: number;
}

class DriverService {
  /**
   * Get driver profile
   */
  async getProfile(driverId: string): Promise<IDriver> {
    const driver = await Driver.findById(driverId)
      .populate('userId', 'name email phone avatar')
      .populate('preferredZones', 'name nameAr')
      .lean();

    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    return driver as IDriver;
  }

  /**
   * Update driver profile
   */
  async updateProfile(
    driverId: string,
    updates: UpdateDriverProfileInput
  ): Promise<IDriver> {
    const driver = await Driver.findById(driverId);

    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    // Validate preferred zones
    if (updates.preferredZones && updates.preferredZones.length > 0) {
      const zones = await Zone.find({
        _id: { $in: updates.preferredZones },
        isActive: true,
      });

      if (zones.length !== updates.preferredZones.length) {
        throw new BadRequestError('بعض المناطق غير صالحة');
      }

      driver.preferredZones = updates.preferredZones.map(
        (id) => new Types.ObjectId(id)
      );
    }

    if (updates.vehicleColor) driver.vehicleColor = updates.vehicleColor;
    if (updates.vehicleModel) driver.vehicleModel = updates.vehicleModel;
    if (updates.vehicleImage) driver.vehicleImage = updates.vehicleImage;

    await driver.save();

    return driver.populate([
      { path: 'userId', select: 'name email phone avatar' },
      { path: 'preferredZones', select: 'name nameAr' },
    ]);
  }

  /**
   * Update driver avatar
   */
  async updateAvatar(driverId: string, avatarUrl: string): Promise<IDriver> {
    const driver = await Driver.findById(driverId);

    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    // Update the user's avatar
    await User.findByIdAndUpdate(driver.userId, { avatar: avatarUrl });

    return driver.populate('userId', 'name email phone avatar');
  }

  /**
   * Update driver location
   */
  async updateLocation(
    driverId: string,
    location: UpdateLocationInput
  ): Promise<IDriver> {
    // Validate coordinates
    if (
      location.latitude < -90 ||
      location.latitude > 90 ||
      location.longitude < -180 ||
      location.longitude > 180
    ) {
      throw new BadRequestError('إحداثيات الموقع غير صالحة');
    }

    // Validate location is within reasonable bounds for Egypt
    // Egypt bounds: lat 22-32, lng 24-37
    if (
      location.latitude < 22 ||
      location.latitude > 32 ||
      location.longitude < 24 ||
      location.longitude > 37
    ) {
      throw new BadRequestError('الموقع خارج نطاق الخدمة');
    }

    const driver = await Driver.findByIdAndUpdate(
      driverId,
      {
        currentLocation: {
          type: 'Point',
          coordinates: [location.longitude, location.latitude],
        },
        lastLocationUpdate: new Date(),
      },
      { new: true }
    );

    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    // Broadcast location update if driver has current order
    if (driver.currentOrderId) {
      const io = getIO();
      if (io) {
        io.to(`order:${driver.currentOrderId}`).emit('driver:location', {
          orderId: driver.currentOrderId,
          location: {
            latitude: location.latitude,
            longitude: location.longitude,
          },
          timestamp: new Date().toISOString(),
        });
      }
    }

    return driver;
  }

  /**
   * Toggle driver online status
   */
  async toggleOnlineStatus(driverId: string, isOnline: boolean): Promise<IDriver> {
    const driver = await Driver.findById(driverId);

    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    if (!driver.isApproved || driver.status !== 'approved') {
      throw new ForbiddenError('حسابك غير معتمد بعد');
    }

    if (!driver.isActive) {
      throw new ForbiddenError('حسابك موقوف');
    }

    driver.isOnline = isOnline;

    // If going offline, also set unavailable
    if (!isOnline) {
      driver.isAvailable = false;
    } else {
      // If going online and not busy, set as available
      if (!driver.isBusy) {
        driver.isAvailable = true;
      }
    }

    await driver.save();

    // Broadcast status change
    const io = getIO();
    if (io) {
      io.to('admin').emit('driver:status', {
        driverId: driver._id,
        isOnline: driver.isOnline,
        isAvailable: driver.isAvailable,
      });

      // Join/leave drivers:online room
      // Note: This would be handled on the socket connection side
    }

    return driver;
  }

  /**
   * Toggle driver availability
   */
  async toggleAvailability(driverId: string, isAvailable: boolean): Promise<IDriver> {
    const driver = await Driver.findById(driverId);

    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    if (!driver.isOnline) {
      throw new BadRequestError('يجب أن تكون متصلاً للتبديل للحالة متاح');
    }

    if (driver.isBusy) {
      throw new BadRequestError('لا يمكن تغيير الحالة أثناء التوصيل');
    }

    driver.isAvailable = isAvailable;
    await driver.save();

    // Broadcast status change
    const io = getIO();
    if (io) {
      io.to('admin').emit('driver:status', {
        driverId: driver._id,
        isOnline: driver.isOnline,
        isAvailable: driver.isAvailable,
      });
    }

    return driver;
  }

  /**
   * Get driver statistics
   */
  async getStats(driverId: string): Promise<DriverStats> {
    const driver = await Driver.findById(driverId);

    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    // Import Order model here to avoid circular dependency
    const { Order } = await import('../models/Order');

    const now = new Date();
    const startOfToday = new Date(now.setHours(0, 0, 0, 0));
    const startOfWeek = new Date(now);
    startOfWeek.setDate(startOfWeek.getDate() - 7);

    // Get today's stats
    const todayStats = await Order.aggregate([
      {
        $match: {
          driverId: new Types.ObjectId(driverId),
          status: 'delivered',
          updatedAt: { $gte: startOfToday },
        },
      },
      {
        $group: {
          _id: null,
          count: { $sum: 1 },
          earnings: { $sum: '$driverEarnings' },
        },
      },
    ]);

    // Get weekly stats
    const weeklyStats = await Order.aggregate([
      {
        $match: {
          driverId: new Types.ObjectId(driverId),
          status: 'delivered',
          updatedAt: { $gte: startOfWeek },
        },
      },
      {
        $group: {
          _id: null,
          count: { $sum: 1 },
          earnings: { $sum: '$driverEarnings' },
        },
      },
    ]);

    return {
      totalDeliveries: driver.totalDeliveries,
      totalEarnings: driver.totalEarnings,
      currentBalance: driver.currentBalance,
      rating: driver.rating,
      totalRatings: driver.totalRatings,
      todayDeliveries: todayStats[0]?.count || 0,
      todayEarnings: todayStats[0]?.earnings || 0,
      weeklyDeliveries: weeklyStats[0]?.count || 0,
      weeklyEarnings: weeklyStats[0]?.earnings || 0,
    };
  }

  /**
   * Update driver documents (for re-verification)
   */
  async updateDocuments(
    driverId: string,
    documents: {
      nationalIdImage?: string;
      nationalIdBackImage?: string;
      licenseImage?: string;
      licenseExpiryDate?: Date;
    }
  ): Promise<IDriver> {
    const driver = await Driver.findById(driverId);

    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    if (documents.nationalIdImage) driver.nationalIdImage = documents.nationalIdImage;
    if (documents.nationalIdBackImage) driver.nationalIdBackImage = documents.nationalIdBackImage;
    if (documents.licenseImage) driver.licenseImage = documents.licenseImage;
    if (documents.licenseExpiryDate) driver.licenseExpiryDate = documents.licenseExpiryDate;

    await driver.save();

    return driver;
  }

  /**
   * Get available zones for driver
   */
  async getAvailableZones(): Promise<unknown[]> {
    const zones = await Zone.find({ isActive: true })
      .select('name nameAr deliveryFee')
      .lean();

    return zones;
  }

  /**
   * Get nearby online drivers (for admin/system use)
   */
  async getNearbyDrivers(
    latitude: number,
    longitude: number,
    maxDistanceKm: number = 5
  ): Promise<IDriver[]> {
    const drivers = await Driver.find({
      isOnline: true,
      isAvailable: true,
      isApproved: true,
      status: 'approved',
      currentLocation: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [longitude, latitude],
          },
          $maxDistance: maxDistanceKm * 1000, // Convert to meters
        },
      },
    })
      .populate('userId', 'name phone')
      .lean();

    return drivers as IDriver[];
  }

  /**
   * Reject an assigned order
   */
  async rejectOrder(
    driverId: string,
    orderId: string,
    reason: string
  ): Promise<{
    order: IOrder;
    rejectedAt: Date;
  }> {
    const order = await Order.findById(orderId)
      .populate('restaurantId', 'name userId');

    if (!order) {
      throw new NotFoundError('الطلب غير موجود');
    }

    if (!order.driverId || order.driverId.toString() !== driverId) {
      throw new ForbiddenError('هذا الطلب غير مخصص لك');
    }

    const nonRejectableStatuses = ['delivered', 'cancelled'];
    if (nonRejectableStatuses.includes(order.status)) {
      throw new BadRequestError('لا يمكن رفض هذا الطلب');
    }

    const rejectedAt = new Date();

    // Update order - remove driver and set status back to 'ready' for reassignment
    order.driverId = undefined;
    order.status = 'ready';
    order.driverAssignedAt = undefined;
    order.statusHistory.push({
      status: 'ready',
      timestamp: rejectedAt,
      note: `تم رفض الطلب من السائق: ${reason}`,
      updatedBy: new Types.ObjectId(driverId),
    });

    await order.save();

    // Update driver - clear current order and increment rejection count
    const driver = await Driver.findById(driverId);
    if (driver) {
      driver.currentOrderId = undefined;
      driver.isBusy = false;
      driver.isAvailable = true;
      await driver.save();
    }

    // Socket notifications
    const io = getIO();

    // Notify restaurant about driver rejection
    emitToRestaurant(order.restaurantId._id.toString(), 'order:driver_rejected', {
      orderId: order._id,
      orderNumber: order.orderNumber,
      reason,
      driverId,
      rejectedAt,
    });

    // Broadcast to online drivers that order is available again
    if (io) {
      io.to('drivers:online').emit('order:available', {
        orderId: order._id,
        orderNumber: order.orderNumber,
        restaurantId: order.restaurantId._id,
        restaurantName: (order.restaurantId as unknown as { name: string }).name,
        deliveryAddress: order.deliveryAddress,
        total: order.total,
        status: 'ready',
      });
    }

    // Push notification to restaurant owner
    const restaurant = order.restaurantId as unknown as { userId: Types.ObjectId; name: string };
    if (restaurant.userId) {
      await notificationService.createAndSendNotification({
        userId: restaurant.userId.toString(),
        title: 'Driver Rejected Order',
        titleAr: 'السائق رفض الطلب',
        body: `Order #${order.orderNumber} was rejected. Reason: ${reason}`,
        bodyAr: `تم رفض الطلب #${order.orderNumber}. السبب: ${reason}`,
        type: 'order',
        data: {
          orderId: order._id.toString(),
          action: 'driver_rejected',
        },
      });
    }

    return {
      order,
      rejectedAt,
    };
  }
}

export const driverService = new DriverService();
export default driverService;
