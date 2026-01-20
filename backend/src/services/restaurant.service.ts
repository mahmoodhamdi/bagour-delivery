import { Types, SortOrder } from 'mongoose';
import mongoose from 'mongoose';
import { Restaurant, IRestaurant } from '../models/Restaurant';
import { MenuCategory } from '../models/MenuCategory';
import { MenuItem } from '../models/MenuItem';
import { Order } from '../models/Order';
import { Review } from '../models/Review';
import { Setting } from '../models/Setting';
import { User } from '../models';
import { AppError } from '../utils/errors';
import { StatusCodes } from 'http-status-codes';
import slugify from 'slugify';

// Types
interface CreateRestaurantData {
  userId: string;
  name: string;
  nameAr: string;
  description?: string;
  descriptionAr?: string;
  phone: string;
  whatsapp?: string;
  address: string;
  area: string;
  coordinates?: { lat: number; lng: number };
  categories?: string[];
  priceRange?: 1 | 2 | 3;
  minimumOrder?: number;
  deliveryFee?: number;
  estimatedDeliveryTime?: { min: number; max: number };
}

interface UpdateRestaurantData {
  name?: string;
  nameAr?: string;
  description?: string;
  descriptionAr?: string;
  phone?: string;
  whatsapp?: string;
  address?: string;
  area?: string;
  categories?: string[];
  priceRange?: 1 | 2 | 3;
  minimumOrder?: number;
  deliveryFee?: number;
  freeDeliveryAbove?: number;
  estimatedDeliveryTime?: { min: number; max: number };
  acceptsCash?: boolean;
  acceptsOnlinePayment?: boolean;
  autoAcceptOrders?: boolean;
  logo?: string;
  coverImage?: string;
  images?: string[];
}

interface SearchRestaurantsOptions {
  query?: string;
  category?: string;
  area?: string;
  priceRange?: number;
  isOpen?: boolean;
  lat?: number;
  lng?: number;
  maxDistance?: number;
  sortBy?: 'rating' | 'deliveryTime' | 'minimumOrder' | 'distance';
  sortOrder?: 'asc' | 'desc';
  page?: number;
  limit?: number;
}

interface PaginatedResult<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}

class RestaurantService {
  /**
   * Create a new restaurant
   */
  async createRestaurant(data: CreateRestaurantData): Promise<IRestaurant> {
    // Check if user already has a restaurant
    const existingRestaurant = await Restaurant.findOne({ userId: data.userId });
    if (existingRestaurant) {
      throw new AppError('لديك مطعم مسجل بالفعل', StatusCodes.CONFLICT);
    }

    // Check if user exists and has restaurant role
    const user = await User.findById(data.userId);
    if (!user) {
      throw new AppError('المستخدم غير موجود', StatusCodes.NOT_FOUND);
    }

    // Generate unique slug
    let slug = slugify(data.name, { lower: true, strict: true });
    const existingSlug = await Restaurant.findOne({ slug });
    if (existingSlug) {
      slug = `${slug}-${Date.now()}`;
    }

    // Create restaurant
    const restaurant = await Restaurant.create({
      userId: data.userId,
      name: data.name,
      nameAr: data.nameAr,
      description: data.description,
      descriptionAr: data.descriptionAr,
      slug,
      phone: data.phone,
      whatsapp: data.whatsapp,
      address: data.address,
      area: data.area,
      location: data.coordinates ? {
        type: 'Point',
        coordinates: [data.coordinates.lng, data.coordinates.lat],
      } : undefined,
      categories: data.categories || [],
      priceRange: data.priceRange || 2,
      minimumOrder: data.minimumOrder || 30,
      deliveryFee: data.deliveryFee || 10,
      estimatedDeliveryTime: data.estimatedDeliveryTime || { min: 30, max: 60 },
      isApproved: false,
      isActive: true,
      isPaused: false,
    });

    return restaurant;
  }

  /**
   * Get restaurant by user ID
   */
  async getRestaurantByUserId(userId: string): Promise<IRestaurant | null> {
    return Restaurant.findOne({ userId })
      .populate('userId', 'name email phone isPhoneVerified isEmailVerified');
  }

  /**
   * Get restaurant by ID
   */
  async getRestaurantById(id: string): Promise<IRestaurant | null> {
    if (!Types.ObjectId.isValid(id)) {
      throw new AppError('معرف المطعم غير صالح', StatusCodes.BAD_REQUEST);
    }
    return Restaurant.findById(id);
  }

  /**
   * Get restaurant by slug
   */
  async getRestaurantBySlug(slug: string, includePrivate = false): Promise<IRestaurant | null> {
    const query: Record<string, unknown> = { slug };

    if (!includePrivate) {
      query.isApproved = true;
      query.isActive = true;
    }

    const queryBuilder = Restaurant.findOne(query);
    if (!includePrivate) {
      queryBuilder.select('-userId -totalRevenue -commission -approvedBy -rejectionReason -subscription');
    }
    return queryBuilder;
  }

  /**
   * Update restaurant
   */
  async updateRestaurant(userId: string, updates: UpdateRestaurantData): Promise<IRestaurant> {
    const restaurant = await Restaurant.findOneAndUpdate(
      { userId },
      { $set: updates },
      { new: true, runValidators: true }
    );

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    return restaurant;
  }

  /**
   * Update restaurant location
   */
  async updateLocation(
    userId: string,
    address: string,
    area: string,
    coordinates: { lat: number; lng: number }
  ): Promise<IRestaurant> {
    const restaurant = await Restaurant.findOneAndUpdate(
      { userId },
      {
        $set: {
          address,
          area,
          location: {
            type: 'Point',
            coordinates: [coordinates.lng, coordinates.lat],
          },
        },
      },
      { new: true, runValidators: true }
    );

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    return restaurant;
  }

  /**
   * Update working hours
   */
  async updateWorkingHours(
    userId: string,
    workingHours: Array<{
      day: number;
      isOpen: boolean;
      shifts: Array<{ open: string; close: string }>;
    }>
  ): Promise<IRestaurant> {
    const restaurant = await Restaurant.findOneAndUpdate(
      { userId },
      { $set: { workingHours } },
      { new: true, runValidators: true }
    );

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    return restaurant;
  }

  /**
   * Toggle pause status
   */
  async togglePause(userId: string, isPaused: boolean, pauseReason?: string): Promise<IRestaurant> {
    const restaurant = await Restaurant.findOneAndUpdate(
      { userId },
      {
        $set: {
          isPaused,
          pauseReason: isPaused ? pauseReason : null,
        },
      },
      { new: true }
    );

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    return restaurant;
  }

  /**
   * Get dashboard stats
   */
  async getDashboardStats(userId: string): Promise<{
    totalOrders: number;
    totalRevenue: number;
    rating: number;
    totalRatings: number;
    isOpen: boolean;
    isPaused: boolean;
    isApproved: boolean;
    menu: {
      categories: number;
      totalItems: number;
      availableItems: number;
    };
  }> {
    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const [categoriesCount, itemsCount, availableItemsCount] = await Promise.all([
      MenuCategory.countDocuments({ restaurantId: restaurant._id, isActive: true }),
      MenuItem.countDocuments({ restaurantId: restaurant._id }),
      MenuItem.countDocuments({ restaurantId: restaurant._id, isAvailable: true }),
    ]);

    return {
      totalOrders: restaurant.totalOrders,
      totalRevenue: restaurant.totalRevenue,
      rating: restaurant.rating,
      totalRatings: restaurant.totalRatings,
      isOpen: restaurant.isOpen,
      isPaused: restaurant.isPaused,
      isApproved: restaurant.isApproved,
      menu: {
        categories: categoriesCount,
        totalItems: itemsCount,
        availableItems: availableItemsCount,
      },
    };
  }

  /**
   * Search restaurants (public)
   */
  async searchRestaurants(options: SearchRestaurantsOptions): Promise<PaginatedResult<IRestaurant>> {
    const {
      query,
      category,
      area,
      priceRange,
      lat,
      lng,
      maxDistance = 10,
      sortBy = 'rating',
      sortOrder = 'desc',
      page = 1,
      limit = 20,
    } = options;

    const filter: Record<string, unknown> = {
      isApproved: true,
      isActive: true,
    };

    // Text search
    if (query) {
      filter.$text = { $search: query };
    }

    // Category filter
    if (category) {
      filter.categories = category;
    }

    // Area filter
    if (area) {
      filter.area = area;
    }

    // Price range filter
    if (priceRange) {
      filter.priceRange = priceRange;
    }

    // Geo query if coordinates provided
    if (lat && lng) {
      filter.location = {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [lng, lat],
          },
          $maxDistance: maxDistance * 1000, // Convert km to meters
        },
      };
    }

    // Sorting
    const sortOptions: Record<string, SortOrder> = {};
    switch (sortBy) {
      case 'rating':
        sortOptions.rating = sortOrder === 'asc' ? 1 : -1;
        break;
      case 'deliveryTime':
        sortOptions['estimatedDeliveryTime.min'] = sortOrder === 'asc' ? 1 : -1;
        break;
      case 'minimumOrder':
        sortOptions.minimumOrder = sortOrder === 'asc' ? 1 : -1;
        break;
      default:
        sortOptions.rating = -1;
    }

    const skip = (page - 1) * limit;

    const [restaurants, total] = await Promise.all([
      Restaurant.find(filter)
        .select('name nameAr slug logo coverImage categories priceRange rating totalRatings minimumOrder deliveryFee estimatedDeliveryTime address area workingHours isPaused')
        .sort(sortOptions)
        .skip(skip)
        .limit(limit),
      Restaurant.countDocuments(filter),
    ]);

    const pages = Math.ceil(total / limit);

    return {
      data: restaurants,
      pagination: {
        page,
        limit,
        total,
        pages,
        hasNext: page < pages,
        hasPrev: page > 1,
      },
    };
  }

  /**
   * Get nearby restaurants
   */
  async getNearbyRestaurants(
    lat: number,
    lng: number,
    maxDistance = 5,
    limit = 20
  ): Promise<IRestaurant[]> {
    return Restaurant.find({
      isApproved: true,
      isActive: true,
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [lng, lat],
          },
          $maxDistance: maxDistance * 1000,
        },
      },
    })
      .select('name nameAr slug logo coverImage categories priceRange rating totalRatings minimumOrder deliveryFee estimatedDeliveryTime address area workingHours isPaused')
      .limit(limit);
  }

  /**
   * Get featured restaurants
   */
  async getFeaturedRestaurants(limit = 10): Promise<IRestaurant[]> {
    return Restaurant.find({
      isApproved: true,
      isActive: true,
      rating: { $gte: 4 },
    })
      .select('name nameAr slug logo coverImage categories priceRange rating totalRatings minimumOrder deliveryFee estimatedDeliveryTime')
      .sort({ rating: -1, totalOrders: -1 })
      .limit(limit);
  }

  /**
   * Get restaurant with full menu
   */
  async getRestaurantWithMenu(slug: string): Promise<{
    restaurant: IRestaurant;
    menu: Array<{
      _id: Types.ObjectId;
      name: string;
      nameAr: string;
      items: Array<unknown>;
    }>;
  } | null> {
    const restaurant = await this.getRestaurantBySlug(slug);
    if (!restaurant) {
      return null;
    }

    const categories = await MenuCategory.find({
      restaurantId: restaurant._id,
      isActive: true,
    })
      .sort('sortOrder')
      .lean();

    const items = await MenuItem.find({
      restaurantId: restaurant._id,
      isAvailable: true,
    })
      .select('name nameAr description descriptionAr image price discountPrice discountEndsAt preparationTime addons variations tags isPopular categoryId')
      .sort('sortOrder')
      .lean();

    // Group items by category
    const menu = categories.map((category) => ({
      ...category,
      items: items.filter(
        (item) => item.categoryId.toString() === category._id.toString()
      ),
    }));

    return { restaurant, menu };
  }

  /**
   * Admin: Approve restaurant
   */
  async approveRestaurant(restaurantId: string, adminId: string): Promise<IRestaurant> {
    const restaurant = await Restaurant.findByIdAndUpdate(
      restaurantId,
      {
        $set: {
          isApproved: true,
          approvedAt: new Date(),
          approvedBy: adminId,
          rejectionReason: null,
        },
      },
      { new: true }
    );

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    return restaurant;
  }

  /**
   * Admin: Reject restaurant
   */
  async rejectRestaurant(restaurantId: string, reason: string): Promise<IRestaurant> {
    const restaurant = await Restaurant.findByIdAndUpdate(
      restaurantId,
      {
        $set: {
          isApproved: false,
          rejectionReason: reason,
        },
      },
      { new: true }
    );

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    return restaurant;
  }

  /**
   * Admin: Suspend restaurant
   */
  async suspendRestaurant(restaurantId: string, reason: string): Promise<IRestaurant> {
    const restaurant = await Restaurant.findByIdAndUpdate(
      restaurantId,
      {
        $set: {
          isActive: false,
          suspensionReason: reason,
          suspendedAt: new Date(),
        },
      },
      { new: true }
    );

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    return restaurant;
  }

  /**
   * Admin: Activate restaurant
   */
  async activateRestaurant(restaurantId: string): Promise<IRestaurant> {
    const restaurant = await Restaurant.findByIdAndUpdate(
      restaurantId,
      {
        $set: {
          isActive: true,
          suspensionReason: null,
          suspendedAt: null,
        },
      },
      { new: true }
    );

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    return restaurant;
  }

  /**
   * Admin: Update commission
   */
  async updateCommission(restaurantId: string, commission: number): Promise<IRestaurant> {
    if (commission < 0 || commission > 100) {
      throw new AppError('نسبة العمولة يجب أن تكون بين 0 و 100', StatusCodes.BAD_REQUEST);
    }

    const restaurant = await Restaurant.findByIdAndUpdate(
      restaurantId,
      { $set: { commission } },
      { new: true }
    );

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    return restaurant;
  }

  /**
   * Admin: Get all restaurants with filters
   */
  async getAllRestaurants(options: {
    status?: 'pending' | 'approved' | 'rejected' | 'suspended';
    search?: string;
    page?: number;
    limit?: number;
  }): Promise<PaginatedResult<IRestaurant>> {
    const { status, search, page = 1, limit = 20 } = options;

    const filter: Record<string, unknown> = {};

    if (status) {
      switch (status) {
        case 'pending':
          filter.isApproved = false;
          filter.rejectionReason = { $exists: false };
          break;
        case 'approved':
          filter.isApproved = true;
          filter.isActive = true;
          break;
        case 'rejected':
          filter.isApproved = false;
          filter.rejectionReason = { $exists: true };
          break;
        case 'suspended':
          filter.isActive = false;
          break;
      }
    }

    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { nameAr: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (page - 1) * limit;

    const [restaurants, total] = await Promise.all([
      Restaurant.find(filter)
        .populate('userId', 'name email phone')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      Restaurant.countDocuments(filter),
    ]);

    const pages = Math.ceil(total / limit);

    return {
      data: restaurants,
      pagination: {
        page,
        limit,
        total,
        pages,
        hasNext: page < pages,
        hasPrev: page > 1,
      },
    };
  }

  /**
   * Get restaurant analytics
   */
  async getAnalytics(
    restaurantId: string,
    period: string = 'week',
    startDate?: Date,
    endDate?: Date
  ): Promise<{
    summary: {
      totalOrders: number;
      completedOrders: number;
      cancelledOrders: number;
      totalRevenue: number;
      netRevenue: number;
      averageOrderValue: number;
      averageRating: string;
      totalReviews: number;
    };
    charts: {
      ordersByDay: Array<{ date: string; orders: number; revenue: number }>;
      ordersByHour: Array<{ hour: number; orders: number }>;
      topItems: Array<{ itemId: string; name: string; quantity: number; revenue: number }>;
      ordersByStatus: {
        completed: number;
        cancelled: number;
        pending: number;
      };
    };
    comparison: {
      previousPeriod: {
        orders: number;
        revenue: number;
      };
      growth: {
        ordersPercent: number;
        revenuePercent: number;
      };
    };
  }> {
    const now = new Date();
    let start: Date;
    let end: Date = endDate || now;

    // Calculate date range based on period
    switch (period) {
      case 'week':
        start = startDate || new Date(new Date().setDate(now.getDate() - 7));
        break;
      case 'month':
        start = startDate || new Date(new Date().setMonth(now.getMonth() - 1));
        break;
      case 'year':
        start = startDate || new Date(new Date().setFullYear(now.getFullYear() - 1));
        break;
      default:
        start = startDate || new Date(new Date().setDate(now.getDate() - 7));
    }

    const restaurantObjectId = new mongoose.Types.ObjectId(restaurantId);

    // Aggregation pipeline for orders
    const orderStats = await Order.aggregate([
      {
        $match: {
          restaurantId: restaurantObjectId,
          createdAt: { $gte: start, $lte: end },
        },
      },
      {
        $group: {
          _id: null,
          totalOrders: { $sum: 1 },
          completedOrders: {
            $sum: { $cond: [{ $eq: ['$status', 'delivered'] }, 1, 0] },
          },
          cancelledOrders: {
            $sum: { $cond: [{ $eq: ['$status', 'cancelled'] }, 1, 0] },
          },
          totalRevenue: {
            $sum: { $cond: [{ $eq: ['$status', 'delivered'] }, '$subtotal', 0] },
          },
          averageOrderValue: { $avg: '$subtotal' },
        },
      },
    ]);

    // Orders by day
    const ordersByDay = await Order.aggregate([
      {
        $match: {
          restaurantId: restaurantObjectId,
          createdAt: { $gte: start, $lte: end },
        },
      },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          orders: { $sum: 1 },
          revenue: { $sum: '$subtotal' },
        },
      },
      { $sort: { _id: 1 } },
      { $project: { date: '$_id', orders: 1, revenue: 1, _id: 0 } },
    ]);

    // Orders by hour
    const ordersByHour = await Order.aggregate([
      {
        $match: {
          restaurantId: restaurantObjectId,
          createdAt: { $gte: start, $lte: end },
        },
      },
      {
        $group: {
          _id: { $hour: '$createdAt' },
          orders: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
      { $project: { hour: '$_id', orders: 1, _id: 0 } },
    ]);

    // Top items
    const topItems = await Order.aggregate([
      {
        $match: {
          restaurantId: restaurantObjectId,
          createdAt: { $gte: start, $lte: end },
          status: 'delivered',
        },
      },
      { $unwind: '$items' },
      {
        $group: {
          _id: '$items.menuItemId',
          name: { $first: '$items.nameAr' },
          quantity: { $sum: '$items.quantity' },
          revenue: { $sum: { $multiply: ['$items.basePrice', '$items.quantity'] } },
        },
      },
      { $sort: { quantity: -1 } },
      { $limit: 10 },
      { $project: { itemId: '$_id', name: 1, quantity: 1, revenue: 1, _id: 0 } },
    ]);

    // Get ratings
    const ratingStats = await Review.aggregate([
      {
        $match: {
          restaurantId: restaurantObjectId,
          createdAt: { $gte: start, $lte: end },
        },
      },
      {
        $group: {
          _id: null,
          averageRating: { $avg: '$restaurantRating' },
          totalReviews: { $sum: 1 },
        },
      },
    ]);

    // Previous period comparison
    const periodDuration = end.getTime() - start.getTime();
    const previousStart = new Date(start.getTime() - periodDuration);
    const previousEnd = start;

    const previousStats = await Order.aggregate([
      {
        $match: {
          restaurantId: restaurantObjectId,
          createdAt: { $gte: previousStart, $lte: previousEnd },
          status: 'delivered',
        },
      },
      {
        $group: {
          _id: null,
          orders: { $sum: 1 },
          revenue: { $sum: '$subtotal' },
        },
      },
    ]);

    // Calculate commission (from settings or default 15%)
    const commissionSetting = await Setting.findOne({ key: 'default_commission' });
    const commissionRate = (commissionSetting?.value as number) || 15;

    const stats = orderStats[0] || {
      totalOrders: 0,
      completedOrders: 0,
      cancelledOrders: 0,
      totalRevenue: 0,
      averageOrderValue: 0,
    };
    const netRevenue = stats.totalRevenue * (1 - commissionRate / 100);

    const prevStats = previousStats[0] || { orders: 0, revenue: 0 };
    const ordersGrowth =
      prevStats.orders > 0
        ? ((stats.completedOrders - prevStats.orders) / prevStats.orders) * 100
        : 0;
    const revenueGrowth =
      prevStats.revenue > 0
        ? ((stats.totalRevenue - prevStats.revenue) / prevStats.revenue) * 100
        : 0;

    return {
      summary: {
        totalOrders: stats.totalOrders,
        completedOrders: stats.completedOrders,
        cancelledOrders: stats.cancelledOrders,
        totalRevenue: Math.round(stats.totalRevenue),
        netRevenue: Math.round(netRevenue),
        averageOrderValue: Math.round(stats.averageOrderValue || 0),
        averageRating: ratingStats[0]?.averageRating?.toFixed(1) || '0.0',
        totalReviews: ratingStats[0]?.totalReviews || 0,
      },
      charts: {
        ordersByDay,
        ordersByHour,
        topItems,
        ordersByStatus: {
          completed: stats.completedOrders,
          cancelled: stats.cancelledOrders,
          pending: stats.totalOrders - stats.completedOrders - stats.cancelledOrders,
        },
      },
      comparison: {
        previousPeriod: {
          orders: prevStats.orders,
          revenue: Math.round(prevStats.revenue),
        },
        growth: {
          ordersPercent: parseFloat(ordersGrowth.toFixed(1)),
          revenuePercent: parseFloat(revenueGrowth.toFixed(1)),
        },
      },
    };
  }
}

export const restaurantService = new RestaurantService();
