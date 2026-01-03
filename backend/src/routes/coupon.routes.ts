import { Router } from 'express';
import { validate } from '../middleware/validate';
import { authenticate, authorize } from '../middleware/auth';
import {
  createCouponSchema,
  updateCouponSchema,
  getCouponsQuerySchema,
  validateCouponSchema,
  createBulkCouponsSchema,
} from '../validators/coupon.validator';
import {
  // Admin endpoints
  createCoupon,
  getCoupons,
  getCouponById,
  updateCoupon,
  deleteCoupon,
  toggleCouponStatus,
  getCouponStats,
  createBulkCoupons,
  generateCouponCode,
  // Customer endpoints
  validateCoupon,
  getAvailableCoupons,
  getCouponByCode,
} from '../controllers/coupon.controller';

const router = Router();

// ==================== Customer Routes ====================

// Validate coupon
router.post(
  '/validate',
  authenticate,
  authorize('customer'),
  validate(validateCouponSchema),
  validateCoupon
);

// Get available coupons for customer
router.get(
  '/available',
  authenticate,
  authorize('customer'),
  getAvailableCoupons
);

// Get coupon by code (public info)
router.get(
  '/code/:code',
  authenticate,
  getCouponByCode
);

// ==================== Admin Routes ====================

const adminRouter = Router();

// Generate coupon code
adminRouter.get(
  '/coupons/generate-code',
  authenticate,
  authorize('admin'),
  generateCouponCode
);

// Create bulk coupons
adminRouter.post(
  '/coupons/bulk',
  authenticate,
  authorize('admin'),
  validate(createBulkCouponsSchema),
  createBulkCoupons
);

// Get all coupons
adminRouter.get(
  '/coupons',
  authenticate,
  authorize('admin'),
  validate(getCouponsQuerySchema, 'query'),
  getCoupons
);

// Create coupon
adminRouter.post(
  '/coupons',
  authenticate,
  authorize('admin'),
  validate(createCouponSchema),
  createCoupon
);

// Get coupon by ID
adminRouter.get(
  '/coupons/:id',
  authenticate,
  authorize('admin'),
  getCouponById
);

// Update coupon
adminRouter.put(
  '/coupons/:id',
  authenticate,
  authorize('admin'),
  validate(updateCouponSchema),
  updateCoupon
);

// Delete coupon
adminRouter.delete(
  '/coupons/:id',
  authenticate,
  authorize('admin'),
  deleteCoupon
);

// Toggle coupon status
adminRouter.put(
  '/coupons/:id/toggle',
  authenticate,
  authorize('admin'),
  toggleCouponStatus
);

// Get coupon statistics
adminRouter.get(
  '/coupons/:id/stats',
  authenticate,
  authorize('admin'),
  getCouponStats
);

export default router;
export { adminRouter as couponAdminRouter };
