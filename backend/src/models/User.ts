import mongoose, { Schema, Document, Model } from 'mongoose';
import bcrypt from 'bcryptjs';
import { UserRole } from '../types';

export interface IUser extends Document {
  _id: mongoose.Types.ObjectId;
  role: UserRole;
  email: string;
  phone?: string;
  password?: string;
  name: string;
  avatar?: string;

  // Auth provider
  authProvider: 'email' | 'google';
  googleId?: string;

  // OTP fields
  emailOTP?: string;
  emailOTPExpires?: Date;
  resetOTP?: string;
  resetOTPExpires?: Date;

  isEmailVerified: boolean;
  isPhoneVerified: boolean;
  isActive: boolean;
  isBlocked: boolean;
  fcmTokens: string[];
  lastLogin?: Date;
  lastLoginAt?: Date;
  createdAt: Date;
  updatedAt: Date;

  // Methods
  comparePassword(candidatePassword: string): Promise<boolean>;
}

interface IUserModel extends Model<IUser> {
  findByEmail(email: string): Promise<IUser | null>;
  findByPhone(phone: string): Promise<IUser | null>;
  findByGoogleId(googleId: string): Promise<IUser | null>;
}

const userSchema = new Schema<IUser>(
  {
    role: {
      type: String,
      enum: ['customer', 'restaurant', 'driver', 'delivery', 'admin'],
      required: [true, 'User role is required'],
      default: 'customer',
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^\S+@\S+\.\S+$/, 'Please enter a valid email'],
    },
    phone: {
      type: String,
      unique: true,
      sparse: true,
      trim: true,
      match: [/^01[0125][0-9]{8}$/, 'Please enter a valid Egyptian phone number'],
    },
    password: {
      type: String,
      minlength: [8, 'Password must be at least 8 characters'],
      select: false,
    },
    authProvider: {
      type: String,
      enum: ['email', 'google'],
      default: 'email',
    },
    googleId: {
      type: String,
      sparse: true,
      unique: true,
    },
    emailOTP: {
      type: String,
      select: false,
    },
    emailOTPExpires: {
      type: Date,
      select: false,
    },
    resetOTP: {
      type: String,
      select: false,
    },
    resetOTPExpires: {
      type: Date,
      select: false,
    },
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
      minlength: [2, 'Name must be at least 2 characters'],
      maxlength: [50, 'Name cannot exceed 50 characters'],
    },
    avatar: {
      type: String,
      default: null,
    },
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    isPhoneVerified: {
      type: Boolean,
      default: false,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    isBlocked: {
      type: Boolean,
      default: false,
    },
    fcmTokens: {
      type: [String],
      default: [],
    },
    lastLogin: {
      type: Date,
      default: null,
    },
    lastLoginAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform(_doc, ret: Record<string, unknown>) {
        delete ret.password;
        delete ret.emailOTP;
        delete ret.emailOTPExpires;
        delete ret.resetOTP;
        delete ret.resetOTPExpires;
        delete ret.__v;
        return ret;
      },
    },
  }
);

// Indexes
userSchema.index({ email: 1 }, { unique: true });
userSchema.index({ phone: 1 }, { unique: true, sparse: true });
userSchema.index({ googleId: 1 }, { unique: true, sparse: true });
userSchema.index({ role: 1 });
userSchema.index({ isActive: 1 });
userSchema.index({ authProvider: 1 });

// Pre-save hook for password hashing
userSchema.pre('save', async function () {
  if (!this.isModified('password') || !this.password) {
    return;
  }

  const salt = await bcrypt.genSalt(12);
  this.password = await bcrypt.hash(this.password, salt);
});

// Instance method to compare password
userSchema.methods.comparePassword = async function (candidatePassword: string): Promise<boolean> {
  return bcrypt.compare(candidatePassword, this.password);
};

// Static method to find by email
userSchema.statics.findByEmail = function (email: string): Promise<IUser | null> {
  return this.findOne({ email: email.toLowerCase() });
};

// Static method to find by phone
userSchema.statics.findByPhone = function (phone: string): Promise<IUser | null> {
  return this.findOne({ phone });
};

// Static method to find by Google ID
userSchema.statics.findByGoogleId = function (googleId: string): Promise<IUser | null> {
  return this.findOne({ googleId });
};

export const User = mongoose.model<IUser, IUserModel>('User', userSchema);
export default User;
