import { v2 as cloudinary } from 'cloudinary';
import { config } from './index';
import { logger } from '../utils/logger';

export const configureCloudinary = (): void => {
  if (!config.cloudinary.cloudName || !config.cloudinary.apiKey || !config.cloudinary.apiSecret) {
    logger.warn('Cloudinary credentials not configured. Image uploads will not work.');
    return;
  }

  cloudinary.config({
    cloud_name: config.cloudinary.cloudName,
    api_key: config.cloudinary.apiKey,
    api_secret: config.cloudinary.apiSecret,
  });

  logger.info('Cloudinary configured successfully');
};

export { cloudinary };
export default configureCloudinary;
