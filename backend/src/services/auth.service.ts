import jwt, { SignOptions } from 'jsonwebtoken';
import crypto from 'crypto';
import admin from 'firebase-admin';
import { User, Customer, Restaurant, Driver } from '../models';
import { AppError } from '../utils/errors';
import { config } from '../config';
import { IUser } from '../models/User';
import { notificationService } from './notification.service';
import { emailService } from './email.service';
import { logger } from '../utils/logger';

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: config.firebase.projectId,
      privateKey: config.firebase.privateKey,
      clientEmail: config.firebase.clientEmail,
    }),
  });
}

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
   * Register with Email + Password (sends OTP for verification)
   */
  async registerWithEmail(data: {
    name: string;
    email: string;
    password: string;
    role: 'customer' | 'restaurant' | 'driver';
    phone?: string;
    restaurantData?: {
      name: string;
      description?: string;
      cuisineTypes: string[];
      address: {
        street: string;
        area: string;
        city?: string;
        location?: { lat: number; lng: number };
      };
    };
    driverData?: {
      nationalId: string;
      vehicleType: 'motorcycle' | 'bicycle' | 'car';
      vehiclePlateNumber: string;
      licenseNumber: string;
      licenseExpiryDate: Date;
    };
  }): Promise<{ requiresVerification: true; email: string }> {
    // Check if email already exists
    const existingEmail = await User.findOne({ email: data.email.toLowerCase() });
    if (existingEmail) {
      throw new AppError('البريد الإلكتروني مستخدم بالفعل', 400);
    }

    // Create user
    const user = await User.create({
      name: data.name,
      email: data.email.toLowerCase(),
      password: data.password,
      role: data.role,
      authProvider: 'email',
      phone: data.phone,
      isEmailVerified: false,
    });

    // Create role-specific profile
    if (data.role === 'customer') {
      const referralCode = this.generateReferralCode();
      await Customer.create({
        userId: user._id,
        referralCode,
      });
    } else if (data.role === 'restaurant' && data.restaurantData) {
      await Restaurant.create({
        userId: user._id,
        name: data.restaurantData.name,
        nameAr: data.restaurantData.name,
        description: data.restaurantData.description,
        descriptionAr: data.restaurantData.description,
        phone: data.phone || '',
        categories: data.restaurantData.cuisineTypes,
        address: `${data.restaurantData.address.street}, ${data.restaurantData.address.area}${data.restaurantData.address.city ? ', ' + data.restaurantData.address.city : ''}`,
        area: data.restaurantData.address.area,
        location: data.restaurantData.address.location
          ? {
              type: 'Point',
              coordinates: [data.restaurantData.address.location.lng, data.restaurantData.address.location.lat],
            }
          : { type: 'Point', coordinates: [0, 0] },
        isApproved: false,
      });
    } else if (data.role === 'driver' && data.driverData) {
      await Driver.create({
        userId: user._id,
        nationalId: data.driverData.nationalId,
        vehicleType: data.driverData.vehicleType,
        vehiclePlate: data.driverData.vehiclePlateNumber,
        licenseNumber: data.driverData.licenseNumber,
        licenseExpiryDate: data.driverData.licenseExpiryDate,
        status: 'pending',
      });
    }

    // Generate and save email OTP
    const otp = this.generateOtp();
    user.emailOTP = otp;
    user.emailOTPExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
    await user.save();

    // Send OTP via email
    try {
      await emailService.sendVerificationOTP(data.email, otp, data.name);
    } catch (emailError) {
      logger.error(`Failed to send verification email: ${emailError}`);
      throw new AppError('فشل في إرسال رمز التحقق، يرجى المحاولة مرة أخرى', 500);
    }

    return {
      requiresVerification: true,
      email: data.email.toLowerCase(),
    };
  }

  /**
   * Verify Email with OTP
   */
  async verifyEmail(email: string, otp: string): Promise<{ user: IUser; tokens: TokenPair }> {
    const user = await User.findOne({ email: email.toLowerCase() })
      .select('+emailOTP +emailOTPExpires');

    if (!user) {
      throw new AppError('المستخدم غير موجود', 404);
    }

    if (user.isEmailVerified) {
      throw new AppError('البريد الإلكتروني موثق بالفعل', 400);
    }

    if (!user.emailOTP || !user.emailOTPExpires) {
      throw new AppError('رمز التحقق غير موجود، يرجى طلب رمز جديد', 400);
    }

    if (new Date() > user.emailOTPExpires) {
      throw new AppError('انتهت صلاحية رمز التحقق', 400);
    }

    if (user.emailOTP !== otp) {
      throw new AppError('رمز التحقق غير صحيح', 400);
    }

    // Mark as verified and clear OTP
    user.isEmailVerified = true;
    user.emailOTP = undefined;
    user.emailOTPExpires = undefined;
    user.lastLogin = new Date();
    await user.save();

    // Send welcome email
    try {
      await emailService.sendWelcomeEmail(user.email, user.name, user.role);
    } catch (emailError) {
      logger.error(`Failed to send welcome email: ${emailError}`);
    }

    // Send welcome notification
    try {
      await notificationService.sendWelcomeNotification(user._id.toString(), user.name);
    } catch (notifError) {
      logger.error(`Failed to send welcome notification: ${notifError}`);
    }

    const tokens = this.generateTokenPair(user._id.toString(), user.role);

    return { user, tokens };
  }

  /**
   * Resend Email OTP
   */
  async resendEmailOTP(email: string): Promise<{ message: string }> {
    const user = await User.findOne({ email: email.toLowerCase() });

    if (!user) {
      throw new AppError('المستخدم غير موجود', 404);
    }

    if (user.isEmailVerified) {
      throw new AppError('البريد الإلكتروني موثق بالفعل', 400);
    }

    // Generate new OTP
    const otp = this.generateOtp();
    user.emailOTP = otp;
    user.emailOTPExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
    await user.save();

    // Send OTP via email
    try {
      await emailService.sendVerificationOTP(email, otp, user.name);
    } catch (emailError) {
      logger.error(`Failed to send verification email: ${emailError}`);
      throw new AppError('فشل في إرسال رمز التحقق، يرجى المحاولة مرة أخرى', 500);
    }

    return { message: 'تم إرسال رمز التحقق بنجاح' };
  }

  /**
   * Login with Email + Password
   */
  async loginWithEmail(
    email: string,
    password: string,
    allowedRoles?: string[]
  ): Promise<{ user: IUser; tokens: TokenPair } | { requiresVerification: true; email: string }> {
    const user = await User.findOne({ email: email.toLowerCase() })
      .select('+password');

    if (!user || user.authProvider !== 'email') {
      throw new AppError('البريد الإلكتروني أو كلمة المرور غير صحيحة', 401);
    }

    if (allowedRoles && !allowedRoles.includes(user.role)) {
      throw new AppError('غير مصرح لك بالدخول', 403);
    }

    if (!user.password) {
      throw new AppError('كلمة المرور غير موجودة، يرجى استخدام تسجيل الدخول بحساب Google', 400);
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

    // Check if email is verified
    if (!user.isEmailVerified) {
      // Generate new OTP and send
      const otp = this.generateOtp();
      user.emailOTP = otp;
      user.emailOTPExpires = new Date(Date.now() + 10 * 60 * 1000);
      await user.save();

      try {
        await emailService.sendVerificationOTP(email, otp, user.name);
      } catch (emailError) {
        logger.error(`Failed to send verification email: ${emailError}`);
      }

      return {
        requiresVerification: true,
        email: email.toLowerCase(),
      };
    }

    // Update last login
    user.lastLogin = new Date();
    await user.save();

    const tokens = this.generateTokenPair(user._id.toString(), user.role);

    return { user, tokens };
  }

  /**
   * Google Sign-In
   */
  async signInWithGoogle(
    idToken: string,
    role: 'customer' | 'restaurant' | 'driver'
  ): Promise<{ user: IUser; tokens: TokenPair; isNewUser: boolean }> {
    // Verify Google ID token with Firebase Admin
    let decodedToken;
    try {
      decodedToken = await admin.auth().verifyIdToken(idToken);
    } catch (error) {
      logger.error(`Google token verification failed: ${error}`);
      throw new AppError('فشل في التحقق من حساب Google', 401);
    }

    const { uid: googleId, email, name, picture } = decodedToken;

    if (!email) {
      throw new AppError('البريد الإلكتروني مطلوب من حساب Google', 400);
    }

    // Check if user exists by Google ID
    let user = await User.findOne({ googleId });

    if (user) {
      // User exists, update last login
      user.lastLogin = new Date();
      await user.save();

      const tokens = this.generateTokenPair(user._id.toString(), user.role);
      return { user, tokens, isNewUser: false };
    }

    // Check if user exists by email
    user = await User.findOne({ email: email.toLowerCase() });

    if (user) {
      // Email exists but with different auth provider
      if (user.authProvider === 'email') {
        throw new AppError(
          'البريد الإلكتروني مستخدم بالفعل مع كلمة مرور. يرجى تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور',
          400
        );
      }

      // Link Google account
      user.googleId = googleId;
      user.authProvider = 'google';
      user.isEmailVerified = true;
      user.lastLogin = new Date();
      if (picture && !user.avatar) {
        user.avatar = picture;
      }
      await user.save();

      const tokens = this.generateTokenPair(user._id.toString(), user.role);
      return { user, tokens, isNewUser: false };
    }

    // Create new user with Google
    user = await User.create({
      name: name || email.split('@')[0],
      email: email.toLowerCase(),
      role,
      authProvider: 'google',
      googleId,
      avatar: picture,
      isEmailVerified: true, // Auto-verified with Google
      isActive: true,
    });

    // Create role-specific profile
    if (role === 'customer') {
      const referralCode = this.generateReferralCode();
      await Customer.create({
        userId: user._id,
        referralCode,
      });
    } else if (role === 'restaurant') {
      await Restaurant.create({
        userId: user._id,
        name: name || 'مطعم جديد',
        nameAr: name || 'مطعم جديد',
        phone: '',
        address: '',
        area: '',
        location: { type: 'Point', coordinates: [0, 0] },
        isApproved: false,
      });
    } else if (role === 'driver') {
      await Driver.create({
        userId: user._id,
        nationalId: '',
        vehicleType: 'motorcycle',
        vehiclePlate: '',
        licenseNumber: '',
        status: 'pending',
      });
    }

    // Send welcome email
    try {
      await emailService.sendWelcomeEmail(user.email, user.name, user.role);
    } catch (emailError) {
      logger.error(`Failed to send welcome email: ${emailError}`);
    }

    // Send welcome notification
    try {
      await notificationService.sendWelcomeNotification(user._id.toString(), user.name);
    } catch (notifError) {
      logger.error(`Failed to send welcome notification: ${notifError}`);
    }

    const tokens = this.generateTokenPair(user._id.toString(), user.role);

    return { user, tokens, isNewUser: true };
  }

  /**
   * Forgot Password - Send Reset OTP
   */
  async forgotPassword(email: string): Promise<{ message: string }> {
    const user = await User.findOne({ email: email.toLowerCase() });

    if (!user) {
      // Don't reveal if email exists or not for security
      return { message: 'إذا كان البريد الإلكتروني موجوداً، سيتم إرسال رمز إعادة التعيين' };
    }

    if (user.authProvider === 'google') {
      throw new AppError('هذا الحساب مسجل عبر Google. لا يمكن إعادة تعيين كلمة المرور', 400);
    }

    // Generate reset OTP
    const otp = this.generateOtp();
    user.resetOTP = otp;
    user.resetOTPExpires = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
    await user.save();

    // Send OTP via email
    try {
      await emailService.sendPasswordResetOTP(email, otp, user.name);
    } catch (emailError) {
      logger.error(`Failed to send password reset email: ${emailError}`);
      throw new AppError('فشل في إرسال رمز إعادة التعيين، يرجى المحاولة مرة أخرى', 500);
    }

    return { message: 'تم إرسال رمز إعادة التعيين إلى بريدك الإلكتروني' };
  }

  /**
   * Reset Password with OTP
   */
  async resetPassword(
    email: string,
    otp: string,
    newPassword: string
  ): Promise<{ message: string }> {
    const user = await User.findOne({ email: email.toLowerCase() })
      .select('+resetOTP +resetOTPExpires');

    if (!user) {
      throw new AppError('المستخدم غير موجود', 404);
    }

    if (user.authProvider === 'google') {
      throw new AppError('هذا الحساب مسجل عبر Google. لا يمكن إعادة تعيين كلمة المرور', 400);
    }

    if (!user.resetOTP || !user.resetOTPExpires) {
      throw new AppError('رمز إعادة التعيين غير موجود، يرجى طلب رمز جديد', 400);
    }

    if (new Date() > user.resetOTPExpires) {
      throw new AppError('انتهت صلاحية رمز إعادة التعيين', 400);
    }

    if (user.resetOTP !== otp) {
      throw new AppError('رمز إعادة التعيين غير صحيح', 400);
    }

    // Update password and clear reset OTP
    user.password = newPassword;
    user.resetOTP = undefined;
    user.resetOTPExpires = undefined;
    await user.save();

    return { message: 'تم تغيير كلمة المرور بنجاح' };
  }

  /**
   * Change Password (for logged-in users)
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

    if (user.authProvider === 'google') {
      throw new AppError('هذا الحساب مسجل عبر Google. لا يمكن تغيير كلمة المرور', 400);
    }

    if (!user.password) {
      throw new AppError('كلمة المرور غير موجودة', 400);
    }

    const isValid = await user.comparePassword(currentPassword);
    if (!isValid) {
      throw new AppError('كلمة المرور الحالية غير صحيحة', 400);
    }

    user.password = newPassword;
    await user.save();
  }

  /**
   * Generate referral code
   */
  generateReferralCode(): string {
    return crypto.randomBytes(4).toString('hex').toUpperCase();
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
}

export const authService = new AuthService();
