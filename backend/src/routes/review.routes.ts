import { Router } from 'express';
import { validate } from '../middleware/validate';
import { authenticate, authorize } from '../middleware/auth';
import {
  reviewQuerySchema,
  adminReviewQuerySchema,
  replySchema,
  reportSchema,
  toggleVisibilitySchema,
  resolveReportSchema,
} from '../validators/review.validator';
import {
  // Public
  getRestaurantReviews,
  getRestaurantReviewStats,
  getReviewById,
  // Customer
  getMyReviews,
  reportReview,
  // Restaurant
  replyToReview,
  updateReply,
  deleteReply,
  getMyRestaurantReviews,
  getMyRestaurantReviewStats,
  // Admin
  getAllReviews,
  toggleReviewVisibility,
  resolveReport,
  deleteReview,
} from '../controllers/review.controller';

const router = Router();

// ==================== Public Routes ====================

// Get review by ID
router.get('/:id', getReviewById);

// Report a review (requires auth)
router.post(
  '/:id/report',
  authenticate,
  validate(reportSchema),
  reportReview
);

// ==================== Restaurant Reviews Routes (Public) ====================

const restaurantReviewsRouter = Router({ mergeParams: true });

// Get restaurant reviews (public)
restaurantReviewsRouter.get(
  '/',
  validate(reviewQuerySchema, 'query'),
  getRestaurantReviews
);

// Get restaurant review stats (public)
restaurantReviewsRouter.get('/stats', getRestaurantReviewStats);

// ==================== Customer Routes ====================

const customerReviewRouter = Router();

// Get my reviews
customerReviewRouter.get(
  '/',
  authenticate,
  authorize('customer'),
  validate(reviewQuerySchema, 'query'),
  getMyReviews
);

// ==================== Restaurant Owner Routes ====================

const restaurantOwnerReviewRouter = Router();

// Get my restaurant reviews
restaurantOwnerReviewRouter.get(
  '/',
  authenticate,
  authorize('restaurant'),
  validate(reviewQuerySchema, 'query'),
  getMyRestaurantReviews
);

// Get my restaurant review stats
restaurantOwnerReviewRouter.get(
  '/stats',
  authenticate,
  authorize('restaurant'),
  getMyRestaurantReviewStats
);

// Reply to review
restaurantOwnerReviewRouter.post(
  '/:id/reply',
  authenticate,
  authorize('restaurant'),
  validate(replySchema),
  replyToReview
);

// Update reply
restaurantOwnerReviewRouter.put(
  '/:id/reply',
  authenticate,
  authorize('restaurant'),
  validate(replySchema),
  updateReply
);

// Delete reply
restaurantOwnerReviewRouter.delete(
  '/:id/reply',
  authenticate,
  authorize('restaurant'),
  deleteReply
);

// ==================== Admin Routes ====================

const adminReviewRouter = Router();

// Get all reviews
adminReviewRouter.get(
  '/',
  authenticate,
  authorize('admin'),
  validate(adminReviewQuerySchema, 'query'),
  getAllReviews
);

// Toggle visibility
adminReviewRouter.put(
  '/:id/visibility',
  authenticate,
  authorize('admin'),
  validate(toggleVisibilitySchema),
  toggleReviewVisibility
);

// Resolve report
adminReviewRouter.put(
  '/:id/resolve',
  authenticate,
  authorize('admin'),
  validate(resolveReportSchema),
  resolveReport
);

// Delete review
adminReviewRouter.delete(
  '/:id',
  authenticate,
  authorize('admin'),
  deleteReview
);

export default router;
export {
  restaurantReviewsRouter,
  customerReviewRouter,
  restaurantOwnerReviewRouter,
  adminReviewRouter
};
