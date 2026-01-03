import Joi from 'joi';

// Query schema for getting notifications
export const notificationsQuerySchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(50).default(20),
  unreadOnly: Joi.string().valid('true', 'false').default('false'),
});

// FCM token registration
export const fcmTokenSchema = Joi.object({
  token: Joi.string().required().messages({
    'string.empty': 'رمز الجهاز مطلوب',
    'any.required': 'رمز الجهاز مطلوب',
  }),
});

// Send promotional notification to specific users
export const promotionalNotificationSchema = Joi.object({
  userIds: Joi.array().items(Joi.string().hex().length(24)).min(1).required().messages({
    'array.min': 'يجب تحديد مستخدم واحد على الأقل',
    'any.required': 'قائمة المستخدمين مطلوبة',
  }),
  title: Joi.string().required().max(100).messages({
    'string.empty': 'العنوان بالإنجليزية مطلوب',
    'string.max': 'العنوان يجب أن لا يتجاوز 100 حرف',
  }),
  titleAr: Joi.string().required().max(100).messages({
    'string.empty': 'العنوان بالعربية مطلوب',
    'string.max': 'العنوان يجب أن لا يتجاوز 100 حرف',
  }),
  body: Joi.string().required().max(500).messages({
    'string.empty': 'نص الإشعار بالإنجليزية مطلوب',
    'string.max': 'نص الإشعار يجب أن لا يتجاوز 500 حرف',
  }),
  bodyAr: Joi.string().required().max(500).messages({
    'string.empty': 'نص الإشعار بالعربية مطلوب',
    'string.max': 'نص الإشعار يجب أن لا يتجاوز 500 حرف',
  }),
  image: Joi.string().uri().optional().messages({
    'string.uri': 'رابط الصورة غير صحيح',
  }),
  data: Joi.object({
    restaurantId: Joi.string().hex().length(24).optional(),
    action: Joi.string().optional(),
    url: Joi.string().uri().optional(),
  }).optional(),
});

// Send system notification to single user
export const systemNotificationSchema = Joi.object({
  userId: Joi.string().hex().length(24).required().messages({
    'string.hex': 'معرف المستخدم غير صحيح',
    'string.length': 'معرف المستخدم غير صحيح',
    'any.required': 'معرف المستخدم مطلوب',
  }),
  title: Joi.string().required().max(100).messages({
    'string.empty': 'العنوان بالإنجليزية مطلوب',
  }),
  titleAr: Joi.string().required().max(100).messages({
    'string.empty': 'العنوان بالعربية مطلوب',
  }),
  body: Joi.string().required().max(500).messages({
    'string.empty': 'نص الإشعار بالإنجليزية مطلوب',
  }),
  bodyAr: Joi.string().required().max(500).messages({
    'string.empty': 'نص الإشعار بالعربية مطلوب',
  }),
});

// Broadcast notification to all users or specific role
export const broadcastNotificationSchema = Joi.object({
  title: Joi.string().required().max(100).messages({
    'string.empty': 'العنوان بالإنجليزية مطلوب',
  }),
  titleAr: Joi.string().required().max(100).messages({
    'string.empty': 'العنوان بالعربية مطلوب',
  }),
  body: Joi.string().required().max(500).messages({
    'string.empty': 'نص الإشعار بالإنجليزية مطلوب',
  }),
  bodyAr: Joi.string().required().max(500).messages({
    'string.empty': 'نص الإشعار بالعربية مطلوب',
  }),
  image: Joi.string().uri().optional().messages({
    'string.uri': 'رابط الصورة غير صحيح',
  }),
  targetRole: Joi.string().valid('all', 'customer', 'driver', 'restaurant_owner').default('all').messages({
    'any.only': 'نوع المستخدم غير صحيح',
  }),
});

// Notification ID param
export const notificationIdSchema = Joi.object({
  id: Joi.string().hex().length(24).required().messages({
    'string.hex': 'معرف الإشعار غير صحيح',
    'string.length': 'معرف الإشعار غير صحيح',
    'any.required': 'معرف الإشعار مطلوب',
  }),
});
