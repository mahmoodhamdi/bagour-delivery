import { Response, NextFunction } from 'express';
import { AuthRequest, OrderStatus } from '../types';
import { orderService } from '../services/order.service';
import { successResponse, paginatedResponse } from '../utils/response';
import { AppError } from '../utils/errors';
import { StatusCodes } from 'http-status-codes';
import { Customer } from '../models/Customer';
import { Restaurant } from '../models/Restaurant';
import { Driver } from '../models/Driver';

// ==================== Customer Order Endpoints ====================

/**
 * Create a new order
 * POST /api/v1/orders
 */
export const createOrder = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;

    // Get customer ID from user ID
    const customer = await Customer.findOne({ userId });
    if (!customer) {
      throw new AppError('العميل غير موجود', StatusCodes.NOT_FOUND);
    }

    const order = await orderService.createOrder({
      customerId: customer._id.toString(),
      restaurantId: req.body.restaurantId,
      items: req.body.items,
      deliveryAddress: req.body.deliveryAddress,
      paymentMethod: req.body.paymentMethod,
      couponCode: req.body.couponCode,
      customerNotes: req.body.customerNotes,
      isScheduled: req.body.isScheduled,
      scheduledFor: req.body.scheduledFor,
    });

    successResponse(res, StatusCodes.CREATED, 'تم إنشاء الطلب بنجاح', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Get customer's orders
 * GET /api/v1/orders
 */
export const getMyOrders = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;

    const customer = await Customer.findOne({ userId });
    if (!customer) {
      throw new AppError('العميل غير موجود', StatusCodes.NOT_FOUND);
    }

    const { status, page, limit } = req.query;

    const result = await orderService.getCustomerOrders(customer._id.toString(), {
      status: status as OrderStatus[] | undefined,
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
    });

    paginatedResponse(
      res,
      StatusCodes.OK,
      'تم جلب الطلبات بنجاح',
      result.data,
      result.pagination
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get order by ID
 * GET /api/v1/orders/:id
 */
export const getOrderById = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;
    const role = req.user?.role;

    // Get the appropriate ID based on role
    let accessId = userId;
    if (role === 'customer') {
      const customer = await Customer.findOne({ userId });
      if (customer) accessId = customer._id.toString();
    } else if (role === 'restaurant') {
      const restaurant = await Restaurant.findOne({ userId });
      if (restaurant) accessId = restaurant._id.toString();
    } else if (role === 'driver' || role === 'delivery') {
      const driver = await Driver.findOne({ userId });
      if (driver) accessId = driver._id.toString();
    }

    const order = await orderService.getOrderById(id, accessId, role);

    successResponse(res, StatusCodes.OK, 'تم جلب الطلب بنجاح', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Cancel order
 * PUT /api/v1/orders/:id/cancel
 */
export const cancelOrder = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const userId = req.user?.userId;

    const customer = await Customer.findOne({ userId });
    if (!customer) {
      throw new AppError('العميل غير موجود', StatusCodes.NOT_FOUND);
    }

    const order = await orderService.cancelOrder(
      id,
      'customer',
      reason,
      customer._id.toString()
    );

    successResponse(res, StatusCodes.OK, 'تم إلغاء الطلب بنجاح', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Rate order
 * POST /api/v1/orders/:id/rate
 */
export const rateOrder = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { restaurant, driver, food, comment } = req.body;
    const userId = req.user?.userId;

    const customer = await Customer.findOne({ userId });
    if (!customer) {
      throw new AppError('العميل غير موجود', StatusCodes.NOT_FOUND);
    }

    const order = await orderService.rateOrder(id, customer._id.toString(), {
      restaurant,
      driver,
      food,
      comment,
    });

    successResponse(res, StatusCodes.OK, 'تم تقييم الطلب بنجاح', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Reorder from previous order
 * POST /api/v1/orders/:id/reorder
 */
export const reorder = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;

    const customer = await Customer.findOne({ userId });
    if (!customer) {
      throw new AppError('العميل غير موجود', StatusCodes.NOT_FOUND);
    }

    const order = await orderService.reorder(id, customer._id.toString());

    successResponse(res, StatusCodes.CREATED, 'تم إنشاء الطلب بنجاح', { order });
  } catch (error) {
    next(error);
  }
};

// ==================== Restaurant Order Endpoints ====================

/**
 * Get restaurant's orders
 * GET /api/v1/restaurant/orders
 */
export const getRestaurantOrders = async (
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

    const { status, startDate, endDate, page, limit } = req.query;

    const result = await orderService.getRestaurantOrders(
      restaurant._id.toString(),
      {
        status: status as OrderStatus[] | undefined,
        startDate: startDate ? new Date(startDate as string) : undefined,
        endDate: endDate ? new Date(endDate as string) : undefined,
        page: page ? Number(page) : undefined,
        limit: limit ? Number(limit) : undefined,
      }
    );

    paginatedResponse(
      res,
      StatusCodes.OK,
      'تم جلب الطلبات بنجاح',
      result.data,
      result.pagination
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get active orders for restaurant
 * GET /api/v1/restaurant/orders/active
 */
export const getActiveRestaurantOrders = async (
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

    const orders = await orderService.getActiveRestaurantOrders(
      restaurant._id.toString()
    );

    successResponse(res, StatusCodes.OK, 'تم جلب الطلبات النشطة بنجاح', { orders });
  } catch (error) {
    next(error);
  }
};

/**
 * Get restaurant order by ID
 * GET /api/v1/restaurant/orders/:id
 */
export const getRestaurantOrderById = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const order = await orderService.getOrderById(
      id,
      restaurant._id.toString(),
      'restaurant'
    );

    successResponse(res, StatusCodes.OK, 'تم جلب الطلب بنجاح', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Confirm order
 * PUT /api/v1/restaurant/orders/:id/confirm
 */
export const confirmOrder = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { note } = req.body;
    const userId = req.user?.userId;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const order = await orderService.updateOrderStatus(
      id,
      'confirmed',
      restaurant._id.toString(),
      note
    );

    successResponse(res, StatusCodes.OK, 'تم تأكيد الطلب بنجاح', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Reject order
 * PUT /api/v1/restaurant/orders/:id/reject
 */
export const rejectOrder = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const userId = req.user?.userId;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const order = await orderService.cancelOrder(
      id,
      'restaurant',
      reason,
      restaurant._id.toString()
    );

    successResponse(res, StatusCodes.OK, 'تم رفض الطلب', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Mark order as preparing
 * PUT /api/v1/restaurant/orders/:id/preparing
 */
export const markAsPreparing = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { note } = req.body;
    const userId = req.user?.userId;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const order = await orderService.updateOrderStatus(
      id,
      'preparing',
      restaurant._id.toString(),
      note
    );

    successResponse(res, StatusCodes.OK, 'تم بدء تحضير الطلب', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Mark order as ready
 * PUT /api/v1/restaurant/orders/:id/ready
 */
export const markAsReady = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { note } = req.body;
    const userId = req.user?.userId;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const order = await orderService.updateOrderStatus(
      id,
      'ready',
      restaurant._id.toString(),
      note
    );

    successResponse(res, StatusCodes.OK, 'الطلب جاهز للاستلام', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Get restaurant order statistics
 * GET /api/v1/restaurant/orders/stats
 */
export const getRestaurantOrderStats = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { startDate, endDate } = req.query;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const stats = await orderService.getRestaurantOrderStats(
      restaurant._id.toString(),
      startDate ? new Date(startDate as string) : undefined,
      endDate ? new Date(endDate as string) : undefined
    );

    successResponse(res, StatusCodes.OK, 'تم جلب الإحصائيات بنجاح', { stats });
  } catch (error) {
    next(error);
  }
};

// ==================== Driver Order Endpoints ====================

/**
 * Get available orders for driver
 * GET /api/v1/driver/orders/available
 */
export const getAvailableOrders = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { lat, lng, maxDistance } = req.query;

    if (!lat || !lng) {
      throw new AppError('الموقع مطلوب', StatusCodes.BAD_REQUEST);
    }

    const orders = await orderService.getAvailableOrdersForDriver(
      { lat: Number(lat), lng: Number(lng) },
      maxDistance ? Number(maxDistance) : undefined
    );

    successResponse(res, StatusCodes.OK, 'تم جلب الطلبات المتاحة بنجاح', { orders });
  } catch (error) {
    next(error);
  }
};

/**
 * Get driver's orders
 * GET /api/v1/driver/orders
 */
export const getDriverOrders = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;

    const driver = await Driver.findOne({ userId });
    if (!driver) {
      throw new AppError('السائق غير موجود', StatusCodes.NOT_FOUND);
    }

    const { status, page, limit } = req.query;

    const result = await orderService.getDriverOrders(driver._id.toString(), {
      status: status as OrderStatus[] | undefined,
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
    });

    paginatedResponse(
      res,
      StatusCodes.OK,
      'تم جلب الطلبات بنجاح',
      result.data,
      result.pagination
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get driver order by ID
 * GET /api/v1/driver/orders/:id
 */
export const getDriverOrderById = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;

    const driver = await Driver.findOne({ userId });
    if (!driver) {
      throw new AppError('السائق غير موجود', StatusCodes.NOT_FOUND);
    }

    const order = await orderService.getOrderById(id, driver._id.toString(), 'driver');

    successResponse(res, StatusCodes.OK, 'تم جلب الطلب بنجاح', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Accept order for delivery
 * PUT /api/v1/driver/orders/:id/accept
 */
export const acceptOrderForDelivery = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;

    const driver = await Driver.findOne({ userId });
    if (!driver) {
      throw new AppError('السائق غير موجود', StatusCodes.NOT_FOUND);
    }

    if (!driver.isApproved || !driver.isActive) {
      throw new AppError('حسابك غير مفعل', StatusCodes.FORBIDDEN);
    }

    if (!driver.isOnline || !driver.isAvailable) {
      throw new AppError('يجب أن تكون متصلاً ومتاحاً لقبول الطلبات', StatusCodes.BAD_REQUEST);
    }

    const order = await orderService.assignDriver(id, driver._id.toString());

    // Update driver status
    driver.isAvailable = false;
    driver.isBusy = true;
    driver.currentOrderId = order._id;
    await driver.save();

    successResponse(res, StatusCodes.OK, 'تم قبول الطلب بنجاح', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Mark order as picked up
 * PUT /api/v1/driver/orders/:id/picked-up
 */
export const markAsPickedUp = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { note } = req.body;
    const userId = req.user?.userId;

    const driver = await Driver.findOne({ userId });
    if (!driver) {
      throw new AppError('السائق غير موجود', StatusCodes.NOT_FOUND);
    }

    const order = await orderService.updateOrderStatus(
      id,
      'picked_up',
      driver._id.toString(),
      note
    );

    successResponse(res, StatusCodes.OK, 'تم استلام الطلب من المطعم', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Mark order as on the way
 * PUT /api/v1/driver/orders/:id/on-the-way
 */
export const markAsOnTheWay = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { note } = req.body;
    const userId = req.user?.userId;

    const driver = await Driver.findOne({ userId });
    if (!driver) {
      throw new AppError('السائق غير موجود', StatusCodes.NOT_FOUND);
    }

    const order = await orderService.updateOrderStatus(
      id,
      'on_the_way',
      driver._id.toString(),
      note
    );

    successResponse(res, StatusCodes.OK, 'الطلب في الطريق للعميل', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Mark order as delivered
 * PUT /api/v1/driver/orders/:id/delivered
 */
export const markAsDelivered = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { note } = req.body;
    const userId = req.user?.userId;

    const driver = await Driver.findOne({ userId });
    if (!driver) {
      throw new AppError('السائق غير موجود', StatusCodes.NOT_FOUND);
    }

    const order = await orderService.updateOrderStatus(
      id,
      'delivered',
      driver._id.toString(),
      note
    );

    // Update driver status
    driver.isAvailable = true;
    driver.isBusy = false;
    driver.currentOrderId = undefined;
    driver.totalDeliveries = (driver.totalDeliveries || 0) + 1;
    driver.totalEarnings = (driver.totalEarnings || 0) + (order.driverEarnings || 0);
    await driver.save();

    successResponse(res, StatusCodes.OK, 'تم تسليم الطلب بنجاح', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Get driver earnings statistics
 * GET /api/v1/driver/earnings
 */
export const getDriverEarnings = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { startDate, endDate } = req.query;

    const driver = await Driver.findOne({ userId });
    if (!driver) {
      throw new AppError('السائق غير موجود', StatusCodes.NOT_FOUND);
    }

    const stats = await orderService.getDriverEarningsStats(
      driver._id.toString(),
      startDate ? new Date(startDate as string) : undefined,
      endDate ? new Date(endDate as string) : undefined
    );

    successResponse(res, StatusCodes.OK, 'تم جلب الأرباح بنجاح', { stats });
  } catch (error) {
    next(error);
  }
};

// ==================== Admin Order Endpoints ====================

/**
 * Get all orders (admin)
 * GET /api/v1/admin/orders
 */
export const getAllOrders = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      status,
      restaurantId,
      customerId,
      driverId,
      paymentStatus,
      startDate,
      endDate,
      page,
      limit,
      sortBy,
      sortOrder,
    } = req.query;

    const result = await orderService.getOrders({
      status: status as OrderStatus | OrderStatus[] | undefined,
      restaurantId: restaurantId as string | undefined,
      customerId: customerId as string | undefined,
      driverId: driverId as string | undefined,
      paymentStatus: paymentStatus as string | undefined,
      startDate: startDate ? new Date(startDate as string) : undefined,
      endDate: endDate ? new Date(endDate as string) : undefined,
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
      sortBy: sortBy as string | undefined,
      sortOrder: sortOrder as 'asc' | 'desc' | undefined,
    });

    paginatedResponse(
      res,
      StatusCodes.OK,
      'تم جلب الطلبات بنجاح',
      result.data,
      result.pagination
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get order by ID (admin)
 * GET /api/v1/admin/orders/:id
 */
export const getAdminOrderById = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;

    const order = await orderService.getOrderById(id, userId, 'admin');

    successResponse(res, StatusCodes.OK, 'تم جلب الطلب بنجاح', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Assign driver to order (admin)
 * PUT /api/v1/admin/orders/:id/assign-driver
 */
export const adminAssignDriver = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { driverId } = req.body;

    const driver = await Driver.findById(driverId);
    if (!driver) {
      throw new AppError('السائق غير موجود', StatusCodes.NOT_FOUND);
    }

    if (!driver.isApproved || !driver.isActive) {
      throw new AppError('السائق غير مفعل', StatusCodes.BAD_REQUEST);
    }

    const order = await orderService.assignDriver(id, driverId);

    // Update driver status
    driver.isAvailable = false;
    driver.isBusy = true;
    driver.currentOrderId = order._id;
    await driver.save();

    successResponse(res, StatusCodes.OK, 'تم تخصيص السائق بنجاح', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Cancel order (admin)
 * PUT /api/v1/admin/orders/:id/cancel
 */
export const adminCancelOrder = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const userId = req.user?.userId;

    const order = await orderService.cancelOrder(id, 'admin', reason, userId || '');

    successResponse(res, StatusCodes.OK, 'تم إلغاء الطلب بنجاح', { order });
  } catch (error) {
    next(error);
  }
};

/**
 * Get platform order statistics (admin)
 * GET /api/v1/admin/orders/stats
 */
export const getPlatformOrderStats = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { startDate, endDate } = req.query;

    const stats = await orderService.getPlatformOrderStats(
      startDate ? new Date(startDate as string) : undefined,
      endDate ? new Date(endDate as string) : undefined
    );

    successResponse(res, StatusCodes.OK, 'تم جلب الإحصائيات بنجاح', { stats });
  } catch (error) {
    next(error);
  }
};
