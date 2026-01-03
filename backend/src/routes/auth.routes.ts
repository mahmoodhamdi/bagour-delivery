import { Router } from 'express';
import { validate } from '../middleware/validate';
import {
  customerRegisterSchema,
  restaurantRegisterSchema,
  driverRegisterSchema,
  loginSchema,
  verifyOtpSchema,
  resendOtpSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  changePasswordSchema,
  refreshTokenSchema,
  updateFcmTokenSchema,
} from '../validators/auth.validator';
import {
  registerCustomer,
  registerRestaurant,
  registerDriver,
  customerLogin,
  restaurantLogin,
  driverLogin,
  adminLogin,
  verifyOtp,
  resendOtp,
  forgotPassword,
  resetPassword,
  changePassword,
  refreshToken,
  updateFcmToken,
  logout,
  getMe,
} from '../controllers/auth.controller';
import { authenticate } from '../middleware/auth';

const router = Router();

// Customer routes
router.post(
  '/customer/register',
  validate(customerRegisterSchema),
  registerCustomer
);
router.post('/customer/login', validate(loginSchema), customerLogin);

// Restaurant routes
router.post(
  '/restaurant/register',
  validate(restaurantRegisterSchema),
  registerRestaurant
);
router.post('/restaurant/login', validate(loginSchema), restaurantLogin);

// Driver routes
router.post('/driver/register', validate(driverRegisterSchema), registerDriver);
router.post('/driver/login', validate(loginSchema), driverLogin);

// Admin routes
router.post('/admin/login', validate(loginSchema), adminLogin);

// OTP routes
router.post('/verify-otp', validate(verifyOtpSchema), verifyOtp);
router.post('/resend-otp', validate(resendOtpSchema), resendOtp);

// Password routes
router.post('/forgot-password', validate(forgotPasswordSchema), forgotPassword);
router.post('/reset-password', validate(resetPasswordSchema), resetPassword);
router.post(
  '/change-password',
  authenticate,
  validate(changePasswordSchema),
  changePassword
);

// Token routes
router.post('/refresh-token', validate(refreshTokenSchema), refreshToken);

// FCM token
router.post(
  '/fcm-token',
  authenticate,
  validate(updateFcmTokenSchema),
  updateFcmToken
);

// Profile
router.get('/me', authenticate, getMe);

// Logout
router.post('/logout', authenticate, logout);

export default router;
