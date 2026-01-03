import mongoose, { Schema, Document, Types } from 'mongoose';
import { INotificationData } from '../types';

export type NotificationType = 'order' | 'promotion' | 'system' | 'chat';

export interface INotification extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId;

  // Content
  title: string;
  titleAr: string;
  body: string;
  bodyAr: string;
  image?: string;

  // Type & Data
  type: NotificationType;
  data?: INotificationData;

  // Status
  isRead: boolean;
  readAt?: Date;

  // Delivery
  isSent: boolean;
  sentAt?: Date;
  fcmMessageId?: string;

  createdAt: Date;
}

const notificationSchema = new Schema<INotification>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    // Content
    title: {
      type: String,
      required: [true, 'Title is required'],
      trim: true,
      maxlength: [100, 'Title cannot exceed 100 characters'],
    },
    titleAr: {
      type: String,
      required: [true, 'Arabic title is required'],
      trim: true,
      maxlength: [100, 'Arabic title cannot exceed 100 characters'],
    },
    body: {
      type: String,
      required: [true, 'Body is required'],
      trim: true,
      maxlength: [300, 'Body cannot exceed 300 characters'],
    },
    bodyAr: {
      type: String,
      required: [true, 'Arabic body is required'],
      trim: true,
      maxlength: [300, 'Arabic body cannot exceed 300 characters'],
    },
    image: {
      type: String,
    },

    // Type & Data
    type: {
      type: String,
      enum: ['order', 'promotion', 'system', 'chat'],
      default: 'system',
    },
    data: {
      orderId: { type: Schema.Types.ObjectId, ref: 'Order' },
      restaurantId: { type: Schema.Types.ObjectId, ref: 'Restaurant' },
      action: { type: String },
      url: { type: String },
    },

    // Status
    isRead: {
      type: Boolean,
      default: false,
    },
    readAt: {
      type: Date,
    },

    // Delivery
    isSent: {
      type: Boolean,
      default: false,
    },
    sentAt: {
      type: Date,
    },
    fcmMessageId: {
      type: String,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes
notificationSchema.index({ userId: 1 });
notificationSchema.index({ userId: 1, isRead: 1 });
notificationSchema.index({ createdAt: -1 });
notificationSchema.index({ userId: 1, createdAt: -1 });

// TTL index - auto-delete after 30 days
notificationSchema.index({ createdAt: 1 }, { expireAfterSeconds: 30 * 24 * 60 * 60 });

export const Notification = mongoose.model<INotification>('Notification', notificationSchema);
export default Notification;
