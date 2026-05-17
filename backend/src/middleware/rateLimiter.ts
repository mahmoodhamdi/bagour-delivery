import rateLimit, { ipKeyGenerator } from 'express-rate-limit';
import { TooManyRequestsError } from '../utils/errors';

// express-rate-limit 7+ forbids raw `req.ip` in custom keyGenerators because
// IPv6 addresses can be spoofed across /64 subnets. Use the bundled
// ipKeyGenerator helper which masks the lower 64 bits of an IPv6 address.

/**
 * Rate limiter for sensitive financial operations (payouts)
 * - Very strict: 5 requests per 15 minutes
 */
export const payoutLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, _res, next) => {
    next(new TooManyRequestsError('تجاوزت الحد المسموح من طلبات السحب. يرجى المحاولة بعد 15 دقيقة'));
  },
  keyGenerator: (req) => {
    // Use user ID if available, otherwise fall back to IP
    return req.user?.id || ipKeyGenerator(req.ip || '') || 'unknown';
  },
});

/**
 * Rate limiter for order actions (accept, reject, status updates)
 * - Moderate: 30 requests per minute
 */
export const orderActionLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 30, // 30 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, _res, next) => {
    next(new TooManyRequestsError('تجاوزت الحد المسموح من العمليات على الطلبات. يرجى المحاولة بعد دقيقة'));
  },
  keyGenerator: (req) => {
    return req.user?.id || ipKeyGenerator(req.ip || '') || 'unknown';
  },
});

/**
 * Rate limiter for analytics endpoints (heavy queries)
 * - Conservative: 10 requests per 5 minutes
 */
export const analyticsLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 10, // 10 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, _res, next) => {
    next(new TooManyRequestsError('تجاوزت الحد المسموح من طلبات التحليلات. يرجى المحاولة بعد 5 دقائق'));
  },
  keyGenerator: (req) => {
    return req.user?.id || ipKeyGenerator(req.ip || '') || 'unknown';
  },
});

/**
 * Rate limiter for authentication endpoints
 * - Strict: 10 requests per 15 minutes
 */
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // 10 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, _res, next) => {
    next(new TooManyRequestsError('تجاوزت الحد المسموح من محاولات تسجيل الدخول. يرجى المحاولة بعد 15 دقيقة'));
  },
  keyGenerator: (req) => ipKeyGenerator(req.ip || '') || 'unknown',
});

/**
 * Rate limiter for file uploads
 * - Moderate: 20 uploads per 10 minutes
 */
export const uploadLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 20, // 20 uploads per window
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, _res, next) => {
    next(new TooManyRequestsError('تجاوزت الحد المسموح من رفع الملفات. يرجى المحاولة بعد 10 دقائق'));
  },
  keyGenerator: (req) => {
    return req.user?.id || ipKeyGenerator(req.ip || '') || 'unknown';
  },
});

/**
 * Rate limiter for OTP/verification codes
 * - Very strict: 3 requests per 10 minutes
 */
export const otpLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 3, // 3 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, _res, next) => {
    next(new TooManyRequestsError('تجاوزت الحد المسموح من طلبات كود التحقق. يرجى المحاولة بعد 10 دقائق'));
  },
  keyGenerator: (req) => ipKeyGenerator(req.ip || '') || 'unknown',
});
