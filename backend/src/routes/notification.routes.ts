import { Router } from 'express';
import { authenticate, authorize } from '@middleware/auth';
import { validate } from '@middleware/validate';
import {
  getMyNotifications,
  getUnreadCount,
  markNotificationAsRead,
  markAllNotificationsAsRead,
  deleteNotification,
  registerFcmToken,
  unregisterFcmToken,
  sendPromotionalNotification,
  sendSystemNotification,
  broadcastNotification,
} from '@controllers/notification.controller';
import {
  notificationsQuerySchema,
  fcmTokenSchema,
  promotionalNotificationSchema,
  systemNotificationSchema,
  broadcastNotificationSchema,
  notificationIdSchema,
} from '@validators/notification.validator';

const router = Router();

// ==================== User Notification Routes ====================
// All authenticated users can access their notifications

router.get(
  '/',
  authenticate,
  validate(notificationsQuerySchema, 'query'),
  getMyNotifications
);

router.get(
  '/unread-count',
  authenticate,
  getUnreadCount
);

router.put(
  '/:id/read',
  authenticate,
  validate(notificationIdSchema, 'params'),
  markNotificationAsRead
);

router.put(
  '/read-all',
  authenticate,
  markAllNotificationsAsRead
);

router.delete(
  '/:id',
  authenticate,
  validate(notificationIdSchema, 'params'),
  deleteNotification
);

// ==================== FCM Token Management ====================

router.post(
  '/fcm/register',
  authenticate,
  validate(fcmTokenSchema),
  registerFcmToken
);

router.post(
  '/fcm/unregister',
  authenticate,
  validate(fcmTokenSchema),
  unregisterFcmToken
);

// ==================== Admin Routes ====================

router.post(
  '/admin/promotional',
  authenticate,
  authorize('admin'),
  validate(promotionalNotificationSchema),
  sendPromotionalNotification
);

router.post(
  '/admin/system',
  authenticate,
  authorize('admin'),
  validate(systemNotificationSchema),
  sendSystemNotification
);

router.post(
  '/admin/broadcast',
  authenticate,
  authorize('admin'),
  validate(broadcastNotificationSchema),
  broadcastNotification
);

export default router;
