import mongoose, { Schema, Document, Types } from 'mongoose';

export type PayoutMethod = 'bank_transfer' | 'vodafone_cash' | 'instapay';
export type PayoutStatus = 'pending' | 'processing' | 'completed' | 'rejected';

export interface IAccountDetails {
  bankName?: string;
  accountNumber?: string;
  accountHolderName?: string;
  phoneNumber?: string;
  ipaAddress?: string;
}

export interface IPayout extends Document {
  _id: Types.ObjectId;
  restaurantId: Types.ObjectId;
  amount: number;
  method: PayoutMethod;
  accountDetails: IAccountDetails;
  status: PayoutStatus;
  reference: string;
  notes?: string;
  adminNotes?: string;
  processedAt?: Date;
  processedBy?: Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const accountDetailsSchema = new Schema<IAccountDetails>(
  {
    bankName: { type: String },
    accountNumber: { type: String },
    accountHolderName: { type: String },
    phoneNumber: { type: String },
    ipaAddress: { type: String },
  },
  { _id: false }
);

const payoutSchema = new Schema<IPayout>(
  {
    restaurantId: {
      type: Schema.Types.ObjectId,
      ref: 'Restaurant',
      required: true,
      index: true,
    },
    amount: {
      type: Number,
      required: [true, 'المبلغ مطلوب'],
      min: [100, 'الحد الأدنى للسحب 100 جنيه'],
    },
    method: {
      type: String,
      enum: ['bank_transfer', 'vodafone_cash', 'instapay'],
      required: [true, 'طريقة السحب مطلوبة'],
    },
    accountDetails: {
      type: accountDetailsSchema,
      required: [true, 'تفاصيل الحساب مطلوبة'],
    },
    status: {
      type: String,
      enum: ['pending', 'processing', 'completed', 'rejected'],
      default: 'pending',
    },
    reference: {
      type: String,
      required: true,
      unique: true,
    },
    notes: {
      type: String,
      maxlength: [500, 'الملاحظات يجب ألا تتجاوز 500 حرف'],
    },
    adminNotes: {
      type: String,
      maxlength: [500, 'ملاحظات الإدارة يجب ألا تتجاوز 500 حرف'],
    },
    processedAt: {
      type: Date,
    },
    processedBy: {
      type: Schema.Types.ObjectId,
      ref: 'User',
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes
payoutSchema.index({ restaurantId: 1, status: 1 });
payoutSchema.index({ reference: 1 }, { unique: true });
payoutSchema.index({ createdAt: -1 });
payoutSchema.index({ status: 1, createdAt: -1 });

// Generate reference number before save
payoutSchema.pre('save', async function () {
  if (this.isNew && !this.reference) {
    const today = new Date();
    const dateStr = today.toISOString().slice(2, 10).replace(/-/g, '');
    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));

    const count = await mongoose.model('Payout').countDocuments({
      createdAt: {
        $gte: startOfDay,
        $lt: endOfDay,
      },
    });

    this.reference = `PAY-${dateStr}-${String(count + 1).padStart(4, '0')}`;
  }
});

// Virtual for restaurant details
payoutSchema.virtual('restaurant', {
  ref: 'Restaurant',
  localField: 'restaurantId',
  foreignField: '_id',
  justOne: true,
});

export const Payout = mongoose.model<IPayout>('Payout', payoutSchema);
export default Payout;
