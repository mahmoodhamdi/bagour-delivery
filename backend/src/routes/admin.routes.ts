import { Router } from 'express';
import { validate } from '../middleware/validate';
import { authenticate, authorize } from '../middleware/auth';
import {
  usersQuerySchema,
  restaurantsQuerySchema,
  driversQuerySchema,
  analyticsQuerySchema,
  rejectReasonSchema,
  suspendReasonSchema,
  createZoneSchema,
  updateZoneSchema,
  updateSettingsSchema,
} from '../validators/admin.validator';
import {
  // Dashboard
  getAdminDashboardStats,
  getRevenueChart,
  getRecentOrders,
  getTopRestaurants,
  // Users
  getUsers,
  getUserById,
  blockUser,
  unblockUser,
  deleteUser,
  // Restaurants
  getRestaurants,
  getRestaurantById,
  approveRestaurant,
  rejectRestaurant,
  suspendRestaurant,
  activateRestaurant,
  // Drivers
  getDrivers,
  getDriverById,
  approveDriver,
  rejectDriver,
  suspendDriver,
  activateDriver,
  // Zones
  getZones,
  getZoneById,
  createZone,
  updateZone,
  deleteZone,
  // Settings
  getSettings,
  updateSettings,
  // Analytics
  getOrdersAnalytics,
  getPopularItems,
  getCustomerStats,
  getFinancialSummary,
} from '../controllers/admin.controller';

const router = Router();

// All admin routes require authentication and admin role
router.use(authenticate);
router.use(authorize('admin'));

// ==================== Dashboard ====================
router.get('/dashboard/stats', getAdminDashboardStats);
router.get('/dashboard/revenue-chart', validate(analyticsQuerySchema, 'query'), getRevenueChart);
router.get('/dashboard/recent-orders', getRecentOrders);
router.get('/dashboard/top-restaurants', getTopRestaurants);

// ==================== Users ====================
router.get('/users', validate(usersQuerySchema, 'query'), getUsers);
router.get('/users/:id', getUserById);
router.put('/users/:id/block', blockUser);
router.put('/users/:id/unblock', unblockUser);
router.delete('/users/:id', deleteUser);

// ==================== Restaurants ====================
router.get('/restaurants', validate(restaurantsQuerySchema, 'query'), getRestaurants);
router.get('/restaurants/:id', getRestaurantById);
router.put('/restaurants/:id/approve', approveRestaurant);
router.put('/restaurants/:id/reject', validate(rejectReasonSchema), rejectRestaurant);
router.put('/restaurants/:id/suspend', validate(suspendReasonSchema), suspendRestaurant);
router.put('/restaurants/:id/activate', activateRestaurant);

// ==================== Drivers ====================
router.get('/drivers', validate(driversQuerySchema, 'query'), getDrivers);
router.get('/drivers/:id', getDriverById);
router.put('/drivers/:id/approve', approveDriver);
router.put('/drivers/:id/reject', validate(rejectReasonSchema), rejectDriver);
router.put('/drivers/:id/suspend', validate(suspendReasonSchema), suspendDriver);
router.put('/drivers/:id/activate', activateDriver);

// ==================== Zones ====================
router.get('/zones', getZones);
router.get('/zones/:id', getZoneById);
router.post('/zones', validate(createZoneSchema), createZone);
router.put('/zones/:id', validate(updateZoneSchema), updateZone);
router.delete('/zones/:id', deleteZone);

// ==================== Settings ====================
router.get('/settings', getSettings);
router.put('/settings', validate(updateSettingsSchema), updateSettings);

// ==================== Analytics ====================
router.get('/analytics/orders', validate(analyticsQuerySchema, 'query'), getOrdersAnalytics);
router.get('/analytics/popular-items', validate(analyticsQuerySchema, 'query'), getPopularItems);
router.get('/analytics/customers', getCustomerStats);
router.get('/analytics/financial', validate(analyticsQuerySchema, 'query'), getFinancialSummary);

export default router;
