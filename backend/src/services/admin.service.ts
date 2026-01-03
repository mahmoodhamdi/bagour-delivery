import { Types } from 'mongoose';
import User, { IUser } from '@models/User';
import Restaurant, { IRestaurant } from '@models/Restaurant';
import Driver, { IDriver } from '@models/Driver';
import Order from '@models/Order';
import Transaction from '@models/Transaction';
import Zone, { IZone } from '@models/Zone';
import Setting, { ISetting } from '@models/Setting';
import { NotFoundError, BadRequestError } from '@utils/errors';
import { notificationService } from './notification.service';
import { logger } from '@utils/logger';

// Pagination result interface
interface IPaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  pages: number;
}

// Types
export interface DashboardStats {
  totalUsers: number;
  totalRestaurants: number;
  totalDrivers: number;
  totalOrders: number;
  todayOrders: number;
  activeOrders: number;
  todayRevenue: number;
  weekRevenue: number;
  monthlyRevenue: number;
  pendingRestaurants: number;
  pendingDrivers: number;
  onlineDrivers: number;
  deliveredToday: number;
  cancelledToday: number;
}

export interface RevenueData {
  date: string;
  revenue: number;
  orders: number;
  commission: number;
}

export interface UserListOptions {
  page?: number;
  limit?: number;
  search?: string;
  role?: string;
  status?: 'active' | 'blocked';
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface RestaurantListOptions {
  page?: number;
  limit?: number;
  search?: string;
  status?: 'pending' | 'approved' | 'rejected' | 'suspended';
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface DriverListOptions {
  page?: number;
  limit?: number;
  search?: string;
  status?: 'pending' | 'approved' | 'rejected' | 'suspended';
  isOnline?: boolean;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface ZoneInput {
  name: string;
  nameAr: string;
  deliveryFee: number;
  minOrderAmount: number;
  isActive?: boolean;
  coordinates?: {
    type: 'Polygon';
    coordinates: number[][][];
  };
}

class AdminService {
  // ==================== Dashboard ====================

  async getDashboardStats(): Promise<DashboardStats> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const startOfWeek = new Date(today);
    startOfWeek.setDate(today.getDate() - today.getDay());

    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    const [
      totalUsers,
      totalRestaurants,
      totalDrivers,
      totalOrders,
      todayOrders,
      activeOrders,
      pendingRestaurants,
      pendingDrivers,
      onlineDrivers,
      todayDelivered,
      todayCancelled,
      todayRevenueData,
      weekRevenueData,
      monthRevenueData,
    ] = await Promise.all([
      // Total counts
      User.countDocuments({ role: 'customer', isDeleted: { $ne: true } }),
      Restaurant.countDocuments({ isDeleted: { $ne: true } }),
      Driver.countDocuments({ isDeleted: { $ne: true } }),
      Order.countDocuments(),

      // Today's orders
      Order.countDocuments({ createdAt: { $gte: today } }),

      // Active orders
      Order.countDocuments({
        status: { $in: ['pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'on_the_way'] },
      }),

      // Pending approvals
      Restaurant.countDocuments({ status: 'pending' }),
      Driver.countDocuments({ status: 'pending' }),

      // Online drivers
      Driver.countDocuments({ isOnline: true, status: 'approved' }),

      // Today delivered/cancelled
      Order.countDocuments({ status: 'delivered', updatedAt: { $gte: today } }),
      Order.countDocuments({ status: 'cancelled', updatedAt: { $gte: today } }),

      // Revenue aggregations
      Order.aggregate([
        { $match: { createdAt: { $gte: today }, status: 'delivered' } },
        { $group: { _id: null, total: { $sum: '$totalAmount' } } },
      ]),
      Order.aggregate([
        { $match: { createdAt: { $gte: startOfWeek }, status: 'delivered' } },
        { $group: { _id: null, total: { $sum: '$totalAmount' } } },
      ]),
      Order.aggregate([
        { $match: { createdAt: { $gte: startOfMonth }, status: 'delivered' } },
        { $group: { _id: null, total: { $sum: '$totalAmount' } } },
      ]),
    ]);

    return {
      totalUsers,
      totalRestaurants,
      totalDrivers,
      totalOrders,
      todayOrders,
      activeOrders,
      todayRevenue: todayRevenueData[0]?.total || 0,
      weekRevenue: weekRevenueData[0]?.total || 0,
      monthlyRevenue: monthRevenueData[0]?.total || 0,
      pendingRestaurants,
      pendingDrivers,
      onlineDrivers,
      deliveredToday: todayDelivered,
      cancelledToday: todayCancelled,
    };
  }

  async getRevenueChart(days: number = 30): Promise<RevenueData[]> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    startDate.setHours(0, 0, 0, 0);

    const revenue = await Order.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: 'delivered',
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: '%Y-%m-%d', date: '$createdAt' },
          },
          revenue: { $sum: '$totalAmount' },
          orders: { $sum: 1 },
          commission: { $sum: '$platformFee' },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    return revenue.map((item) => ({
      date: item._id,
      revenue: item.revenue,
      orders: item.orders,
      commission: item.commission || 0,
    }));
  }

  async getRecentOrders(limit: number = 10) {
    return Order.find()
      .sort({ createdAt: -1 })
      .limit(limit)
      .populate('customerId', 'name phone')
      .populate('restaurantId', 'name logo')
      .populate('driverId', 'name phone')
      .select('orderNumber status totalAmount createdAt');
  }

  async getTopRestaurants(limit: number = 5) {
    return Order.aggregate([
      { $match: { status: 'delivered' } },
      {
        $group: {
          _id: '$restaurantId',
          totalOrders: { $sum: 1 },
          totalRevenue: { $sum: '$totalAmount' },
        },
      },
      { $sort: { totalOrders: -1 } },
      { $limit: limit },
      {
        $lookup: {
          from: 'restaurants',
          localField: '_id',
          foreignField: '_id',
          as: 'restaurant',
        },
      },
      { $unwind: '$restaurant' },
      {
        $project: {
          _id: '$restaurant._id',
          name: '$restaurant.name',
          logo: '$restaurant.logo',
          totalOrders: 1,
          totalRevenue: 1,
        },
      },
    ]);
  }

  // ==================== Users Management ====================

  async getUsers(options: UserListOptions): Promise<IPaginatedResult<IUser>> {
    const {
      page = 1,
      limit = 20,
      search,
      role,
      status,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = options;

    const query: Record<string, unknown> = {
      isDeleted: { $ne: true },
    };

    if (role) {
      query.role = role;
    }

    if (status === 'blocked') {
      query.isBlocked = true;
    } else if (status === 'active') {
      query.isBlocked = { $ne: true };
    }

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (page - 1) * limit;
    const sort: Record<string, 1 | -1> = { [sortBy]: sortOrder === 'asc' ? 1 : -1 };

    const [data, total] = await Promise.all([
      User.find(query)
        .sort(sort)
        .skip(skip)
        .limit(limit)
        .select('-password -refreshToken'),
      User.countDocuments(query),
    ]);

    return {
      data,
      total,
      page,
      limit,
      pages: Math.ceil(total / limit),
    };
  }

  async getUserById(userId: string): Promise<IUser> {
    const user = await User.findById(userId).select('-password -refreshToken');
    if (!user) {
      throw new NotFoundError('المستخدم غير موجود');
    }
    return user;
  }

  async blockUser(userId: string, blocked: boolean): Promise<IUser> {
    const user = await User.findByIdAndUpdate(
      userId,
      { isBlocked: blocked },
      { new: true }
    ).select('-password -refreshToken');

    if (!user) {
      throw new NotFoundError('المستخدم غير موجود');
    }

    return user;
  }

  async deleteUser(userId: string): Promise<void> {
    const user = await User.findByIdAndUpdate(userId, { isDeleted: true });
    if (!user) {
      throw new NotFoundError('المستخدم غير موجود');
    }
  }

  // ==================== Restaurant Management ====================

  async getRestaurants(options: RestaurantListOptions): Promise<IPaginatedResult<IRestaurant>> {
    const {
      page = 1,
      limit = 20,
      search,
      status,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = options;

    const query: Record<string, unknown> = {
      isDeleted: { $ne: true },
    };

    if (status) {
      query.status = status;
    }

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { 'address.city': { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (page - 1) * limit;
    const sort: Record<string, 1 | -1> = { [sortBy]: sortOrder === 'asc' ? 1 : -1 };

    const [data, total] = await Promise.all([
      Restaurant.find(query)
        .sort(sort)
        .skip(skip)
        .limit(limit)
        .populate('ownerId', 'name email phone'),
      Restaurant.countDocuments(query),
    ]);

    return {
      data,
      total,
      page,
      limit,
      pages: Math.ceil(total / limit),
    };
  }

  async getRestaurantById(restaurantId: string): Promise<IRestaurant> {
    const restaurant = await Restaurant.findById(restaurantId)
      .populate('ownerId', 'name email phone');

    if (!restaurant) {
      throw new NotFoundError('المطعم غير موجود');
    }
    return restaurant;
  }

  async approveRestaurant(restaurantId: string): Promise<IRestaurant> {
    const restaurant = await Restaurant.findByIdAndUpdate(
      restaurantId,
      { status: 'approved', approvedAt: new Date() },
      { new: true }
    );

    if (!restaurant) {
      throw new NotFoundError('المطعم غير موجود');
    }

    // Send approval notification to restaurant owner
    try {
      if (restaurant.userId) {
        await notificationService.sendRestaurantApprovalNotification(
          restaurant.userId.toString(),
          restaurant.nameAr || restaurant.name,
          true
        );
      }
    } catch (notifError) {
      logger.error(`Failed to send restaurant approval notification: ${notifError}`);
    }

    return restaurant;
  }

  async rejectRestaurant(restaurantId: string, reason: string): Promise<IRestaurant> {
    const restaurant = await Restaurant.findByIdAndUpdate(
      restaurantId,
      { status: 'rejected', rejectionReason: reason },
      { new: true }
    );

    if (!restaurant) {
      throw new NotFoundError('المطعم غير موجود');
    }

    // Send rejection notification to restaurant owner
    try {
      if (restaurant.userId) {
        await notificationService.sendRestaurantApprovalNotification(
          restaurant.userId.toString(),
          restaurant.nameAr || restaurant.name,
          false
        );
      }
    } catch (notifError) {
      logger.error(`Failed to send restaurant rejection notification: ${notifError}`);
    }

    return restaurant;
  }

  async suspendRestaurant(restaurantId: string, reason: string): Promise<IRestaurant> {
    const restaurant = await Restaurant.findByIdAndUpdate(
      restaurantId,
      { status: 'suspended', suspensionReason: reason },
      { new: true }
    );

    if (!restaurant) {
      throw new NotFoundError('المطعم غير موجود');
    }

    return restaurant;
  }

  async activateRestaurant(restaurantId: string): Promise<IRestaurant> {
    const restaurant = await Restaurant.findByIdAndUpdate(
      restaurantId,
      { status: 'approved', suspensionReason: null },
      { new: true }
    );

    if (!restaurant) {
      throw new NotFoundError('المطعم غير موجود');
    }

    return restaurant;
  }

  // ==================== Driver Management ====================

  async getDrivers(options: DriverListOptions): Promise<IPaginatedResult<IDriver>> {
    const {
      page = 1,
      limit = 20,
      search,
      status,
      isOnline,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = options;

    const query: Record<string, unknown> = {
      isDeleted: { $ne: true },
    };

    if (status) {
      query.status = status;
    }

    if (typeof isOnline === 'boolean') {
      query.isOnline = isOnline;
    }

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } },
        { vehiclePlate: { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (page - 1) * limit;
    const sort: Record<string, 1 | -1> = { [sortBy]: sortOrder === 'asc' ? 1 : -1 };

    const [data, total] = await Promise.all([
      Driver.find(query)
        .sort(sort)
        .skip(skip)
        .limit(limit)
        .populate('userId', 'name email phone'),
      Driver.countDocuments(query),
    ]);

    return {
      data,
      total,
      page,
      limit,
      pages: Math.ceil(total / limit),
    };
  }

  async getDriverById(driverId: string): Promise<IDriver> {
    const driver = await Driver.findById(driverId)
      .populate('userId', 'name email phone');

    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }
    return driver;
  }

  async approveDriver(driverId: string): Promise<IDriver> {
    const driver = await Driver.findByIdAndUpdate(
      driverId,
      { status: 'approved', approvedAt: new Date() },
      { new: true }
    );

    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    // Update user role
    await User.findByIdAndUpdate(driver.userId, { role: 'driver' });

    // Send approval notification to driver
    try {
      if (driver.userId) {
        await notificationService.sendDriverApprovalNotification(
          driver.userId.toString(),
          true
        );
      }
    } catch (notifError) {
      logger.error(`Failed to send driver approval notification: ${notifError}`);
    }

    return driver;
  }

  async rejectDriver(driverId: string, reason: string): Promise<IDriver> {
    const driver = await Driver.findByIdAndUpdate(
      driverId,
      { status: 'rejected', rejectionReason: reason },
      { new: true }
    );

    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    // Send rejection notification to driver
    try {
      if (driver.userId) {
        await notificationService.sendDriverApprovalNotification(
          driver.userId.toString(),
          false
        );
      }
    } catch (notifError) {
      logger.error(`Failed to send driver rejection notification: ${notifError}`);
    }

    return driver;
  }

  async suspendDriver(driverId: string, reason: string): Promise<IDriver> {
    const driver = await Driver.findByIdAndUpdate(
      driverId,
      { status: 'suspended', suspensionReason: reason, isOnline: false },
      { new: true }
    );

    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    return driver;
  }

  async activateDriver(driverId: string): Promise<IDriver> {
    const driver = await Driver.findByIdAndUpdate(
      driverId,
      { status: 'approved', suspensionReason: null },
      { new: true }
    );

    if (!driver) {
      throw new NotFoundError('السائق غير موجود');
    }

    return driver;
  }

  // ==================== Zone Management ====================

  async getZones(): Promise<IZone[]> {
    return Zone.find({ isDeleted: { $ne: true } }).sort({ name: 1 });
  }

  async getZoneById(zoneId: string): Promise<IZone> {
    const zone = await Zone.findById(zoneId);
    if (!zone) {
      throw new NotFoundError('المنطقة غير موجودة');
    }
    return zone;
  }

  async createZone(input: ZoneInput): Promise<IZone> {
    const zone = new Zone(input);
    await zone.save();
    return zone;
  }

  async updateZone(zoneId: string, input: Partial<ZoneInput>): Promise<IZone> {
    const zone = await Zone.findByIdAndUpdate(zoneId, input, { new: true });
    if (!zone) {
      throw new NotFoundError('المنطقة غير موجودة');
    }
    return zone;
  }

  async deleteZone(zoneId: string): Promise<void> {
    const zone = await Zone.findByIdAndUpdate(zoneId, { isDeleted: true });
    if (!zone) {
      throw new NotFoundError('المنطقة غير موجودة');
    }
  }

  // ==================== Settings Management ====================

  async getSettings(): Promise<ISetting | null> {
    return Setting.findOne();
  }

  async updateSettings(settings: Partial<ISetting>): Promise<ISetting> {
    let setting = await Setting.findOne();

    if (!setting) {
      setting = new Setting(settings);
    } else {
      Object.assign(setting, settings);
    }

    await setting.save();
    return setting;
  }

  // ==================== Analytics ====================

  async getOrdersAnalytics(startDate: Date, endDate: Date) {
    return Order.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate, $lte: endDate },
        },
      },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
          totalAmount: { $sum: '$totalAmount' },
        },
      },
    ]);
  }

  async getPopularItems(limit: number = 10) {
    return Order.aggregate([
      { $unwind: '$items' },
      {
        $group: {
          _id: '$items.menuItemId',
          name: { $first: '$items.name' },
          orderCount: { $sum: '$items.quantity' },
          revenue: { $sum: { $multiply: ['$items.price', '$items.quantity'] } },
        },
      },
      { $sort: { orderCount: -1 } },
      { $limit: limit },
    ]);
  }

  async getCustomerStats() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    const [
      totalCustomers,
      newToday,
      newThisMonth,
      activeCustomers,
    ] = await Promise.all([
      User.countDocuments({ role: 'customer', isDeleted: { $ne: true } }),
      User.countDocuments({ role: 'customer', createdAt: { $gte: today } }),
      User.countDocuments({ role: 'customer', createdAt: { $gte: startOfMonth } }),
      Order.distinct('customerId', {
        createdAt: { $gte: startOfMonth },
      }).then((ids) => ids.length),
    ]);

    return {
      totalCustomers,
      newToday,
      newThisMonth,
      activeCustomers,
    };
  }

  async getFinancialSummary(startDate?: Date, endDate?: Date) {
    const matchQuery: Record<string, unknown> = {};

    if (startDate && endDate) {
      matchQuery.createdAt = { $gte: startDate, $lte: endDate };
    }

    const [orderRevenue, transactionSummary] = await Promise.all([
      Order.aggregate([
        { $match: { ...matchQuery, status: 'delivered' } },
        {
          $group: {
            _id: null,
            totalRevenue: { $sum: '$totalAmount' },
            totalDeliveryFees: { $sum: '$deliveryFee' },
            totalPlatformFees: { $sum: '$platformFee' },
            orderCount: { $sum: 1 },
          },
        },
      ]),
      Transaction.aggregate([
        { $match: matchQuery },
        {
          $group: {
            _id: '$type',
            total: { $sum: '$amount' },
            count: { $sum: 1 },
          },
        },
      ]),
    ]);

    return {
      revenue: orderRevenue[0] || {
        totalRevenue: 0,
        totalDeliveryFees: 0,
        totalPlatformFees: 0,
        orderCount: 0,
      },
      transactions: transactionSummary,
    };
  }
}

export const adminService = new AdminService();
