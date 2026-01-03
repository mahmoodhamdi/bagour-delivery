import { Request, Response, NextFunction } from 'express';
import { Restaurant } from '../models/Restaurant';
import { MenuCategory } from '../models/MenuCategory';
import { MenuItem } from '../models/MenuItem';
import { successResponse, paginatedResponse } from '../utils/response';
import { AppError } from '../utils/errors';
import { StatusCodes } from 'http-status-codes';
import { AuthRequest } from '../types';

// ==================== Restaurant Profile ====================

/**
 * Get current restaurant profile
 * GET /api/v1/restaurants/profile
 */
export const getProfile = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;

    const restaurant = await Restaurant.findOne({ userId })
      .populate('user', 'name email phone isPhoneVerified isEmailVerified')
      .populate('menuCategories');

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    successResponse(res, 200, 'تم جلب بيانات المطعم بنجاح', { restaurant });
  } catch (error) {
    next(error);
  }
};

/**
 * Update restaurant profile
 * PATCH /api/v1/restaurants/profile
 */
export const updateProfile = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const updates = req.body;

    const restaurant = await Restaurant.findOneAndUpdate(
      { userId },
      { $set: updates },
      { new: true, runValidators: true }
    );

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    successResponse(res, 200, 'تم تحديث بيانات المطعم بنجاح', { restaurant });
  } catch (error) {
    next(error);
  }
};

/**
 * Update restaurant location
 * PUT /api/v1/restaurants/location
 */
export const updateLocation = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { address, area, coordinates } = req.body;

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

    successResponse(res, 200, 'تم تحديث موقع المطعم بنجاح', { restaurant });
  } catch (error) {
    next(error);
  }
};

/**
 * Update working hours
 * PUT /api/v1/restaurants/working-hours
 */
export const updateWorkingHours = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { workingHours } = req.body;

    const restaurant = await Restaurant.findOneAndUpdate(
      { userId },
      { $set: { workingHours } },
      { new: true, runValidators: true }
    );

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    successResponse(res, 200, 'تم تحديث ساعات العمل بنجاح', { restaurant });
  } catch (error) {
    next(error);
  }
};

/**
 * Update delivery settings
 * PUT /api/v1/restaurants/delivery-settings
 */
export const updateDeliverySettings = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const {
      minimumOrder,
      deliveryFee,
      freeDeliveryAbove,
      estimatedDeliveryTime,
      acceptsCash,
      acceptsOnlinePayment,
      autoAcceptOrders,
    } = req.body;

    const updates: Record<string, unknown> = {};
    if (minimumOrder !== undefined) updates.minimumOrder = minimumOrder;
    if (deliveryFee !== undefined) updates.deliveryFee = deliveryFee;
    if (freeDeliveryAbove !== undefined) updates.freeDeliveryAbove = freeDeliveryAbove;
    if (estimatedDeliveryTime) updates.estimatedDeliveryTime = estimatedDeliveryTime;
    if (acceptsCash !== undefined) updates.acceptsCash = acceptsCash;
    if (acceptsOnlinePayment !== undefined) updates.acceptsOnlinePayment = acceptsOnlinePayment;
    if (autoAcceptOrders !== undefined) updates.autoAcceptOrders = autoAcceptOrders;

    const restaurant = await Restaurant.findOneAndUpdate(
      { userId },
      { $set: updates },
      { new: true, runValidators: true }
    );

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    successResponse(res, 200, 'تم تحديث إعدادات التوصيل بنجاح', { restaurant });
  } catch (error) {
    next(error);
  }
};

/**
 * Toggle restaurant pause status
 * POST /api/v1/restaurants/toggle-pause
 */
export const togglePause = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { isPaused, pauseReason } = req.body;

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

    const message = isPaused
      ? 'تم إيقاف استقبال الطلبات مؤقتاً'
      : 'تم تفعيل استقبال الطلبات';

    successResponse(res, 200, message, { restaurant });
  } catch (error) {
    next(error);
  }
};

/**
 * Get restaurant dashboard stats
 * GET /api/v1/restaurants/stats
 */
export const getDashboardStats = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    // Get menu stats
    const [categoriesCount, itemsCount, availableItemsCount] = await Promise.all([
      MenuCategory.countDocuments({ restaurantId: restaurant._id, isActive: true }),
      MenuItem.countDocuments({ restaurantId: restaurant._id }),
      MenuItem.countDocuments({ restaurantId: restaurant._id, isAvailable: true }),
    ]);

    successResponse(res, 200, 'تم جلب الإحصائيات بنجاح', {
      stats: {
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
      },
    });
  } catch (error) {
    next(error);
  }
};

// ==================== Public Restaurant APIs ====================

/**
 * Search restaurants
 * GET /api/v1/restaurants
 */
export const searchRestaurants = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      q,
      category,
      area,
      priceRange,
      isOpen,
      sortBy = 'rating',
      sortOrder = 'desc',
      page = 1,
      limit = 20,
      lat,
      lng,
      maxDistance = 10,
    } = req.query;

    const query: Record<string, unknown> = {
      isApproved: true,
      isActive: true,
    };

    // Text search
    if (q) {
      query.$text = { $search: q as string };
    }

    // Category filter
    if (category) {
      query.categories = category;
    }

    // Area filter
    if (area) {
      query.area = area;
    }

    // Price range filter
    if (priceRange) {
      query.priceRange = Number(priceRange);
    }

    // Geo query if coordinates provided
    if (lat && lng) {
      query.location = {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [Number(lng), Number(lat)],
          },
          $maxDistance: Number(maxDistance) * 1000, // Convert km to meters
        },
      };
    }

    // Sorting
    const sortOptions: Record<string, 1 | -1> = {};
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

    const skip = (Number(page) - 1) * Number(limit);

    const [restaurants, total] = await Promise.all([
      Restaurant.find(query)
        .select('name nameAr slug logo coverImage categories priceRange rating totalRatings minimumOrder deliveryFee estimatedDeliveryTime address area workingHours isPaused')
        .sort(sortOptions)
        .skip(skip)
        .limit(Number(limit)),
      Restaurant.countDocuments(query),
    ]);

    // Filter by isOpen if requested (needs to be done after fetch due to virtual field)
    let filteredRestaurants = restaurants;
    if (isOpen === 'true') {
      filteredRestaurants = restaurants.filter((r) => r.isOpen);
    }

    paginatedResponse(
      res,
      200,
      'تم جلب المطاعم بنجاح',
      filteredRestaurants,
      {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit)),
      }
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get restaurant by slug
 * GET /api/v1/restaurants/:slug
 */
export const getRestaurantBySlug = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { slug } = req.params;

    const restaurant = await Restaurant.findOne({
      slug,
      isApproved: true,
      isActive: true,
    }).select('-userId -totalRevenue -commission -approvedBy -rejectionReason -subscription');

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    // Get menu categories with items
    const categories = await MenuCategory.find({
      restaurantId: restaurant._id,
      isActive: true,
    })
      .sort('sortOrder')
      .populate({
        path: 'items',
        match: { isAvailable: true },
        select: 'name nameAr description descriptionAr image price discountPrice discountEndsAt preparationTime addons variations tags isPopular currentPrice hasDiscount',
        options: { sort: { sortOrder: 1 } },
      });

    successResponse(res, 200, 'تم جلب بيانات المطعم بنجاح', {
      restaurant,
      menu: categories,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get restaurant menu
 * GET /api/v1/restaurants/:slug/menu
 */
export const getRestaurantMenu = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { slug } = req.params;
    const { categoryId, isAvailable, search } = req.query;

    const restaurant = await Restaurant.findOne({
      slug,
      isApproved: true,
      isActive: true,
    }).select('_id name');

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const categoriesQuery: Record<string, unknown> = {
      restaurantId: restaurant._id,
      isActive: true,
    };

    if (categoryId) {
      categoriesQuery._id = categoryId;
    }

    const categories = await MenuCategory.find(categoriesQuery).sort('sortOrder');

    // Build items query
    const itemsQuery: Record<string, unknown> = {
      restaurantId: restaurant._id,
    };

    if (categoryId) {
      itemsQuery.categoryId = categoryId;
    }

    if (isAvailable === 'true') {
      itemsQuery.isAvailable = true;
    }

    if (search) {
      itemsQuery.$text = { $search: search as string };
    }

    const items = await MenuItem.find(itemsQuery)
      .select('name nameAr description descriptionAr image price discountPrice discountEndsAt preparationTime addons variations tags isPopular isAvailable categoryId currentPrice hasDiscount')
      .sort('sortOrder');

    // Group items by category
    const menu = categories.map((category) => ({
      ...category.toObject(),
      items: items.filter((item) => item.categoryId.toString() === category._id.toString()),
    }));

    successResponse(res, 200, 'تم جلب قائمة الطعام بنجاح', { menu });
  } catch (error) {
    next(error);
  }
};

/**
 * Get featured restaurants
 * GET /api/v1/restaurants/featured
 */
export const getFeaturedRestaurants = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { limit = 10 } = req.query;

    const restaurants = await Restaurant.find({
      isApproved: true,
      isActive: true,
      rating: { $gte: 4 },
    })
      .select('name nameAr slug logo coverImage categories priceRange rating totalRatings minimumOrder deliveryFee estimatedDeliveryTime')
      .sort({ rating: -1, totalOrders: -1 })
      .limit(Number(limit));

    successResponse(res, 200, 'تم جلب المطاعم المميزة بنجاح', { restaurants });
  } catch (error) {
    next(error);
  }
};

/**
 * Get nearby restaurants
 * GET /api/v1/restaurants/nearby
 */
export const getNearbyRestaurants = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { lat, lng, maxDistance = 5, limit = 20 } = req.query;

    if (!lat || !lng) {
      throw new AppError('الموقع مطلوب', StatusCodes.BAD_REQUEST);
    }

    const restaurants = await Restaurant.find({
      isApproved: true,
      isActive: true,
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [Number(lng), Number(lat)],
          },
          $maxDistance: Number(maxDistance) * 1000,
        },
      },
    })
      .select('name nameAr slug logo coverImage categories priceRange rating totalRatings minimumOrder deliveryFee estimatedDeliveryTime address area workingHours isPaused')
      .limit(Number(limit));

    successResponse(res, 200, 'تم جلب المطاعم القريبة بنجاح', { restaurants });
  } catch (error) {
    next(error);
  }
};
