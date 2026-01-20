import { Request, Response, NextFunction } from 'express';
import { authService } from '../services/auth.service';
import { successResponse } from '../utils/response';
import { AppError } from '../utils/errors';
import { IAuthRequest } from '../types';

/**
 * Register with Email + Password (sends OTP)
 * POST /api/v1/auth/register
 */
export const register = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { name, email, password, role, phone, restaurantData, driverData } = req.body;

    const result = await authService.registerWithEmail({
      name,
      email,
      password,
      role,
      phone,
      restaurantData,
      driverData,
    });

    successResponse(res, 201, 'تم إرسال رمز التحقق إلى بريدك الإلكتروني', result);
  } catch (error) {
    next(error);
  }
};

/**
 * Verify Email with OTP
 * POST /api/v1/auth/verify-email
 */
export const verifyEmail = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, otp } = req.body;

    const { user, tokens } = await authService.verifyEmail(email, otp);

    const { profile } = await authService.getUserWithProfile(user._id.toString());

    successResponse(res, 200, 'تم التحقق من البريد الإلكتروني بنجاح', {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        avatar: user.avatar,
        authProvider: user.authProvider,
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
 * Resend Email OTP
 * POST /api/v1/auth/resend-otp
 */
export const resendOTP = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email } = req.body;

    const result = await authService.resendEmailOTP(email);

    successResponse(res, 200, result.message);
  } catch (error) {
    next(error);
  }
};

/**
 * Login with Email + Password
 * POST /api/v1/auth/login
 */
export const login = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, password, role } = req.body;

    const result = await authService.loginWithEmail(
      email,
      password,
      role ? [role] : undefined
    );

    // Check if requires verification
    if ('requiresVerification' in result && result.requiresVerification) {
      successResponse(res, 200, 'يرجى تأكيد بريدك الإلكتروني. تم إرسال رمز التحقق', {
        requiresVerification: true,
        email: result.email,
      });
      return;
    }

    // Type guard: At this point, result must be { user, tokens }
    if (!('user' in result) || !('tokens' in result)) {
      throw new AppError('خطأ في تسجيل الدخول', 500);
    }

    const { user, tokens } = result;
    const { profile } = await authService.getUserWithProfile(user._id.toString());

    // Check role-specific status
    if (user.role === 'restaurant') {
      const restaurant = profile as { status?: string } | null;
      if (restaurant?.status === 'pending') {
        throw new AppError('حسابك قيد المراجعة', 403);
      }
      if (restaurant?.status === 'rejected') {
        throw new AppError('تم رفض طلب التسجيل', 403);
      }
      if (restaurant?.status === 'suspended') {
        throw new AppError('تم إيقاف حسابك', 403);
      }
    } else if (user.role === 'driver') {
      const driver = profile as { status?: string } | null;
      if (driver?.status === 'pending') {
        throw new AppError('حسابك قيد المراجعة', 403);
      }
      if (driver?.status === 'rejected') {
        throw new AppError('تم رفض طلب التسجيل', 403);
      }
      if (driver?.status === 'suspended') {
        throw new AppError('تم إيقاف حسابك', 403);
      }
    }

    successResponse(res, 200, 'تم تسجيل الدخول بنجاح', {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        avatar: user.avatar,
        authProvider: user.authProvider,
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
 * Google Sign-In
 * POST /api/v1/auth/google
 */
export const googleSignIn = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { idToken, role } = req.body;

    const { user, tokens, isNewUser } = await authService.signInWithGoogle(idToken, role);

    const { profile } = await authService.getUserWithProfile(user._id.toString());

    successResponse(
      res,
      isNewUser ? 201 : 200,
      isNewUser ? 'تم إنشاء الحساب بنجاح' : 'تم تسجيل الدخول بنجاح',
      {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: user.role,
          avatar: user.avatar,
          authProvider: user.authProvider,
          isEmailVerified: user.isEmailVerified,
        },
        profile,
        isNewUser,
        ...tokens,
      }
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Forgot Password - Send Reset OTP
 * POST /api/v1/auth/forgot-password
 */
export const forgotPassword = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email } = req.body;

    const result = await authService.forgotPassword(email);

    successResponse(res, 200, result.message);
  } catch (error) {
    next(error);
  }
};

/**
 * Reset Password with OTP
 * POST /api/v1/auth/reset-password
 */
export const resetPassword = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, otp, newPassword } = req.body;

    const result = await authService.resetPassword(email, otp, newPassword);

    successResponse(res, 200, result.message);
  } catch (error) {
    next(error);
  }
};

/**
 * Change Password (authenticated users)
 * POST /api/v1/auth/change-password
 */
export const changePassword = async (
  req: IAuthRequest,
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
 * Refresh Tokens
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
 * Update FCM Token
 * POST /api/v1/auth/fcm-token
 */
export const updateFcmToken = async (
  req: IAuthRequest,
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
  req: IAuthRequest,
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
 * Get Current User Profile
 * GET /api/v1/auth/me
 */
export const getMe = async (
  req: IAuthRequest,
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
        authProvider: user.authProvider,
        isEmailVerified: user.isEmailVerified,
      },
      profile,
    });
  } catch (error) {
    next(error);
  }
};
