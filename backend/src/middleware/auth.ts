import { Request, Response, NextFunction } from 'express';
import { authService } from '../services/auth.service';
import { AppError } from '../utils/errors';
import { User } from '../models';

/**
 * Authentication middleware
 * Verifies JWT token and attaches user to request
 */
export const authenticate = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError('الرجاء تسجيل الدخول', 401, true, 'NO_TOKEN');
    }

    const token = authHeader.split(' ')[1];

    if (!token) {
      throw new AppError('الرجاء تسجيل الدخول', 401, true, 'NO_TOKEN');
    }

    const decoded = authService.verifyAccessToken(token);

    // Check if user still exists and is active
    const user = await User.findById(decoded.userId);

    if (!user) {
      throw new AppError('المستخدم غير موجود', 401);
    }

    if (!user.isActive) {
      throw new AppError('الحساب غير نشط', 403);
    }

    if (user.isBlocked) {
      throw new AppError('تم حظر هذا الحساب', 403);
    }

    // Attach user to request
    req.user = {
      id: user._id.toString(),
      role: user.role,
      email: user.email,
    };

    next();
  } catch (error) {
    next(error);
  }
};

/**
 * Authorization middleware factory
 * Restricts access to specific roles
 */
export const authorize = (...allowedRoles: string[]) => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) {
      throw new AppError('الرجاء تسجيل الدخول', 401);
    }

    if (!allowedRoles.includes(req.user.role)) {
      throw new AppError('غير مصرح لك بالوصول', 403);
    }

    next();
  };
};

/**
 * Optional authentication middleware
 * Attaches user to request if token is valid, but doesn't require it
 */
export const optionalAuth = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next();
    }

    const token = authHeader.split(' ')[1];

    if (!token) {
      return next();
    }

    try {
      const decoded = authService.verifyAccessToken(token);
      const user = await User.findById(decoded.userId);

      if (user && user.isActive && !user.isBlocked) {
        req.user = {
          id: user._id.toString(),
          role: user.role,
          email: user.email,
        };
      }
    } catch {
      // Token is invalid, but we don't throw - just continue without user
    }

    next();
  } catch (error) {
    next(error);
  }
};

/**
 * Verify restaurant ownership middleware
 * Ensures the logged-in user is the owner of the restaurant
 */
export const verifyRestaurantOwner = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.user) {
      throw new AppError('الرجاء تسجيل الدخول', 401);
    }

    const { Restaurant } = await import('../models');
    const restaurantId = req.params.restaurantId || req.params.id;

    if (!restaurantId) {
      throw new AppError('معرف المطعم مطلوب', 400);
    }

    const restaurant = await Restaurant.findById(restaurantId);

    if (!restaurant) {
      throw new AppError('المطعم غير موجود', 404);
    }

    if (restaurant.userId.toString() !== req.user.id && req.user.role !== 'admin') {
      throw new AppError('غير مصرح لك بالوصول', 403);
    }

    next();
  } catch (error) {
    next(error);
  }
};

/**
 * Verify driver middleware
 * Ensures the logged-in user is the driver for the operation
 */
export const verifyDriver = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.user) {
      throw new AppError('الرجاء تسجيل الدخول', 401);
    }

    if (req.user.role !== 'driver' && req.user.role !== 'admin') {
      throw new AppError('غير مصرح لك بالوصول', 403);
    }

    const { Driver } = await import('../models');
    const driver = await Driver.findOne({ userId: req.user.id });

    if (!driver && req.user.role === 'driver') {
      throw new AppError('ملف السائق غير موجود', 404);
    }

    if (driver && driver.status !== 'approved' && req.user.role !== 'admin') {
      throw new AppError('حسابك غير مفعل بعد', 403);
    }

    next();
  } catch (error) {
    next(error);
  }
};

/**
 * Check if email is verified middleware
 */
export const requireEmailVerification = (
  req: Request,
  _res: Response,
  next: NextFunction
): void => {
  if (!req.user) {
    throw new AppError('الرجاء تسجيل الدخول', 401);
  }

  // For now, we'll check this from the database in the actual implementation
  // This is a placeholder that can be enhanced
  next();
};

/**
 * Check if phone is verified middleware
 */
export const requirePhoneVerification = (
  req: Request,
  _res: Response,
  next: NextFunction
): void => {
  if (!req.user) {
    throw new AppError('الرجاء تسجيل الدخول', 401);
  }

  // For now, we'll check this from the database in the actual implementation
  // This is a placeholder that can be enhanced
  next();
};

/**
 * Rate limiting for auth endpoints (basic implementation)
 * In production, use redis-based rate limiting
 */
const loginAttempts = new Map<string, { count: number; lastAttempt: Date }>();

export const loginRateLimit = (
  req: Request,
  _res: Response,
  next: NextFunction
): void => {
  const ip = req.ip || req.socket.remoteAddress || 'unknown';
  const key = `login:${ip}`;
  const now = new Date();
  const windowMs = 15 * 60 * 1000; // 15 minutes
  const maxAttempts = 5;

  const attempts = loginAttempts.get(key);

  if (attempts) {
    const timeDiff = now.getTime() - attempts.lastAttempt.getTime();

    if (timeDiff > windowMs) {
      // Reset if window has passed
      loginAttempts.set(key, { count: 1, lastAttempt: now });
    } else if (attempts.count >= maxAttempts) {
      const remainingTime = Math.ceil((windowMs - timeDiff) / 60000);
      throw new AppError(
        `تم تجاوز عدد المحاولات المسموحة. حاول مرة أخرى بعد ${remainingTime} دقيقة`,
        429
      );
    } else {
      attempts.count += 1;
      attempts.lastAttempt = now;
    }
  } else {
    loginAttempts.set(key, { count: 1, lastAttempt: now });
  }

  next();
};
