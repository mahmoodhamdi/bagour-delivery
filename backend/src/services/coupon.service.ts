import { Types, SortOrder } from 'mongoose';
import { Coupon, ICoupon, ICouponUsage } from '../models/Coupon';
import { Customer } from '../models/Customer';
import { Order } from '../models/Order';
import { NotFoundError, BadRequestError, ConflictError } from '../utils/errors';
import { CouponType, IPaginatedResult } from '../types';

// Types
interface CreateCouponInput {
  code: string;
  type: CouponType;
  value: number;
  minimumOrder?: number;
  maximumDiscount?: number;
  totalUsageLimit?: number;
  perUserLimit?: number;
  validFrom: Date;
  validUntil: Date;
  restaurantIds?: string[];
  categoryIds?: string[];
  customerIds?: string[];
  firstOrderOnly?: boolean;
  isActive?: boolean;
  createdBy: string;
}

interface UpdateCouponInput {
  type?: CouponType;
  value?: number;
  minimumOrder?: number;
  maximumDiscount?: number;
  totalUsageLimit?: number;
  perUserLimit?: number;
  validFrom?: Date;
  validUntil?: Date;
  restaurantIds?: string[];
  categoryIds?: string[];
  customerIds?: string[];
  firstOrderOnly?: boolean;
  isActive?: boolean;
}

interface GetCouponsOptions {
  isActive?: boolean;
  type?: CouponType;
  search?: string;
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

interface ValidateCouponResult {
  isValid: boolean;
  coupon?: ICoupon;
  discount?: number;
  message?: string;
}

class CouponService {
  /**
   * Create a new coupon
   */
  async createCoupon(input: CreateCouponInput): Promise<ICoupon> {
    // Check if code already exists
    const existingCoupon = await Coupon.findOne({ code: input.code.toUpperCase() });
    if (existingCoupon) {
      throw new ConflictError('كود الخصم موجود بالفعل');
    }

    // Validate percentage
    if (input.type === 'percentage' && input.value > 100) {
      throw new BadRequestError('نسبة الخصم لا يمكن أن تتجاوز 100%');
    }

    // Validate dates
    if (new Date(input.validUntil) <= new Date(input.validFrom)) {
      throw new BadRequestError('تاريخ الانتهاء يجب أن يكون بعد تاريخ البداية');
    }

    const coupon = new Coupon({
      code: input.code.toUpperCase(),
      type: input.type,
      value: input.value,
      minimumOrder: input.minimumOrder || 0,
      maximumDiscount: input.maximumDiscount,
      totalUsageLimit: input.totalUsageLimit,
      perUserLimit: input.perUserLimit || 1,
      validFrom: input.validFrom,
      validUntil: input.validUntil,
      restaurantIds: input.restaurantIds || [],
      categoryIds: input.categoryIds || [],
      customerIds: input.customerIds || [],
      firstOrderOnly: input.firstOrderOnly || false,
      isActive: input.isActive !== undefined ? input.isActive : true,
      createdBy: input.createdBy,
    });

    await coupon.save();
    return coupon;
  }

  /**
   * Get coupon by ID
   */
  async getCouponById(couponId: string): Promise<ICoupon> {
    const coupon = await Coupon.findById(couponId);
    if (!coupon) {
      throw new NotFoundError('كود الخصم غير موجود');
    }
    return coupon;
  }

  /**
   * Get coupon by code
   */
  async getCouponByCode(code: string): Promise<ICoupon> {
    const coupon = await Coupon.findOne({ code: code.toUpperCase() });
    if (!coupon) {
      throw new NotFoundError('كود الخصم غير موجود');
    }
    return coupon;
  }

  /**
   * Get all coupons with filters
   */
  async getCoupons(options: GetCouponsOptions): Promise<IPaginatedResult<ICoupon>> {
    const {
      isActive,
      type,
      search,
      page = 1,
      limit = 20,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = options;

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const query: Record<string, any> = {};

    if (isActive !== undefined) {
      query.isActive = isActive;
    }

    if (type) {
      query.type = type;
    }

    if (search) {
      query.code = { $regex: search.toUpperCase(), $options: 'i' };
    }

    const skip = (page - 1) * limit;
    const sort: { [key: string]: SortOrder } = { [sortBy]: sortOrder === 'asc' ? 1 : -1 };

    const [coupons, total] = await Promise.all([
      Coupon.find(query).sort(sort).skip(skip).limit(limit),
      Coupon.countDocuments(query),
    ]);

    const pages = Math.ceil(total / limit);

    return {
      data: coupons,
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
   * Update coupon
   */
  async updateCoupon(couponId: string, input: UpdateCouponInput): Promise<ICoupon> {
    const coupon = await Coupon.findById(couponId);
    if (!coupon) {
      throw new NotFoundError('كود الخصم غير موجود');
    }

    // Validate percentage
    if (input.type === 'percentage' && input.value && input.value > 100) {
      throw new BadRequestError('نسبة الخصم لا يمكن أن تتجاوز 100%');
    }

    // Validate dates
    const validFrom = input.validFrom || coupon.validFrom;
    const validUntil = input.validUntil || coupon.validUntil;
    if (new Date(validUntil) <= new Date(validFrom)) {
      throw new BadRequestError('تاريخ الانتهاء يجب أن يكون بعد تاريخ البداية');
    }

    Object.assign(coupon, input);
    await coupon.save();

    return coupon;
  }

  /**
   * Delete coupon
   */
  async deleteCoupon(couponId: string): Promise<void> {
    const coupon = await Coupon.findById(couponId);
    if (!coupon) {
      throw new NotFoundError('كود الخصم غير موجود');
    }

    // Check if coupon has been used
    if (coupon.usedCount > 0) {
      throw new BadRequestError('لا يمكن حذف كود خصم تم استخدامه. يمكنك تعطيله بدلاً من ذلك');
    }

    await coupon.deleteOne();
  }

  /**
   * Toggle coupon active status
   */
  async toggleCouponStatus(couponId: string): Promise<ICoupon> {
    const coupon = await Coupon.findById(couponId);
    if (!coupon) {
      throw new NotFoundError('كود الخصم غير موجود');
    }

    coupon.isActive = !coupon.isActive;
    await coupon.save();

    return coupon;
  }

  /**
   * Validate coupon for customer
   */
  async validateCoupon(
    code: string,
    customerId: string,
    subtotal: number,
    restaurantId?: string
  ): Promise<ValidateCouponResult> {
    const coupon = await Coupon.findOne({ code: code.toUpperCase() });

    if (!coupon) {
      return {
        isValid: false,
        message: 'كود الخصم غير موجود',
      };
    }

    // Check if active
    if (!coupon.isActive) {
      return {
        isValid: false,
        message: 'كود الخصم غير مفعل',
      };
    }

    // Check validity dates
    const now = new Date();
    if (now < coupon.validFrom) {
      return {
        isValid: false,
        message: 'كود الخصم لم يبدأ بعد',
      };
    }

    if (now > coupon.validUntil) {
      return {
        isValid: false,
        message: 'كود الخصم منتهي الصلاحية',
      };
    }

    // Check total usage limit
    if (coupon.totalUsageLimit && coupon.usedCount >= coupon.totalUsageLimit) {
      return {
        isValid: false,
        message: 'تم استخدام كود الخصم الحد الأقصى من المرات',
      };
    }

    // Check user usage limit
    const userUsageCount = coupon.usedBy.filter(
      (usage: ICouponUsage) => usage.customerId.toString() === customerId
    ).length;
    if (userUsageCount >= coupon.perUserLimit) {
      return {
        isValid: false,
        message: 'لقد استخدمت هذا الكود الحد الأقصى من المرات',
      };
    }

    // Check minimum order
    if (coupon.minimumOrder && subtotal < coupon.minimumOrder) {
      return {
        isValid: false,
        message: `الحد الأدنى للطلب لاستخدام هذا الكود هو ${coupon.minimumOrder} ج.م`,
      };
    }

    // Check restaurant restriction
    if (restaurantId && coupon.restaurantIds.length > 0) {
      const isValidRestaurant = coupon.restaurantIds.some(
        (r: Types.ObjectId) => r.toString() === restaurantId
      );
      if (!isValidRestaurant) {
        return {
          isValid: false,
          message: 'كود الخصم غير صالح لهذا المطعم',
        };
      }
    }

    // Check customer restriction
    if (coupon.customerIds.length > 0) {
      const isValidCustomer = coupon.customerIds.some(
        (c: Types.ObjectId) => c.toString() === customerId
      );
      if (!isValidCustomer) {
        return {
          isValid: false,
          message: 'كود الخصم غير مخصص لك',
        };
      }
    }

    // Check first order only
    if (coupon.firstOrderOnly) {
      const customer = await Customer.findById(customerId);
      if (customer && customer.totalOrders > 0) {
        return {
          isValid: false,
          message: 'كود الخصم صالح للطلب الأول فقط',
        };
      }
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

    // Cap discount at subtotal
    discount = Math.min(discount, subtotal);

    return {
      isValid: true,
      coupon,
      discount,
      message: `تم تطبيق خصم ${discount} ج.م`,
    };
  }

  /**
   * Apply coupon to order (record usage)
   */
  async applyCouponToOrder(
    couponId: string,
    customerId: string,
    orderId: string,
    discountAmount: number
  ): Promise<void> {
    await Coupon.findByIdAndUpdate(couponId, {
      $inc: { usedCount: 1 },
      $push: {
        usedBy: {
          customerId: new Types.ObjectId(customerId),
          orderId: new Types.ObjectId(orderId),
          usedAt: new Date(),
          discountAmount,
        },
      },
    });
  }

  /**
   * Reverse coupon usage (for cancelled orders)
   */
  async reverseCouponUsage(couponId: string, orderId: string): Promise<void> {
    await Coupon.findByIdAndUpdate(couponId, {
      $inc: { usedCount: -1 },
      $pull: { usedBy: { orderId: new Types.ObjectId(orderId) } },
    });
  }

  /**
   * Get coupon usage statistics
   */
  async getCouponStats(couponId: string): Promise<{
    totalUsage: number;
    totalDiscount: number;
    uniqueUsers: number;
    recentUsage: ICouponUsage[];
  }> {
    const coupon = await Coupon.findById(couponId);
    if (!coupon) {
      throw new NotFoundError('كود الخصم غير موجود');
    }

    const totalDiscount = coupon.usedBy.reduce(
      (sum: number, usage: ICouponUsage) => sum + usage.discountAmount,
      0
    );

    const uniqueUsers = new Set(
      coupon.usedBy.map((usage: ICouponUsage) => usage.customerId.toString())
    ).size;

    const recentUsage = coupon.usedBy
      .sort((a: ICouponUsage, b: ICouponUsage) =>
        new Date(b.usedAt).getTime() - new Date(a.usedAt).getTime()
      )
      .slice(0, 10);

    return {
      totalUsage: coupon.usedCount,
      totalDiscount,
      uniqueUsers,
      recentUsage,
    };
  }

  /**
   * Get active coupons for customer
   */
  async getActiveCouponsForCustomer(
    customerId: string,
    restaurantId?: string
  ): Promise<ICoupon[]> {
    const now = new Date();

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const query: Record<string, any> = {
      isActive: true,
      validFrom: { $lte: now },
      validUntil: { $gte: now },
      $or: [
        { customerIds: { $size: 0 } }, // No customer restriction
        { customerIds: new Types.ObjectId(customerId) }, // Customer is in the list
      ],
    };

    if (restaurantId) {
      query.$and = [
        {
          $or: [
            { restaurantIds: { $size: 0 } }, // No restaurant restriction
            { restaurantIds: new Types.ObjectId(restaurantId) }, // Restaurant is in the list
          ],
        },
      ];
    }

    const coupons = await Coupon.find(query);

    // Filter out coupons that the user has used up
    const filteredCoupons = coupons.filter((coupon) => {
      const userUsageCount = coupon.usedBy.filter(
        (usage: ICouponUsage) => usage.customerId.toString() === customerId
      ).length;
      return userUsageCount < coupon.perUserLimit;
    });

    return filteredCoupons;
  }

  /**
   * Generate unique coupon code
   */
  generateCouponCode(prefix: string = '', length: number = 8): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = prefix.toUpperCase();

    for (let i = 0; i < length; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }

    return code;
  }

  /**
   * Create bulk coupons
   */
  async createBulkCoupons(
    baseInput: Omit<CreateCouponInput, 'code'>,
    count: number,
    prefix: string = ''
  ): Promise<ICoupon[]> {
    const coupons: ICoupon[] = [];

    for (let i = 0; i < count; i++) {
      let code: string;
      let attempts = 0;

      // Generate unique code
      do {
        code = this.generateCouponCode(prefix);
        const existing = await Coupon.findOne({ code });
        if (!existing) break;
        attempts++;
      } while (attempts < 10);

      if (attempts >= 10) {
        throw new BadRequestError('فشل في إنشاء كود فريد');
      }

      const coupon = await this.createCoupon({
        ...baseInput,
        code,
      });
      coupons.push(coupon);
    }

    return coupons;
  }
}

export const couponService = new CouponService();
export default couponService;
