import mongoose, { Schema, Document, Types } from 'mongoose';
import dayjs from 'dayjs';
import { TransactionType } from '../types';

export type TransactionStatus = 'pending' | 'processing' | 'completed' | 'failed';

export interface ITransaction extends Document {
  _id: Types.ObjectId;
  transactionNumber: string;

  type: TransactionType;

  // References
  orderId?: Types.ObjectId;
  fromUserId?: Types.ObjectId;
  toUserId?: Types.ObjectId;

  // Amount
  amount: number;
  fee: number;
  netAmount: number;
  currency: string;

  // Status
  status: TransactionStatus;

  // Payment Details
  paymentMethod?: string;
  paymentGateway?: string;
  paymentId?: string;
  paymentData?: Record<string, unknown>;

  // For payouts
  bankName?: string;
  accountNumber?: string;
  accountName?: string;

  notes?: string;
  processedBy?: Types.ObjectId;
  processedAt?: Date;

  createdAt: Date;
  updatedAt: Date;
}

const transactionSchema = new Schema<ITransaction>(
  {
    transactionNumber: {
      type: String,
      unique: true,
    },

    type: {
      type: String,
      enum: ['order_payment', 'restaurant_payout', 'driver_payout', 'refund', 'withdrawal', 'bonus'],
      required: [true, 'Transaction type is required'],
    },

    // References
    orderId: {
      type: Schema.Types.ObjectId,
      ref: 'Order',
    },
    fromUserId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
    },
    toUserId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
    },

    // Amount
    amount: {
      type: Number,
      required: [true, 'Amount is required'],
      min: [0, 'Amount cannot be negative'],
    },
    fee: {
      type: Number,
      default: 0,
      min: [0, 'Fee cannot be negative'],
    },
    netAmount: {
      type: Number,
      required: [true, 'Net amount is required'],
    },
    currency: {
      type: String,
      default: 'EGP',
    },

    // Status
    status: {
      type: String,
      enum: ['pending', 'processing', 'completed', 'failed'],
      default: 'pending',
    },

    // Payment Details
    paymentMethod: {
      type: String,
    },
    paymentGateway: {
      type: String,
    },
    paymentId: {
      type: String,
    },
    paymentData: {
      type: Schema.Types.Mixed,
    },

    // For payouts
    bankName: {
      type: String,
    },
    accountNumber: {
      type: String,
    },
    accountName: {
      type: String,
    },

    notes: {
      type: String,
    },
    processedBy: {
      type: Schema.Types.ObjectId,
      ref: 'User',
    },
    processedAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes
transactionSchema.index({ transactionNumber: 1 }, { unique: true });
transactionSchema.index({ orderId: 1 });
transactionSchema.index({ type: 1 });
transactionSchema.index({ status: 1 });
transactionSchema.index({ createdAt: -1 });
transactionSchema.index({ fromUserId: 1 });
transactionSchema.index({ toUserId: 1 });

// Pre-save hook to generate transaction number
transactionSchema.pre('save', async function () {
  if (!this.transactionNumber) {
    const date = dayjs().format('YYMMDD');
    const count = await mongoose.model('Transaction').countDocuments({
      createdAt: {
        $gte: dayjs().startOf('day').toDate(),
        $lte: dayjs().endOf('day').toDate(),
      },
    });
    this.transactionNumber = `TXN-${date}-${(count + 1).toString().padStart(4, '0')}`;
  }

  // Calculate net amount
  if ((this as any).isNew || this.isModified('amount') || this.isModified('fee')) {
    this.netAmount = this.amount - this.fee;
  }
});

// Virtual for order details
transactionSchema.virtual('order', {
  ref: 'Order',
  localField: 'orderId',
  foreignField: '_id',
  justOne: true,
});

export const Transaction = mongoose.model<ITransaction>('Transaction', transactionSchema);
export default Transaction;
