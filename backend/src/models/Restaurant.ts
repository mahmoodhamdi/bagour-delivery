import mongoose, { Schema, Document, Types } from 'mongoose';
import slugify from 'slugify';
import { ILocation, IWorkingHours, SubscriptionPlan } from '../types';

export interface IRestaurant extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId;

  // Basic Info
  name: string;
  nameAr: string;
  description?: string;
  descriptionAr?: string;
  slug: string;

  // Images
  logo: string;
  coverImage?: string;
  images: string[];

  // Classification
  categories: string[];
  tags: string[];
  priceRange: 1 | 2 | 3;

  // Location
  address: string;
  area: string;
  location: ILocation;

  // Contact
  phone: string;
  whatsapp?: string;

  // Working Hours
  workingHours: IWorkingHours[];

  // Delivery Settings
  minimumOrder: number;
  deliveryFee: number;
  freeDeliveryAbove?: number;
  estimatedDeliveryTime: {
    min: number;
    max: number;
  };
  deliveryZones: Types.ObjectId[];

  // Business Settings
  acceptsOnlinePayment: boolean;
  acceptsCash: boolean;
  autoAcceptOrders: boolean;

  // Stats
  rating: number;
  totalRatings: number;
  totalOrders: number;
  totalRevenue: number;

  // Admin Settings
  commission: number;
  isApproved: boolean;
  approvedAt?: Date;
  approvedBy?: Types.ObjectId;
  rejectionReason?: string;

  // Status
  isActive: boolean;
  isPaused: boolean;
  pauseReason?: string;

  // Subscription
  subscription: {
    plan: SubscriptionPlan;
    startedAt?: Date;
    expiresAt?: Date;
    features: string[];
  };

  createdAt: Date;
  updatedAt: Date;

  // Virtuals
  isOpen: boolean;
}

const workingHoursSchema = new Schema<IWorkingHours>(
  {
    day: {
      type: Number,
      required: true,
      min: 0,
      max: 6,
    },
    isOpen: {
      type: Boolean,
      default: true,
    },
    shifts: [
      {
        open: {
          type: String,
          required: true,
          match: [/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Invalid time format'],
        },
        close: {
          type: String,
          required: true,
          match: [/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Invalid time format'],
        },
      },
    ],
  },
  { _id: false }
);

const restaurantSchema = new Schema<IRestaurant>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },

    // Basic Info
    name: {
      type: String,
      required: [true, 'Restaurant name is required'],
      trim: true,
      maxlength: [100, 'Name cannot exceed 100 characters'],
    },
    nameAr: {
      type: String,
      required: [true, 'Arabic name is required'],
      trim: true,
      maxlength: [100, 'Arabic name cannot exceed 100 characters'],
    },
    description: {
      type: String,
      trim: true,
      maxlength: [500, 'Description cannot exceed 500 characters'],
    },
    descriptionAr: {
      type: String,
      trim: true,
      maxlength: [500, 'Arabic description cannot exceed 500 characters'],
    },
    slug: {
      type: String,
      unique: true,
      lowercase: true,
    },

    // Images
    logo: {
      type: String,
      required: [true, 'Restaurant logo is required'],
    },
    coverImage: {
      type: String,
    },
    images: {
      type: [String],
      default: [],
      validate: {
        validator: function (images: string[]) {
          return images.length <= 10;
        },
        message: 'Maximum 10 images allowed',
      },
    },

    // Classification
    categories: {
      type: [String],
      default: [],
    },
    tags: {
      type: [String],
      default: [],
    },
    priceRange: {
      type: Number,
      enum: [1, 2, 3],
      default: 2,
    },

    // Location
    address: {
      type: String,
      required: [true, 'Address is required'],
      trim: true,
    },
    area: {
      type: String,
      required: [true, 'Area is required'],
      trim: true,
    },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number],
        required: true,
      },
    },

    // Contact
    phone: {
      type: String,
      required: [true, 'Phone number is required'],
      match: [/^01[0125][0-9]{8}$/, 'Invalid Egyptian phone number'],
    },
    whatsapp: {
      type: String,
      match: [/^01[0125][0-9]{8}$/, 'Invalid WhatsApp number'],
    },

    // Working Hours
    workingHours: {
      type: [workingHoursSchema],
      default: () => [
        { day: 0, isOpen: true, shifts: [{ open: '09:00', close: '23:00' }] },
        { day: 1, isOpen: true, shifts: [{ open: '09:00', close: '23:00' }] },
        { day: 2, isOpen: true, shifts: [{ open: '09:00', close: '23:00' }] },
        { day: 3, isOpen: true, shifts: [{ open: '09:00', close: '23:00' }] },
        { day: 4, isOpen: true, shifts: [{ open: '09:00', close: '23:00' }] },
        { day: 5, isOpen: true, shifts: [{ open: '09:00', close: '23:00' }] },
        { day: 6, isOpen: true, shifts: [{ open: '09:00', close: '23:00' }] },
      ],
    },

    // Delivery Settings
    minimumOrder: {
      type: Number,
      default: 30,
      min: [0, 'Minimum order cannot be negative'],
    },
    deliveryFee: {
      type: Number,
      default: 10,
      min: [0, 'Delivery fee cannot be negative'],
    },
    freeDeliveryAbove: {
      type: Number,
      min: [0, 'Free delivery threshold cannot be negative'],
    },
    estimatedDeliveryTime: {
      min: {
        type: Number,
        default: 30,
      },
      max: {
        type: Number,
        default: 60,
      },
    },
    deliveryZones: {
      type: [{ type: Schema.Types.ObjectId, ref: 'Zone' }],
      default: [],
    },

    // Business Settings
    acceptsOnlinePayment: {
      type: Boolean,
      default: false,
    },
    acceptsCash: {
      type: Boolean,
      default: true,
    },
    autoAcceptOrders: {
      type: Boolean,
      default: false,
    },

    // Stats
    rating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    totalRatings: {
      type: Number,
      default: 0,
      min: 0,
    },
    totalOrders: {
      type: Number,
      default: 0,
      min: 0,
    },
    totalRevenue: {
      type: Number,
      default: 0,
      min: 0,
    },

    // Admin Settings
    commission: {
      type: Number,
      default: 15,
      min: [0, 'Commission cannot be negative'],
      max: [100, 'Commission cannot exceed 100%'],
    },
    isApproved: {
      type: Boolean,
      default: false,
    },
    approvedAt: {
      type: Date,
    },
    approvedBy: {
      type: Schema.Types.ObjectId,
      ref: 'User',
    },
    rejectionReason: {
      type: String,
    },

    // Status
    isActive: {
      type: Boolean,
      default: true,
    },
    isPaused: {
      type: Boolean,
      default: false,
    },
    pauseReason: {
      type: String,
    },

    // Subscription
    subscription: {
      plan: {
        type: String,
        enum: ['free', 'silver', 'gold', 'platinum'],
        default: 'free',
      },
      startedAt: {
        type: Date,
      },
      expiresAt: {
        type: Date,
      },
      features: {
        type: [String],
        default: [],
      },
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes — `userId` and `slug` declare `unique: true` at the field level
// so Mongoose creates those indexes automatically; the rest are query
// accelerators.
restaurantSchema.index({ location: '2dsphere' });
restaurantSchema.index({ categories: 1 });
restaurantSchema.index({ isApproved: 1, isActive: 1 });
restaurantSchema.index({ rating: -1 });
restaurantSchema.index({ name: 'text', nameAr: 'text', description: 'text', descriptionAr: 'text' });

// Pre-save hook to generate slug
restaurantSchema.pre('save', async function () {
  if (this.isModified('name') || !this.slug) {
    const baseSlug = slugify(this.name, { lower: true, strict: true });
    this.slug = `${baseSlug}-${this._id.toString().substring(0, 6)}`;
  }
});

// Virtual: Check if restaurant is currently open
restaurantSchema.virtual('isOpen').get(function () {
  if (this.isPaused || !this.isActive || !this.isApproved) {
    return false;
  }

  const now = new Date();
  const currentDay = now.getDay();
  const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;

  const todayHours = this.workingHours.find((wh) => wh.day === currentDay);

  if (!todayHours || !todayHours.isOpen) {
    return false;
  }

  return todayHours.shifts.some((shift) => {
    return currentTime >= shift.open && currentTime <= shift.close;
  });
});

// Virtual for user details
restaurantSchema.virtual('user', {
  ref: 'User',
  localField: 'userId',
  foreignField: '_id',
  justOne: true,
});

// Virtual for menu categories
restaurantSchema.virtual('menuCategories', {
  ref: 'MenuCategory',
  localField: '_id',
  foreignField: 'restaurantId',
});

export const Restaurant = mongoose.model<IRestaurant>('Restaurant', restaurantSchema);
export default Restaurant;
