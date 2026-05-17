import mongoose, { Schema, Document, Types } from 'mongoose';
import { ILocation, VehicleType } from '../types';

export interface IDriver extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId;

  // Documents
  nationalId: string;
  nationalIdImage: string;
  nationalIdBackImage?: string;
  licenseNumber: string;
  licenseImage: string;
  licenseExpiryDate: Date;

  // Vehicle
  vehicleType: VehicleType;
  vehiclePlate: string;
  vehicleColor?: string;
  vehicleModel?: string;
  vehicleImage?: string;

  // Current State
  currentLocation?: ILocation;
  lastLocationUpdate?: Date;
  isOnline: boolean;
  isAvailable: boolean;
  isBusy: boolean;
  currentOrderId?: Types.ObjectId;

  // Zones
  preferredZones: Types.ObjectId[];

  // Approval
  isApproved: boolean;
  approvedAt?: Date;
  approvedBy?: Types.ObjectId;
  rejectionReason?: string;
  status: 'pending' | 'approved' | 'rejected' | 'suspended';

  // Status
  isActive: boolean;

  // Stats
  rating: number;
  totalRatings: number;
  totalDeliveries: number;
  totalEarnings: number;

  // Financials
  currentBalance: number;
  totalWithdrawn: number;

  createdAt: Date;
  updatedAt: Date;
}

const driverSchema = new Schema<IDriver>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },

    // Documents
    nationalId: {
      type: String,
      required: [true, 'National ID is required'],
      trim: true,
    },
    nationalIdImage: {
      type: String,
      default: '',
    },
    nationalIdBackImage: {
      type: String,
    },
    licenseNumber: {
      type: String,
      required: [true, 'License number is required'],
      trim: true,
    },
    licenseImage: {
      type: String,
      default: '',
    },
    licenseExpiryDate: {
      type: Date,
      required: [true, 'License expiry date is required'],
    },

    // Vehicle
    vehicleType: {
      type: String,
      enum: ['motorcycle', 'car', 'bicycle'],
      required: [true, 'Vehicle type is required'],
    },
    vehiclePlate: {
      type: String,
      required: [true, 'Vehicle plate is required'],
      trim: true,
    },
    vehicleColor: {
      type: String,
      trim: true,
    },
    vehicleModel: {
      type: String,
      trim: true,
    },
    vehicleImage: {
      type: String,
    },

    // Current State
    currentLocation: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number],
      },
    },
    lastLocationUpdate: {
      type: Date,
    },
    isOnline: {
      type: Boolean,
      default: false,
    },
    isAvailable: {
      type: Boolean,
      default: false,
    },
    isBusy: {
      type: Boolean,
      default: false,
    },
    currentOrderId: {
      type: Schema.Types.ObjectId,
      ref: 'Order',
    },

    // Zones
    preferredZones: {
      type: [{ type: Schema.Types.ObjectId, ref: 'Zone' }],
      default: [],
    },

    // Approval
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
    status: {
      type: String,
      enum: ['pending', 'approved', 'rejected', 'suspended'],
      default: 'pending',
    },

    // Status
    isActive: {
      type: Boolean,
      default: true,
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
    totalDeliveries: {
      type: Number,
      default: 0,
      min: 0,
    },
    totalEarnings: {
      type: Number,
      default: 0,
      min: 0,
    },

    // Financials
    currentBalance: {
      type: Number,
      default: 0,
      min: 0,
    },
    totalWithdrawn: {
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

// Indexes — `userId` already declares `unique: true` at the field level.
driverSchema.index({ currentLocation: '2dsphere' });
driverSchema.index({ isOnline: 1, isAvailable: 1 });
driverSchema.index({ isApproved: 1, isActive: 1 });

// Virtual for user details
driverSchema.virtual('user', {
  ref: 'User',
  localField: 'userId',
  foreignField: '_id',
  justOne: true,
});

// Check if license is expired
driverSchema.virtual('isLicenseExpired').get(function () {
  return this.licenseExpiryDate && new Date() > this.licenseExpiryDate;
});

export const Driver = mongoose.model<IDriver>('Driver', driverSchema);
export default Driver;
