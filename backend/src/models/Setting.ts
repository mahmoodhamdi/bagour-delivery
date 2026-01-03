import mongoose, { Schema, Document, Types } from 'mongoose';

export type SettingType = 'string' | 'number' | 'boolean' | 'json';

export interface ISetting extends Document {
  _id: Types.ObjectId;
  key: string;
  value: unknown;
  type: SettingType;
  description?: string;
  descriptionAr?: string;
  isPublic: boolean;
  updatedAt: Date;
  updatedBy?: Types.ObjectId;
}

const settingSchema = new Schema<ISetting>(
  {
    key: {
      type: String,
      required: [true, 'Setting key is required'],
      unique: true,
      trim: true,
      lowercase: true,
    },
    value: {
      type: Schema.Types.Mixed,
      required: [true, 'Setting value is required'],
    },
    type: {
      type: String,
      enum: ['string', 'number', 'boolean', 'json'],
      required: [true, 'Setting type is required'],
    },
    description: {
      type: String,
    },
    descriptionAr: {
      type: String,
    },
    isPublic: {
      type: Boolean,
      default: false,
    },
    updatedBy: {
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

// Index
settingSchema.index({ key: 1 }, { unique: true });
settingSchema.index({ isPublic: 1 });

// Static method to get setting value by key
settingSchema.statics.getValue = async function (key: string): Promise<unknown> {
  const setting = await this.findOne({ key: key.toLowerCase() });
  return setting?.value;
};

// Static method to set setting value
settingSchema.statics.setValue = async function (
  key: string,
  value: unknown,
  type: SettingType,
  updatedBy?: Types.ObjectId
): Promise<ISetting> {
  return this.findOneAndUpdate(
    { key: key.toLowerCase() },
    { value, type, updatedBy, updatedAt: new Date() },
    { upsert: true, new: true }
  );
};

// Default settings to seed
export const defaultSettings = [
  {
    key: 'default_commission',
    value: 15,
    type: 'number',
    description: 'Default commission percentage for restaurants',
    descriptionAr: 'نسبة العمولة الافتراضية للمطاعم',
    isPublic: false,
  },
  {
    key: 'service_fee',
    value: 3,
    type: 'number',
    description: 'Service fee added to each order',
    descriptionAr: 'رسوم الخدمة المضافة لكل طلب',
    isPublic: true,
  },
  {
    key: 'minimum_order',
    value: 30,
    type: 'number',
    description: 'Minimum order amount',
    descriptionAr: 'الحد الأدنى للطلب',
    isPublic: true,
  },
  {
    key: 'delivery_fee_per_km',
    value: 2,
    type: 'number',
    description: 'Delivery fee per kilometer',
    descriptionAr: 'رسوم التوصيل لكل كيلومتر',
    isPublic: true,
  },
  {
    key: 'max_delivery_distance',
    value: 10,
    type: 'number',
    description: 'Maximum delivery distance in kilometers',
    descriptionAr: 'الحد الأقصى لمسافة التوصيل بالكيلومتر',
    isPublic: true,
  },
  {
    key: 'support_phone',
    value: '01xxxxxxxxx',
    type: 'string',
    description: 'Support phone number',
    descriptionAr: 'رقم هاتف الدعم',
    isPublic: true,
  },
  {
    key: 'support_email',
    value: 'support@bagour.com',
    type: 'string',
    description: 'Support email address',
    descriptionAr: 'البريد الإلكتروني للدعم',
    isPublic: true,
  },
  {
    key: 'app_version_android',
    value: '1.0.0',
    type: 'string',
    description: 'Minimum Android app version',
    descriptionAr: 'الحد الأدنى لإصدار تطبيق أندرويد',
    isPublic: true,
  },
  {
    key: 'app_version_ios',
    value: '1.0.0',
    type: 'string',
    description: 'Minimum iOS app version',
    descriptionAr: 'الحد الأدنى لإصدار تطبيق iOS',
    isPublic: true,
  },
  {
    key: 'maintenance_mode',
    value: false,
    type: 'boolean',
    description: 'Enable maintenance mode',
    descriptionAr: 'تفعيل وضع الصيانة',
    isPublic: true,
  },
  {
    key: 'driver_base_pay',
    value: 5,
    type: 'number',
    description: 'Base pay for drivers per delivery',
    descriptionAr: 'الأجر الأساسي للسائقين لكل توصيل',
    isPublic: false,
  },
  {
    key: 'driver_pay_per_km',
    value: 1,
    type: 'number',
    description: 'Pay per kilometer for drivers',
    descriptionAr: 'أجر السائقين لكل كيلومتر',
    isPublic: false,
  },
];

export const Setting = mongoose.model<ISetting>('Setting', settingSchema);
export default Setting;
