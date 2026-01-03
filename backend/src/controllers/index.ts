export * from './auth.controller';
export * from './restaurant.controller';
export * from './menu.controller';
export * from './order.controller';
export {
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
  getProfile as getCustomerProfile,
} from './customer.controller';
export * from './coupon.controller';
export * from './payment.controller';
export * from './transaction.controller';
export * from './admin.controller';
export * from './notification.controller';
