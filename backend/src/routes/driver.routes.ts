import { Router } from 'express';
import { validate } from '../middleware/validate';
import { authenticate, authorize } from '../middleware/auth';
import { loadDriverProfile } from '../middleware/loadProfile';
import { orderActionLimiter } from '../middleware/rateLimiter';
import {
  updateProfileSchema,
  updateAvatarSchema,
  updateLocationSchema,
  toggleOnlineSchema,
  toggleAvailabilitySchema,
  updateDocumentsSchema,
  rejectOrderSchema,
} from '../validators/driver.validator';
import {
  getProfile,
  updateProfile,
  updateAvatar,
  updateLocation,
  toggleOnline,
  toggleAvailability,
  getStats,
  updateDocuments,
  getAvailableZones,
  rejectOrder,
} from '../controllers/driver.controller';

const router = Router();

// All routes require driver/delivery role authentication.
// `loadDriverProfile` resolves the Driver document so controllers can
// rely on `req.driverId` instead of repeating the lookup.
router.use(authenticate);
router.use(authorize('driver', 'delivery'));
router.use(loadDriverProfile);

// ==================== Profile Routes ====================

// Get driver profile
router.get('/profile', getProfile);

// Update driver profile
router.patch('/profile', validate(updateProfileSchema), updateProfile);

// Update avatar
router.put('/avatar', validate(updateAvatarSchema), updateAvatar);

// ==================== Location & Status Routes ====================

// Update location
router.put('/location', validate(updateLocationSchema), updateLocation);

// Toggle online status
router.put('/online', validate(toggleOnlineSchema), toggleOnline);

// Toggle availability
router.put('/availability', validate(toggleAvailabilitySchema), toggleAvailability);

// ==================== Stats & Documents ====================

// Get driver stats
router.get('/stats', getStats);

// Update documents
router.put('/documents', validate(updateDocumentsSchema), updateDocuments);

// Get available zones
router.get('/zones', getAvailableZones);

// ==================== Order Actions ====================

// Reject assigned order (rate limited)
router.put('/orders/:id/reject', orderActionLimiter, validate(rejectOrderSchema), rejectOrder);

export default router;
