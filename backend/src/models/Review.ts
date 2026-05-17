import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IReview extends Document {
  _id: Types.ObjectId;
  orderId: Types.ObjectId;
  customerId: Types.ObjectId;
  restaurantId: Types.ObjectId;
  driverId?: Types.ObjectId;

  // Ratings
  restaurantRating: number;
  foodRating: number;
  driverRating?: number;

  // Review
  comment?: string;
  images: string[];

  // Restaurant Response
  restaurantReply?: string;
  repliedAt?: Date;

  // Moderation
  isVisible: boolean;
  isReported: boolean;
  reportReason?: string;

  createdAt: Date;
  updatedAt: Date;
}

const reviewSchema = new Schema<IReview>(
  {
    orderId: {
      type: Schema.Types.ObjectId,
      ref: 'Order',
      required: true,
      unique: true,
    },
    customerId: {
      type: Schema.Types.ObjectId,
      ref: 'Customer',
      required: true,
    },
    restaurantId: {
      type: Schema.Types.ObjectId,
      ref: 'Restaurant',
      required: true,
    },
    driverId: {
      type: Schema.Types.ObjectId,
      ref: 'Driver',
    },

    // Ratings
    restaurantRating: {
      type: Number,
      required: [true, 'Restaurant rating is required'],
      min: [1, 'Rating must be at least 1'],
      max: [5, 'Rating cannot exceed 5'],
    },
    foodRating: {
      type: Number,
      required: [true, 'Food rating is required'],
      min: [1, 'Rating must be at least 1'],
      max: [5, 'Rating cannot exceed 5'],
    },
    driverRating: {
      type: Number,
      min: [1, 'Rating must be at least 1'],
      max: [5, 'Rating cannot exceed 5'],
    },

    // Review
    comment: {
      type: String,
      maxlength: [500, 'Comment cannot exceed 500 characters'],
    },
    images: {
      type: [String],
      default: [],
      validate: {
        validator: function (images: string[]) {
          return images.length <= 5;
        },
        message: 'Maximum 5 images allowed',
      },
    },

    // Restaurant Response
    restaurantReply: {
      type: String,
      maxlength: [300, 'Reply cannot exceed 300 characters'],
    },
    repliedAt: {
      type: Date,
    },

    // Moderation
    isVisible: {
      type: Boolean,
      default: true,
    },
    isReported: {
      type: Boolean,
      default: false,
    },
    reportReason: {
      type: String,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes — `orderId` declares `unique: true` at the field level.
reviewSchema.index({ restaurantId: 1 });
reviewSchema.index({ customerId: 1 });
reviewSchema.index({ createdAt: -1 });
reviewSchema.index({ restaurantId: 1, isVisible: 1 });

// Virtual for customer details
reviewSchema.virtual('customer', {
  ref: 'Customer',
  localField: 'customerId',
  foreignField: '_id',
  justOne: true,
});

// Virtual for restaurant details
reviewSchema.virtual('restaurant', {
  ref: 'Restaurant',
  localField: 'restaurantId',
  foreignField: '_id',
  justOne: true,
});

// Virtual for average rating
reviewSchema.virtual('averageRating').get(function () {
  const ratings = [this.restaurantRating, this.foodRating];
  if (this.driverRating) ratings.push(this.driverRating);
  return ratings.reduce((a, b) => a + b, 0) / ratings.length;
});

// Post-save hook to update restaurant rating
reviewSchema.post('save', async function () {
  const Review = mongoose.model('Review');
  const Restaurant = mongoose.model('Restaurant');

  const stats = await Review.aggregate([
    { $match: { restaurantId: this.restaurantId, isVisible: true } },
    {
      $group: {
        _id: '$restaurantId',
        avgRating: { $avg: '$restaurantRating' },
        count: { $sum: 1 },
      },
    },
  ]);

  if (stats.length > 0) {
    await Restaurant.findByIdAndUpdate(this.restaurantId, {
      rating: Math.round(stats[0].avgRating * 10) / 10,
      totalRatings: stats[0].count,
    });
  }
});

export const Review = mongoose.model<IReview>('Review', reviewSchema);
export default Review;
