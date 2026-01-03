import { Response, NextFunction } from 'express';
import { MenuCategory } from '../models/MenuCategory';
import { MenuItem } from '../models/MenuItem';
import { Restaurant } from '../models/Restaurant';
import { successResponse } from '../utils/response';
import { AppError } from '../utils/errors';
import { StatusCodes } from 'http-status-codes';
import { AuthRequest } from '../types';
import mongoose from 'mongoose';

// ==================== Menu Categories ====================

/**
 * Get all categories for current restaurant
 * GET /api/v1/restaurants/menu/categories
 */
export const getCategories = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const categories = await MenuCategory.find({ restaurantId: restaurant._id })
      .sort('sortOrder')
      .populate('itemCount');

    successResponse(res, 200, 'تم جلب الأقسام بنجاح', { categories });
  } catch (error) {
    next(error);
  }
};

/**
 * Create a new category
 * POST /api/v1/restaurants/menu/categories
 */
export const createCategory = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { name, nameAr, description, descriptionAr, sortOrder, isActive } = req.body;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    // Check for duplicate name
    const existingCategory = await MenuCategory.findOne({
      restaurantId: restaurant._id,
      $or: [{ name }, { nameAr }],
    });

    if (existingCategory) {
      throw new AppError('قسم بهذا الاسم موجود بالفعل', StatusCodes.CONFLICT);
    }

    // Get max sort order if not provided
    let finalSortOrder = sortOrder;
    if (finalSortOrder === undefined) {
      const maxSortOrder = await MenuCategory.findOne({ restaurantId: restaurant._id })
        .sort('-sortOrder')
        .select('sortOrder');
      finalSortOrder = (maxSortOrder?.sortOrder ?? -1) + 1;
    }

    const category = await MenuCategory.create({
      restaurantId: restaurant._id,
      name,
      nameAr,
      description,
      descriptionAr,
      sortOrder: finalSortOrder,
      isActive: isActive ?? true,
    });

    successResponse(res, 201, 'تم إنشاء القسم بنجاح', { category });
  } catch (error) {
    next(error);
  }
};

/**
 * Update a category
 * PATCH /api/v1/restaurants/menu/categories/:id
 */
export const updateCategory = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { id } = req.params;
    const updates = req.body;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    // Check for duplicate name if updating name
    if (updates.name || updates.nameAr) {
      const existingCategory = await MenuCategory.findOne({
        restaurantId: restaurant._id,
        _id: { $ne: id },
        $or: [
          ...(updates.name ? [{ name: updates.name }] : []),
          ...(updates.nameAr ? [{ nameAr: updates.nameAr }] : []),
        ],
      });

      if (existingCategory) {
        throw new AppError('قسم بهذا الاسم موجود بالفعل', StatusCodes.CONFLICT);
      }
    }

    const category = await MenuCategory.findOneAndUpdate(
      { _id: id, restaurantId: restaurant._id },
      { $set: updates },
      { new: true, runValidators: true }
    );

    if (!category) {
      throw new AppError('القسم غير موجود', StatusCodes.NOT_FOUND);
    }

    successResponse(res, 200, 'تم تحديث القسم بنجاح', { category });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete a category
 * DELETE /api/v1/restaurants/menu/categories/:id
 */
export const deleteCategory = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { id } = req.params;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    // Check if category has items
    const itemsCount = await MenuItem.countDocuments({ categoryId: id });
    if (itemsCount > 0) {
      throw new AppError(
        `لا يمكن حذف القسم لأنه يحتوي على ${itemsCount} صنف. قم بنقل أو حذف الأصناف أولاً`,
        StatusCodes.BAD_REQUEST
      );
    }

    const category = await MenuCategory.findOneAndDelete({
      _id: id,
      restaurantId: restaurant._id,
    });

    if (!category) {
      throw new AppError('القسم غير موجود', StatusCodes.NOT_FOUND);
    }

    successResponse(res, 200, 'تم حذف القسم بنجاح', null);
  } catch (error) {
    next(error);
  }
};

/**
 * Reorder categories
 * PUT /api/v1/restaurants/menu/categories/reorder
 */
export const reorderCategories = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { categories } = req.body;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    // Use bulkWrite for efficient updates
    const bulkOps = categories.map((cat: { id: string; sortOrder: number }) => ({
      updateOne: {
        filter: { _id: cat.id, restaurantId: restaurant._id },
        update: { $set: { sortOrder: cat.sortOrder } },
      },
    }));

    await MenuCategory.bulkWrite(bulkOps);

    const updatedCategories = await MenuCategory.find({ restaurantId: restaurant._id })
      .sort('sortOrder')
      .populate('itemCount');

    successResponse(res, 200, 'تم إعادة ترتيب الأقسام بنجاح', { categories: updatedCategories });
  } catch (error) {
    next(error);
  }
};

// ==================== Menu Items ====================

/**
 * Get all items for current restaurant
 * GET /api/v1/restaurants/menu/items
 */
export const getItems = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { categoryId, isAvailable, search, page = 1, limit = 50 } = req.query;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const query: Record<string, unknown> = { restaurantId: restaurant._id };

    if (categoryId) {
      query.categoryId = categoryId;
    }

    if (isAvailable !== undefined) {
      query.isAvailable = isAvailable === 'true';
    }

    if (search) {
      query.$text = { $search: search as string };
    }

    const skip = (Number(page) - 1) * Number(limit);

    const [items, total] = await Promise.all([
      MenuItem.find(query)
        .populate('categoryId', 'name nameAr')
        .sort('categoryId sortOrder')
        .skip(skip)
        .limit(Number(limit)),
      MenuItem.countDocuments(query),
    ]);

    successResponse(res, 200, 'تم جلب الأصناف بنجاح', {
      items,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit)),
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get single item
 * GET /api/v1/restaurants/menu/items/:id
 */
export const getItem = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { id } = req.params;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const item = await MenuItem.findOne({
      _id: id,
      restaurantId: restaurant._id,
    }).populate('categoryId', 'name nameAr');

    if (!item) {
      throw new AppError('الصنف غير موجود', StatusCodes.NOT_FOUND);
    }

    successResponse(res, 200, 'تم جلب الصنف بنجاح', { item });
  } catch (error) {
    next(error);
  }
};

/**
 * Create a new item
 * POST /api/v1/restaurants/menu/items
 */
export const createItem = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const itemData = req.body;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    // Verify category belongs to this restaurant
    const category = await MenuCategory.findOne({
      _id: itemData.categoryId,
      restaurantId: restaurant._id,
    });

    if (!category) {
      throw new AppError('القسم غير موجود', StatusCodes.NOT_FOUND);
    }

    // Get max sort order if not provided
    if (itemData.sortOrder === undefined) {
      const maxSortOrder = await MenuItem.findOne({
        restaurantId: restaurant._id,
        categoryId: itemData.categoryId,
      })
        .sort('-sortOrder')
        .select('sortOrder');
      itemData.sortOrder = (maxSortOrder?.sortOrder ?? -1) + 1;
    }

    const item = await MenuItem.create({
      ...itemData,
      restaurantId: restaurant._id,
    });

    await item.populate('categoryId', 'name nameAr');

    successResponse(res, 201, 'تم إنشاء الصنف بنجاح', { item });
  } catch (error) {
    next(error);
  }
};

/**
 * Update an item
 * PATCH /api/v1/restaurants/menu/items/:id
 */
export const updateItem = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { id } = req.params;
    const updates = req.body;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    // If changing category, verify it belongs to this restaurant
    if (updates.categoryId) {
      const category = await MenuCategory.findOne({
        _id: updates.categoryId,
        restaurantId: restaurant._id,
      });

      if (!category) {
        throw new AppError('القسم غير موجود', StatusCodes.NOT_FOUND);
      }
    }

    const item = await MenuItem.findOneAndUpdate(
      { _id: id, restaurantId: restaurant._id },
      { $set: updates },
      { new: true, runValidators: true }
    ).populate('categoryId', 'name nameAr');

    if (!item) {
      throw new AppError('الصنف غير موجود', StatusCodes.NOT_FOUND);
    }

    successResponse(res, 200, 'تم تحديث الصنف بنجاح', { item });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete an item
 * DELETE /api/v1/restaurants/menu/items/:id
 */
export const deleteItem = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { id } = req.params;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const item = await MenuItem.findOneAndDelete({
      _id: id,
      restaurantId: restaurant._id,
    });

    if (!item) {
      throw new AppError('الصنف غير موجود', StatusCodes.NOT_FOUND);
    }

    successResponse(res, 200, 'تم حذف الصنف بنجاح', null);
  } catch (error) {
    next(error);
  }
};

/**
 * Toggle item availability
 * POST /api/v1/restaurants/menu/items/:id/toggle
 */
export const toggleItemAvailability = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { id } = req.params;
    const { isAvailable } = req.body;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const item = await MenuItem.findOneAndUpdate(
      { _id: id, restaurantId: restaurant._id },
      { $set: { isAvailable } },
      { new: true }
    );

    if (!item) {
      throw new AppError('الصنف غير موجود', StatusCodes.NOT_FOUND);
    }

    const message = isAvailable ? 'تم تفعيل الصنف بنجاح' : 'تم إيقاف الصنف بنجاح';
    successResponse(res, 200, message, { item });
  } catch (error) {
    next(error);
  }
};

/**
 * Bulk update items (availability, sort order)
 * PUT /api/v1/restaurants/menu/items/bulk
 */
export const bulkUpdateItems = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { items } = req.body;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const bulkOps = items.map((item: { id: string; isAvailable?: boolean; sortOrder?: number }) => {
      const update: Record<string, unknown> = {};
      if (item.isAvailable !== undefined) update.isAvailable = item.isAvailable;
      if (item.sortOrder !== undefined) update.sortOrder = item.sortOrder;

      return {
        updateOne: {
          filter: { _id: item.id, restaurantId: restaurant._id },
          update: { $set: update },
        },
      };
    });

    await MenuItem.bulkWrite(bulkOps);

    successResponse(res, 200, 'تم تحديث الأصناف بنجاح', null);
  } catch (error) {
    next(error);
  }
};

/**
 * Duplicate an item
 * POST /api/v1/restaurants/menu/items/:id/duplicate
 */
export const duplicateItem = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { id } = req.params;

    const restaurant = await Restaurant.findOne({ userId });
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }

    const originalItem = await MenuItem.findOne({
      _id: id,
      restaurantId: restaurant._id,
    });

    if (!originalItem) {
      throw new AppError('الصنف غير موجود', StatusCodes.NOT_FOUND);
    }

    // Create a copy (omit _id)
    const { _id, ...itemData } = originalItem.toObject();
    itemData.name = `${itemData.name} (نسخة)`;
    itemData.nameAr = `${itemData.nameAr} (نسخة)`;
    itemData.isAvailable = false;
    itemData.isPopular = false;
    itemData.totalOrders = 0;

    // Get next sort order
    const maxSortOrder = await MenuItem.findOne({
      restaurantId: restaurant._id,
      categoryId: originalItem.categoryId,
    })
      .sort('-sortOrder')
      .select('sortOrder');
    itemData.sortOrder = (maxSortOrder?.sortOrder ?? -1) + 1;

    const newItem = await MenuItem.create(itemData);
    await newItem.populate('categoryId', 'name nameAr');

    successResponse(res, 201, 'تم نسخ الصنف بنجاح', { item: newItem });
  } catch (error) {
    next(error);
  }
};
