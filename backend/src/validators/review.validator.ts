import Joi from 'joi';

export const reviewQuerySchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(50).default(10),
  minRating: Joi.number().integer().min(1).max(5),
  maxRating: Joi.number().integer().min(1).max(5),
  hasComment: Joi.boolean(),
  sortBy: Joi.string().valid('createdAt', 'restaurantRating', 'foodRating').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc'),
});

export const adminReviewQuerySchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  restaurantId: Joi.string().regex(/^[0-9a-fA-F]{24}$/),
  customerId: Joi.string().regex(/^[0-9a-fA-F]{24}$/),
  isVisible: Joi.boolean(),
  isReported: Joi.boolean(),
  minRating: Joi.number().integer().min(1).max(5),
  maxRating: Joi.number().integer().min(1).max(5),
  sortBy: Joi.string().valid('createdAt', 'restaurantRating', 'updatedAt').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc'),
});

export const replySchema = Joi.object({
  reply: Joi.string().min(1).max(300).required().messages({
    'string.empty': 'الرد مطلوب',
    'string.max': 'الرد يجب أن لا يتجاوز 300 حرف',
  }),
});

export const reportSchema = Joi.object({
  reason: Joi.string().min(10).max(500).required().messages({
    'string.empty': 'سبب البلاغ مطلوب',
    'string.min': 'سبب البلاغ يجب أن يكون 10 أحرف على الأقل',
    'string.max': 'سبب البلاغ يجب أن لا يتجاوز 500 حرف',
  }),
});

export const toggleVisibilitySchema = Joi.object({
  isVisible: Joi.boolean().required().messages({
    'boolean.base': 'قيمة الظهور يجب أن تكون صحيحة أو خاطئة',
  }),
});

export const resolveReportSchema = Joi.object({
  action: Joi.string().valid('dismiss', 'hide', 'delete').required().messages({
    'any.only': 'الإجراء يجب أن يكون: dismiss، hide، أو delete',
    'any.required': 'الإجراء مطلوب',
  }),
});
