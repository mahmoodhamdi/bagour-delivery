import mongoose, { Schema, Document, Types } from 'mongoose';
import { ILocation, IPolygon } from '../types';

export interface IZone extends Document {
  _id: Types.ObjectId;
  name: string;
  nameAr: string;

  // Geographic boundary (polygon or circle)
  polygon?: IPolygon;
  center?: ILocation;
  radius?: number; // in meters

  // Pricing
  deliveryFee: number;
  minimumOrder: number;
  freeDeliveryAbove?: number;

  // Timing
  estimatedDeliveryTime: {
    min: number;
    max: number;
  };

  // Status
  isActive: boolean;

  createdAt: Date;
  updatedAt: Date;
}

const zoneSchema = new Schema<IZone>(
  {
    name: {
      type: String,
      required: [true, 'Zone name is required'],
      trim: true,
    },
    nameAr: {
      type: String,
      required: [true, 'Arabic zone name is required'],
      trim: true,
    },

    // Geographic boundary - polygon
    polygon: {
      type: {
        type: String,
        enum: ['Polygon'],
      },
      coordinates: {
        type: [[[Number]]],
      },
    },

    // Geographic boundary - circle
    center: {
      type: {
        type: String,
        enum: ['Point'],
      },
      coordinates: {
        type: [Number],
      },
    },
    radius: {
      type: Number,
      min: [0, 'Radius cannot be negative'],
    },

    // Pricing
    deliveryFee: {
      type: Number,
      default: 10,
      min: [0, 'Delivery fee cannot be negative'],
    },
    minimumOrder: {
      type: Number,
      default: 30,
      min: [0, 'Minimum order cannot be negative'],
    },
    freeDeliveryAbove: {
      type: Number,
      min: [0, 'Free delivery threshold cannot be negative'],
    },

    // Timing
    estimatedDeliveryTime: {
      min: {
        type: Number,
        default: 30,
        min: [0, 'Minimum time cannot be negative'],
      },
      max: {
        type: Number,
        default: 60,
        min: [0, 'Maximum time cannot be negative'],
      },
    },

    // Status
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes
zoneSchema.index({ polygon: '2dsphere' });
zoneSchema.index({ center: '2dsphere' });
zoneSchema.index({ isActive: 1 });

// Validate that either polygon or center+radius is provided
zoneSchema.pre('save', async function () {
  const hasPolygon = this.polygon && this.polygon.coordinates && this.polygon.coordinates.length > 0;
  const hasCircle = this.center && this.center.coordinates && this.center.coordinates.length === 2 && this.radius;

  if (!hasPolygon && !hasCircle) {
    throw new Error('Either polygon or center with radius must be provided');
  }
});

export const Zone = mongoose.model<IZone>('Zone', zoneSchema);
export default Zone;
