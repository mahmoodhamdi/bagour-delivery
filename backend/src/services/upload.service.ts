import { v2 as cloudinary } from 'cloudinary';
import { AppError } from '../utils/errors';
import { StatusCodes } from 'http-status-codes';

// Types
interface UploadResult {
  url: string;
  publicId: string;
  width?: number;
  height?: number;
  format?: string;
  size?: number;
}

interface UploadOptions {
  folder?: string;
  transformation?: {
    width?: number;
    height?: number;
    crop?: string;
    quality?: string | number;
  };
}

class UploadService {
  /**
   * Upload a single image
   */
  async uploadImage(
    file: Express.Multer.File,
    options: UploadOptions = {}
  ): Promise<UploadResult> {
    const { folder = 'bagour-delivery', transformation } = options;

    try {
      // Convert buffer to base64
      const base64 = `data:${file.mimetype};base64,${file.buffer.toString('base64')}`;

      const uploadOptions: Record<string, unknown> = {
        folder,
        resource_type: 'image',
      };

      if (transformation) {
        uploadOptions.transformation = {
          width: transformation.width || 1000,
          height: transformation.height || 1000,
          crop: transformation.crop || 'limit',
          quality: transformation.quality || 'auto:good',
        };
      } else {
        // Default transformation
        uploadOptions.transformation = {
          width: 1000,
          height: 1000,
          crop: 'limit',
          quality: 'auto:good',
        };
      }

      const result = await cloudinary.uploader.upload(base64, uploadOptions);

      return {
        url: result.secure_url,
        publicId: result.public_id,
        width: result.width,
        height: result.height,
        format: result.format,
        size: result.bytes,
      };
    } catch (error) {
      console.error('Cloudinary upload error:', error);
      throw new AppError('فشل في رفع الصورة', StatusCodes.BAD_REQUEST);
    }
  }

  /**
   * Upload multiple images
   */
  async uploadImages(
    files: Express.Multer.File[],
    options: UploadOptions = {}
  ): Promise<UploadResult[]> {
    const uploadPromises = files.map((file) => this.uploadImage(file, options));
    return Promise.all(uploadPromises);
  }

  /**
   * Delete an image
   */
  async deleteImage(publicId: string): Promise<boolean> {
    try {
      const result = await cloudinary.uploader.destroy(publicId);
      return result.result === 'ok';
    } catch (error) {
      console.error('Cloudinary delete error:', error);
      throw new AppError('فشل في حذف الصورة', StatusCodes.BAD_REQUEST);
    }
  }

  /**
   * Delete multiple images
   */
  async deleteImages(publicIds: string[]): Promise<boolean[]> {
    const deletePromises = publicIds.map((id) => this.deleteImage(id));
    return Promise.all(deletePromises);
  }

  /**
   * Upload restaurant logo
   */
  async uploadRestaurantLogo(file: Express.Multer.File): Promise<UploadResult> {
    return this.uploadImage(file, {
      folder: 'bagour-delivery/restaurants/logos',
      transformation: {
        width: 400,
        height: 400,
        crop: 'fill',
        quality: 'auto:good',
      },
    });
  }

  /**
   * Upload restaurant cover image
   */
  async uploadRestaurantCover(file: Express.Multer.File): Promise<UploadResult> {
    return this.uploadImage(file, {
      folder: 'bagour-delivery/restaurants/covers',
      transformation: {
        width: 1200,
        height: 600,
        crop: 'fill',
        quality: 'auto:good',
      },
    });
  }

  /**
   * Upload menu item image
   */
  async uploadMenuItemImage(file: Express.Multer.File): Promise<UploadResult> {
    return this.uploadImage(file, {
      folder: 'bagour-delivery/menu-items',
      transformation: {
        width: 600,
        height: 600,
        crop: 'fill',
        quality: 'auto:good',
      },
    });
  }

  /**
   * Upload category image
   */
  async uploadCategoryImage(file: Express.Multer.File): Promise<UploadResult> {
    return this.uploadImage(file, {
      folder: 'bagour-delivery/categories',
      transformation: {
        width: 400,
        height: 400,
        crop: 'fill',
        quality: 'auto:good',
      },
    });
  }

  /**
   * Upload user avatar
   */
  async uploadUserAvatar(file: Express.Multer.File): Promise<UploadResult> {
    return this.uploadImage(file, {
      folder: 'bagour-delivery/avatars',
      transformation: {
        width: 200,
        height: 200,
        crop: 'fill',
        quality: 'auto:good',
      },
    });
  }

  /**
   * Upload driver document
   */
  async uploadDriverDocument(file: Express.Multer.File): Promise<UploadResult> {
    return this.uploadImage(file, {
      folder: 'bagour-delivery/drivers/documents',
      transformation: {
        width: 1500,
        height: 1500,
        crop: 'limit',
        quality: 'auto:good',
      },
    });
  }
}

export const uploadService = new UploadService();
