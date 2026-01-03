import { Request, Response, NextFunction } from 'express';
import { authService } from '../services/auth.service';
import { successResponse } from '../utils/response';
import { AppError } from '../utils/errors';

/**
 * Register a new customer
 * POST /api/v1/auth/customer/register
 */
export const registerCustomer = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { name, email, phone, password, referralCode } = req.body;

    const { user, tokens } = await authService.registerCustomer({
      name,
      email,
      phone,
      password,
      referralCode,
    });

    // Send OTP for phone verification
    const otp = authService.storeOtp(phone, 'phone_verification');
    await authService.sendSmsOtp(phone, otp);

    successResponse(res, 201, 'تم إنشاء الحساب بنجاح', {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        isPhoneVerified: user.isPhoneVerified,
        isEmailVerified: user.isEmailVerified,
      },
      ...tokens,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Register a new restaurant
 * POST /api/v1/auth/restaurant/register
 */
export const registerRestaurant = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      ownerName,
      email,
      phone,
      password,
      name,
      nameEn,
      description,
      cuisineTypes,
      address,
    } = req.body;

    const { user, tokens } = await authService.registerRestaurant({
      ownerName,
      email,
      phone,
      password,
      name,
      nameEn,
      description,
      cuisineTypes,
      address,
    });

    // Send OTP for email verification
    const otp = authService.storeOtp(email, 'email_verification');
    await authService.sendEmailOtp(email, otp);

    successResponse(res, 201, 'تم إنشاء حساب المطعم بنجاح. في انتظار الموافقة.', {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
      },
      ...tokens,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Register a new driver
 * POST /api/v1/auth/driver/register
 */
export const registerDriver = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      name,
      email,
      phone,
      password,
      nationalId,
      vehicleType,
      vehicleModel,
      vehicleColor,
      vehiclePlateNumber,
      licenseNumber,
      licenseExpiryDate,
    } = req.body;

    const { user, tokens } = await authService.registerDriver({
      name,
      email,
      phone,
      password,
      nationalId,
      vehicleType,
      vehicleModel,
      vehicleColor,
      vehiclePlateNumber,
      licenseNumber,
      licenseExpiryDate,
    });

    // Send OTP for phone verification
    const otp = authService.storeOtp(phone, 'phone_verification');
    await authService.sendSmsOtp(phone, otp);

    successResponse(res, 201, 'تم إنشاء حساب السائق بنجاح. في انتظار الموافقة.', {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
      },
      ...tokens,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Login for customers
 * POST /api/v1/auth/customer/login
 */
export const customerLogin = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, password } = req.body;

    const { user, tokens } = await authService.login(email, password, ['customer']);

    const { profile } = await authService.getUserWithProfile(user._id.toString());

    successResponse(res, 200, 'تم تسجيل الدخول بنجاح', {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        avatar: user.avatar,
        isPhoneVerified: user.isPhoneVerified,
        isEmailVerified: user.isEmailVerified,
      },
      profile,
      ...tokens,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Login for restaurants
 * POST /api/v1/auth/restaurant/login
 */
export const restaurantLogin = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, password } = req.body;

    const { user, tokens } = await authService.login(email, password, ['restaurant']);

    const { profile } = await authService.getUserWithProfile(user._id.toString());

    // Check restaurant status
    const restaurant = profile as { status: string } | null;
    if (restaurant?.status === 'pending') {
      throw new AppError('حسابك قيد المراجعة', 403);
    }
    if (restaurant?.status === 'rejected') {
      throw new AppError('تم رفض طلب التسجيل', 403);
    }
    if (restaurant?.status === 'suspended') {
      throw new AppError('تم إيقاف حسابك', 403);
    }

    successResponse(res, 200, 'تم تسجيل الدخول بنجاح', {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
      },
      restaurant: profile,
      ...tokens,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Login for drivers
 * POST /api/v1/auth/driver/login
 */
export const driverLogin = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, password } = req.body;

    const { user, tokens } = await authService.login(email, password, ['driver']);

    const { profile } = await authService.getUserWithProfile(user._id.toString());

    // Check driver status
    const driver = profile as { status: string } | null;
    if (driver?.status === 'pending') {
      throw new AppError('حسابك قيد المراجعة', 403);
    }
    if (driver?.status === 'rejected') {
      throw new AppError('تم رفض طلب التسجيل', 403);
    }
    if (driver?.status === 'suspended') {
      throw new AppError('تم إيقاف حسابك', 403);
    }

    successResponse(res, 200, 'تم تسجيل الدخول بنجاح', {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
      },
      driver: profile,
      ...tokens,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Login for admins
 * POST /api/v1/auth/admin/login
 */
export const adminLogin = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, password } = req.body;

    const { user, tokens } = await authService.login(email, password, ['admin']);

    successResponse(res, 200, 'تم تسجيل الدخول بنجاح', {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
      ...tokens,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Verify OTP
 * POST /api/v1/auth/verify-otp
 */
export const verifyOtp = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { phone, email, otp, type } = req.body;

    const identifier = phone || email;
    authService.verifyOtp(identifier, otp, type);

    // Update user verification status
    if (type === 'phone_verification' && phone) {
      const { User } = await import('../models');
      await User.findOneAndUpdate({ phone }, { isPhoneVerified: true });
    } else if (type === 'email_verification' && email) {
      const { User } = await import('../models');
      await User.findOneAndUpdate({ email }, { isEmailVerified: true });
    }

    successResponse(res, 200, 'تم التحقق بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Resend OTP
 * POST /api/v1/auth/resend-otp
 */
export const resendOtp = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { phone, email, type } = req.body;

    const identifier = phone || email;
    const otp = authService.storeOtp(identifier, type);

    if (phone) {
      await authService.sendSmsOtp(phone, otp);
    } else if (email) {
      await authService.sendEmailOtp(email, otp);
    }

    successResponse(res, 200, 'تم إرسال رمز التحقق');
  } catch (error) {
    next(error);
  }
};

/**
 * Forgot password - request reset
 * POST /api/v1/auth/forgot-password
 */
export const forgotPassword = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email } = req.body;

    const { User } = await import('../models');
    const user = await User.findOne({ email });

    if (!user) {
      // Don't reveal if email exists
      successResponse(res, 200, 'إذا كان البريد الإلكتروني مسجلاً، سيتم إرسال رمز التحقق');
      return;
    }

    const otp = authService.storeOtp(email, 'password_reset');
    await authService.sendEmailOtp(email, otp);

    successResponse(res, 200, 'تم إرسال رمز التحقق إلى بريدك الإلكتروني');
  } catch (error) {
    next(error);
  }
};

/**
 * Reset password with OTP
 * POST /api/v1/auth/reset-password
 */
export const resetPassword = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, otp, newPassword } = req.body;

    await authService.resetPassword(email, otp, newPassword);

    successResponse(res, 200, 'تم تغيير كلمة المرور بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Change password (authenticated)
 * POST /api/v1/auth/change-password
 */
export const changePassword = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { currentPassword, newPassword } = req.body;
    const userId = req.user?.id;

    if (!userId) {
      throw new AppError('غير مصرح', 401);
    }

    await authService.changePassword(userId, currentPassword, newPassword);

    successResponse(res, 200, 'تم تغيير كلمة المرور بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Refresh tokens
 * POST /api/v1/auth/refresh-token
 */
export const refreshToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { refreshToken: token } = req.body;

    const tokens = await authService.refreshTokens(token);

    successResponse(res, 200, 'تم تحديث الرموز بنجاح', tokens);
  } catch (error) {
    next(error);
  }
};

/**
 * Update FCM token
 * POST /api/v1/auth/fcm-token
 */
export const updateFcmToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { fcmToken, deviceType } = req.body;
    const userId = req.user?.id;

    if (!userId) {
      throw new AppError('غير مصرح', 401);
    }

    await authService.updateFcmToken(userId, fcmToken, deviceType);

    successResponse(res, 200, 'تم تحديث رمز الإشعارات');
  } catch (error) {
    next(error);
  }
};

/**
 * Logout
 * POST /api/v1/auth/logout
 */
export const logout = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { fcmToken } = req.body;
    const userId = req.user?.id;

    if (userId && fcmToken) {
      await authService.removeFcmToken(userId, fcmToken);
    }

    successResponse(res, 200, 'تم تسجيل الخروج بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Get current user profile
 * GET /api/v1/auth/me
 */
export const getMe = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      throw new AppError('غير مصرح', 401);
    }

    const { user, profile } = await authService.getUserWithProfile(userId);

    successResponse(res, 200, 'تم جلب البيانات بنجاح', {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        avatar: user.avatar,
        isPhoneVerified: user.isPhoneVerified,
        isEmailVerified: user.isEmailVerified,
      },
      profile,
    });
  } catch (error) {
    next(error);
  }
};
