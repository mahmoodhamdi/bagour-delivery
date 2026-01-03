import { Router } from 'express';
import authRoutes from './auth.routes';
import restaurantRoutes from './restaurant.routes';
import menuRoutes from './menu.routes';
import uploadRoutes from './upload.routes';
import orderRoutes, {
  restaurantRouter as restaurantOrderRoutes,
  driverRouter as driverOrderRoutes,
  adminRouter as adminOrderRoutes,
} from './order.routes';
import customerRoutes from './customer.routes';
import couponRoutes, { couponAdminRouter } from './coupon.routes';
import paymentRoutes, { paymentAdminRouter } from './payment.routes';
import {
  transactionDriverRouter,
  transactionRestaurantRouter,
  transactionAdminRouter,
} from './transaction.routes';
import adminRoutes from './admin.routes';
import notificationRoutes from './notification.routes';

const router = Router();

// API version prefix
const API_VERSION = '/api/v1';

// Auth routes
router.use(`${API_VERSION}/auth`, authRoutes);

// Restaurant routes
router.use(`${API_VERSION}/restaurants`, restaurantRoutes);

// Menu routes (for restaurant owners)
router.use(`${API_VERSION}/menu`, menuRoutes);

// Upload routes
router.use(`${API_VERSION}/upload`, uploadRoutes);

// Order routes (customer)
router.use(`${API_VERSION}/orders`, orderRoutes);

// Customer routes
router.use(`${API_VERSION}/customer`, customerRoutes);

// Restaurant order routes
router.use(`${API_VERSION}/restaurant`, restaurantOrderRoutes);

// Restaurant transaction routes
router.use(`${API_VERSION}/restaurant`, transactionRestaurantRouter);

// Driver order routes
router.use(`${API_VERSION}/driver`, driverOrderRoutes);

// Driver transaction routes
router.use(`${API_VERSION}/driver`, transactionDriverRouter);

// Admin order routes
router.use(`${API_VERSION}/admin`, adminOrderRoutes);

// Coupon routes (customer)
router.use(`${API_VERSION}/coupons`, couponRoutes);

// Admin coupon routes
router.use(`${API_VERSION}/admin`, couponAdminRouter);

// Payment routes
router.use(`${API_VERSION}/payment`, paymentRoutes);

// Admin payment routes
router.use(`${API_VERSION}/admin`, paymentAdminRouter);

// Admin transaction routes
router.use(`${API_VERSION}/admin`, transactionAdminRouter);

// Admin routes (dashboard, users, restaurants, drivers, zones, settings, analytics)
router.use(`${API_VERSION}/admin`, adminRoutes);

// Notification routes
router.use(`${API_VERSION}/notifications`, notificationRoutes);

// Health check
router.get('/health', (_req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
  });
});

export default router;
