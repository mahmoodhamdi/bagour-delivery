import { Response, NextFunction } from 'express';
import { AuthRequest } from '../types';
import { notificationService } from '@services/notification.service';
import { sendSuccess, sendCreated } from '@utils/response';
import User from '@models/User';

// ==================== User Notifications ====================

/**
 * Get current user's notifications
 * GET /api/v1/notifications
 */
export const getMyNotifications = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      sendSuccess(res, { data: [], unreadCount: 0, pagination: { total: 0, page: 1, limit: 20, pages: 0 } });
      return;
    }

    const { page, limit, unreadOnly } = req.query;

    const result = await notificationService.getUserNotifications(userId, {
      page: page ? parseInt(page as string) : 1,
      limit: limit ? parseInt(limit as string) : 20,
      unreadOnly: unreadOnly === 'true',
    });

    sendSuccess(res, {
      data: result.data,
      unreadCount: result.unreadCount,
      pagination: {
        total: result.total,
        page: page ? parseInt(page as string) : 1,
        limit: limit ? parseInt(limit as string) : 20,
        pages: Math.ceil(result.total / (limit ? parseInt(limit as string) : 20)),
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get unread notification count
 * GET /api/v1/notifications/unread-count
 */
export const getUnreadCount = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      sendSuccess(res, { count: 0 });
      return;
    }

    const count = await notificationService.getUnreadCount(userId);
    sendSuccess(res, { count });
  } catch (error) {
    next(error);
  }
};

/**
 * Mark a notification as read
 * PUT /api/v1/notifications/:id/read
 */
export const markNotificationAsRead = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      throw new Error('المستخدم غير موجود');
    }

    const { id } = req.params;
    const notification = await notificationService.markAsRead(id, userId);
    sendSuccess(res, notification, 'تم تحديث الإشعار');
  } catch (error) {
    next(error);
  }
};

/**
 * Mark all notifications as read
 * PUT /api/v1/notifications/read-all
 */
export const markAllNotificationsAsRead = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      sendSuccess(res, { markedCount: 0 });
      return;
    }

    const count = await notificationService.markAllAsRead(userId);
    sendSuccess(res, { markedCount: count }, 'تم تحديث جميع الإشعارات');
  } catch (error) {
    next(error);
  }
};

/**
 * Delete a notification
 * DELETE /api/v1/notifications/:id
 */
export const deleteNotification = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      throw new Error('المستخدم غير موجود');
    }

    const { id } = req.params;
    await notificationService.deleteNotification(id, userId);
    sendSuccess(res, null, 'تم حذف الإشعار');
  } catch (error) {
    next(error);
  }
};

// ==================== FCM Token Management ====================

/**
 * Register FCM token
 * POST /api/v1/notifications/fcm/register
 */
export const registerFcmToken = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      throw new Error('المستخدم غير موجود');
    }

    const { token } = req.body;

    await User.findByIdAndUpdate(userId, {
      $addToSet: { fcmTokens: token },
    });

    sendSuccess(res, null, 'تم تسجيل الجهاز بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Unregister FCM token
 * POST /api/v1/notifications/fcm/unregister
 */
export const unregisterFcmToken = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      throw new Error('المستخدم غير موجود');
    }

    const { token } = req.body;

    await User.findByIdAndUpdate(userId, {
      $pull: { fcmTokens: token },
    });

    sendSuccess(res, null, 'تم إلغاء تسجيل الجهاز');
  } catch (error) {
    next(error);
  }
};

// ==================== Admin: Send Notifications ====================

/**
 * Send promotional notification to specific users
 * POST /api/v1/notifications/admin/promotional
 */
export const sendPromotionalNotification = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { userIds, title, titleAr, body, bodyAr, image, data } = req.body;

    const sentCount = await notificationService.sendPromotionalNotification(
      userIds,
      title,
      titleAr,
      body,
      bodyAr,
      image,
      data
    );

    sendCreated(res, { sentCount }, `تم إرسال الإشعار إلى ${sentCount} مستخدم`);
  } catch (error) {
    next(error);
  }
};

/**
 * Send system notification to a single user
 * POST /api/v1/notifications/admin/system
 */
export const sendSystemNotification = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { userId, title, titleAr, body, bodyAr } = req.body;

    await notificationService.sendSystemNotification(userId, title, titleAr, body, bodyAr);
    sendCreated(res, null, 'تم إرسال الإشعار بنجاح');
  } catch (error) {
    next(error);
  }
};

/**
 * Broadcast notification to all users or specific role
 * POST /api/v1/notifications/admin/broadcast
 */
export const broadcastNotification = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { title, titleAr, body, bodyAr, image, targetRole } = req.body;

    // Build query based on target role
    const query: Record<string, unknown> = { isActive: true };
    if (targetRole && targetRole !== 'all') {
      query.role = targetRole;
    }

    const users = await User.find(query).select('_id');
    const userIds = users.map(u => u._id.toString());

    if (userIds.length === 0) {
      sendSuccess(res, { sentCount: 0 }, 'لا يوجد مستخدمين لإرسال الإشعار');
      return;
    }

    const sentCount = await notificationService.sendPromotionalNotification(
      userIds,
      title,
      titleAr,
      body,
      bodyAr,
      image
    );

    sendCreated(res, { sentCount, totalTargeted: userIds.length }, `تم إرسال الإشعار إلى ${sentCount} مستخدم`);
  } catch (error) {
    next(error);
  }
};
