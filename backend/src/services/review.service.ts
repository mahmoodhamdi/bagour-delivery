import { Types } from 'mongoose';
import { Review, IReview } from '../models/Review';
import { Restaurant } from '../models/Restaurant';
import { Driver } from '../models/Driver';
import { NotFoundError, BadRequestError, ForbiddenError } from '../utils/errors';
import { IPaginatedResult } from '../types';

interface GetReviewsOptions {
  restaurantId?: string;
  customerId?: string;
  driverId?: string;
  minRating?: number;
  maxRating?: number;
  hasComment?: boolean;
  isVisible?: boolean;
  isReported?: boolean;
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

interface ReviewStats {
  averageRating: number;
  totalReviews: number;
  ratingDistribution: {
    1: number;
    2: number;
    3: number;
    4: number;
    5: number;
  };
  averageFoodRating: number;
  averageDriverRating: number;
}

class ReviewService {
  /**
   * Get reviews for a restaurant (public)
   */
  async getRestaurantReviews(
    restaurantId: string,
    options: GetReviewsOptions = {}
  ): Promise<IPaginatedResult<IReview>> {
    const {
      minRating,
      maxRating,
      hasComment,
      page = 1,
      limit = 10,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = options;

    const query: Record<string, unknown> = {
      restaurantId: new Types.ObjectId(restaurantId),
      isVisible: true,
    };

    if (minRating !== undefined) {
      query.restaurantRating = { $gte: minRating };
    }
    if (maxRating !== undefined) {
      query.restaurantRating = { ...query.restaurantRating as object, $lte: maxRating };
    }
    if (hasComment !== undefined) {
      query.comment = hasComment ? { $exists: true, $ne: '' } : { $in: [null, ''] };
    }

    const skip = (page - 1) * limit;
    const sortOptions: Record<string, 1 | -1> = { [sortBy]: sortOrder === 'asc' ? 1 : -1 };

    const [reviews, total] = await Promise.all([
      Review.find(query)
        .populate('customerId', 'userId')
        .populate({
          path: 'customerId',
          populate: { path: 'userId', select: 'name avatar' },
        })
        .sort(sortOptions)
        .skip(skip)
        .limit(limit)
        .lean(),
      Review.countDocuments(query),
    ]);

    const pages = Math.ceil(total / limit);
    return {
      data: reviews as IReview[],
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
   * Get customer's reviews
   */
  async getCustomerReviews(
    customerId: string,
    options: GetReviewsOptions = {}
  ): Promise<IPaginatedResult<IReview>> {
    const { page = 1, limit = 10, sortBy = 'createdAt', sortOrder = 'desc' } = options;

    const query = { customerId: new Types.ObjectId(customerId) };
    const skip = (page - 1) * limit;
    const sortOptions: Record<string, 1 | -1> = { [sortBy]: sortOrder === 'asc' ? 1 : -1 };

    const [reviews, total] = await Promise.all([
      Review.find(query)
        .populate('restaurantId', 'name nameAr logo')
        .sort(sortOptions)
        .skip(skip)
        .limit(limit)
        .lean(),
      Review.countDocuments(query),
    ]);

    const pages = Math.ceil(total / limit);
    return {
      data: reviews as IReview[],
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
   * Get review by ID
   */
  async getReviewById(reviewId: string): Promise<IReview> {
    const review = await Review.findById(reviewId)
      .populate('customerId', 'userId')
      .populate({
        path: 'customerId',
        populate: { path: 'userId', select: 'name avatar' },
      })
      .populate('restaurantId', 'name nameAr logo')
      .lean();

    if (!review) {
      throw new NotFoundError('المراجعة غير موجودة');
    }

    return review as IReview;
  }

  /**
   * Restaurant reply to a review
   */
  async replyToReview(
    reviewId: string,
    restaurantId: string,
    reply: string
  ): Promise<IReview> {
    const review = await Review.findById(reviewId);

    if (!review) {
      throw new NotFoundError('المراجعة غير موجودة');
    }

    if (review.restaurantId.toString() !== restaurantId) {
      throw new ForbiddenError('غير مصرح لك بالرد على هذه المراجعة');
    }

    if (review.restaurantReply) {
      throw new BadRequestError('تم الرد على هذه المراجعة مسبقاً');
    }

    review.restaurantReply = reply;
    review.repliedAt = new Date();
    await review.save();

    return review;
  }

  /**
   * Update restaurant reply
   */
  async updateReply(
    reviewId: string,
    restaurantId: string,
    reply: string
  ): Promise<IReview> {
    const review = await Review.findById(reviewId);

    if (!review) {
      throw new NotFoundError('المراجعة غير موجودة');
    }

    if (review.restaurantId.toString() !== restaurantId) {
      throw new ForbiddenError('غير مصرح لك بتعديل هذا الرد');
    }

    if (!review.restaurantReply) {
      throw new BadRequestError('لم يتم الرد على هذه المراجعة بعد');
    }

    review.restaurantReply = reply;
    await review.save();

    return review;
  }

  /**
   * Delete restaurant reply
   */
  async deleteReply(reviewId: string, restaurantId: string): Promise<IReview> {
    const review = await Review.findById(reviewId);

    if (!review) {
      throw new NotFoundError('المراجعة غير موجودة');
    }

    if (review.restaurantId.toString() !== restaurantId) {
      throw new ForbiddenError('غير مصرح لك بحذف هذا الرد');
    }

    review.restaurantReply = undefined;
    review.repliedAt = undefined;
    await review.save();

    return review;
  }

  /**
   * Report a review
   */
  async reportReview(
    reviewId: string,
    reason: string,
    reporterId: string
  ): Promise<IReview> {
    const review = await Review.findById(reviewId);

    if (!review) {
      throw new NotFoundError('المراجعة غير موجودة');
    }

    if (review.isReported) {
      throw new BadRequestError('تم الإبلاغ عن هذه المراجعة مسبقاً');
    }

    review.isReported = true;
    review.reportReason = reason;
    await review.save();

    return review;
  }

  /**
   * Get restaurant review statistics
   */
  async getRestaurantStats(restaurantId: string): Promise<ReviewStats> {
    const stats = await Review.aggregate([
      { $match: { restaurantId: new Types.ObjectId(restaurantId), isVisible: true } },
      {
        $group: {
          _id: null,
          averageRating: { $avg: '$restaurantRating' },
          averageFoodRating: { $avg: '$foodRating' },
          averageDriverRating: { $avg: '$driverRating' },
          totalReviews: { $sum: 1 },
          rating1: { $sum: { $cond: [{ $eq: ['$restaurantRating', 1] }, 1, 0] } },
          rating2: { $sum: { $cond: [{ $eq: ['$restaurantRating', 2] }, 1, 0] } },
          rating3: { $sum: { $cond: [{ $eq: ['$restaurantRating', 3] }, 1, 0] } },
          rating4: { $sum: { $cond: [{ $eq: ['$restaurantRating', 4] }, 1, 0] } },
          rating5: { $sum: { $cond: [{ $eq: ['$restaurantRating', 5] }, 1, 0] } },
        },
      },
    ]);

    if (stats.length === 0) {
      return {
        averageRating: 0,
        totalReviews: 0,
        ratingDistribution: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 },
        averageFoodRating: 0,
        averageDriverRating: 0,
      };
    }

    return {
      averageRating: Math.round(stats[0].averageRating * 10) / 10,
      totalReviews: stats[0].totalReviews,
      ratingDistribution: {
        1: stats[0].rating1,
        2: stats[0].rating2,
        3: stats[0].rating3,
        4: stats[0].rating4,
        5: stats[0].rating5,
      },
      averageFoodRating: Math.round(stats[0].averageFoodRating * 10) / 10,
      averageDriverRating: stats[0].averageDriverRating
        ? Math.round(stats[0].averageDriverRating * 10) / 10
        : 0,
    };
  }

  // ==================== Admin Functions ====================

  /**
   * Get all reviews (admin)
   */
  async getAllReviews(options: GetReviewsOptions = {}): Promise<IPaginatedResult<IReview>> {
    const {
      restaurantId,
      customerId,
      isVisible,
      isReported,
      minRating,
      maxRating,
      page = 1,
      limit = 20,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = options;

    const query: Record<string, unknown> = {};

    if (restaurantId) query.restaurantId = new Types.ObjectId(restaurantId);
    if (customerId) query.customerId = new Types.ObjectId(customerId);
    if (isVisible !== undefined) query.isVisible = isVisible;
    if (isReported !== undefined) query.isReported = isReported;
    if (minRating !== undefined) query.restaurantRating = { $gte: minRating };
    if (maxRating !== undefined) {
      query.restaurantRating = { ...query.restaurantRating as object, $lte: maxRating };
    }

    const skip = (page - 1) * limit;
    const sortOptions: Record<string, 1 | -1> = { [sortBy]: sortOrder === 'asc' ? 1 : -1 };

    const [reviews, total] = await Promise.all([
      Review.find(query)
        .populate('customerId', 'userId')
        .populate({
          path: 'customerId',
          populate: { path: 'userId', select: 'name email phone' },
        })
        .populate('restaurantId', 'name nameAr')
        .sort(sortOptions)
        .skip(skip)
        .limit(limit)
        .lean(),
      Review.countDocuments(query),
    ]);

    const pages = Math.ceil(total / limit);
    return {
      data: reviews as IReview[],
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
   * Hide/show review (admin moderation)
   */
  async toggleVisibility(reviewId: string, isVisible: boolean): Promise<IReview> {
    const review = await Review.findByIdAndUpdate(
      reviewId,
      { isVisible },
      { new: true }
    );

    if (!review) {
      throw new NotFoundError('المراجعة غير موجودة');
    }

    // Update restaurant rating after visibility change
    await this.updateRestaurantRating(review.restaurantId.toString());

    return review;
  }

  /**
   * Resolve report (admin)
   */
  async resolveReport(
    reviewId: string,
    action: 'dismiss' | 'hide' | 'delete'
  ): Promise<IReview | null> {
    const review = await Review.findById(reviewId);

    if (!review) {
      throw new NotFoundError('المراجعة غير موجودة');
    }

    if (action === 'delete') {
      await review.deleteOne();
      await this.updateRestaurantRating(review.restaurantId.toString());
      return null;
    }

    review.isReported = false;
    review.reportReason = undefined;

    if (action === 'hide') {
      review.isVisible = false;
    }

    await review.save();

    if (action === 'hide') {
      await this.updateRestaurantRating(review.restaurantId.toString());
    }

    return review;
  }

  /**
   * Delete review (admin)
   */
  async deleteReview(reviewId: string): Promise<void> {
    const review = await Review.findById(reviewId);

    if (!review) {
      throw new NotFoundError('المراجعة غير موجودة');
    }

    const restaurantId = review.restaurantId.toString();
    await review.deleteOne();
    await this.updateRestaurantRating(restaurantId);
  }

  /**
   * Update restaurant rating after review changes
   */
  private async updateRestaurantRating(restaurantId: string): Promise<void> {
    const stats = await Review.aggregate([
      { $match: { restaurantId: new Types.ObjectId(restaurantId), isVisible: true } },
      {
        $group: {
          _id: '$restaurantId',
          avgRating: { $avg: '$restaurantRating' },
          count: { $sum: 1 },
        },
      },
    ]);

    if (stats.length > 0) {
      await Restaurant.findByIdAndUpdate(restaurantId, {
        rating: Math.round(stats[0].avgRating * 10) / 10,
        totalRatings: stats[0].count,
      });
    } else {
      await Restaurant.findByIdAndUpdate(restaurantId, {
        rating: 0,
        totalRatings: 0,
      });
    }
  }

  /**
   * Update driver rating after review
   */
  async updateDriverRating(driverId: string): Promise<void> {
    const stats = await Review.aggregate([
      {
        $match: {
          driverId: new Types.ObjectId(driverId),
          driverRating: { $exists: true },
          isVisible: true,
        },
      },
      {
        $group: {
          _id: '$driverId',
          avgRating: { $avg: '$driverRating' },
          count: { $sum: 1 },
        },
      },
    ]);

    if (stats.length > 0) {
      await Driver.findByIdAndUpdate(driverId, {
        rating: Math.round(stats[0].avgRating * 10) / 10,
        totalRatings: stats[0].count,
      });
    }
  }
}

export const reviewService = new ReviewService();
export default reviewService;
