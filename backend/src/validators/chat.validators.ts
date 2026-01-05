import Joi from 'joi';

// Chat type enum
const chatTypes = ['customer_restaurant', 'customer_driver', 'restaurant_driver'];
const messageTypes = ['text', 'image', 'location'];

// Get or create chat schema
export const getOrCreateChatSchema = Joi.object({
  query: Joi.object({
    chatType: Joi.string()
      .valid(...chatTypes)
      .required()
      .messages({
        'any.required': 'نوع المحادثة مطلوب',
        'any.only': 'نوع المحادثة غير صحيح',
      }),
  }),
  params: Joi.object({
    orderId: Joi.string()
      .pattern(/^[0-9a-fA-F]{24}$/)
      .required()
      .messages({
        'string.pattern.base': 'معرف الطلب غير صحيح',
        'any.required': 'معرف الطلب مطلوب',
      }),
  }),
});

// Send message schema
export const sendMessageSchema = Joi.object({
  body: Joi.object({
    content: Joi.string()
      .required()
      .max(1000)
      .messages({
        'any.required': 'محتوى الرسالة مطلوب',
        'string.max': 'الرسالة طويلة جداً (الحد الأقصى 1000 حرف)',
      }),
    type: Joi.string()
      .valid(...messageTypes)
      .default('text')
      .messages({
        'any.only': 'نوع الرسالة غير صحيح',
      }),
    imageUrl: Joi.string()
      .uri()
      .when('type', {
        is: 'image',
        then: Joi.required(),
        otherwise: Joi.optional(),
      })
      .messages({
        'string.uri': 'رابط الصورة غير صحيح',
        'any.required': 'رابط الصورة مطلوب لرسائل الصور',
      }),
    location: Joi.object({
      lat: Joi.number().required().min(-90).max(90),
      lng: Joi.number().required().min(-180).max(180),
    })
      .when('type', {
        is: 'location',
        then: Joi.required(),
        otherwise: Joi.optional(),
      })
      .messages({
        'any.required': 'الموقع مطلوب لرسائل الموقع',
      }),
  }),
  params: Joi.object({
    chatId: Joi.string()
      .pattern(/^[0-9a-fA-F]{24}$/)
      .required()
      .messages({
        'string.pattern.base': 'معرف المحادثة غير صحيح',
        'any.required': 'معرف المحادثة مطلوب',
      }),
  }),
});

// Get messages schema
export const getMessagesSchema = Joi.object({
  query: Joi.object({
    page: Joi.number().integer().min(1).default(1),
    limit: Joi.number().integer().min(1).max(100).default(50),
  }),
  params: Joi.object({
    chatId: Joi.string()
      .pattern(/^[0-9a-fA-F]{24}$/)
      .required()
      .messages({
        'string.pattern.base': 'معرف المحادثة غير صحيح',
        'any.required': 'معرف المحادثة مطلوب',
      }),
  }),
});

// Chat ID param schema
export const chatIdSchema = Joi.object({
  params: Joi.object({
    chatId: Joi.string()
      .pattern(/^[0-9a-fA-F]{24}$/)
      .required()
      .messages({
        'string.pattern.base': 'معرف المحادثة غير صحيح',
        'any.required': 'معرف المحادثة مطلوب',
      }),
  }),
});

// Order ID param schema with chat type query
export const orderChatSchema = Joi.object({
  query: Joi.object({
    chatType: Joi.string()
      .valid(...chatTypes)
      .required()
      .messages({
        'any.required': 'نوع المحادثة مطلوب',
        'any.only': 'نوع المحادثة غير صحيح',
      }),
  }),
  params: Joi.object({
    orderId: Joi.string()
      .pattern(/^[0-9a-fA-F]{24}$/)
      .required()
      .messages({
        'string.pattern.base': 'معرف الطلب غير صحيح',
        'any.required': 'معرف الطلب مطلوب',
      }),
  }),
});

// Pagination schema for chats list
export const chatsListSchema = Joi.object({
  query: Joi.object({
    page: Joi.number().integer().min(1).default(1),
    limit: Joi.number().integer().min(1).max(50).default(20),
  }),
});

export default {
  getOrCreateChatSchema,
  sendMessageSchema,
  getMessagesSchema,
  chatIdSchema,
  orderChatSchema,
  chatsListSchema,
};
