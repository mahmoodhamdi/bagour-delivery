import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IAddon {
  _id: Types.ObjectId;
  name: string;
  nameAr: string;
  price: number;
  isAvailable: boolean;
  maxQuantity: number;
}

export interface IVariationOption {
  _id: Types.ObjectId;
  name: string;
  nameAr: string;
  price: number;
}

export interface IVariation {
  _id: Types.ObjectId;
  name: string;
  nameAr: string;
  isRequired: boolean;
  options: IVariationOption[];
}

export interface IMenuItem extends Document {
  _id: Types.ObjectId;
  restaurantId: Types.ObjectId;
  categoryId: Types.ObjectId;

  // Basic Info
  name: string;
  nameAr: string;
  description?: string;
  descriptionAr?: string;
  image?: string;

  // Pricing
  price: number;
  discountPrice?: number;
  discountEndsAt?: Date;

  // Details
  preparationTime?: number;
  calories?: number;
  servingSize?: string;

  // Customization
  addons: IAddon[];
  variations: IVariation[];

  // Status & Flags
  isAvailable: boolean;
  isPopular: boolean;
  isNewItem: boolean;
  tags: string[];

  // Ordering
  sortOrder: number;

  // Stats
  totalOrders: number;

  createdAt: Date;
  updatedAt: Date;

  // Virtuals
  currentPrice: number;
  hasDiscount: boolean;
}

const addonSchema = new Schema<IAddon>(
  {
    name: {
      type: String,
      required: [true, 'Addon name is required'],
      trim: true,
    },
    nameAr: {
      type: String,
      required: [true, 'Arabic addon name is required'],
      trim: true,
    },
    price: {
      type: Number,
      required: [true, 'Addon price is required'],
      min: [0, 'Price cannot be negative'],
    },
    isAvailable: {
      type: Boolean,
      default: true,
    },
    maxQuantity: {
      type: Number,
      default: 5,
      min: [1, 'Max quantity must be at least 1'],
    },
  },
  { _id: true }
);

const variationOptionSchema = new Schema<IVariationOption>(
  {
    name: {
      type: String,
      required: [true, 'Option name is required'],
      trim: true,
    },
    nameAr: {
      type: String,
      required: [true, 'Arabic option name is required'],
      trim: true,
    },
    price: {
      type: Number,
      default: 0,
      min: [0, 'Price cannot be negative'],
    },
  },
  { _id: true }
);

const variationSchema = new Schema<IVariation>(
  {
    name: {
      type: String,
      required: [true, 'Variation name is required'],
      trim: true,
    },
    nameAr: {
      type: String,
      required: [true, 'Arabic variation name is required'],
      trim: true,
    },
    isRequired: {
      type: Boolean,
      default: false,
    },
    options: {
      type: [variationOptionSchema],
      validate: {
        validator: function (options: IVariationOption[]) {
          return options.length >= 2;
        },
        message: 'A variation must have at least 2 options',
      },
    },
  },
  { _id: true }
);

const menuItemSchema = new Schema<IMenuItem>(
  {
    restaurantId: {
      type: Schema.Types.ObjectId,
      ref: 'Restaurant',
      required: [true, 'Restaurant ID is required'],
      index: true,
    },
    categoryId: {
      type: Schema.Types.ObjectId,
      ref: 'MenuCategory',
      required: [true, 'Category ID is required'],
      index: true,
    },

    // Basic Info
    name: {
      type: String,
      required: [true, 'Item name is required'],
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
    image: {
      type: String,
    },

    // Pricing
    price: {
      type: Number,
      required: [true, 'Price is required'],
      min: [0, 'Price cannot be negative'],
    },
    discountPrice: {
      type: Number,
      min: [0, 'Discount price cannot be negative'],
      validate: {
        validator: function (this: IMenuItem, value: number) {
          return !value || value < this.price;
        },
        message: 'Discount price must be less than regular price',
      },
    },
    discountEndsAt: {
      type: Date,
    },

    // Details
    preparationTime: {
      type: Number,
      min: [0, 'Preparation time cannot be negative'],
    },
    calories: {
      type: Number,
      min: [0, 'Calories cannot be negative'],
    },
    servingSize: {
      type: String,
      trim: true,
    },

    // Customization
    addons: {
      type: [addonSchema],
      default: [],
    },
    variations: {
      type: [variationSchema],
      default: [],
    },

    // Status & Flags
    isAvailable: {
      type: Boolean,
      default: true,
    },
    isPopular: {
      type: Boolean,
      default: false,
    },
    isNewItem: {
      type: Boolean,
      default: true,
    },
    tags: {
      type: [String],
      default: [],
    },

    // Ordering
    sortOrder: {
      type: Number,
      default: 0,
    },

    // Stats
    totalOrders: {
      type: Number,
      default: 0,
      min: 0,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes
menuItemSchema.index({ restaurantId: 1, categoryId: 1 });
menuItemSchema.index({ restaurantId: 1, isAvailable: 1 });
menuItemSchema.index({ restaurantId: 1, isPopular: -1 });
menuItemSchema.index({ name: 'text', nameAr: 'text', description: 'text', descriptionAr: 'text' });

// Virtual: Get current price (considering discount)
menuItemSchema.virtual('currentPrice').get(function () {
  if (this.discountPrice && this.discountEndsAt && new Date() < this.discountEndsAt) {
    return this.discountPrice;
  }
  return this.price;
});

// Virtual: Check if has active discount
menuItemSchema.virtual('hasDiscount').get(function () {
  return !!(this.discountPrice && this.discountEndsAt && new Date() < this.discountEndsAt);
});

// Auto-remove isNew flag after 7 days
menuItemSchema.virtual('isNewComputed').get(function () {
  if (!this.createdAt) return false;
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
  return this.createdAt > sevenDaysAgo;
});

export const MenuItem = mongoose.model<IMenuItem>('MenuItem', menuItemSchema);
export default MenuItem;
