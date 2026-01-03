import { Request, Response, NextFunction } from 'express';
import { StatusCodes } from 'http-status-codes';
import { customerService } from '@services/customer.service';
import { sendSuccess, sendError } from '@utils/response';

/**
 * Get customer profile
 * @route GET /api/v1/customer/profile
 */
export const getProfile = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const profile = await customerService.getProfile(userId);

    sendSuccess(res, profile, 'تم جلب الملف الشخصي بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Get all addresses
 * @route GET /api/v1/customer/addresses
 */
export const getAddresses = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const addresses = await customerService.getAddresses(userId);

    sendSuccess(res, addresses, 'تم جلب العناوين بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Get default address
 * @route GET /api/v1/customer/addresses/default
 */
export const getDefaultAddress = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const address = await customerService.getDefaultAddress(userId);

    if (!address) {
      sendSuccess(res, null, 'لا يوجد عنوان افتراضي');
      return;
    }

    sendSuccess(res, address, 'تم جلب العنوان الافتراضي بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Add a new address
 * @route POST /api/v1/customer/addresses
 */
export const addAddress = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const address = await customerService.addAddress(userId, req.body);

    sendSuccess(res, address, 'تمت إضافة العنوان بنجاح', StatusCodes.CREATED);
  } catch (error) {
    next(error);
  }
};

/**
 * Update an address
 * @route PUT /api/v1/customer/addresses/:id
 */
export const updateAddress = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const addressId = req.params.id;
    const address = await customerService.updateAddress(userId, addressId, req.body);

    sendSuccess(res, address, 'تم تحديث العنوان بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Delete an address
 * @route DELETE /api/v1/customer/addresses/:id
 */
export const deleteAddress = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const addressId = req.params.id;
    await customerService.deleteAddress(userId, addressId);

    sendSuccess(res, null, 'تم حذف العنوان بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Set default address
 * @route PATCH /api/v1/customer/addresses/:id/default
 */
export const setDefaultAddress = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const addressId = req.params.id;
    const address = await customerService.setDefaultAddress(userId, addressId);

    sendSuccess(res, address, 'تم تعيين العنوان كافتراضي');
  } catch (error) {
    next(error);
  }
};

/**
 * Get favorites
 * @route GET /api/v1/customer/favorites
 */
export const getFavorites = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const profile = await customerService.getProfile(userId);

    sendSuccess(res, profile.favorites, 'تم جلب المفضلة بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Add to favorites
 * @route POST /api/v1/customer/favorites/:restaurantId
 */
export const addToFavorites = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { restaurantId } = req.params;
    await customerService.addToFavorites(userId, restaurantId);

    sendSuccess(res, null, 'تمت الإضافة للمفضلة بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Remove from favorites
 * @route DELETE /api/v1/customer/favorites/:restaurantId
 */
export const removeFromFavorites = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { restaurantId } = req.params;
    await customerService.removeFromFavorites(userId, restaurantId);

    sendSuccess(res, null, 'تمت الإزالة من المفضلة بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Check if restaurant is favorite
 * @route GET /api/v1/customer/favorites/:restaurantId/check
 */
export const checkFavorite = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { restaurantId } = req.params;
    const isFavorite = await customerService.isFavorite(userId, restaurantId);

    sendSuccess(res, { isFavorite }, 'تم التحقق بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Get loyalty points
 * @route GET /api/v1/customer/loyalty-points
 */
export const getLoyaltyPoints = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const profile = await customerService.getProfile(userId);

    sendSuccess(res, {
      loyaltyPoints: profile.loyaltyPoints,
      totalOrders: profile.totalOrders,
      totalSpent: profile.totalSpent,
    }, 'تم جلب نقاط الولاء بنجاح');
  } catch (error) {
    next(error);
  }
};
