import jwt, { SignOptions } from 'jsonwebtoken';
import crypto from 'crypto';
import { User, Customer, Restaurant, Driver } from '../models';
import { AppError } from '../utils/errors';
import { config } from '../config';
import { IUser } from '../models/User';
import { notificationService } from './notification.service';
import { logger } from '../utils/logger';

// Token types
interface TokenPayload {
  userId: string;
  role: string;
  type: 'access' | 'refresh';
}

interface TokenPair {
  accessToken: string;
  refreshToken: string;
}

interface OtpData {
  otp: string;
  expiresAt: Date;
  type: 'phone_verification' | 'email_verification' | 'password_reset';
}

// In-memory OTP storage (use Redis in production)
const otpStore = new Map<string, OtpData>();

class AuthService {
  /**
   * Generate JWT access token
   */
  generateAccessToken(userId: string, role: string): string {
    const payload: TokenPayload = {
      userId,
      role,
      type: 'access',
    };

    return jwt.sign(payload, config.jwt.accessSecret, {
      expiresIn: config.jwt.accessExpiry,
    } as SignOptions);
  }

  /**
   * Generate JWT refresh token
   */
  generateRefreshToken(userId: string, role: string): string {
    const payload: TokenPayload = {
      userId,
      role,
      type: 'refresh',
    };

    return jwt.sign(payload, config.jwt.refreshSecret, {
      expiresIn: config.jwt.refreshExpiry,
    } as SignOptions);
  }

  /**
   * Generate both access and refresh tokens
   */
  generateTokenPair(userId: string, role: string): TokenPair {
    return {
      accessToken: this.generateAccessToken(userId, role),
      refreshToken: this.generateRefreshToken(userId, role),
    };
  }

  /**
   * Verify access token
   */
  verifyAccessToken(token: string): TokenPayload {
    try {
      const decoded = jwt.verify(token, config.jwt.accessSecret) as TokenPayload;
      if (decoded.type !== 'access') {
        throw new AppError('رمز غير صالح', 401);
      }
      return decoded;
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw new AppError('انتهت صلاحية الجلسة', 401, true, 'TOKEN_EXPIRED');
      }
      throw new AppError('رمز غير صالح', 401);
    }
  }

  /**
   * Verify refresh token
   */
  verifyRefreshToken(token: string): TokenPayload {
    try {
      const decoded = jwt.verify(token, config.jwt.refreshSecret) as TokenPayload;
      if (decoded.type !== 'refresh') {
        throw new AppError('رمز تحديث غير صالح', 401);
      }
      return decoded;
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw new AppError('انتهت صلاحية رمز التحديث', 401, true, 'REFRESH_TOKEN_EXPIRED');
      }
      throw new AppError('رمز تحديث غير صالح', 401);
    }
  }

  /**
   * Refresh tokens using refresh token
   */
  async refreshTokens(refreshToken: string): Promise<TokenPair> {
    const decoded = this.verifyRefreshToken(refreshToken);

    const user = await User.findById(decoded.userId);
    if (!user || !user.isActive) {
      throw new AppError('المستخدم غير موجود أو غير نشط', 401);
    }

    if (user.isBlocked) {
      throw new AppError('تم حظر هذا الحساب', 403);
    }

    return this.generateTokenPair(user._id.toString(), user.role);
  }

  /**
   * Generate 6-digit OTP
   */
  generateOtp(): string {
    return crypto.randomInt(100000, 999999).toString();
  }

  /**
   * Store OTP (use Redis in production)
   */
  storeOtp(
    identifier: string,
    type: OtpData['type'],
    expiryMinutes: number = 5
  ): string {
    const otp = this.generateOtp();
    const expiresAt = new Date(Date.now() + expiryMinutes * 60 * 1000);

    otpStore.set(`${type}:${identifier}`, {
      otp,
      expiresAt,
      type,
    });

    return otp;
  }

  /**
   * Verify OTP
   */
  verifyOtp(identifier: string, otp: string, type: OtpData['type']): boolean {
    const key = `${type}:${identifier}`;
    const storedData = otpStore.get(key);

    if (!storedData) {
      throw new AppError('رمز التحقق غير موجود أو منتهي', 400);
    }

    if (new Date() > storedData.expiresAt) {
      otpStore.delete(key);
      throw new AppError('انتهت صلاحية رمز التحقق', 400);
    }

    if (storedData.otp !== otp) {
      throw new AppError('رمز التحقق غير صحيح', 400);
    }

    // Delete OTP after successful verification
    otpStore.delete(key);
    return true;
  }

  /**
   * Register a new customer
   */
  async registerCustomer(data: {
    name: string;
    email: string;
    phone: string;
    password: string;
    referralCode?: string;
  }): Promise<{ user: IUser; tokens: TokenPair }> {
    // Check if email already exists
    const existingEmail = await User.findOne({ email: data.email });
    if (existingEmail) {
      throw new AppError('البريد الإلكتروني مستخدم بالفعل', 400);
    }

    // Check if phone already exists
    const existingPhone = await User.findOne({ phone: data.phone });
    if (existingPhone) {
      throw new AppError('رقم الهاتف مستخدم بالفعل', 400);
    }

    // Create user
    const user = await User.create({
      name: data.name,
      email: data.email,
      phone: data.phone,
      password: data.password,
      role: 'customer',
    });

    // Create customer profile
    const referralCode = this.generateReferralCode();
    await Customer.create({
      userId: user._id,
      referralCode,
      referredBy: data.referralCode || undefined,
    });

    // Generate tokens
    const tokens = this.generateTokenPair(user._id.toString(), user.role);

    // Send welcome notification
    try {
      await notificationService.sendWelcomeNotification(
        user._id.toString(),
        user.name
      );
    } catch (notifError) {
      logger.error(`Failed to send welcome notification: ${notifError}`);
    }

    return { user, tokens };
  }

  /**
   * Register a new restaurant
   */
  async registerRestaurant(data: {
    ownerName: string;
    email: string;
    phone: string;
    password: string;
    name: string;
    nameEn?: string;
    description?: string;
    cuisineTypes: string[];
    address: {
      street: string;
      area: string;
      city?: string;
      buildingNumber?: string;
      landmark?: string;
      location?: { lat: number; lng: number };
    };
  }): Promise<{ user: IUser; tokens: TokenPair }> {
    // Check if email already exists
    const existingEmail = await User.findOne({ email: data.email });
    if (existingEmail) {
      throw new AppError('البريد الإلكتروني مستخدم بالفعل', 400);
    }

    // Check if phone already exists
    const existingPhone = await User.findOne({ phone: data.phone });
    if (existingPhone) {
      throw new AppError('رقم الهاتف مستخدم بالفعل', 400);
    }

    // Create user
    const user = await User.create({
      name: data.ownerName,
      email: data.email,
      phone: data.phone,
      password: data.password,
      role: 'restaurant',
    });

    // Create restaurant profile
    await Restaurant.create({
      userId: user._id,
      name: data.name,
      nameAr: data.name,
      description: data.description,
      descriptionAr: data.description,
      phone: data.phone,
      categories: data.cuisineTypes,
      address: `${data.address.street}, ${data.address.area}${data.address.city ? ', ' + data.address.city : ''}`,
      area: data.address.area,
      location: data.address.location
        ? {
            type: 'Point',
            coordinates: [data.address.location.lng, data.address.location.lat],
          }
        : { type: 'Point', coordinates: [0, 0] },
      isApproved: false,
    });

    // Generate tokens
    const tokens = this.generateTokenPair(user._id.toString(), user.role);

    return { user, tokens };
  }

  /**
   * Register a new driver
   */
  async registerDriver(data: {
    name: string;
    email: string;
    phone: string;
    password: string;
    nationalId: string;
    vehicleType: 'motorcycle' | 'bicycle' | 'car';
    vehicleModel?: string;
    vehicleColor?: string;
    vehiclePlateNumber: string;
    licenseNumber: string;
    licenseExpiryDate: Date;
  }): Promise<{ user: IUser; tokens: TokenPair }> {
    // Check if email already exists
    const existingEmail = await User.findOne({ email: data.email });
    if (existingEmail) {
      throw new AppError('البريد الإلكتروني مستخدم بالفعل', 400);
    }

    // Check if phone already exists
    const existingPhone = await User.findOne({ phone: data.phone });
    if (existingPhone) {
      throw new AppError('رقم الهاتف مستخدم بالفعل', 400);
    }

    // Check if national ID already exists
    const existingNationalId = await Driver.findOne({ nationalId: data.nationalId });
    if (existingNationalId) {
      throw new AppError('الرقم القومي مستخدم بالفعل', 400);
    }

    // Create user
    const user = await User.create({
      name: data.name,
      email: data.email,
      phone: data.phone,
      password: data.password,
      role: 'driver',
    });

    // Create driver profile
    await Driver.create({
      userId: user._id,
      nationalId: data.nationalId,
      vehicleType: data.vehicleType,
      vehicleModel: data.vehicleModel,
      vehicleColor: data.vehicleColor,
      vehiclePlate: data.vehiclePlateNumber,
      licenseNumber: data.licenseNumber,
      licenseExpiryDate: data.licenseExpiryDate,
      status: 'pending',
    });

    // Generate tokens
    const tokens = this.generateTokenPair(user._id.toString(), user.role);

    return { user, tokens };
  }

  /**
   * Login with email and password
   */
  async login(
    email: string,
    password: string,
    allowedRoles?: string[]
  ): Promise<{ user: IUser; tokens: TokenPair }> {
    const user = await User.findOne({ email }).select('+password');

    if (!user) {
      throw new AppError('البريد الإلكتروني أو كلمة المرور غير صحيحة', 401);
    }

    if (allowedRoles && !allowedRoles.includes(user.role)) {
      throw new AppError('غير مصرح لك بالدخول', 403);
    }

    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      throw new AppError('البريد الإلكتروني أو كلمة المرور غير صحيحة', 401);
    }

    if (!user.isActive) {
      throw new AppError('الحساب غير نشط', 403);
    }

    if (user.isBlocked) {
      throw new AppError('تم حظر هذا الحساب', 403);
    }

    // Update last login
    user.lastLogin = new Date();
    await user.save();

    const tokens = this.generateTokenPair(user._id.toString(), user.role);

    return { user, tokens };
  }

  /**
   * Generate referral code
   */
  generateReferralCode(): string {
    return crypto.randomBytes(4).toString('hex').toUpperCase();
  }

  /**
   * Send OTP via SMS (placeholder - integrate with SMS service)
   */
  async sendSmsOtp(phone: string, otp: string): Promise<void> {
    // TODO: Integrate with SMS service (e.g., Twilio, Vonage)
    console.log(`[SMS] Sending OTP ${otp} to ${phone}`);
  }

  /**
   * Send OTP via Email (placeholder - integrate with email service)
   */
  async sendEmailOtp(email: string, otp: string): Promise<void> {
    // TODO: Integrate with email service (e.g., SendGrid, Nodemailer)
    console.log(`[EMAIL] Sending OTP ${otp} to ${email}`);
  }

  /**
   * Get user with profile
   */
  async getUserWithProfile(userId: string): Promise<{
    user: IUser;
    profile: unknown;
  }> {
    const user = await User.findById(userId);
    if (!user) {
      throw new AppError('المستخدم غير موجود', 404);
    }

    let profile = null;

    switch (user.role) {
      case 'customer':
        profile = await Customer.findOne({ userId });
        break;
      case 'restaurant':
        profile = await Restaurant.findOne({ userId });
        break;
      case 'driver':
        profile = await Driver.findOne({ userId });
        break;
    }

    return { user, profile };
  }

  /**
   * Update FCM token
   */
  async updateFcmToken(
    userId: string,
    fcmToken: string,
    deviceType?: string
  ): Promise<void> {
    const user = await User.findById(userId);
    if (!user) {
      throw new AppError('المستخدم غير موجود', 404);
    }

    // Remove token if it exists (to avoid duplicates)
    user.fcmTokens = user.fcmTokens.filter((token) => token !== fcmToken);

    // Add the new token
    user.fcmTokens.push(fcmToken);

    // Keep only last 5 tokens
    if (user.fcmTokens.length > 5) {
      user.fcmTokens = user.fcmTokens.slice(-5);
    }

    await user.save();
  }

  /**
   * Remove FCM token
   */
  async removeFcmToken(userId: string, fcmToken: string): Promise<void> {
    await User.findByIdAndUpdate(userId, {
      $pull: { fcmTokens: fcmToken },
    });
  }

  /**
   * Change password
   */
  async changePassword(
    userId: string,
    currentPassword: string,
    newPassword: string
  ): Promise<void> {
    const user = await User.findById(userId).select('+password');
    if (!user) {
      throw new AppError('المستخدم غير موجود', 404);
    }

    const isValid = await user.comparePassword(currentPassword);
    if (!isValid) {
      throw new AppError('كلمة المرور الحالية غير صحيحة', 400);
    }

    user.password = newPassword;
    await user.save();
  }

  /**
   * Reset password with OTP
   */
  async resetPassword(
    email: string,
    otp: string,
    newPassword: string
  ): Promise<void> {
    // Verify OTP first
    this.verifyOtp(email, otp, 'password_reset');

    const user = await User.findOne({ email });
    if (!user) {
      throw new AppError('المستخدم غير موجود', 404);
    }

    user.password = newPassword;
    await user.save();
  }
}

export const authService = new AuthService();
