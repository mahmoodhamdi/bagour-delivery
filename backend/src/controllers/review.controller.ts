import { Request, Response, NextFunction } from 'express';
import { reviewService } from '../services/review.service';
import { sendSuccess, sendPaginated } from '../utils/response';
import { IAuthRequest } from '../types';

// ==================== Public Routes ====================

/**
 * Get reviews for a restaurant
 * GET /api/v1/restaurants/:restaurantId/reviews
 */
export const getRestaurantReviews = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { restaurantId } = req.params;
    const { page, limit, minRating, maxRating, hasComment, sortBy, sortOrder } = req.query;

    const result = await reviewService.getRestaurantReviews(restaurantId, {
      page: page ? parseInt(page as string) : undefined,
      limit: limit ? parseInt(limit as string) : undefined,
      minRating: minRating ? parseInt(minRating as string) : undefined,
      maxRating: maxRating ? parseInt(maxRating as string) : undefined,
      hasComment: hasComment ? hasComment === 'true' : undefined,
      sortBy: sortBy as string,
      sortOrder: sortOrder as 'asc' | 'desc',
    });

    sendPaginated(res, result.data, result.pagination);
  } catch (error) {
    next(error);
  }
};

/**
 * Get restaurant review statistics
 * GET /api/v1/restaurants/:restaurantId/reviews/stats
 */
export const getRestaurantReviewStats = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { restaurantId } = req.params;
    const stats = await reviewService.getRestaurantStats(restaurantId);
    sendSuccess(res, stats);
  } catch (error) {
    next(error);
  }
};

/**
 * Get review by ID
 * GET /api/v1/reviews/:id
 */
export const getReviewById = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const review = await reviewService.getReviewById(req.params.id);
    sendSuccess(res, review);
  } catch (error) {
    next(error);
  }
};

// ==================== Customer Routes ====================

/**
 * Get my reviews
 * GET /api/v1/customer/reviews
 */
export const getMyReviews = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const { page, limit, sortBy, sortOrder } = req.query;

    const result = await reviewService.getCustomerReviews(req.customerId!, {
      page: page ? parseInt(page as string) : undefined,
      limit: limit ? parseInt(limit as string) : undefined,
      sortBy: sortBy as string,
      sortOrder: sortOrder as 'asc' | 'desc',
    });

    sendPaginated(res, result.data, result.pagination);
  } catch (error) {
    next(error);
  }
};

/**
 * Report a review
 * POST /api/v1/reviews/:id/report
 */
export const reportReview = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const { reason } = req.body;
    const review = await reviewService.reportReview(
      req.params.id,
      reason,
      req.user!.id
    );
    sendSuccess(res, review, 'تم الإبلاغ عن المراجعة بنجاح');
  } catch (error) {
    next(error);
  }
};

// ==================== Restaurant Routes ====================

/**
 * Reply to a review
 * POST /api/v1/restaurant/reviews/:id/reply
 */
export const replyToReview = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const { reply } = req.body;
    const review = await reviewService.replyToReview(
      req.params.id,
      req.restaurantId!,
      reply
    );
    sendSuccess(res, review, 'تم الرد على المراجعة بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Update reply
 * PUT /api/v1/restaurant/reviews/:id/reply
 */
export const updateReply = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const { reply } = req.body;
    const review = await reviewService.updateReply(
      req.params.id,
      req.restaurantId!,
      reply
    );
    sendSuccess(res, review, 'تم تحديث الرد بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Delete reply
 * DELETE /api/v1/restaurant/reviews/:id/reply
 */
export const deleteReply = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const review = await reviewService.deleteReply(req.params.id, req.restaurantId!);
    sendSuccess(res, review, 'تم حذف الرد بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Get reviews for my restaurant
 * GET /api/v1/restaurant/reviews
 */
export const getMyRestaurantReviews = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const { page, limit, minRating, maxRating, hasComment, sortBy, sortOrder } = req.query;

    const result = await reviewService.getRestaurantReviews(req.restaurantId!, {
      page: page ? parseInt(page as string) : undefined,
      limit: limit ? parseInt(limit as string) : undefined,
      minRating: minRating ? parseInt(minRating as string) : undefined,
      maxRating: maxRating ? parseInt(maxRating as string) : undefined,
      hasComment: hasComment ? hasComment === 'true' : undefined,
      sortBy: sortBy as string,
      sortOrder: sortOrder as 'asc' | 'desc',
    });

    sendPaginated(res, result.data, result.pagination);
  } catch (error) {
    next(error);
  }
};

/**
 * Get my restaurant review stats
 * GET /api/v1/restaurant/reviews/stats
 */
export const getMyRestaurantReviewStats = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const stats = await reviewService.getRestaurantStats(req.restaurantId!);
    sendSuccess(res, stats);
  } catch (error) {
    next(error);
  }
};

// ==================== Admin Routes ====================

/**
 * Get all reviews (admin)
 * GET /api/v1/admin/reviews
 */
export const getAllReviews = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const {
      restaurantId,
      customerId,
      isVisible,
      isReported,
      minRating,
      maxRating,
      page,
      limit,
      sortBy,
      sortOrder,
    } = req.query;

    const result = await reviewService.getAllReviews({
      restaurantId: restaurantId as string,
      customerId: customerId as string,
      isVisible: isVisible ? isVisible === 'true' : undefined,
      isReported: isReported ? isReported === 'true' : undefined,
      minRating: minRating ? parseInt(minRating as string) : undefined,
      maxRating: maxRating ? parseInt(maxRating as string) : undefined,
      page: page ? parseInt(page as string) : undefined,
      limit: limit ? parseInt(limit as string) : undefined,
      sortBy: sortBy as string,
      sortOrder: sortOrder as 'asc' | 'desc',
    });

    sendPaginated(res, result.data, result.pagination);
  } catch (error) {
    next(error);
  }
};

/**
 * Toggle review visibility (admin)
 * PUT /api/v1/admin/reviews/:id/visibility
 */
export const toggleReviewVisibility = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { isVisible } = req.body;
    const review = await reviewService.toggleVisibility(req.params.id, isVisible);
    sendSuccess(res, review, isVisible ? 'تم إظهار المراجعة' : 'تم إخفاء المراجعة');
  } catch (error) {
    next(error);
  }
};

/**
 * Resolve reported review (admin)
 * PUT /api/v1/admin/reviews/:id/resolve
 */
export const resolveReport = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { action } = req.body;
    const review = await reviewService.resolveReport(req.params.id, action);

    const messages = {
      dismiss: 'تم رفض البلاغ',
      hide: 'تم إخفاء المراجعة',
      delete: 'تم حذف المراجعة',
    };

    sendSuccess(res, review, messages[action as keyof typeof messages]);
  } catch (error) {
    next(error);
  }
};

/**
 * Delete review (admin)
 * DELETE /api/v1/admin/reviews/:id
 */
export const deleteReview = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    await reviewService.deleteReview(req.params.id);
    sendSuccess(res, null, 'تم حذف المراجعة بنجاح');
  } catch (error) {
    next(error);
  }
};
