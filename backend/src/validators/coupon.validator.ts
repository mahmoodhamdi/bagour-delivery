import Joi from 'joi';

// ==================== Coupon Creation ====================

// Create coupon schema
export const createCouponSchema = Joi.object({
  code: Joi.string().min(3).max(50).required().messages({
    'string.empty': 'كود الخصم مطلوب',
    'string.min': 'كود الخصم يجب أن يكون 3 أحرف على الأقل',
    'string.max': 'كود الخصم لا يمكن أن يتجاوز 50 حرف',
    'any.required': 'كود الخصم مطلوب',
  }),
  type: Joi.string().valid('percentage', 'fixed').required().messages({
    'any.only': 'نوع الخصم يجب أن يكون نسبة مئوية أو مبلغ ثابت',
    'any.required': 'نوع الخصم مطلوب',
  }),
  value: Joi.number().positive().required().messages({
    'number.base': 'قيمة الخصم يجب أن تكون رقماً',
    'number.positive': 'قيمة الخصم يجب أن تكون موجبة',
    'any.required': 'قيمة الخصم مطلوبة',
  }),
  minimumOrder: Joi.number().min(0).optional().messages({
    'number.base': 'الحد الأدنى للطلب يجب أن يكون رقماً',
    'number.min': 'الحد الأدنى للطلب لا يمكن أن يكون سالباً',
  }),
  maximumDiscount: Joi.number().positive().optional().messages({
    'number.base': 'الحد الأقصى للخصم يجب أن يكون رقماً',
    'number.positive': 'الحد الأقصى للخصم يجب أن يكون موجباً',
  }),
  totalUsageLimit: Joi.number().integer().positive().optional().messages({
    'number.base': 'حد الاستخدام الكلي يجب أن يكون رقماً',
    'number.integer': 'حد الاستخدام الكلي يجب أن يكون عدداً صحيحاً',
    'number.positive': 'حد الاستخدام الكلي يجب أن يكون موجباً',
  }),
  perUserLimit: Joi.number().integer().positive().default(1).messages({
    'number.base': 'حد الاستخدام للمستخدم يجب أن يكون رقماً',
    'number.integer': 'حد الاستخدام للمستخدم يجب أن يكون عدداً صحيحاً',
    'number.positive': 'حد الاستخدام للمستخدم يجب أن يكون موجباً',
  }),
  validFrom: Joi.date().required().messages({
    'date.base': 'تاريخ البداية غير صالح',
    'any.required': 'تاريخ البداية مطلوب',
  }),
  validUntil: Joi.date().greater(Joi.ref('validFrom')).required().messages({
    'date.base': 'تاريخ الانتهاء غير صالح',
    'date.greater': 'تاريخ الانتهاء يجب أن يكون بعد تاريخ البداية',
    'any.required': 'تاريخ الانتهاء مطلوب',
  }),
  restaurantIds: Joi.array().items(Joi.string()).optional(),
  categoryIds: Joi.array().items(Joi.string()).optional(),
  customerIds: Joi.array().items(Joi.string()).optional(),
  firstOrderOnly: Joi.boolean().default(false),
  isActive: Joi.boolean().default(true),
});

// ==================== Coupon Update ====================

export const updateCouponSchema = Joi.object({
  type: Joi.string().valid('percentage', 'fixed').optional().messages({
    'any.only': 'نوع الخصم يجب أن يكون نسبة مئوية أو مبلغ ثابت',
  }),
  value: Joi.number().positive().optional().messages({
    'number.base': 'قيمة الخصم يجب أن تكون رقماً',
    'number.positive': 'قيمة الخصم يجب أن تكون موجبة',
  }),
  minimumOrder: Joi.number().min(0).optional().messages({
    'number.base': 'الحد الأدنى للطلب يجب أن يكون رقماً',
    'number.min': 'الحد الأدنى للطلب لا يمكن أن يكون سالباً',
  }),
  maximumDiscount: Joi.number().positive().allow(null).optional().messages({
    'number.base': 'الحد الأقصى للخصم يجب أن يكون رقماً',
    'number.positive': 'الحد الأقصى للخصم يجب أن يكون موجباً',
  }),
  totalUsageLimit: Joi.number().integer().positive().allow(null).optional().messages({
    'number.base': 'حد الاستخدام الكلي يجب أن يكون رقماً',
    'number.integer': 'حد الاستخدام الكلي يجب أن يكون عدداً صحيحاً',
    'number.positive': 'حد الاستخدام الكلي يجب أن يكون موجباً',
  }),
  perUserLimit: Joi.number().integer().positive().optional().messages({
    'number.base': 'حد الاستخدام للمستخدم يجب أن يكون رقماً',
    'number.integer': 'حد الاستخدام للمستخدم يجب أن يكون عدداً صحيحاً',
    'number.positive': 'حد الاستخدام للمستخدم يجب أن يكون موجباً',
  }),
  validFrom: Joi.date().optional().messages({
    'date.base': 'تاريخ البداية غير صالح',
  }),
  validUntil: Joi.date().optional().messages({
    'date.base': 'تاريخ الانتهاء غير صالح',
  }),
  restaurantIds: Joi.array().items(Joi.string()).optional(),
  categoryIds: Joi.array().items(Joi.string()).optional(),
  customerIds: Joi.array().items(Joi.string()).optional(),
  firstOrderOnly: Joi.boolean().optional(),
  isActive: Joi.boolean().optional(),
}).min(1).messages({
  'object.min': 'يجب تقديم حقل واحد على الأقل للتحديث',
});

// ==================== Query Schemas ====================

// Get coupons query schema
export const getCouponsQuerySchema = Joi.object({
  isActive: Joi.boolean().optional(),
  type: Joi.string().valid('percentage', 'fixed').optional(),
  search: Joi.string().max(100).optional(),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  sortBy: Joi.string()
    .valid('createdAt', 'code', 'value', 'usedCount', 'validUntil')
    .default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc'),
});

// ==================== Validate Coupon ====================

export const validateCouponSchema = Joi.object({
  code: Joi.string().required().messages({
    'string.empty': 'كود الخصم مطلوب',
    'any.required': 'كود الخصم مطلوب',
  }),
  subtotal: Joi.number().positive().required().messages({
    'number.base': 'إجمالي الطلب يجب أن يكون رقماً',
    'number.positive': 'إجمالي الطلب يجب أن يكون موجباً',
    'any.required': 'إجمالي الطلب مطلوب',
  }),
  restaurantId: Joi.string().optional(),
});

// ==================== Bulk Creation ====================

export const createBulkCouponsSchema = Joi.object({
  count: Joi.number().integer().min(1).max(100).required().messages({
    'number.base': 'عدد الكوبونات يجب أن يكون رقماً',
    'number.integer': 'عدد الكوبونات يجب أن يكون عدداً صحيحاً',
    'number.min': 'يجب إنشاء كوبون واحد على الأقل',
    'number.max': 'لا يمكن إنشاء أكثر من 100 كوبون في المرة الواحدة',
    'any.required': 'عدد الكوبونات مطلوب',
  }),
  prefix: Joi.string().max(10).optional().messages({
    'string.max': 'البادئة لا يمكن أن تتجاوز 10 أحرف',
  }),
  type: Joi.string().valid('percentage', 'fixed').required().messages({
    'any.only': 'نوع الخصم يجب أن يكون نسبة مئوية أو مبلغ ثابت',
    'any.required': 'نوع الخصم مطلوب',
  }),
  value: Joi.number().positive().required().messages({
    'number.base': 'قيمة الخصم يجب أن تكون رقماً',
    'number.positive': 'قيمة الخصم يجب أن تكون موجبة',
    'any.required': 'قيمة الخصم مطلوبة',
  }),
  minimumOrder: Joi.number().min(0).optional(),
  maximumDiscount: Joi.number().positive().optional(),
  totalUsageLimit: Joi.number().integer().positive().optional(),
  perUserLimit: Joi.number().integer().positive().default(1),
  validFrom: Joi.date().required().messages({
    'any.required': 'تاريخ البداية مطلوب',
  }),
  validUntil: Joi.date().greater(Joi.ref('validFrom')).required().messages({
    'date.greater': 'تاريخ الانتهاء يجب أن يكون بعد تاريخ البداية',
    'any.required': 'تاريخ الانتهاء مطلوب',
  }),
  restaurantIds: Joi.array().items(Joi.string()).optional(),
  categoryIds: Joi.array().items(Joi.string()).optional(),
  customerIds: Joi.array().items(Joi.string()).optional(),
  firstOrderOnly: Joi.boolean().default(false),
  isActive: Joi.boolean().default(true),
});
