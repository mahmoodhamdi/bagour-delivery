import { Response, NextFunction } from 'express';
import { AuthRequest } from '../types';
import { couponService } from '../services/coupon.service';
import { successResponse, paginatedResponse } from '../utils/response';
import { StatusCodes } from 'http-status-codes';
import { Customer } from '../models/Customer';
import { AppError } from '../utils/errors';

// ==================== Admin Coupon Endpoints ====================

/**
 * Create a new coupon
 * POST /api/v1/admin/coupons
 */
export const createCoupon = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;

    const coupon = await couponService.createCoupon({
      ...req.body,
      createdBy: userId || '',
    });

    successResponse(res, StatusCodes.CREATED, 'تم إنشاء كود الخصم بنجاح', { coupon });
  } catch (error) {
    next(error);
  }
};

/**
 * Get all coupons with filters
 * GET /api/v1/admin/coupons
 */
export const getCoupons = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      isActive,
      type,
      search,
      page,
      limit,
      sortBy,
      sortOrder,
    } = req.query;

    const result = await couponService.getCoupons({
      isActive: isActive !== undefined ? isActive === 'true' : undefined,
      type: type as 'percentage' | 'fixed' | undefined,
      search: search as string | undefined,
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
      sortBy: sortBy as string | undefined,
      sortOrder: sortOrder as 'asc' | 'desc' | undefined,
    });

    paginatedResponse(
      res,
      StatusCodes.OK,
      'تم جلب أكواد الخصم بنجاح',
      result.data,
      result.pagination
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get coupon by ID
 * GET /api/v1/admin/coupons/:id
 */
export const getCouponById = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    const coupon = await couponService.getCouponById(id);

    successResponse(res, StatusCodes.OK, 'تم جلب كود الخصم بنجاح', { coupon });
  } catch (error) {
    next(error);
  }
};

/**
 * Update coupon
 * PUT /api/v1/admin/coupons/:id
 */
export const updateCoupon = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    const coupon = await couponService.updateCoupon(id, req.body);

    successResponse(res, StatusCodes.OK, 'تم تحديث كود الخصم بنجاح', { coupon });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete coupon
 * DELETE /api/v1/admin/coupons/:id
 */
export const deleteCoupon = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    await couponService.deleteCoupon(id);

    successResponse(res, StatusCodes.OK, 'تم حذف كود الخصم بنجاح', null);
  } catch (error) {
    next(error);
  }
};

/**
 * Toggle coupon active status
 * PUT /api/v1/admin/coupons/:id/toggle
 */
export const toggleCouponStatus = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    const coupon = await couponService.toggleCouponStatus(id);

    const message = coupon.isActive
      ? 'تم تفعيل كود الخصم بنجاح'
      : 'تم تعطيل كود الخصم بنجاح';

    successResponse(res, StatusCodes.OK, message, { coupon });
  } catch (error) {
    next(error);
  }
};

/**
 * Get coupon statistics
 * GET /api/v1/admin/coupons/:id/stats
 */
export const getCouponStats = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    const stats = await couponService.getCouponStats(id);

    successResponse(res, StatusCodes.OK, 'تم جلب إحصائيات كود الخصم بنجاح', { stats });
  } catch (error) {
    next(error);
  }
};

/**
 * Create bulk coupons
 * POST /api/v1/admin/coupons/bulk
 */
export const createBulkCoupons = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { count, prefix, ...couponData } = req.body;

    const coupons = await couponService.createBulkCoupons(
      {
        ...couponData,
        createdBy: userId || '',
      },
      count,
      prefix
    );

    successResponse(res, StatusCodes.CREATED, `تم إنشاء ${coupons.length} كود خصم بنجاح`, {
      coupons,
      count: coupons.length,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Generate unique coupon code
 * GET /api/v1/admin/coupons/generate-code
 */
export const generateCouponCode = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { prefix, length } = req.query;

    const code = couponService.generateCouponCode(
      prefix as string | undefined,
      length ? Number(length) : undefined
    );

    successResponse(res, StatusCodes.OK, 'تم إنشاء الكود بنجاح', { code });
  } catch (error) {
    next(error);
  }
};

// ==================== Customer Coupon Endpoints ====================

/**
 * Validate coupon for customer
 * POST /api/v1/coupons/validate
 */
export const validateCoupon = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { code, subtotal, restaurantId } = req.body;

    const customer = await Customer.findOne({ userId });
    if (!customer) {
      throw new AppError('العميل غير موجود', StatusCodes.NOT_FOUND);
    }

    const result = await couponService.validateCoupon(
      code,
      customer._id.toString(),
      subtotal,
      restaurantId
    );

    if (result.isValid) {
      successResponse(res, StatusCodes.OK, result.message || 'كود الخصم صالح', {
        isValid: true,
        discount: result.discount,
        coupon: {
          code: result.coupon?.code,
          type: result.coupon?.type,
          value: result.coupon?.value,
          minimumOrder: result.coupon?.minimumOrder,
          maximumDiscount: result.coupon?.maximumDiscount,
        },
      });
    } else {
      successResponse(res, StatusCodes.OK, result.message || 'كود الخصم غير صالح', {
        isValid: false,
      });
    }
  } catch (error) {
    next(error);
  }
};

/**
 * Get available coupons for customer
 * GET /api/v1/coupons/available
 */
export const getAvailableCoupons = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { restaurantId } = req.query;

    const customer = await Customer.findOne({ userId });
    if (!customer) {
      throw new AppError('العميل غير موجود', StatusCodes.NOT_FOUND);
    }

    const coupons = await couponService.getActiveCouponsForCustomer(
      customer._id.toString(),
      restaurantId as string | undefined
    );

    // Return only public coupon info
    const publicCoupons = coupons.map((coupon) => ({
      code: coupon.code,
      type: coupon.type,
      value: coupon.value,
      minimumOrder: coupon.minimumOrder,
      maximumDiscount: coupon.maximumDiscount,
      validUntil: coupon.validUntil,
      firstOrderOnly: coupon.firstOrderOnly,
    }));

    successResponse(res, StatusCodes.OK, 'تم جلب أكواد الخصم المتاحة بنجاح', {
      coupons: publicCoupons,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get coupon by code (public info only)
 * GET /api/v1/coupons/:code
 */
export const getCouponByCode = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { code } = req.params;

    const coupon = await couponService.getCouponByCode(code);

    // Return only public info
    successResponse(res, StatusCodes.OK, 'تم جلب كود الخصم بنجاح', {
      coupon: {
        code: coupon.code,
        type: coupon.type,
        value: coupon.value,
        minimumOrder: coupon.minimumOrder,
        maximumDiscount: coupon.maximumDiscount,
        validFrom: coupon.validFrom,
        validUntil: coupon.validUntil,
        firstOrderOnly: coupon.firstOrderOnly,
        isActive: coupon.isActive,
      },
    });
  } catch (error) {
    next(error);
  }
};
