import mongoose, { Schema, Document, Types } from 'mongoose';
import dayjs from 'dayjs';
import { ILocation, OrderStatus, PaymentStatus, PaymentMethod } from '../types';

export interface IOrderItemAddon {
  addonId: Types.ObjectId;
  name: string;
  nameAr: string;
  price: number;
  quantity: number;
}

export interface IOrderItemVariation {
  variationId: Types.ObjectId;
  variationName: string;
  optionId: Types.ObjectId;
  optionName: string;
  optionNameAr: string;
  price: number;
}

export interface IOrderItem {
  _id: Types.ObjectId;
  menuItemId: Types.ObjectId;
  name: string;
  nameAr: string;
  image?: string;
  basePrice: number;
  quantity: number;
  selectedAddons: IOrderItemAddon[];
  selectedVariations: IOrderItemVariation[];
  specialInstructions?: string;
  itemTotal: number;
}

export interface IDeliveryAddress {
  name: string;
  address: string;
  area: string;
  building?: string;
  floor?: string;
  apartment?: string;
  landmark?: string;
  phone: string;
  location: ILocation;
}

export interface IStatusHistory {
  status: OrderStatus;
  timestamp: Date;
  note?: string;
  updatedBy?: Types.ObjectId;
}

export interface IOrderRating {
  restaurant?: number;
  driver?: number;
  food?: number;
  comment?: string;
  ratedAt?: Date;
}

export interface IOrder extends Document {
  _id: Types.ObjectId;
  orderNumber: string;

  // Parties
  customerId: Types.ObjectId;
  restaurantId: Types.ObjectId;
  driverId?: Types.ObjectId;

  // Items
  items: IOrderItem[];

  // Pricing
  subtotal: number;
  deliveryFee: number;
  serviceFee: number;
  discount: number;
  total: number;

  // Coupon
  couponId?: Types.ObjectId;
  couponCode?: string;
  couponDiscount: number;

  // Delivery Address
  deliveryAddress: IDeliveryAddress;

  // Notes
  customerNotes?: string;
  restaurantNotes?: string;

  // Status
  status: OrderStatus;
  statusHistory: IStatusHistory[];

  // Cancellation
  isCancelled: boolean;
  cancelReason?: string;
  cancelledBy?: 'customer' | 'restaurant' | 'driver' | 'admin';
  cancelledAt?: Date;

  // Payment
  paymentMethod: PaymentMethod;
  paymentStatus: PaymentStatus;
  paymentId?: string;
  transactionId?: Types.ObjectId;
  paidAt?: Date;

  // Timing
  estimatedDeliveryTime?: Date;
  restaurantAcceptedAt?: Date;
  preparationStartedAt?: Date;
  readyAt?: Date;
  driverAssignedAt?: Date;
  pickedUpAt?: Date;
  deliveredAt?: Date;

  // Rating
  rating?: IOrderRating;

  // Financials
  restaurantEarnings: number;
  driverEarnings: number;
  platformEarnings: number;

  // Flags
  isScheduled: boolean;
  scheduledFor?: Date;
  isReorder: boolean;
  originalOrderId?: Types.ObjectId;

  createdAt: Date;
  updatedAt: Date;
}

const orderItemAddonSchema = new Schema<IOrderItemAddon>(
  {
    addonId: { type: Schema.Types.ObjectId, required: true },
    name: { type: String, required: true },
    nameAr: { type: String, required: true },
    price: { type: Number, required: true },
    quantity: { type: Number, required: true, min: 1 },
  },
  { _id: false }
);

const orderItemVariationSchema = new Schema<IOrderItemVariation>(
  {
    variationId: { type: Schema.Types.ObjectId, required: true },
    variationName: { type: String, required: true },
    optionId: { type: Schema.Types.ObjectId, required: true },
    optionName: { type: String, required: true },
    optionNameAr: { type: String, required: true },
    price: { type: Number, required: true },
  },
  { _id: false }
);

const orderItemSchema = new Schema<IOrderItem>(
  {
    menuItemId: {
      type: Schema.Types.ObjectId,
      ref: 'MenuItem',
      required: true,
    },
    name: { type: String, required: true },
    nameAr: { type: String, required: true },
    image: { type: String },
    basePrice: { type: Number, required: true },
    quantity: { type: Number, required: true, min: 1 },
    selectedAddons: { type: [orderItemAddonSchema], default: [] },
    selectedVariations: { type: [orderItemVariationSchema], default: [] },
    specialInstructions: { type: String },
    itemTotal: { type: Number, required: true },
  },
  { _id: true }
);

const deliveryAddressSchema = new Schema<IDeliveryAddress>(
  {
    name: { type: String, required: true },
    address: { type: String, required: true },
    area: { type: String, required: true },
    building: { type: String },
    floor: { type: String },
    apartment: { type: String },
    landmark: { type: String },
    phone: { type: String, required: true },
    location: {
      type: { type: String, enum: ['Point'], default: 'Point' },
      coordinates: { type: [Number], required: true },
    },
  },
  { _id: false }
);

const statusHistorySchema = new Schema<IStatusHistory>(
  {
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'on_the_way', 'delivered', 'cancelled'],
      required: true,
    },
    timestamp: { type: Date, default: Date.now },
    note: { type: String },
    updatedBy: { type: Schema.Types.ObjectId, ref: 'User' },
  },
  { _id: false }
);

const orderRatingSchema = new Schema<IOrderRating>(
  {
    restaurant: { type: Number, min: 1, max: 5 },
    driver: { type: Number, min: 1, max: 5 },
    food: { type: Number, min: 1, max: 5 },
    comment: { type: String },
    ratedAt: { type: Date },
  },
  { _id: false }
);

const orderSchema = new Schema<IOrder>(
  {
    orderNumber: {
      type: String,
      unique: true,
    },

    // Parties
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

    // Items
    items: {
      type: [orderItemSchema],
      required: true,
      validate: {
        validator: function (items: IOrderItem[]) {
          return items.length > 0;
        },
        message: 'Order must have at least one item',
      },
    },

    // Pricing
    subtotal: {
      type: Number,
      required: true,
      min: 0,
    },
    deliveryFee: {
      type: Number,
      default: 0,
      min: 0,
    },
    serviceFee: {
      type: Number,
      default: 0,
      min: 0,
    },
    discount: {
      type: Number,
      default: 0,
      min: 0,
    },
    total: {
      type: Number,
      required: true,
      min: 0,
    },

    // Coupon
    couponId: {
      type: Schema.Types.ObjectId,
      ref: 'Coupon',
    },
    couponCode: {
      type: String,
    },
    couponDiscount: {
      type: Number,
      default: 0,
      min: 0,
    },

    // Delivery Address
    deliveryAddress: {
      type: deliveryAddressSchema,
      required: true,
    },

    // Notes
    customerNotes: {
      type: String,
    },
    restaurantNotes: {
      type: String,
    },

    // Status
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'on_the_way', 'delivered', 'cancelled'],
      default: 'pending',
    },
    statusHistory: {
      type: [statusHistorySchema],
      default: [],
    },

    // Cancellation
    isCancelled: {
      type: Boolean,
      default: false,
    },
    cancelReason: {
      type: String,
    },
    cancelledBy: {
      type: String,
      enum: ['customer', 'restaurant', 'driver', 'admin'],
    },
    cancelledAt: {
      type: Date,
    },

    // Payment
    paymentMethod: {
      type: String,
      enum: ['cash', 'card', 'wallet'],
      default: 'cash',
    },
    paymentStatus: {
      type: String,
      enum: ['pending', 'paid', 'failed', 'refunded'],
      default: 'pending',
    },
    paymentId: {
      type: String,
    },
    transactionId: {
      type: Schema.Types.ObjectId,
      ref: 'Transaction',
    },
    paidAt: {
      type: Date,
    },

    // Timing
    estimatedDeliveryTime: {
      type: Date,
    },
    restaurantAcceptedAt: {
      type: Date,
    },
    preparationStartedAt: {
      type: Date,
    },
    readyAt: {
      type: Date,
    },
    driverAssignedAt: {
      type: Date,
    },
    pickedUpAt: {
      type: Date,
    },
    deliveredAt: {
      type: Date,
    },

    // Rating
    rating: {
      type: orderRatingSchema,
    },

    // Financials
    restaurantEarnings: {
      type: Number,
      default: 0,
      min: 0,
    },
    driverEarnings: {
      type: Number,
      default: 0,
      min: 0,
    },
    platformEarnings: {
      type: Number,
      default: 0,
      min: 0,
    },

    // Flags
    isScheduled: {
      type: Boolean,
      default: false,
    },
    scheduledFor: {
      type: Date,
    },
    isReorder: {
      type: Boolean,
      default: false,
    },
    originalOrderId: {
      type: Schema.Types.ObjectId,
      ref: 'Order',
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes
orderSchema.index({ orderNumber: 1 }, { unique: true });
orderSchema.index({ customerId: 1 });
orderSchema.index({ restaurantId: 1 });
orderSchema.index({ driverId: 1 });
orderSchema.index({ status: 1 });
orderSchema.index({ createdAt: -1 });
orderSchema.index({ restaurantId: 1, status: 1 });
orderSchema.index({ driverId: 1, status: 1 });

// Pre-save hook to generate order number
orderSchema.pre('save', async function () {
  if (!this.orderNumber) {
    const date = dayjs().format('YYMMDD');
    const count = await mongoose.model('Order').countDocuments({
      createdAt: {
        $gte: dayjs().startOf('day').toDate(),
        $lte: dayjs().endOf('day').toDate(),
      },
    });
    this.orderNumber = `BAG-${date}-${(count + 1).toString().padStart(4, '0')}`;
  }

  // Add initial status to history
  if ((this as any).isNew && this.statusHistory.length === 0) {
    this.statusHistory.push({
      status: this.status,
      timestamp: new Date(),
    });
  }
});

// Virtual for customer details
orderSchema.virtual('customer', {
  ref: 'Customer',
  localField: 'customerId',
  foreignField: '_id',
  justOne: true,
});

// Virtual for restaurant details
orderSchema.virtual('restaurant', {
  ref: 'Restaurant',
  localField: 'restaurantId',
  foreignField: '_id',
  justOne: true,
});

// Virtual for driver details
orderSchema.virtual('driver', {
  ref: 'Driver',
  localField: 'driverId',
  foreignField: '_id',
  justOne: true,
});

export const Order = mongoose.model<IOrder>('Order', orderSchema);
export default Order;
