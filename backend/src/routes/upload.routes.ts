import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import {
  uploadSingleImage,
  uploadMultipleImages,
  uploadLogo,
  uploadCover,
  uploadAvatar,
  uploadRestaurantImages,
} from '../middleware/upload';
import { uploadService } from '../services/upload.service';
import { successResponse } from '../utils/response';
import { AppError } from '../utils/errors';
import { StatusCodes } from 'http-status-codes';

const router = Router();

/**
 * Upload single image
 * POST /api/v1/upload/image
 */
router.post(
  '/image',
  authenticate,
  uploadSingleImage,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.file) {
        throw new AppError('الملف مطلوب', StatusCodes.BAD_REQUEST);
      }

      const result = await uploadService.uploadImage(req.file);
      successResponse(res, 201, 'تم رفع الصورة بنجاح', result);
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Upload multiple images
 * POST /api/v1/upload/images
 */
router.post(
  '/images',
  authenticate,
  uploadMultipleImages,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const files = req.files as Express.Multer.File[];
      if (!files || files.length === 0) {
        throw new AppError('الملفات مطلوبة', StatusCodes.BAD_REQUEST);
      }

      const results = await uploadService.uploadImages(files);
      successResponse(res, 201, 'تم رفع الصور بنجاح', { images: results });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Upload restaurant logo
 * POST /api/v1/upload/restaurant/logo
 */
router.post(
  '/restaurant/logo',
  authenticate,
  uploadLogo,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.file) {
        throw new AppError('الملف مطلوب', StatusCodes.BAD_REQUEST);
      }

      const result = await uploadService.uploadRestaurantLogo(req.file);
      successResponse(res, 201, 'تم رفع الشعار بنجاح', result);
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Upload restaurant cover
 * POST /api/v1/upload/restaurant/cover
 */
router.post(
  '/restaurant/cover',
  authenticate,
  uploadCover,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.file) {
        throw new AppError('الملف مطلوب', StatusCodes.BAD_REQUEST);
      }

      const result = await uploadService.uploadRestaurantCover(req.file);
      successResponse(res, 201, 'تم رفع صورة الغلاف بنجاح', result);
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Upload restaurant images (logo, cover, gallery)
 * POST /api/v1/upload/restaurant/images
 */
router.post(
  '/restaurant/images',
  authenticate,
  uploadRestaurantImages,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const files = req.files as { [fieldname: string]: Express.Multer.File[] };
      const results: Record<string, unknown> = {};

      if (files.logo && files.logo[0]) {
        results.logo = await uploadService.uploadRestaurantLogo(files.logo[0]);
      }

      if (files.coverImage && files.coverImage[0]) {
        results.coverImage = await uploadService.uploadRestaurantCover(files.coverImage[0]);
      }

      if (files.images && files.images.length > 0) {
        results.images = await uploadService.uploadImages(files.images);
      }

      successResponse(res, 201, 'تم رفع الصور بنجاح', results);
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Upload menu item image
 * POST /api/v1/upload/menu-item
 */
router.post(
  '/menu-item',
  authenticate,
  uploadSingleImage,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.file) {
        throw new AppError('الملف مطلوب', StatusCodes.BAD_REQUEST);
      }

      const result = await uploadService.uploadMenuItemImage(req.file);
      successResponse(res, 201, 'تم رفع صورة الصنف بنجاح', result);
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Upload category image
 * POST /api/v1/upload/category
 */
router.post(
  '/category',
  authenticate,
  uploadSingleImage,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.file) {
        throw new AppError('الملف مطلوب', StatusCodes.BAD_REQUEST);
      }

      const result = await uploadService.uploadCategoryImage(req.file);
      successResponse(res, 201, 'تم رفع صورة القسم بنجاح', result);
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Upload user avatar
 * POST /api/v1/upload/avatar
 */
router.post(
  '/avatar',
  authenticate,
  uploadAvatar,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.file) {
        throw new AppError('الملف مطلوب', StatusCodes.BAD_REQUEST);
      }

      const result = await uploadService.uploadUserAvatar(req.file);
      successResponse(res, 201, 'تم رفع الصورة الشخصية بنجاح', result);
    } catch (error) {
      next(error);
    }
  }
);

/**
 * Delete an image
 * DELETE /api/v1/upload/:publicId
 */
router.delete(
  '/:publicId(*)',
  authenticate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { publicId } = req.params;
      if (!publicId) {
        throw new AppError('معرف الصورة مطلوب', StatusCodes.BAD_REQUEST);
      }

      const success = await uploadService.deleteImage(publicId);
      if (success) {
        successResponse(res, 200, 'تم حذف الصورة بنجاح', null);
      } else {
        throw new AppError('فشل في حذف الصورة', StatusCodes.BAD_REQUEST);
      }
    } catch (error) {
      next(error);
    }
  }
);

export default router;
