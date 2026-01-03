import { Types, SortOrder } from 'mongoose';
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type FilterQuery<T> = Record<string, any>;
import { Order, IOrder, IOrderItem, IDeliveryAddress } from '../models/Order';
import { Restaurant } from '../models/Restaurant';
import { MenuItem } from '../models/MenuItem';
import { Customer } from '../models/Customer';
import { Coupon } from '../models/Coupon';
import { AppError } from '../utils/errors';
import { StatusCodes } from 'http-status-codes';
import { OrderStatus, PaymentMethod, IPaginatedResult } from '../types';
import dayjs from 'dayjs';
import { notificationService } from './notification.service';
import { logger } from '../utils/logger';

// Types
interface CreateOrderItemInput {
  menuItemId: string;
  quantity: number;
  selectedAddons?: {
    addonId: string;
    quantity: number;
  }[];
  selectedVariations?: {
    variationId: string;
    optionId: string;
  }[];
  specialInstructions?: string;
}

interface CreateOrderInput {
  customerId: string;
  restaurantId: string;
  items: CreateOrderItemInput[];
  deliveryAddress: IDeliveryAddress;
  paymentMethod: PaymentMethod;
  couponCode?: string;
  customerNotes?: string;
  isScheduled?: boolean;
  scheduledFor?: Date;
}

interface GetOrdersOptions {
  customerId?: string;
  restaurantId?: string;
  driverId?: string;
  status?: OrderStatus | OrderStatus[];
  paymentStatus?: string;
  startDate?: Date;
  endDate?: Date;
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

interface OrderCalculation {
  subtotal: number;
  deliveryFee: number;
  serviceFee: number;
  discount: number;
  couponDiscount: number;
  total: number;
  couponId?: Types.ObjectId;
  couponCode?: string;
}

class OrderService {
  private readonly SERVICE_FEE_PERCENTAGE = 0.05; // 5%
  private readonly PLATFORM_COMMISSION = 0.15; // 15%

  /**
   * Create a new order
   */
  async createOrder(input: CreateOrderInput): Promise<IOrder> {
    // Validate restaurant
    const restaurant = await Restaurant.findById(input.restaurantId);
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    if (!restaurant.isActive || !restaurant.isApproved) {
      throw new AppError('المطعم غير متاح حالياً', StatusCodes.BAD_REQUEST);
    }

    if (!restaurant.isOpen && !input.isScheduled) {
      throw new AppError('المطعم مغلق حالياً', StatusCodes.BAD_REQUEST);
    }

    // Validate customer
    const customer = await Customer.findById(input.customerId);
    if (!customer) {
      throw new AppError('العميل غير موجود', StatusCodes.NOT_FOUND);
    }

    // Process order items
    const processedItems = await this.processOrderItems(
      input.items,
      input.restaurantId
    );

    // Calculate order totals
    const calculation = await this.calculateOrderTotals(
      processedItems,
      restaurant,
      input.couponCode,
      input.customerId
    );

    // Validate minimum order
    if (calculation.subtotal < restaurant.minimumOrder) {
      throw new AppError(
        `الحد الأدنى للطلب هو ${restaurant.minimumOrder} ج.م`,
        StatusCodes.BAD_REQUEST
      );
    }

    // Calculate earnings
    const restaurantEarnings =
      calculation.subtotal * (1 - this.PLATFORM_COMMISSION);
    const platformEarnings = calculation.subtotal * this.PLATFORM_COMMISSION;

    // Create order
    const order = new Order({
      customerId: input.customerId,
      restaurantId: input.restaurantId,
      items: processedItems,
      subtotal: calculation.subtotal,
      deliveryFee: calculation.deliveryFee,
      serviceFee: calculation.serviceFee,
      discount: calculation.discount,
      couponId: calculation.couponId,
      couponCode: calculation.couponCode,
      couponDiscount: calculation.couponDiscount,
      total: calculation.total,
      deliveryAddress: input.deliveryAddress,
      paymentMethod: input.paymentMethod,
      customerNotes: input.customerNotes,
      isScheduled: input.isScheduled || false,
      scheduledFor: input.scheduledFor,
      restaurantEarnings,
      platformEarnings,
      paymentStatus: input.paymentMethod === 'cash' ? 'pending' : 'pending',
    });

    await order.save();

    // Update coupon usage if applied
    if (calculation.couponId) {
      await Coupon.findByIdAndUpdate(calculation.couponId, {
        $inc: { usedCount: 1 },
        $push: { usedBy: input.customerId },
      });
    }

    // Update customer stats
    await Customer.findByIdAndUpdate(input.customerId, {
      $inc: { totalOrders: 1 },
    });

    // Send new order notification to restaurant
    try {
      if (restaurant.userId) {
        await notificationService.sendNewOrderNotification(
          restaurant.userId.toString(),
          order._id.toString(),
          order.orderNumber
        );
      }
    } catch (notifError) {
      logger.error(`Failed to send new order notification: ${notifError}`);
    }

    return order;
  }

  /**
   * Process order items and validate
   */
  private async processOrderItems(
    items: CreateOrderItemInput[],
    restaurantId: string
  ): Promise<IOrderItem[]> {
    const processedItems: IOrderItem[] = [];

    for (const item of items) {
      const menuItem = await MenuItem.findOne({
        _id: item.menuItemId,
        restaurantId,
        isAvailable: true,
      });

      if (!menuItem) {
        throw new AppError(
          `الصنف غير متوفر أو غير موجود`,
          StatusCodes.BAD_REQUEST
        );
      }

      // Calculate item total
      let itemTotal = menuItem.discountPrice || menuItem.price;

      // Process addons
      const selectedAddons: IOrderItem['selectedAddons'] = [];
      if (item.selectedAddons && item.selectedAddons.length > 0) {
        for (const addonInput of item.selectedAddons) {
          const addon = menuItem.addons.find(
            (a) => a._id?.toString() === addonInput.addonId
          );
          if (addon && addon.isAvailable) {
            selectedAddons.push({
              addonId: new Types.ObjectId(addonInput.addonId),
              name: addon.name,
              nameAr: addon.nameAr || addon.name,
              price: addon.price,
              quantity: addonInput.quantity,
            });
            itemTotal += addon.price * addonInput.quantity;
          }
        }
      }

      // Process variations
      const selectedVariations: IOrderItem['selectedVariations'] = [];
      if (item.selectedVariations && item.selectedVariations.length > 0) {
        for (const varInput of item.selectedVariations) {
          const variation = menuItem.variations.find(
            (v) => v._id?.toString() === varInput.variationId
          );
          if (variation) {
            const option = variation.options.find(
              (o) => o._id?.toString() === varInput.optionId
            );
            if (option) {
              selectedVariations.push({
                variationId: new Types.ObjectId(varInput.variationId),
                variationName: variation.name,
                optionId: new Types.ObjectId(varInput.optionId),
                optionName: option.name,
                optionNameAr: option.nameAr || option.name,
                price: option.price,
              });
              itemTotal += option.price;
            }
          }
        }
      }

      // Check required variations
      const requiredVariations = menuItem.variations.filter((v) => v.isRequired);
      for (const reqVar of requiredVariations) {
        const hasSelection = selectedVariations.some(
          (sv) => sv.variationId.toString() === reqVar._id?.toString()
        );
        if (!hasSelection) {
          throw new AppError(
            `يجب اختيار ${reqVar.name} للصنف ${menuItem.name}`,
            StatusCodes.BAD_REQUEST
          );
        }
      }

      processedItems.push({
        _id: new Types.ObjectId(),
        menuItemId: new Types.ObjectId(item.menuItemId),
        name: menuItem.name,
        nameAr: menuItem.nameAr || menuItem.name,
        image: menuItem.image,
        basePrice: menuItem.discountPrice || menuItem.price,
        quantity: item.quantity,
        selectedAddons,
        selectedVariations,
        specialInstructions: item.specialInstructions,
        itemTotal: itemTotal * item.quantity,
      });
    }

    return processedItems;
  }

  /**
   * Calculate order totals
   */
  private async calculateOrderTotals(
    items: IOrderItem[],
    restaurant: typeof Restaurant.prototype,
    couponCode?: string,
    customerId?: string
  ): Promise<OrderCalculation> {
    // Calculate subtotal
    const subtotal = items.reduce((sum, item) => sum + item.itemTotal, 0);

    // Calculate delivery fee
    let deliveryFee = restaurant.deliveryFee || 0;
    if (
      restaurant.freeDeliveryAbove &&
      subtotal >= restaurant.freeDeliveryAbove
    ) {
      deliveryFee = 0;
    }

    // Calculate service fee
    const serviceFee = Math.round(subtotal * this.SERVICE_FEE_PERCENTAGE);

    // Process coupon
    let discount = 0;
    let couponDiscount = 0;
    let couponId: Types.ObjectId | undefined;
    let validCouponCode: string | undefined;

    if (couponCode) {
      const couponResult = await this.validateAndApplyCoupon(
        couponCode,
        subtotal,
        restaurant._id.toString(),
        customerId
      );
      if (couponResult) {
        couponDiscount = couponResult.discount;
        discount = couponResult.discount;
        couponId = couponResult.couponId;
        validCouponCode = couponCode;
      }
    }

    // Calculate total
    const total = subtotal + deliveryFee + serviceFee - discount;

    return {
      subtotal,
      deliveryFee,
      serviceFee,
      discount,
      couponDiscount,
      total: Math.max(0, total),
      couponId,
      couponCode: validCouponCode,
    };
  }

  /**
   * Validate and apply coupon
   */
  private async validateAndApplyCoupon(
    code: string,
    subtotal: number,
    restaurantId: string,
    customerId?: string
  ): Promise<{ discount: number; couponId: Types.ObjectId } | null> {
    const coupon = await Coupon.findOne({
      code: code.toUpperCase(),
      isActive: true,
      validFrom: { $lte: new Date() },
      validUntil: { $gte: new Date() },
    });

    if (!coupon) {
      throw new AppError('كود الخصم غير صالح أو منتهي', StatusCodes.BAD_REQUEST);
    }

    // Check usage limit
    if (coupon.totalUsageLimit && coupon.usedCount >= coupon.totalUsageLimit) {
      throw new AppError(
        'تم استخدام كود الخصم الحد الأقصى من المرات',
        StatusCodes.BAD_REQUEST
      );
    }

    // Check user limit
    if (customerId && coupon.perUserLimit) {
      const userUsageCount = coupon.usedBy.filter(
        (usage) => usage.customerId.toString() === customerId
      ).length;
      if (userUsageCount >= coupon.perUserLimit) {
        throw new AppError(
          'لقد استخدمت هذا الكود الحد الأقصى من المرات',
          StatusCodes.BAD_REQUEST
        );
      }
    }

    // Check minimum order
    if (coupon.minimumOrder && subtotal < coupon.minimumOrder) {
      throw new AppError(
        `الحد الأدنى للطلب لاستخدام هذا الكود هو ${coupon.minimumOrder} ج.م`,
        StatusCodes.BAD_REQUEST
      );
    }

    // Check restaurant restriction
    if (
      coupon.restaurantIds &&
      coupon.restaurantIds.length > 0 &&
      !coupon.restaurantIds.some((r: Types.ObjectId) => r.toString() === restaurantId)
    ) {
      throw new AppError(
        'كود الخصم غير صالح لهذا المطعم',
        StatusCodes.BAD_REQUEST
      );
    }

    // Calculate discount
    let discount: number;
    if (coupon.type === 'percentage') {
      discount = Math.round(subtotal * (coupon.value / 100));
      if (coupon.maximumDiscount) {
        discount = Math.min(discount, coupon.maximumDiscount);
      }
    } else {
      discount = coupon.value;
    }

    return {
      discount: Math.min(discount, subtotal),
      couponId: coupon._id,
    };
  }

  /**
   * Get order by ID
   */
  async getOrderById(
    orderId: string,
    userId?: string,
    role?: string
  ): Promise<IOrder> {
    const order = await Order.findById(orderId)
      .populate('customer', 'name phone email')
      .populate('restaurant', 'name nameAr logo phone address')
      .populate('driver', 'name phone vehicleType');

    if (!order) {
      throw new AppError('الطلب غير موجود', StatusCodes.NOT_FOUND);
    }

    // Check access permissions
    if (userId && role) {
      const hasAccess = this.checkOrderAccess(order, userId, role);
      if (!hasAccess) {
        throw new AppError('غير مصرح بعرض هذا الطلب', StatusCodes.FORBIDDEN);
      }
    }

    return order;
  }

  /**
   * Check if user has access to order
   */
  private checkOrderAccess(
    order: IOrder,
    userId: string,
    role: string
  ): boolean {
    if (role === 'admin') return true;
    if (role === 'customer' && order.customerId.toString() === userId)
      return true;
    if (role === 'restaurant' && order.restaurantId.toString() === userId)
      return true;
    if (
      role === 'driver' &&
      order.driverId &&
      order.driverId.toString() === userId
    )
      return true;
    return false;
  }

  /**
   * Get orders with filters
   */
  async getOrders(
    options: GetOrdersOptions
  ): Promise<IPaginatedResult<IOrder>> {
    const {
      customerId,
      restaurantId,
      driverId,
      status,
      paymentStatus,
      startDate,
      endDate,
      page = 1,
      limit = 20,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = options;

    const query: FilterQuery<IOrder> = {};

    if (customerId) query.customerId = customerId;
    if (restaurantId) query.restaurantId = restaurantId;
    if (driverId) query.driverId = driverId;

    if (status) {
      if (Array.isArray(status)) {
        query.status = { $in: status };
      } else {
        query.status = status;
      }
    }

    if (paymentStatus) query.paymentStatus = paymentStatus;

    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = startDate;
      if (endDate) query.createdAt.$lte = endDate;
    }

    const skip = (page - 1) * limit;
    const sort: { [key: string]: SortOrder } = {
      [sortBy]: sortOrder === 'asc' ? 1 : -1,
    };

    const [orders, total] = await Promise.all([
      Order.find(query)
        .sort(sort)
        .skip(skip)
        .limit(limit)
        .populate('customer', 'name phone')
        .populate('restaurant', 'name nameAr logo')
        .populate('driver', 'name phone'),
      Order.countDocuments(query),
    ]);

    const pages = Math.ceil(total / limit);

    return {
      data: orders,
      pagination: {
        total,
        page,
        limit,
        pages,
        hasNext: page < pages,
        hasPrev: page > 1,
      },
    };
  }

  /**
   * Get customer orders
   */
  async getCustomerOrders(
    customerId: string,
    options: { page?: number; limit?: number; status?: OrderStatus[] } = {}
  ): Promise<IPaginatedResult<IOrder>> {
    return this.getOrders({
      customerId,
      status: options.status,
      page: options.page,
      limit: options.limit,
    });
  }

  /**
   * Get restaurant orders
   */
  async getRestaurantOrders(
    restaurantId: string,
    options: {
      page?: number;
      limit?: number;
      status?: OrderStatus[];
      startDate?: Date;
      endDate?: Date;
    } = {}
  ): Promise<IPaginatedResult<IOrder>> {
    return this.getOrders({
      restaurantId,
      status: options.status,
      startDate: options.startDate,
      endDate: options.endDate,
      page: options.page,
      limit: options.limit,
    });
  }

  /**
   * Get driver orders
   */
  async getDriverOrders(
    driverId: string,
    options: { page?: number; limit?: number; status?: OrderStatus[] } = {}
  ): Promise<IPaginatedResult<IOrder>> {
    return this.getOrders({
      driverId,
      status: options.status,
      page: options.page,
      limit: options.limit,
    });
  }

  /**
   * Get active orders for restaurant
   */
  async getActiveRestaurantOrders(restaurantId: string): Promise<IOrder[]> {
    return Order.find({
      restaurantId,
      status: { $in: ['pending', 'confirmed', 'preparing', 'ready'] },
    })
      .sort({ createdAt: -1 })
      .populate('customer', 'name phone');
  }

  /**
   * Get available orders for drivers
   */
  async getAvailableOrdersForDriver(
    driverLocation: { lat: number; lng: number },
    maxDistance: number = 10
  ): Promise<IOrder[]> {
    // Get orders that are ready for pickup and don't have a driver
    const orders = await Order.find({
      status: 'ready',
      driverId: { $exists: false },
    })
      .populate('restaurant', 'name nameAr logo phone address location')
      .populate('customer', 'name phone');

    // Filter by distance (simple distance calculation)
    const availableOrders = orders.filter((order) => {
      const restaurant = (order as any).restaurant;
      if (!restaurant?.location?.coordinates) return false;

      const [lng, lat] = restaurant.location.coordinates;
      const distance = this.calculateDistance(
        driverLocation.lat,
        driverLocation.lng,
        lat,
        lng
      );

      return distance <= maxDistance;
    });

    return availableOrders;
  }

  /**
   * Calculate distance between two points (Haversine formula)
   */
  private calculateDistance(
    lat1: number,
    lng1: number,
    lat2: number,
    lng2: number
  ): number {
    const R = 6371; // Earth's radius in km
    const dLat = this.toRad(lat2 - lat1);
    const dLng = this.toRad(lng2 - lng1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) *
        Math.cos(this.toRad(lat2)) *
        Math.sin(dLng / 2) *
        Math.sin(dLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private toRad(deg: number): number {
    return deg * (Math.PI / 180);
  }

  /**
   * Reorder - Create new order from previous order
   */
  async reorder(orderId: string, customerId: string): Promise<IOrder> {
    const originalOrder = await Order.findOne({
      _id: orderId,
      customerId,
      status: 'delivered',
    });

    if (!originalOrder) {
      throw new AppError('الطلب غير موجود', StatusCodes.NOT_FOUND);
    }

    // Recreate items from original order
    const items: CreateOrderItemInput[] = originalOrder.items.map((item) => ({
      menuItemId: item.menuItemId.toString(),
      quantity: item.quantity,
      selectedAddons: item.selectedAddons.map((addon) => ({
        addonId: addon.addonId.toString(),
        quantity: addon.quantity,
      })),
      selectedVariations: item.selectedVariations.map((variation) => ({
        variationId: variation.variationId.toString(),
        optionId: variation.optionId.toString(),
      })),
      specialInstructions: item.specialInstructions,
    }));

    // Create new order with original order data
    const newOrder = await this.createOrder({
      customerId,
      restaurantId: originalOrder.restaurantId.toString(),
      items,
      deliveryAddress: originalOrder.deliveryAddress,
      paymentMethod: originalOrder.paymentMethod,
      customerNotes: originalOrder.customerNotes,
    });

    // Mark as reorder
    newOrder.isReorder = true;
    newOrder.originalOrderId = originalOrder._id;
    await newOrder.save();

    return newOrder;
  }

  // =====================
  // Part 2: Status & Actions
  // =====================

  /**
   * Update order status
   */
  async updateOrderStatus(
    orderId: string,
    newStatus: OrderStatus,
    userId: string,
    note?: string
  ): Promise<IOrder> {
    const order = await Order.findById(orderId);
    if (!order) {
      throw new AppError('الطلب غير موجود', StatusCodes.NOT_FOUND);
    }

    // Validate status transition
    const validTransitions: Record<OrderStatus, OrderStatus[]> = {
      pending: ['confirmed', 'cancelled'],
      confirmed: ['preparing', 'cancelled'],
      preparing: ['ready', 'cancelled'],
      ready: ['picked_up', 'cancelled'],
      picked_up: ['on_the_way', 'cancelled'],
      on_the_way: ['delivered', 'cancelled'],
      delivered: [],
      cancelled: [],
    };

    if (!validTransitions[order.status].includes(newStatus)) {
      throw new AppError(
        `لا يمكن تغيير حالة الطلب من ${order.status} إلى ${newStatus}`,
        StatusCodes.BAD_REQUEST
      );
    }

    // Update status
    order.status = newStatus;
    order.statusHistory.push({
      status: newStatus,
      timestamp: new Date(),
      note,
      updatedBy: new Types.ObjectId(userId),
    });

    // Update timing fields based on status
    switch (newStatus) {
      case 'confirmed':
        order.restaurantAcceptedAt = new Date();
        // Calculate estimated delivery time (30-45 min from now)
        order.estimatedDeliveryTime = dayjs().add(45, 'minute').toDate();
        break;
      case 'preparing':
        order.preparationStartedAt = new Date();
        break;
      case 'ready':
        order.readyAt = new Date();
        break;
      case 'picked_up':
        order.pickedUpAt = new Date();
        break;
      case 'delivered':
        order.deliveredAt = new Date();
        if (order.paymentMethod === 'cash') {
          order.paymentStatus = 'paid';
          order.paidAt = new Date();
        }
        break;
    }

    await order.save();

    // Send order status notification to customer
    try {
      const customer = await Customer.findById(order.customerId).select('userId');
      if (customer?.userId) {
        await notificationService.sendOrderStatusNotification(
          customer.userId.toString(),
          order._id.toString(),
          order.orderNumber,
          newStatus
        );
      }
    } catch (notifError) {
      logger.error(`Failed to send order status notification: ${notifError}`);
    }

    return order;
  }

  /**
   * Cancel order
   */
  async cancelOrder(
    orderId: string,
    cancelledBy: 'customer' | 'restaurant' | 'driver' | 'admin',
    reason: string,
    userId: string
  ): Promise<IOrder> {
    const order = await Order.findById(orderId);
    if (!order) {
      throw new AppError('الطلب غير موجود', StatusCodes.NOT_FOUND);
    }

    // Check if order can be cancelled
    const nonCancellableStatuses: OrderStatus[] = [
      'delivered',
      'cancelled',
      'on_the_way',
    ];
    if (nonCancellableStatuses.includes(order.status)) {
      throw new AppError(
        'لا يمكن إلغاء هذا الطلب في الوقت الحالي',
        StatusCodes.BAD_REQUEST
      );
    }

    // Additional restrictions for customer cancellation
    if (cancelledBy === 'customer') {
      const nonCancellableByCustomer: OrderStatus[] = ['preparing', 'ready'];
      if (nonCancellableByCustomer.includes(order.status)) {
        throw new AppError(
          'لا يمكنك إلغاء الطلب بعد بدء التحضير',
          StatusCodes.BAD_REQUEST
        );
      }
    }

    // Update order
    order.status = 'cancelled';
    order.isCancelled = true;
    order.cancelReason = reason;
    order.cancelledBy = cancelledBy;
    order.cancelledAt = new Date();
    order.statusHistory.push({
      status: 'cancelled',
      timestamp: new Date(),
      note: `تم الإلغاء بواسطة ${cancelledBy}: ${reason}`,
      updatedBy: new Types.ObjectId(userId),
    });

    // Handle refund if payment was made
    if (order.paymentStatus === 'paid' && order.paymentMethod !== 'cash') {
      order.paymentStatus = 'refunded';
      // TODO: Process actual refund
    }

    // Restore coupon usage
    if (order.couponId) {
      await Coupon.findByIdAndUpdate(order.couponId, {
        $inc: { usedCount: -1 },
        $pull: { usedBy: order.customerId },
      });
    }

    await order.save();

    // Send cancellation notification to customer
    try {
      if (cancelledBy !== 'customer') {
        const customer = await Customer.findById(order.customerId).select('userId');
        if (customer?.userId) {
          await notificationService.sendOrderStatusNotification(
            customer.userId.toString(),
            order._id.toString(),
            order.orderNumber,
            'cancelled'
          );
        }
      }
    } catch (notifError) {
      logger.error(`Failed to send cancellation notification: ${notifError}`);
    }

    return order;
  }

  /**
   * Assign driver to order
   */
  async assignDriver(orderId: string, driverId: string): Promise<IOrder> {
    const order = await Order.findById(orderId);
    if (!order) {
      throw new AppError('الطلب غير موجود', StatusCodes.NOT_FOUND);
    }

    if (order.driverId) {
      throw new AppError('الطلب مخصص لسائق آخر بالفعل', StatusCodes.CONFLICT);
    }

    if (order.status !== 'ready') {
      throw new AppError(
        'لا يمكن تخصيص سائق حتى يكون الطلب جاهزاً',
        StatusCodes.BAD_REQUEST
      );
    }

    // Validate driver exists and is available
    const { Driver } = await import('../models/Driver');
    const driver = await Driver.findById(driverId);
    if (!driver) {
      throw new AppError('السائق غير موجود', StatusCodes.NOT_FOUND);
    }

    order.driverId = new Types.ObjectId(driverId);
    order.driverAssignedAt = new Date();
    await order.save();

    // Send order assigned notification to driver
    try {
      const restaurant = await Restaurant.findById(order.restaurantId).select('name nameAr');
      if (driver.userId) {
        await notificationService.sendOrderAssignedNotification(
          driver.userId.toString(),
          order._id.toString(),
          order.orderNumber,
          restaurant?.nameAr || restaurant?.name || 'المطعم'
        );
      }
    } catch (notifError) {
      logger.error(`Failed to send order assigned notification: ${notifError}`);
    }

    return order;
  }

  /**
   * Rate order
   */
  async rateOrder(
    orderId: string,
    customerId: string,
    rating: {
      restaurant?: number;
      driver?: number;
      food?: number;
      comment?: string;
    }
  ): Promise<IOrder> {
    const order = await Order.findOne({
      _id: orderId,
      customerId,
      status: 'delivered',
    });

    if (!order) {
      throw new AppError('الطلب غير موجود أو لم يتم تسليمه', StatusCodes.NOT_FOUND);
    }

    if (order.rating?.ratedAt) {
      throw new AppError('تم تقييم هذا الطلب مسبقاً', StatusCodes.CONFLICT);
    }

    // Validate ratings
    const validateRating = (value?: number) => {
      if (value !== undefined && (value < 1 || value > 5)) {
        throw new AppError('التقييم يجب أن يكون بين 1 و 5', StatusCodes.BAD_REQUEST);
      }
    };

    validateRating(rating.restaurant);
    validateRating(rating.driver);
    validateRating(rating.food);

    order.rating = {
      ...rating,
      ratedAt: new Date(),
    };

    await order.save();

    // Update restaurant rating
    if (rating.restaurant) {
      await this.updateRestaurantRating(order.restaurantId.toString());
    }

    // Update driver rating
    if (rating.driver && order.driverId) {
      await this.updateDriverRating(order.driverId.toString());
    }

    return order;
  }

  /**
   * Update restaurant aggregate rating
   */
  private async updateRestaurantRating(restaurantId: string): Promise<void> {
    const result = await Order.aggregate([
      {
        $match: {
          restaurantId: new Types.ObjectId(restaurantId),
          'rating.restaurant': { $exists: true },
        },
      },
      {
        $group: {
          _id: null,
          avgRating: { $avg: '$rating.restaurant' },
          count: { $sum: 1 },
        },
      },
    ]);

    if (result.length > 0) {
      await Restaurant.findByIdAndUpdate(restaurantId, {
        rating: Math.round(result[0].avgRating * 10) / 10,
        totalRatings: result[0].count,
      });
    }
  }

  /**
   * Update driver aggregate rating
   */
  private async updateDriverRating(driverId: string): Promise<void> {
    const { Driver } = await import('../models/Driver');

    const result = await Order.aggregate([
      {
        $match: {
          driverId: new Types.ObjectId(driverId),
          'rating.driver': { $exists: true },
        },
      },
      {
        $group: {
          _id: null,
          avgRating: { $avg: '$rating.driver' },
          count: { $sum: 1 },
        },
      },
    ]);

    if (result.length > 0) {
      await Driver.findByIdAndUpdate(driverId, {
        rating: Math.round(result[0].avgRating * 10) / 10,
        totalRatings: result[0].count,
      });
    }
  }

  // =====================
  // Part 3: Statistics
  // =====================

  /**
   * Get order statistics for restaurant
   */
  async getRestaurantOrderStats(
    restaurantId: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<{
    totalOrders: number;
    completedOrders: number;
    cancelledOrders: number;
    totalRevenue: number;
    averageOrderValue: number;
    ordersByStatus: Record<string, number>;
  }> {
    const query: FilterQuery<IOrder> = { restaurantId };
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = startDate;
      if (endDate) query.createdAt.$lte = endDate;
    }

    const [stats, statusCounts] = await Promise.all([
      Order.aggregate([
        { $match: query },
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
              $sum: {
                $cond: [{ $eq: ['$status', 'delivered'] }, '$restaurantEarnings', 0],
              },
            },
            avgOrderValue: { $avg: '$total' },
          },
        },
      ]),
      Order.aggregate([
        { $match: query },
        { $group: { _id: '$status', count: { $sum: 1 } } },
      ]),
    ]);

    const ordersByStatus: Record<string, number> = {};
    statusCounts.forEach((item) => {
      ordersByStatus[item._id] = item.count;
    });

    const result = stats[0] || {
      totalOrders: 0,
      completedOrders: 0,
      cancelledOrders: 0,
      totalRevenue: 0,
      avgOrderValue: 0,
    };

    return {
      totalOrders: result.totalOrders,
      completedOrders: result.completedOrders,
      cancelledOrders: result.cancelledOrders,
      totalRevenue: Math.round(result.totalRevenue),
      averageOrderValue: Math.round(result.avgOrderValue || 0),
      ordersByStatus,
    };
  }

  /**
   * Get driver earnings statistics
   */
  async getDriverEarningsStats(
    driverId: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<{
    totalDeliveries: number;
    totalEarnings: number;
    todayEarnings: number;
    weekEarnings: number;
    monthEarnings: number;
  }> {
    const query: FilterQuery<IOrder> = {
      driverId,
      status: 'delivered',
    };

    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = startDate;
      if (endDate) query.createdAt.$lte = endDate;
    }

    const today = dayjs().startOf('day').toDate();
    const weekStart = dayjs().startOf('week').toDate();
    const monthStart = dayjs().startOf('month').toDate();

    const [allTimeStats, todayStats, weekStats, monthStats] = await Promise.all([
      Order.aggregate([
        { $match: query },
        {
          $group: {
            _id: null,
            totalDeliveries: { $sum: 1 },
            totalEarnings: { $sum: '$driverEarnings' },
          },
        },
      ]),
      Order.aggregate([
        { $match: { ...query, deliveredAt: { $gte: today } } },
        { $group: { _id: null, earnings: { $sum: '$driverEarnings' } } },
      ]),
      Order.aggregate([
        { $match: { ...query, deliveredAt: { $gte: weekStart } } },
        { $group: { _id: null, earnings: { $sum: '$driverEarnings' } } },
      ]),
      Order.aggregate([
        { $match: { ...query, deliveredAt: { $gte: monthStart } } },
        { $group: { _id: null, earnings: { $sum: '$driverEarnings' } } },
      ]),
    ]);

    return {
      totalDeliveries: allTimeStats[0]?.totalDeliveries || 0,
      totalEarnings: allTimeStats[0]?.totalEarnings || 0,
      todayEarnings: todayStats[0]?.earnings || 0,
      weekEarnings: weekStats[0]?.earnings || 0,
      monthEarnings: monthStats[0]?.earnings || 0,
    };
  }

  /**
   * Get platform-wide order statistics (admin)
   */
  async getPlatformOrderStats(
    startDate?: Date,
    endDate?: Date
  ): Promise<{
    totalOrders: number;
    completedOrders: number;
    cancelledOrders: number;
    totalRevenue: number;
    platformEarnings: number;
    averageOrderValue: number;
    ordersByStatus: Record<string, number>;
    ordersByPaymentMethod: Record<string, number>;
  }> {
    const query: FilterQuery<IOrder> = {};
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = startDate;
      if (endDate) query.createdAt.$lte = endDate;
    }

    const [stats, statusCounts, paymentCounts] = await Promise.all([
      Order.aggregate([
        { $match: query },
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
              $sum: { $cond: [{ $eq: ['$status', 'delivered'] }, '$total', 0] },
            },
            platformEarnings: {
              $sum: {
                $cond: [{ $eq: ['$status', 'delivered'] }, '$platformEarnings', 0],
              },
            },
            avgOrderValue: { $avg: '$total' },
          },
        },
      ]),
      Order.aggregate([
        { $match: query },
        { $group: { _id: '$status', count: { $sum: 1 } } },
      ]),
      Order.aggregate([
        { $match: query },
        { $group: { _id: '$paymentMethod', count: { $sum: 1 } } },
      ]),
    ]);

    const ordersByStatus: Record<string, number> = {};
    statusCounts.forEach((item) => {
      ordersByStatus[item._id] = item.count;
    });

    const ordersByPaymentMethod: Record<string, number> = {};
    paymentCounts.forEach((item) => {
      ordersByPaymentMethod[item._id] = item.count;
    });

    const result = stats[0] || {
      totalOrders: 0,
      completedOrders: 0,
      cancelledOrders: 0,
      totalRevenue: 0,
      platformEarnings: 0,
      avgOrderValue: 0,
    };

    return {
      totalOrders: result.totalOrders,
      completedOrders: result.completedOrders,
      cancelledOrders: result.cancelledOrders,
      totalRevenue: Math.round(result.totalRevenue),
      platformEarnings: Math.round(result.platformEarnings),
      averageOrderValue: Math.round(result.avgOrderValue || 0),
      ordersByStatus,
      ordersByPaymentMethod,
    };
  }
}

export const orderService = new OrderService();
export default orderService;
