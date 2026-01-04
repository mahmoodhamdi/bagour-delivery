import { Request, Response, NextFunction } from 'express';
import { driverService } from '../services/driver.service';
import { sendSuccess } from '../utils/response';
import { IAuthRequest } from '../types';

/**
 * Get driver profile
 * GET /api/v1/driver/profile
 */
export const getProfile = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const driver = await driverService.getProfile(req.driverId!);
    sendSuccess(res, driver);
  } catch (error) {
    next(error);
  }
};

/**
 * Update driver profile
 * PATCH /api/v1/driver/profile
 */
export const updateProfile = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const driver = await driverService.updateProfile(req.driverId!, req.body);
    sendSuccess(res, driver, 'تم تحديث الملف الشخصي بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Update driver avatar
 * PUT /api/v1/driver/avatar
 */
export const updateAvatar = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const { avatar } = req.body;
    const driver = await driverService.updateAvatar(req.driverId!, avatar);
    sendSuccess(res, driver, 'تم تحديث الصورة الشخصية بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Update driver location
 * PUT /api/v1/driver/location
 */
export const updateLocation = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const { latitude, longitude } = req.body;
    const driver = await driverService.updateLocation(req.driverId!, {
      latitude,
      longitude,
    });
    sendSuccess(res, driver);
  } catch (error) {
    next(error);
  }
};

/**
 * Toggle online status
 * PUT /api/v1/driver/online
 */
export const toggleOnline = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const { isOnline } = req.body;
    const driver = await driverService.toggleOnlineStatus(req.driverId!, isOnline);
    sendSuccess(
      res,
      driver,
      isOnline ? 'أنت الآن متصل' : 'أنت الآن غير متصل'
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Toggle availability
 * PUT /api/v1/driver/availability
 */
export const toggleAvailability = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const { isAvailable } = req.body;
    const driver = await driverService.toggleAvailability(req.driverId!, isAvailable);
    sendSuccess(
      res,
      driver,
      isAvailable ? 'أنت الآن متاح لاستقبال الطلبات' : 'أنت الآن غير متاح'
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Get driver statistics
 * GET /api/v1/driver/stats
 */
export const getStats = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const stats = await driverService.getStats(req.driverId!);
    sendSuccess(res, stats);
  } catch (error) {
    next(error);
  }
};

/**
 * Update documents
 * PUT /api/v1/driver/documents
 */
export const updateDocuments = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const driver = await driverService.updateDocuments(req.driverId!, req.body);
    sendSuccess(res, driver, 'تم تحديث المستندات بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Get available zones
 * GET /api/v1/driver/zones
 */
export const getAvailableZones = async (
  _req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const zones = await driverService.getAvailableZones();
    sendSuccess(res, zones);
  } catch (error) {
    next(error);
  }
};
