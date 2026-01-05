import mongoose, { Schema, Document, Types } from 'mongoose';
import { ILocation, AddressLabel } from '../types';
import { v4 as uuidv4 } from 'uuid';

export interface IAddress {
  _id: Types.ObjectId;
  label: AddressLabel;
  name: string;
  address: string;
  area: string;
  city: string;
  building?: string;
  floor?: string;
  apartment?: string;
  landmark?: string;
  location: ILocation;
  isDefault: boolean;
}

export interface ICustomer extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId;
  addresses: IAddress[];
  favorites: Types.ObjectId[];
  loyaltyPoints: number;
  totalOrders: number;
  totalSpent: number;
  walletBalance: number;
  totalWalletTopups: number;
  totalWalletSpent: number;
  referralCode: string;
  referredBy?: Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const addressSchema = new Schema<IAddress>(
  {
    label: {
      type: String,
      enum: ['home', 'work', 'other'],
      default: 'home',
    },
    name: {
      type: String,
      required: [true, 'Address name is required'],
      trim: true,
    },
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
    city: {
      type: String,
      default: 'الباجور',
      trim: true,
    },
    building: {
      type: String,
      trim: true,
    },
    floor: {
      type: String,
      trim: true,
    },
    apartment: {
      type: String,
      trim: true,
    },
    landmark: {
      type: String,
      trim: true,
    },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        required: true,
        default: 'Point',
      },
      coordinates: {
        type: [Number],
        required: true,
        validate: {
          validator: function (coords: number[]) {
            return coords.length === 2;
          },
          message: 'Coordinates must have exactly 2 values [longitude, latitude]',
        },
      },
    },
    isDefault: {
      type: Boolean,
      default: false,
    },
  },
  { _id: true }
);

const customerSchema = new Schema<ICustomer>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    addresses: {
      type: [addressSchema],
      default: [],
    },
    favorites: {
      type: [{ type: Schema.Types.ObjectId, ref: 'Restaurant' }],
      default: [],
    },
    loyaltyPoints: {
      type: Number,
      default: 0,
      min: 0,
    },
    totalOrders: {
      type: Number,
      default: 0,
      min: 0,
    },
    totalSpent: {
      type: Number,
      default: 0,
      min: 0,
    },
    walletBalance: {
      type: Number,
      default: 0,
      min: 0,
    },
    totalWalletTopups: {
      type: Number,
      default: 0,
      min: 0,
    },
    totalWalletSpent: {
      type: Number,
      default: 0,
      min: 0,
    },
    referralCode: {
      type: String,
      unique: true,
    },
    referredBy: {
      type: Schema.Types.ObjectId,
      ref: 'Customer',
      default: null,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes
customerSchema.index({ userId: 1 }, { unique: true });
customerSchema.index({ referralCode: 1 }, { unique: true });
customerSchema.index({ 'addresses.location': '2dsphere' });

// Pre-save hook to generate referral code
customerSchema.pre('save', async function () {
  if (!this.referralCode) {
    this.referralCode = `BAG-${uuidv4().substring(0, 8).toUpperCase()}`;
  }
});

// Virtual for user details
customerSchema.virtual('user', {
  ref: 'User',
  localField: 'userId',
  foreignField: '_id',
  justOne: true,
});

export const Customer = mongoose.model<ICustomer>('Customer', customerSchema);
export default Customer;
