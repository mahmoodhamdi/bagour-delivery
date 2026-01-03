import multer, { FileFilterCallback } from 'multer';
import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/errors';
import { StatusCodes } from 'http-status-codes';

// Allowed file types
const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

// Max file sizes
const MAX_IMAGE_SIZE = 5 * 1024 * 1024; // 5MB
const MAX_DOCUMENT_SIZE = 10 * 1024 * 1024; // 10MB

// Memory storage (for cloudinary)
const storage = multer.memoryStorage();

// File filter for images
const imageFileFilter = (
  _req: Request,
  file: Express.Multer.File,
  callback: FileFilterCallback
) => {
  if (ALLOWED_IMAGE_TYPES.includes(file.mimetype)) {
    callback(null, true);
  } else {
    callback(
      new AppError(
        'نوع الملف غير مسموح به. الأنواع المسموحة: JPEG, PNG, WebP, GIF',
        StatusCodes.BAD_REQUEST
      )
    );
  }
};

// File filter for documents (images + PDF)
const documentFileFilter = (
  _req: Request,
  file: Express.Multer.File,
  callback: FileFilterCallback
) => {
  const allowedTypes = [...ALLOWED_IMAGE_TYPES, 'application/pdf'];
  if (allowedTypes.includes(file.mimetype)) {
    callback(null, true);
  } else {
    callback(
      new AppError(
        'نوع الملف غير مسموح به. الأنواع المسموحة: JPEG, PNG, WebP, GIF, PDF',
        StatusCodes.BAD_REQUEST
      )
    );
  }
};

/**
 * Upload single image
 */
export const uploadSingleImage = multer({
  storage,
  limits: { fileSize: MAX_IMAGE_SIZE },
  fileFilter: imageFileFilter,
}).single('image');

/**
 * Upload multiple images (max 10)
 */
export const uploadMultipleImages = multer({
  storage,
  limits: { fileSize: MAX_IMAGE_SIZE },
  fileFilter: imageFileFilter,
}).array('images', 10);

/**
 * Upload logo
 */
export const uploadLogo = multer({
  storage,
  limits: { fileSize: MAX_IMAGE_SIZE },
  fileFilter: imageFileFilter,
}).single('logo');

/**
 * Upload cover image
 */
export const uploadCover = multer({
  storage,
  limits: { fileSize: MAX_IMAGE_SIZE },
  fileFilter: imageFileFilter,
}).single('cover');

/**
 * Upload avatar
 */
export const uploadAvatar = multer({
  storage,
  limits: { fileSize: MAX_IMAGE_SIZE },
  fileFilter: imageFileFilter,
}).single('avatar');

/**
 * Upload document (for driver verification)
 */
export const uploadDocument = multer({
  storage,
  limits: { fileSize: MAX_DOCUMENT_SIZE },
  fileFilter: documentFileFilter,
}).single('document');

/**
 * Upload multiple documents (for driver verification)
 */
export const uploadMultipleDocuments = multer({
  storage,
  limits: { fileSize: MAX_DOCUMENT_SIZE },
  fileFilter: documentFileFilter,
}).fields([
  { name: 'nationalIdFront', maxCount: 1 },
  { name: 'nationalIdBack', maxCount: 1 },
  { name: 'license', maxCount: 1 },
  { name: 'vehicleImage', maxCount: 1 },
]);

/**
 * Upload restaurant images (logo, cover, gallery)
 */
export const uploadRestaurantImages = multer({
  storage,
  limits: { fileSize: MAX_IMAGE_SIZE },
  fileFilter: imageFileFilter,
}).fields([
  { name: 'logo', maxCount: 1 },
  { name: 'coverImage', maxCount: 1 },
  { name: 'images', maxCount: 10 },
]);

/**
 * Generic upload handler that wraps multer errors
 */
export const handleUploadError = (
  err: Error,
  _req: Request,
  _res: Response,
  next: NextFunction
): void => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return next(new AppError('حجم الملف كبير جداً', StatusCodes.BAD_REQUEST));
    }
    if (err.code === 'LIMIT_FILE_COUNT') {
      return next(new AppError('عدد الملفات كبير جداً', StatusCodes.BAD_REQUEST));
    }
    if (err.code === 'LIMIT_UNEXPECTED_FILE') {
      return next(new AppError('حقل الملف غير متوقع', StatusCodes.BAD_REQUEST));
    }
    return next(new AppError('خطأ في رفع الملف', StatusCodes.BAD_REQUEST));
  }
  next(err);
};
