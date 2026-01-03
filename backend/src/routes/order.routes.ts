import { Router } from 'express';
import { validate } from '../middleware/validate';
import { authenticate, authorize } from '../middleware/auth';
import {
  createOrderSchema,
  cancelOrderSchema,
  rateOrderSchema,
  rejectOrderSchema,
  statusNoteSchema,
  getOrdersQuerySchema,
  driverLocationSchema,
  assignDriverSchema,
  adminOrdersQuerySchema,
} from '../validators/order.validator';
import {
  // Customer endpoints
  createOrder,
  getMyOrders,
  getOrderById,
  cancelOrder,
  rateOrder,
  reorder,
  // Restaurant endpoints
  getRestaurantOrders,
  getActiveRestaurantOrders,
  getRestaurantOrderById,
  confirmOrder,
  rejectOrder,
  markAsPreparing,
  markAsReady,
  getRestaurantOrderStats,
  // Driver endpoints
  getAvailableOrders,
  getDriverOrders,
  getDriverOrderById,
  acceptOrderForDelivery,
  markAsPickedUp,
  markAsOnTheWay,
  markAsDelivered,
  getDriverEarnings,
  // Admin endpoints
  getAllOrders,
  getAdminOrderById,
  adminAssignDriver,
  adminCancelOrder,
  getPlatformOrderStats,
} from '../controllers/order.controller';

const router = Router();

// ==================== Customer Routes ====================

// Create order
router.post(
  '/',
  authenticate,
  authorize('customer'),
  validate(createOrderSchema),
  createOrder
);

// Get my orders
router.get(
  '/',
  authenticate,
  authorize('customer'),
  validate(getOrdersQuerySchema, 'query'),
  getMyOrders
);

// Get order by ID
router.get(
  '/:id',
  authenticate,
  authorize('customer', 'restaurant', 'driver', 'delivery', 'admin'),
  getOrderById
);

// Cancel order
router.put(
  '/:id/cancel',
  authenticate,
  authorize('customer'),
  validate(cancelOrderSchema),
  cancelOrder
);

// Rate order
router.post(
  '/:id/rate',
  authenticate,
  authorize('customer'),
  validate(rateOrderSchema),
  rateOrder
);

// Reorder
router.post(
  '/:id/reorder',
  authenticate,
  authorize('customer'),
  reorder
);

// ==================== Restaurant Routes ====================

const restaurantRouter = Router();

// Get restaurant orders
restaurantRouter.get(
  '/orders',
  authenticate,
  authorize('restaurant'),
  validate(getOrdersQuerySchema, 'query'),
  getRestaurantOrders
);

// Get active orders
restaurantRouter.get(
  '/orders/active',
  authenticate,
  authorize('restaurant'),
  getActiveRestaurantOrders
);

// Get order statistics
restaurantRouter.get(
  '/orders/stats',
  authenticate,
  authorize('restaurant'),
  getRestaurantOrderStats
);

// Get restaurant order by ID
restaurantRouter.get(
  '/orders/:id',
  authenticate,
  authorize('restaurant'),
  getRestaurantOrderById
);

// Confirm order
restaurantRouter.put(
  '/orders/:id/confirm',
  authenticate,
  authorize('restaurant'),
  validate(statusNoteSchema),
  confirmOrder
);

// Reject order
restaurantRouter.put(
  '/orders/:id/reject',
  authenticate,
  authorize('restaurant'),
  validate(rejectOrderSchema),
  rejectOrder
);

// Mark as preparing
restaurantRouter.put(
  '/orders/:id/preparing',
  authenticate,
  authorize('restaurant'),
  validate(statusNoteSchema),
  markAsPreparing
);

// Mark as ready
restaurantRouter.put(
  '/orders/:id/ready',
  authenticate,
  authorize('restaurant'),
  validate(statusNoteSchema),
  markAsReady
);

// ==================== Driver Routes ====================

const driverRouter = Router();

// Get available orders
driverRouter.get(
  '/orders/available',
  authenticate,
  authorize('driver', 'delivery'),
  validate(driverLocationSchema, 'query'),
  getAvailableOrders
);

// Get driver orders
driverRouter.get(
  '/orders',
  authenticate,
  authorize('driver', 'delivery'),
  validate(getOrdersQuerySchema, 'query'),
  getDriverOrders
);

// Get driver earnings
driverRouter.get(
  '/earnings',
  authenticate,
  authorize('driver', 'delivery'),
  getDriverEarnings
);

// Get driver order by ID
driverRouter.get(
  '/orders/:id',
  authenticate,
  authorize('driver', 'delivery'),
  getDriverOrderById
);

// Accept order
driverRouter.put(
  '/orders/:id/accept',
  authenticate,
  authorize('driver', 'delivery'),
  acceptOrderForDelivery
);

// Mark as picked up
driverRouter.put(
  '/orders/:id/picked-up',
  authenticate,
  authorize('driver', 'delivery'),
  validate(statusNoteSchema),
  markAsPickedUp
);

// Mark as on the way
driverRouter.put(
  '/orders/:id/on-the-way',
  authenticate,
  authorize('driver', 'delivery'),
  validate(statusNoteSchema),
  markAsOnTheWay
);

// Mark as delivered
driverRouter.put(
  '/orders/:id/delivered',
  authenticate,
  authorize('driver', 'delivery'),
  validate(statusNoteSchema),
  markAsDelivered
);

// ==================== Admin Routes ====================

const adminRouter = Router();

// Get all orders
adminRouter.get(
  '/orders',
  authenticate,
  authorize('admin'),
  validate(adminOrdersQuerySchema, 'query'),
  getAllOrders
);

// Get order statistics
adminRouter.get(
  '/orders/stats',
  authenticate,
  authorize('admin'),
  getPlatformOrderStats
);

// Get order by ID
adminRouter.get(
  '/orders/:id',
  authenticate,
  authorize('admin'),
  getAdminOrderById
);

// Assign driver
adminRouter.put(
  '/orders/:id/assign-driver',
  authenticate,
  authorize('admin'),
  validate(assignDriverSchema),
  adminAssignDriver
);

// Cancel order
adminRouter.put(
  '/orders/:id/cancel',
  authenticate,
  authorize('admin'),
  validate(cancelOrderSchema),
  adminCancelOrder
);

export default router;
export { restaurantRouter, driverRouter, adminRouter };
