import { Router, Response, NextFunction } from 'express';
import { authenticate, authorize } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { menuService } from '../services/menu.service';
import { successResponse, paginatedResponse } from '../utils/response';
import { AppError } from '../utils/errors';
import { StatusCodes } from 'http-status-codes';
import { AuthRequest } from '../types';
import Joi from 'joi';

const router = Router();

// ==================== Validators ====================

const createCategorySchema = Joi.object({
  name: Joi.string().min(2).max(100).required().messages({
    'string.min': 'اسم القسم يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم القسم يجب ألا يتجاوز 100 حرف',
    'any.required': 'اسم القسم مطلوب',
  }),
  nameAr: Joi.string().min(2).max(100).required().messages({
    'string.min': 'اسم القسم بالعربية يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم القسم بالعربية يجب ألا يتجاوز 100 حرف',
    'any.required': 'اسم القسم بالعربية مطلوب',
  }),
  description: Joi.string().max(500).optional(),
  descriptionAr: Joi.string().max(500).optional(),
  image: Joi.string().uri().optional(),
  sortOrder: Joi.number().min(0).optional(),
  isActive: Joi.boolean().optional(),
});

const updateCategorySchema = Joi.object({
  name: Joi.string().min(2).max(100).optional(),
  nameAr: Joi.string().min(2).max(100).optional(),
  description: Joi.string().max(500).optional().allow(''),
  descriptionAr: Joi.string().max(500).optional().allow(''),
  image: Joi.string().uri().optional().allow(''),
  sortOrder: Joi.number().min(0).optional(),
  isActive: Joi.boolean().optional(),
});

const reorderCategoriesSchema = Joi.object({
  categories: Joi.array()
    .items(
      Joi.object({
        id: Joi.string().required(),
        sortOrder: Joi.number().min(0).required(),
      })
    )
    .min(1)
    .required(),
});

const addonSchema = Joi.object({
  name: Joi.string().required(),
  nameAr: Joi.string().required(),
  price: Joi.number().min(0).required(),
  isAvailable: Joi.boolean().optional().default(true),
  maxQuantity: Joi.number().min(1).max(10).optional().default(5),
});

const variationOptionSchema = Joi.object({
  name: Joi.string().required(),
  nameAr: Joi.string().required(),
  price: Joi.number().min(0).required(),
});

const variationSchema = Joi.object({
  name: Joi.string().required(),
  nameAr: Joi.string().required(),
  isRequired: Joi.boolean().optional().default(false),
  options: Joi.array().items(variationOptionSchema).min(1).required(),
});

const createItemSchema = Joi.object({
  categoryId: Joi.string().required().messages({
    'any.required': 'القسم مطلوب',
  }),
  name: Joi.string().min(2).max(200).required().messages({
    'string.min': 'اسم الصنف يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم الصنف يجب ألا يتجاوز 200 حرف',
    'any.required': 'اسم الصنف مطلوب',
  }),
  nameAr: Joi.string().min(2).max(200).required().messages({
    'string.min': 'اسم الصنف بالعربية يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم الصنف بالعربية يجب ألا يتجاوز 200 حرف',
    'any.required': 'اسم الصنف بالعربية مطلوب',
  }),
  description: Joi.string().max(1000).optional(),
  descriptionAr: Joi.string().max(1000).optional(),
  image: Joi.string().uri().optional(),
  price: Joi.number().min(0).required().messages({
    'number.min': 'السعر يجب أن يكون 0 أو أكثر',
    'any.required': 'السعر مطلوب',
  }),
  discountPrice: Joi.number().min(0).optional(),
  discountEndsAt: Joi.date().optional(),
  preparationTime: Joi.number().min(0).optional(),
  calories: Joi.number().min(0).optional(),
  servingSize: Joi.string().max(50).optional(),
  addons: Joi.array().items(addonSchema).optional(),
  variations: Joi.array().items(variationSchema).optional(),
  isAvailable: Joi.boolean().optional().default(true),
  isPopular: Joi.boolean().optional().default(false),
  isNew: Joi.boolean().optional().default(true),
  tags: Joi.array().items(Joi.string()).optional(),
  sortOrder: Joi.number().min(0).optional(),
});

const updateItemSchema = Joi.object({
  categoryId: Joi.string().optional(),
  name: Joi.string().min(2).max(200).optional(),
  nameAr: Joi.string().min(2).max(200).optional(),
  description: Joi.string().max(1000).optional().allow(''),
  descriptionAr: Joi.string().max(1000).optional().allow(''),
  image: Joi.string().uri().optional().allow(''),
  price: Joi.number().min(0).optional(),
  discountPrice: Joi.number().min(0).optional().allow(null),
  discountEndsAt: Joi.date().optional().allow(null),
  preparationTime: Joi.number().min(0).optional(),
  calories: Joi.number().min(0).optional(),
  servingSize: Joi.string().max(50).optional().allow(''),
  addons: Joi.array().items(addonSchema).optional(),
  variations: Joi.array().items(variationSchema).optional(),
  isAvailable: Joi.boolean().optional(),
  isPopular: Joi.boolean().optional(),
  isNew: Joi.boolean().optional(),
  tags: Joi.array().items(Joi.string()).optional(),
  sortOrder: Joi.number().min(0).optional(),
});

const toggleAvailabilitySchema = Joi.object({
  isAvailable: Joi.boolean().required(),
});

const bulkUpdateSchema = Joi.object({
  items: Joi.array()
    .items(
      Joi.object({
        id: Joi.string().required(),
        isAvailable: Joi.boolean().optional(),
        sortOrder: Joi.number().min(0).optional(),
      })
    )
    .min(1)
    .required(),
});

// ==================== Category Routes (Restaurant Owner) ====================

/**
 * Get all categories
 * GET /api/v1/menu/categories
 */
router.get(
  '/categories',
  authenticate,
  authorize('restaurant'),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
      }

      const categories = await menuService.getCategories(userId);
      successResponse(res, 200, 'تم جلب الأقسام بنجاح', { categories });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Create category
 * POST /api/v1/menu/categories
 */
router.post(
  '/categories',
  authenticate,
  authorize('restaurant'),
  validate(createCategorySchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
      }

      const category = await menuService.createCategory(userId, req.body);
      successResponse(res, 201, 'تم إنشاء القسم بنجاح', { category });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Update category
 * PATCH /api/v1/menu/categories/:id
 */
router.patch(
  '/categories/:id',
  authenticate,
  authorize('restaurant'),
  validate(updateCategorySchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
      }

      const category = await menuService.updateCategory(userId, req.params.id, req.body);
      successResponse(res, 200, 'تم تحديث القسم بنجاح', { category });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Delete category
 * DELETE /api/v1/menu/categories/:id
 */
router.delete(
  '/categories/:id',
  authenticate,
  authorize('restaurant'),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
      }

      await menuService.deleteCategory(userId, req.params.id);
      successResponse(res, 200, 'تم حذف القسم بنجاح', null);
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Reorder categories
 * PUT /api/v1/menu/categories/reorder
 */
router.put(
  '/categories/reorder',
  authenticate,
  authorize('restaurant'),
  validate(reorderCategoriesSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
      }

      const categories = await menuService.reorderCategories(userId, req.body.categories);
      successResponse(res, 200, 'تم إعادة ترتيب الأقسام بنجاح', { categories });
    } catch (error) {
      next(error);
    }
  }
);

// ==================== Item Routes (Restaurant Owner) ====================

/**
 * Get all items
 * GET /api/v1/menu/items
 */
router.get(
  '/items',
  authenticate,
  authorize('restaurant'),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
      }

      const { categoryId, isAvailable, search, page, limit } = req.query;

      const result = await menuService.getItems(userId, {
        categoryId: categoryId as string,
        isAvailable: isAvailable === 'true' ? true : isAvailable === 'false' ? false : undefined,
        search: search as string,
        page: page ? Number(page) : undefined,
        limit: limit ? Number(limit) : undefined,
      });

      paginatedResponse(res, 200, 'تم جلب الأصناف بنجاح', result.data, result.pagination);
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Get single item
 * GET /api/v1/menu/items/:id
 */
router.get(
  '/items/:id',
  authenticate,
  authorize('restaurant'),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
      }

      const item = await menuService.getItemById(userId, req.params.id);
      if (!item) {
        throw new AppError('الصنف غير موجود', StatusCodes.NOT_FOUND);
      }

      successResponse(res, 200, 'تم جلب الصنف بنجاح', { item });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Create item
 * POST /api/v1/menu/items
 */
router.post(
  '/items',
  authenticate,
  authorize('restaurant'),
  validate(createItemSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
      }

      const item = await menuService.createItem(userId, req.body);
      successResponse(res, 201, 'تم إنشاء الصنف بنجاح', { item });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Update item
 * PATCH /api/v1/menu/items/:id
 */
router.patch(
  '/items/:id',
  authenticate,
  authorize('restaurant'),
  validate(updateItemSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
      }

      const item = await menuService.updateItem(userId, req.params.id, req.body);
      successResponse(res, 200, 'تم تحديث الصنف بنجاح', { item });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Delete item
 * DELETE /api/v1/menu/items/:id
 */
router.delete(
  '/items/:id',
  authenticate,
  authorize('restaurant'),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
      }

      await menuService.deleteItem(userId, req.params.id);
      successResponse(res, 200, 'تم حذف الصنف بنجاح', null);
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Toggle item availability
 * POST /api/v1/menu/items/:id/toggle
 */
router.post(
  '/items/:id/toggle',
  authenticate,
  authorize('restaurant'),
  validate(toggleAvailabilitySchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
      }

      const item = await menuService.toggleItemAvailability(
        userId,
        req.params.id,
        req.body.isAvailable
      );

      const message = req.body.isAvailable ? 'تم تفعيل الصنف بنجاح' : 'تم إيقاف الصنف بنجاح';
      successResponse(res, 200, message, { item });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Bulk update items
 * PUT /api/v1/menu/items/bulk
 */
router.put(
  '/items/bulk',
  authenticate,
  authorize('restaurant'),
  validate(bulkUpdateSchema),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
      }

      await menuService.bulkUpdateItems(userId, req.body.items);
      successResponse(res, 200, 'تم تحديث الأصناف بنجاح', null);
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Duplicate item
 * POST /api/v1/menu/items/:id/duplicate
 */
router.post(
  '/items/:id/duplicate',
  authenticate,
  authorize('restaurant'),
  async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
      }

      const item = await menuService.duplicateItem(userId, req.params.id);
      successResponse(res, 201, 'تم نسخ الصنف بنجاح', { item });
    } catch (error) {
      next(error);
    }
  }
);

export default router;
