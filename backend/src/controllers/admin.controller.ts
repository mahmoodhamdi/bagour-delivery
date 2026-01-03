import { Request, Response, NextFunction } from 'express';
import { adminService } from '@services/admin.service';
import { sendSuccess, sendPaginated, sendCreated } from '@utils/response';

// ==================== Dashboard ====================

export const getAdminDashboardStats = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const stats = await adminService.getDashboardStats();
    sendSuccess(res, stats);
  } catch (error) {
    next(error);
  }
};

export const getRevenueChart = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const days = parseInt(req.query.days as string) || 30;
    const data = await adminService.getRevenueChart(days);
    sendSuccess(res, data);
  } catch (error) {
    next(error);
  }
};

export const getRecentOrders = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const limit = parseInt(req.query.limit as string) || 10;
    const data = await adminService.getRecentOrders(limit);
    sendSuccess(res, data);
  } catch (error) {
    next(error);
  }
};

export const getTopRestaurants = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const limit = parseInt(req.query.limit as string) || 5;
    const data = await adminService.getTopRestaurants(limit);
    sendSuccess(res, data);
  } catch (error) {
    next(error);
  }
};

// ==================== Users ====================

export const getUsers = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const result = await adminService.getUsers({
      page: parseInt(req.query.page as string) || 1,
      limit: parseInt(req.query.limit as string) || 20,
      search: req.query.search as string,
      role: req.query.role as string,
      status: req.query.status as 'active' | 'blocked',
      sortBy: req.query.sortBy as string,
      sortOrder: req.query.sortOrder as 'asc' | 'desc',
    });
    sendPaginated(res, result.data, {
      total: result.total,
      page: result.page,
      limit: result.limit,
      pages: result.pages,
    });
  } catch (error) {
    next(error);
  }
};

export const getUserById = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const user = await adminService.getUserById(req.params.id);
    sendSuccess(res, user);
  } catch (error) {
    next(error);
  }
};

export const blockUser = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const user = await adminService.blockUser(req.params.id, true);
    sendSuccess(res, user, 'تم حظر المستخدم بنجاح');
  } catch (error) {
    next(error);
  }
};

export const unblockUser = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const user = await adminService.blockUser(req.params.id, false);
    sendSuccess(res, user, 'تم إلغاء حظر المستخدم بنجاح');
  } catch (error) {
    next(error);
  }
};

export const deleteUser = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    await adminService.deleteUser(req.params.id);
    sendSuccess(res, null, 'تم حذف المستخدم بنجاح');
  } catch (error) {
    next(error);
  }
};

// ==================== Restaurants ====================

export const getRestaurants = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const result = await adminService.getRestaurants({
      page: parseInt(req.query.page as string) || 1,
      limit: parseInt(req.query.limit as string) || 20,
      search: req.query.search as string,
      status: req.query.status as 'pending' | 'approved' | 'rejected' | 'suspended',
      sortBy: req.query.sortBy as string,
      sortOrder: req.query.sortOrder as 'asc' | 'desc',
    });
    sendPaginated(res, result.data, {
      total: result.total,
      page: result.page,
      limit: result.limit,
      pages: result.pages,
    });
  } catch (error) {
    next(error);
  }
};

export const getRestaurantById = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const restaurant = await adminService.getRestaurantById(req.params.id);
    sendSuccess(res, restaurant);
  } catch (error) {
    next(error);
  }
};

export const approveRestaurant = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const restaurant = await adminService.approveRestaurant(req.params.id);
    sendSuccess(res, restaurant, 'تم الموافقة على المطعم بنجاح');
  } catch (error) {
    next(error);
  }
};

export const rejectRestaurant = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { reason } = req.body;
    const restaurant = await adminService.rejectRestaurant(req.params.id, reason);
    sendSuccess(res, restaurant, 'تم رفض المطعم');
  } catch (error) {
    next(error);
  }
};

export const suspendRestaurant = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { reason } = req.body;
    const restaurant = await adminService.suspendRestaurant(req.params.id, reason);
    sendSuccess(res, restaurant, 'تم إيقاف المطعم');
  } catch (error) {
    next(error);
  }
};

export const activateRestaurant = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const restaurant = await adminService.activateRestaurant(req.params.id);
    sendSuccess(res, restaurant, 'تم تفعيل المطعم بنجاح');
  } catch (error) {
    next(error);
  }
};

// ==================== Drivers ====================

export const getDrivers = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const result = await adminService.getDrivers({
      page: parseInt(req.query.page as string) || 1,
      limit: parseInt(req.query.limit as string) || 20,
      search: req.query.search as string,
      status: req.query.status as 'pending' | 'approved' | 'rejected' | 'suspended',
      isOnline: req.query.isOnline === 'true' ? true : req.query.isOnline === 'false' ? false : undefined,
      sortBy: req.query.sortBy as string,
      sortOrder: req.query.sortOrder as 'asc' | 'desc',
    });
    sendPaginated(res, result.data, {
      total: result.total,
      page: result.page,
      limit: result.limit,
      pages: result.pages,
    });
  } catch (error) {
    next(error);
  }
};

export const getDriverById = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const driver = await adminService.getDriverById(req.params.id);
    sendSuccess(res, driver);
  } catch (error) {
    next(error);
  }
};

export const approveDriver = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const driver = await adminService.approveDriver(req.params.id);
    sendSuccess(res, driver, 'تم الموافقة على السائق بنجاح');
  } catch (error) {
    next(error);
  }
};

export const rejectDriver = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { reason } = req.body;
    const driver = await adminService.rejectDriver(req.params.id, reason);
    sendSuccess(res, driver, 'تم رفض السائق');
  } catch (error) {
    next(error);
  }
};

export const suspendDriver = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { reason } = req.body;
    const driver = await adminService.suspendDriver(req.params.id, reason);
    sendSuccess(res, driver, 'تم إيقاف السائق');
  } catch (error) {
    next(error);
  }
};

export const activateDriver = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const driver = await adminService.activateDriver(req.params.id);
    sendSuccess(res, driver, 'تم تفعيل السائق بنجاح');
  } catch (error) {
    next(error);
  }
};

// ==================== Zones ====================

export const getZones = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const zones = await adminService.getZones();
    sendSuccess(res, zones);
  } catch (error) {
    next(error);
  }
};

export const getZoneById = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const zone = await adminService.getZoneById(req.params.id);
    sendSuccess(res, zone);
  } catch (error) {
    next(error);
  }
};

export const createZone = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const zone = await adminService.createZone(req.body);
    sendCreated(res, zone, 'تم إنشاء المنطقة بنجاح');
  } catch (error) {
    next(error);
  }
};

export const updateZone = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const zone = await adminService.updateZone(req.params.id, req.body);
    sendSuccess(res, zone, 'تم تحديث المنطقة بنجاح');
  } catch (error) {
    next(error);
  }
};

export const deleteZone = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    await adminService.deleteZone(req.params.id);
    sendSuccess(res, null, 'تم حذف المنطقة بنجاح');
  } catch (error) {
    next(error);
  }
};

// ==================== Settings ====================

export const getSettings = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const settings = await adminService.getSettings();
    sendSuccess(res, settings);
  } catch (error) {
    next(error);
  }
};

export const updateSettings = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const settings = await adminService.updateSettings(req.body);
    sendSuccess(res, settings, 'تم تحديث الإعدادات بنجاح');
  } catch (error) {
    next(error);
  }
};

// ==================== Analytics ====================

export const getOrdersAnalytics = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const startDate = req.query.startDate ? new Date(req.query.startDate as string) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const endDate = req.query.endDate ? new Date(req.query.endDate as string) : new Date();

    const data = await adminService.getOrdersAnalytics(startDate, endDate);
    sendSuccess(res, data);
  } catch (error) {
    next(error);
  }
};

export const getPopularItems = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const limit = parseInt(req.query.limit as string) || 10;
    const data = await adminService.getPopularItems(limit);
    sendSuccess(res, data);
  } catch (error) {
    next(error);
  }
};

export const getCustomerStats = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const data = await adminService.getCustomerStats();
    sendSuccess(res, data);
  } catch (error) {
    next(error);
  }
};

export const getFinancialSummary = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const startDate = req.query.startDate ? new Date(req.query.startDate as string) : undefined;
    const endDate = req.query.endDate ? new Date(req.query.endDate as string) : undefined;

    const data = await adminService.getFinancialSummary(startDate, endDate);
    sendSuccess(res, data);
  } catch (error) {
    next(error);
  }
};
