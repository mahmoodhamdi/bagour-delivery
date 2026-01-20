import { Router } from 'express';
import { validate } from '../middleware/validate';
import { authenticate, authorize } from '../middleware/auth';
import { payoutLimiter, analyticsLimiter } from '../middleware/rateLimiter';
import {
  updateProfileSchema,
  updateLocationSchema,
  updateWorkingHoursSchema,
  updateDeliverySettingsSchema,
  togglePauseSchema,
  createCategorySchema,
  updateCategorySchema,
  reorderCategoriesSchema,
  createMenuItemSchema,
  updateMenuItemSchema,
  toggleItemAvailabilitySchema,
  bulkUpdateItemsSchema,
  searchRestaurantsSchema,
  getRestaurantMenuSchema,
} from '../validators/restaurant.validator';
import {
  getProfile,
  updateProfile,
  updateLocation,
  updateWorkingHours,
  updateDeliverySettings,
  togglePause,
  getDashboardStats,
  getAnalytics,
  getBalance,
  getPayouts,
  createPayout,
  searchRestaurants,
  getRestaurantBySlug,
  getRestaurantMenu,
  getFeaturedRestaurants,
  getNearbyRestaurants,
} from '../controllers/restaurant.controller';
import { createPayoutSchema } from '../validators/payout.validator';
import {
  getCategories,
  createCategory,
  updateCategory,
  deleteCategory,
  reorderCategories,
  getItems,
  getItem,
  createItem,
  updateItem,
  deleteItem,
  toggleItemAvailability,
  bulkUpdateItems,
  duplicateItem,
} from '../controllers/menu.controller';

const router = Router();

// ==================== Public Routes ====================

// Search and list restaurants
router.get('/', validate(searchRestaurantsSchema, 'query'), searchRestaurants);

// Get featured restaurants
router.get('/featured', getFeaturedRestaurants);

// Get nearby restaurants
router.get('/nearby', getNearbyRestaurants);

// Get restaurant by slug
router.get('/:slug', getRestaurantBySlug);

// Get restaurant menu
router.get('/:slug/menu', validate(getRestaurantMenuSchema, 'query'), getRestaurantMenu);

// ==================== Restaurant Owner Routes ====================

// Profile management
router.get(
  '/profile',
  authenticate,
  authorize('restaurant'),
  getProfile
);

router.patch(
  '/profile',
  authenticate,
  authorize('restaurant'),
  validate(updateProfileSchema),
  updateProfile
);

router.put(
  '/location',
  authenticate,
  authorize('restaurant'),
  validate(updateLocationSchema),
  updateLocation
);

router.put(
  '/working-hours',
  authenticate,
  authorize('restaurant'),
  validate(updateWorkingHoursSchema),
  updateWorkingHours
);

router.put(
  '/delivery-settings',
  authenticate,
  authorize('restaurant'),
  validate(updateDeliverySettingsSchema),
  updateDeliverySettings
);

router.post(
  '/toggle-pause',
  authenticate,
  authorize('restaurant'),
  validate(togglePauseSchema),
  togglePause
);

router.get(
  '/stats',
  authenticate,
  authorize('restaurant'),
  getDashboardStats
);

router.get(
  '/analytics',
  authenticate,
  authorize('restaurant'),
  analyticsLimiter,
  getAnalytics
);

// ==================== Balance & Payouts ====================

router.get(
  '/balance',
  authenticate,
  authorize('restaurant'),
  getBalance
);

router.get(
  '/payouts',
  authenticate,
  authorize('restaurant'),
  getPayouts
);

router.post(
  '/payouts',
  authenticate,
  authorize('restaurant'),
  payoutLimiter,
  validate(createPayoutSchema),
  createPayout
);

// ==================== Menu Categories ====================

router.get(
  '/menu/categories',
  authenticate,
  authorize('restaurant'),
  getCategories
);

router.post(
  '/menu/categories',
  authenticate,
  authorize('restaurant'),
  validate(createCategorySchema),
  createCategory
);

router.patch(
  '/menu/categories/:id',
  authenticate,
  authorize('restaurant'),
  validate(updateCategorySchema),
  updateCategory
);

router.delete(
  '/menu/categories/:id',
  authenticate,
  authorize('restaurant'),
  deleteCategory
);

router.put(
  '/menu/categories/reorder',
  authenticate,
  authorize('restaurant'),
  validate(reorderCategoriesSchema),
  reorderCategories
);

// ==================== Menu Items ====================

router.get(
  '/menu/items',
  authenticate,
  authorize('restaurant'),
  getItems
);

router.get(
  '/menu/items/:id',
  authenticate,
  authorize('restaurant'),
  getItem
);

router.post(
  '/menu/items',
  authenticate,
  authorize('restaurant'),
  validate(createMenuItemSchema),
  createItem
);

router.patch(
  '/menu/items/:id',
  authenticate,
  authorize('restaurant'),
  validate(updateMenuItemSchema),
  updateItem
);

router.delete(
  '/menu/items/:id',
  authenticate,
  authorize('restaurant'),
  deleteItem
);

router.post(
  '/menu/items/:id/toggle',
  authenticate,
  authorize('restaurant'),
  validate(toggleItemAvailabilitySchema),
  toggleItemAvailability
);

router.put(
  '/menu/items/bulk',
  authenticate,
  authorize('restaurant'),
  validate(bulkUpdateItemsSchema),
  bulkUpdateItems
);

router.post(
  '/menu/items/:id/duplicate',
  authenticate,
  authorize('restaurant'),
  duplicateItem
);

export default router;
