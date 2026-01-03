import { Router } from 'express';
import {
  getProfile,
  getAddresses,
  getDefaultAddress,
  addAddress,
  updateAddress,
  deleteAddress,
  setDefaultAddress,
  getFavorites,
  addToFavorites,
  removeFromFavorites,
  checkFavorite,
  getLoyaltyPoints,
} from '@controllers/customer.controller';
import { authenticate, authorize } from '@middleware/auth';
import { validate } from '@middleware/validate';
import {
  addAddressSchema,
  updateAddressSchema,
  addressIdSchema,
  restaurantIdSchema,
} from '@validators/customer.validator';

const router = Router();

// All routes require authentication as customer
router.use(authenticate, authorize('customer'));

// Profile
router.get('/profile', getProfile);
router.get('/loyalty-points', getLoyaltyPoints);

// Addresses
router.get('/addresses', getAddresses);
router.get('/addresses/default', getDefaultAddress);
router.post('/addresses', validate(addAddressSchema), addAddress);
router.put('/addresses/:id', validate(addressIdSchema, 'params'), validate(updateAddressSchema), updateAddress);
router.delete('/addresses/:id', validate(addressIdSchema, 'params'), deleteAddress);
router.patch('/addresses/:id/default', validate(addressIdSchema, 'params'), setDefaultAddress);

// Favorites
router.get('/favorites', getFavorites);
router.post('/favorites/:restaurantId', validate(restaurantIdSchema, 'params'), addToFavorites);
router.delete('/favorites/:restaurantId', validate(restaurantIdSchema, 'params'), removeFromFavorites);
router.get('/favorites/:restaurantId/check', validate(restaurantIdSchema, 'params'), checkFavorite);

export default router;
