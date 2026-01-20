import { Router } from 'express';
import { validate } from '../middleware/validate';
import { authLimiter, otpLimiter } from '../middleware/rateLimiter';
import {
  registerSchema,
  verifyEmailSchema,
  resendOtpSchema,
  loginSchema,
  googleSignInSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  changePasswordSchema,
  refreshTokenSchema,
  updateFcmTokenSchema,
} from '../validators/auth.validator';
import {
  register,
  verifyEmail,
  resendOTP,
  login,
  googleSignIn,
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

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Register with Email + Password (sends OTP)
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - password
 *               - role
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               role:
 *                 type: string
 *                 enum: [customer, restaurant, driver]
 *               phone:
 *                 type: string
 *               restaurantData:
 *                 type: object
 *               driverData:
 *                 type: object
 *     responses:
 *       201:
 *         description: OTP sent successfully
 */
router.post('/register', authLimiter, validate(registerSchema), register);

/**
 * @swagger
 * /auth/verify-email:
 *   post:
 *     summary: Verify Email with OTP
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - otp
 *             properties:
 *               email:
 *                 type: string
 *               otp:
 *                 type: string
 *     responses:
 *       200:
 *         description: Email verified successfully
 */
router.post('/verify-email', validate(verifyEmailSchema), verifyEmail);

/**
 * @swagger
 * /auth/resend-otp:
 *   post:
 *     summary: Resend Email OTP
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *     responses:
 *       200:
 *         description: OTP sent successfully
 */
router.post('/resend-otp', otpLimiter, validate(resendOtpSchema), resendOTP);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Login with Email + Password
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               role:
 *                 type: string
 *                 enum: [customer, restaurant, driver, admin]
 *     responses:
 *       200:
 *         description: Login successful
 */
router.post('/login', authLimiter, validate(loginSchema), login);

/**
 * @swagger
 * /auth/google:
 *   post:
 *     summary: Google Sign-In
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - idToken
 *               - role
 *             properties:
 *               idToken:
 *                 type: string
 *               role:
 *                 type: string
 *                 enum: [customer, restaurant, driver]
 *     responses:
 *       200:
 *         description: Login successful
 *       201:
 *         description: Account created successfully
 */
router.post('/google', authLimiter, validate(googleSignInSchema), googleSignIn);

/**
 * @swagger
 * /auth/forgot-password:
 *   post:
 *     summary: Forgot Password - Send Reset OTP
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *     responses:
 *       200:
 *         description: Reset OTP sent successfully
 */
router.post('/forgot-password', otpLimiter, validate(forgotPasswordSchema), forgotPassword);

/**
 * @swagger
 * /auth/reset-password:
 *   post:
 *     summary: Reset Password with OTP
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - otp
 *               - newPassword
 *             properties:
 *               email:
 *                 type: string
 *               otp:
 *                 type: string
 *               newPassword:
 *                 type: string
 *     responses:
 *       200:
 *         description: Password reset successfully
 */
router.post('/reset-password', validate(resetPasswordSchema), resetPassword);

/**
 * @swagger
 * /auth/change-password:
 *   post:
 *     summary: Change Password (authenticated)
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - currentPassword
 *               - newPassword
 *             properties:
 *               currentPassword:
 *                 type: string
 *               newPassword:
 *                 type: string
 *     responses:
 *       200:
 *         description: Password changed successfully
 */
router.post(
  '/change-password',
  authenticate,
  validate(changePasswordSchema),
  changePassword
);

/**
 * @swagger
 * /auth/refresh-token:
 *   post:
 *     summary: Refresh Tokens
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - refreshToken
 *             properties:
 *               refreshToken:
 *                 type: string
 *     responses:
 *       200:
 *         description: Tokens refreshed successfully
 */
router.post('/refresh-token', validate(refreshTokenSchema), refreshToken);

/**
 * @swagger
 * /auth/fcm-token:
 *   post:
 *     summary: Update FCM Token
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - fcmToken
 *             properties:
 *               fcmToken:
 *                 type: string
 *               deviceType:
 *                 type: string
 *     responses:
 *       200:
 *         description: FCM token updated successfully
 */
router.post(
  '/fcm-token',
  authenticate,
  validate(updateFcmTokenSchema),
  updateFcmToken
);

/**
 * @swagger
 * /auth/logout:
 *   post:
 *     summary: Logout
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               fcmToken:
 *                 type: string
 *     responses:
 *       200:
 *         description: Logout successful
 */
router.post('/logout', authenticate, logout);

/**
 * @swagger
 * /auth/me:
 *   get:
 *     summary: Get Current User Profile
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile retrieved successfully
 */
router.get('/me', authenticate, getMe);

export default router;
