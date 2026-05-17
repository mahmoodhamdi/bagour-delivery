import mongoose, { Schema, Document, Types } from 'mongoose';
import { CouponType } from '../types';

export interface ICouponUsage {
  customerId: Types.ObjectId;
  orderId: Types.ObjectId;
  usedAt: Date;
  discountAmount: number;
}

export interface ICoupon extends Document {
  _id: Types.ObjectId;
  code: string;

  // Type & Value
  type: CouponType;
  value: number;

  // Limits
  minimumOrder: number;
  maximumDiscount?: number;

  // Usage Limits
  totalUsageLimit?: number;
  perUserLimit: number;
  usedCount: number;

  // Validity
  validFrom: Date;
  validUntil: Date;

  // Restrictions
  restaurantIds: Types.ObjectId[];
  categoryIds: string[];
  customerIds: Types.ObjectId[];

  // For new users only
  firstOrderOnly: boolean;

  // Status
  isActive: boolean;

  // Tracking
  usedBy: ICouponUsage[];

  createdAt: Date;
  createdBy: Types.ObjectId;
  updatedAt: Date;

  // Virtuals
  isValid: boolean;
  remainingUses: number;
}

const couponUsageSchema = new Schema<ICouponUsage>(
  {
    customerId: {
      type: Schema.Types.ObjectId,
      ref: 'Customer',
      required: true,
    },
    orderId: {
      type: Schema.Types.ObjectId,
      ref: 'Order',
      required: true,
    },
    usedAt: {
      type: Date,
      default: Date.now,
    },
    discountAmount: {
      type: Number,
      required: true,
    },
  },
  { _id: false }
);

const couponSchema = new Schema<ICoupon>(
  {
    code: {
      type: String,
      required: [true, 'Coupon code is required'],
      unique: true,
      uppercase: true,
      trim: true,
      match: [/^[A-Z0-9]{4,20}$/, 'Code must be 4-20 alphanumeric characters'],
    },

    // Type & Value
    type: {
      type: String,
      enum: ['percentage', 'fixed'],
      required: [true, 'Coupon type is required'],
    },
    value: {
      type: Number,
      required: [true, 'Coupon value is required'],
      min: [0, 'Value cannot be negative'],
    },

    // Limits
    minimumOrder: {
      type: Number,
      default: 0,
      min: [0, 'Minimum order cannot be negative'],
    },
    maximumDiscount: {
      type: Number,
      min: [0, 'Maximum discount cannot be negative'],
    },

    // Usage Limits
    totalUsageLimit: {
      type: Number,
      min: [1, 'Total usage limit must be at least 1'],
    },
    perUserLimit: {
      type: Number,
      default: 1,
      min: [1, 'Per user limit must be at least 1'],
    },
    usedCount: {
      type: Number,
      default: 0,
      min: 0,
    },

    // Validity
    validFrom: {
      type: Date,
      required: [true, 'Valid from date is required'],
    },
    validUntil: {
      type: Date,
      required: [true, 'Valid until date is required'],
    },

    // Restrictions
    restaurantIds: {
      type: [{ type: Schema.Types.ObjectId, ref: 'Restaurant' }],
      default: [],
    },
    categoryIds: {
      type: [String],
      default: [],
    },
    customerIds: {
      type: [{ type: Schema.Types.ObjectId, ref: 'Customer' }],
      default: [],
    },

    // For new users only
    firstOrderOnly: {
      type: Boolean,
      default: false,
    },

    // Status
    isActive: {
      type: Boolean,
      default: true,
    },

    // Tracking
    usedBy: {
      type: [couponUsageSchema],
      default: [],
    },

    createdBy: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes — `code` declares `unique: true` at the field level.
couponSchema.index({ validFrom: 1, validUntil: 1 });
couponSchema.index({ isActive: 1 });

// Pre-save validation
couponSchema.pre('save', async function () {
  // Validate percentage value
  if (this.type === 'percentage' && this.value > 100) {
    throw new Error('Percentage value cannot exceed 100');
  }

  // Validate validUntil
  if (this.validUntil <= this.validFrom) {
    throw new Error('Valid until must be after valid from');
  }
});

// Virtual: Check if coupon is valid
couponSchema.virtual('isValid').get(function (this: ICoupon) {
  const now = new Date();
  return (
    this.isActive &&
    now >= this.validFrom &&
    now <= this.validUntil &&
    (!this.totalUsageLimit || this.usedCount < this.totalUsageLimit)
  );
});

// Virtual: Remaining uses
couponSchema.virtual('remainingUses').get(function (this: ICoupon) {
  if (!this.totalUsageLimit) return Infinity;
  return Math.max(0, this.totalUsageLimit - this.usedCount);
});

export const Coupon = mongoose.model<ICoupon>('Coupon', couponSchema);
export default Coupon;
