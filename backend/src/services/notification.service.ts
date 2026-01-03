import { Types } from 'mongoose';
import admin from 'firebase-admin';
import User from '@models/User';
import Notification, { INotification, NotificationType } from '@models/Notification';
import { getFirebaseMessaging } from '@config/firebase';
import { logger } from '@utils/logger';
import { NotFoundError } from '@utils/errors';

// Types
export interface CreateNotificationInput {
  userId: string;
  title: string;
  titleAr: string;
  body: string;
  bodyAr: string;
  type?: NotificationType;
  image?: string;
  data?: {
    orderId?: string;
    restaurantId?: string;
    action?: string;
    url?: string;
  };
}

export interface SendPushInput {
  tokens: string[];
  title: string;
  body: string;
  image?: string;
  data?: Record<string, string>;
}

export interface NotificationPayload {
  title: string;
  titleAr: string;
  body: string;
  bodyAr: string;
  type: NotificationType;
  data?: Record<string, string>;
}

class NotificationService {
  // ==================== Create & Send Notifications ====================

  async createNotification(input: CreateNotificationInput): Promise<INotification> {
    const notification = new Notification({
      userId: new Types.ObjectId(input.userId),
      title: input.title,
      titleAr: input.titleAr,
      body: input.body,
      bodyAr: input.bodyAr,
      type: input.type || 'system',
      image: input.image,
      data: input.data ? {
        orderId: input.data.orderId ? new Types.ObjectId(input.data.orderId) : undefined,
        restaurantId: input.data.restaurantId ? new Types.ObjectId(input.data.restaurantId) : undefined,
        action: input.data.action,
        url: input.data.url,
      } : undefined,
    });

    await notification.save();
    return notification;
  }

  async createAndSendNotification(input: CreateNotificationInput): Promise<INotification> {
    // Create notification in database
    const notification = await this.createNotification(input);

    // Get user's FCM tokens
    const user = await User.findById(input.userId).select('fcmTokens');
    if (user && user.fcmTokens && user.fcmTokens.length > 0) {
      // Send push notification
      const success = await this.sendPushNotification({
        tokens: user.fcmTokens,
        title: input.titleAr, // Use Arabic by default
        body: input.bodyAr,
        image: input.image,
        data: {
          notificationId: notification._id.toString(),
          type: input.type || 'system',
          ...(input.data?.orderId && { orderId: input.data.orderId }),
          ...(input.data?.restaurantId && { restaurantId: input.data.restaurantId }),
          ...(input.data?.action && { action: input.data.action }),
        },
      });

      if (success) {
        notification.isSent = true;
        notification.sentAt = new Date();
        await notification.save();
      }
    }

    return notification;
  }

  async sendPushNotification(input: SendPushInput): Promise<boolean> {
    const messaging = getFirebaseMessaging();
    if (!messaging) {
      logger.warn('Firebase messaging not available');
      return false;
    }

    if (input.tokens.length === 0) {
      logger.warn('No FCM tokens provided');
      return false;
    }

    try {
      const message: admin.messaging.MulticastMessage = {
        tokens: input.tokens,
        notification: {
          title: input.title,
          body: input.body,
          imageUrl: input.image,
        },
        data: input.data,
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await messaging.sendEachForMulticast(message);

      logger.info(`FCM: ${response.successCount} sent, ${response.failureCount} failed`);

      // Remove invalid tokens
      if (response.failureCount > 0) {
        const invalidTokens: string[] = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            const error = resp.error;
            if (
              error?.code === 'messaging/invalid-registration-token' ||
              error?.code === 'messaging/registration-token-not-registered'
            ) {
              invalidTokens.push(input.tokens[idx]);
            }
          }
        });

        if (invalidTokens.length > 0) {
          await this.removeInvalidTokens(invalidTokens);
        }
      }

      return response.successCount > 0;
    } catch (error) {
      logger.error(`FCM send error: ${error}`);
      return false;
    }
  }

  async removeInvalidTokens(tokens: string[]): Promise<void> {
    try {
      await User.updateMany(
        { fcmTokens: { $in: tokens } },
        { $pull: { fcmTokens: { $in: tokens } } }
      );
      logger.info(`Removed ${tokens.length} invalid FCM tokens`);
    } catch (error) {
      logger.error(`Error removing invalid tokens: ${error}`);
    }
  }

  // ==================== Notification Management ====================

  async getUserNotifications(
    userId: string,
    options: { page?: number; limit?: number; unreadOnly?: boolean }
  ): Promise<{ data: INotification[]; total: number; unreadCount: number }> {
    const { page = 1, limit = 20, unreadOnly = false } = options;

    const query: Record<string, unknown> = { userId: new Types.ObjectId(userId) };
    if (unreadOnly) {
      query.isRead = false;
    }

    const skip = (page - 1) * limit;

    const [data, total, unreadCount] = await Promise.all([
      Notification.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      Notification.countDocuments(query),
      Notification.countDocuments({ userId: new Types.ObjectId(userId), isRead: false }),
    ]);

    return { data, total, unreadCount };
  }

  async markAsRead(notificationId: string, userId: string): Promise<INotification> {
    const notification = await Notification.findOneAndUpdate(
      { _id: notificationId, userId: new Types.ObjectId(userId) },
      { isRead: true, readAt: new Date() },
      { new: true }
    );

    if (!notification) {
      throw new NotFoundError('الإشعار غير موجود');
    }

    return notification;
  }

  async markAllAsRead(userId: string): Promise<number> {
    const result = await Notification.updateMany(
      { userId: new Types.ObjectId(userId), isRead: false },
      { isRead: true, readAt: new Date() }
    );

    return result.modifiedCount;
  }

  async deleteNotification(notificationId: string, userId: string): Promise<void> {
    const result = await Notification.deleteOne({
      _id: notificationId,
      userId: new Types.ObjectId(userId),
    });

    if (result.deletedCount === 0) {
      throw new NotFoundError('الإشعار غير موجود');
    }
  }

  async getUnreadCount(userId: string): Promise<number> {
    return Notification.countDocuments({
      userId: new Types.ObjectId(userId),
      isRead: false,
    });
  }

  // ==================== Order Notifications ====================

  async sendOrderStatusNotification(
    userId: string,
    orderId: string,
    orderNumber: string,
    status: string
  ): Promise<void> {
    const statusMessages: Record<string, { title: string; titleAr: string; body: string; bodyAr: string }> = {
      confirmed: {
        title: 'Order Confirmed',
        titleAr: 'تم تأكيد الطلب',
        body: `Your order #${orderNumber} has been confirmed`,
        bodyAr: `تم تأكيد طلبك رقم #${orderNumber}`,
      },
      preparing: {
        title: 'Order Being Prepared',
        titleAr: 'جاري تحضير الطلب',
        body: `Your order #${orderNumber} is being prepared`,
        bodyAr: `جاري تحضير طلبك رقم #${orderNumber}`,
      },
      ready: {
        title: 'Order Ready',
        titleAr: 'الطلب جاهز',
        body: `Your order #${orderNumber} is ready for pickup`,
        bodyAr: `طلبك رقم #${orderNumber} جاهز للاستلام`,
      },
      picked_up: {
        title: 'Order Picked Up',
        titleAr: 'تم استلام الطلب',
        body: `Your order #${orderNumber} has been picked up by the driver`,
        bodyAr: `تم استلام طلبك رقم #${orderNumber} من قبل السائق`,
      },
      on_the_way: {
        title: 'Order On The Way',
        titleAr: 'الطلب في الطريق',
        body: `Your order #${orderNumber} is on the way`,
        bodyAr: `طلبك رقم #${orderNumber} في الطريق إليك`,
      },
      delivered: {
        title: 'Order Delivered',
        titleAr: 'تم التوصيل',
        body: `Your order #${orderNumber} has been delivered. Enjoy!`,
        bodyAr: `تم توصيل طلبك رقم #${orderNumber}. بالهناء والشفاء!`,
      },
      cancelled: {
        title: 'Order Cancelled',
        titleAr: 'تم إلغاء الطلب',
        body: `Your order #${orderNumber} has been cancelled`,
        bodyAr: `تم إلغاء طلبك رقم #${orderNumber}`,
      },
    };

    const message = statusMessages[status];
    if (!message) return;

    await this.createAndSendNotification({
      userId,
      ...message,
      type: 'order',
      data: { orderId, action: `order_${status}` },
    });
  }

  async sendNewOrderNotification(
    restaurantUserId: string,
    orderId: string,
    orderNumber: string
  ): Promise<void> {
    await this.createAndSendNotification({
      userId: restaurantUserId,
      title: 'New Order',
      titleAr: 'طلب جديد',
      body: `You have a new order #${orderNumber}`,
      bodyAr: `لديك طلب جديد رقم #${orderNumber}`,
      type: 'order',
      data: { orderId, action: 'new_order' },
    });
  }

  async sendOrderAssignedNotification(
    driverUserId: string,
    orderId: string,
    orderNumber: string,
    restaurantName: string
  ): Promise<void> {
    await this.createAndSendNotification({
      userId: driverUserId,
      title: 'New Delivery',
      titleAr: 'توصيل جديد',
      body: `New delivery order #${orderNumber} from ${restaurantName}`,
      bodyAr: `طلب توصيل جديد رقم #${orderNumber} من ${restaurantName}`,
      type: 'order',
      data: { orderId, action: 'order_assigned' },
    });
  }

  // ==================== Promotional Notifications ====================

  async sendPromotionalNotification(
    userIds: string[],
    title: string,
    titleAr: string,
    body: string,
    bodyAr: string,
    image?: string,
    data?: { restaurantId?: string; action?: string; url?: string }
  ): Promise<number> {
    let sentCount = 0;

    // Process in batches of 500
    const batchSize = 500;
    for (let i = 0; i < userIds.length; i += batchSize) {
      const batch = userIds.slice(i, i + batchSize);

      const users = await User.find({ _id: { $in: batch } }).select('fcmTokens');
      const allTokens: string[] = [];

      for (const user of users) {
        if (user.fcmTokens && user.fcmTokens.length > 0) {
          allTokens.push(...user.fcmTokens);
        }

        // Create notification record
        await this.createNotification({
          userId: user._id.toString(),
          title,
          titleAr,
          body,
          bodyAr,
          type: 'promotion',
          image,
          data,
        });
      }

      // Send push notifications
      if (allTokens.length > 0) {
        const success = await this.sendPushNotification({
          tokens: allTokens,
          title: titleAr,
          body: bodyAr,
          image,
          data: data ? {
            type: 'promotion',
            ...(data.restaurantId && { restaurantId: data.restaurantId }),
            ...(data.action && { action: data.action }),
            ...(data.url && { url: data.url }),
          } : undefined,
        });

        if (success) {
          sentCount += batch.length;
        }
      }
    }

    return sentCount;
  }

  // ==================== System Notifications ====================

  async sendSystemNotification(
    userId: string,
    title: string,
    titleAr: string,
    body: string,
    bodyAr: string
  ): Promise<void> {
    await this.createAndSendNotification({
      userId,
      title,
      titleAr,
      body,
      bodyAr,
      type: 'system',
    });
  }

  async sendWelcomeNotification(userId: string, userName: string): Promise<void> {
    await this.createAndSendNotification({
      userId,
      title: 'Welcome to Bagour Delivery!',
      titleAr: 'مرحباً بك في باجور ديليفري!',
      body: `Hello ${userName}! We're excited to have you. Start ordering now!`,
      bodyAr: `مرحباً ${userName}! نحن سعداء بانضمامك. ابدأ الطلب الآن!`,
      type: 'system',
    });
  }

  async sendDriverApprovalNotification(userId: string, approved: boolean): Promise<void> {
    if (approved) {
      await this.createAndSendNotification({
        userId,
        title: 'Account Approved',
        titleAr: 'تم قبول حسابك',
        body: 'Congratulations! Your driver account has been approved. You can now start accepting deliveries.',
        bodyAr: 'تهانينا! تم قبول حسابك كسائق. يمكنك الآن البدء في قبول التوصيلات.',
        type: 'system',
      });
    } else {
      await this.createAndSendNotification({
        userId,
        title: 'Account Rejected',
        titleAr: 'تم رفض حسابك',
        body: 'Unfortunately, your driver account application was not approved. Please contact support for more information.',
        bodyAr: 'للأسف، لم يتم قبول طلب تسجيلك كسائق. يرجى التواصل مع الدعم لمزيد من المعلومات.',
        type: 'system',
      });
    }
  }

  async sendRestaurantApprovalNotification(userId: string, restaurantName: string, approved: boolean): Promise<void> {
    if (approved) {
      await this.createAndSendNotification({
        userId,
        title: 'Restaurant Approved',
        titleAr: 'تم قبول المطعم',
        body: `Congratulations! ${restaurantName} has been approved. You can now receive orders.`,
        bodyAr: `تهانينا! تم قبول ${restaurantName}. يمكنك الآن استقبال الطلبات.`,
        type: 'system',
      });
    } else {
      await this.createAndSendNotification({
        userId,
        title: 'Restaurant Rejected',
        titleAr: 'تم رفض المطعم',
        body: `Unfortunately, ${restaurantName} was not approved. Please contact support for more information.`,
        bodyAr: `للأسف، لم يتم قبول ${restaurantName}. يرجى التواصل مع الدعم لمزيد من المعلومات.`,
        type: 'system',
      });
    }
  }
}

export const notificationService = new NotificationService();
