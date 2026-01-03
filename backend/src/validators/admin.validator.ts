import Joi from 'joi';

// ==================== Query Schemas ====================

export const paginationQuerySchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  sortBy: Joi.string().valid('createdAt', 'name', 'email', 'status'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc'),
});

export const usersQuerySchema = paginationQuerySchema.keys({
  search: Joi.string().max(100),
  role: Joi.string().valid('customer', 'restaurant', 'driver', 'admin'),
  status: Joi.string().valid('active', 'blocked'),
});

export const restaurantsQuerySchema = paginationQuerySchema.keys({
  search: Joi.string().max(100),
  status: Joi.string().valid('pending', 'approved', 'rejected', 'suspended'),
});

export const driversQuerySchema = paginationQuerySchema.keys({
  search: Joi.string().max(100),
  status: Joi.string().valid('pending', 'approved', 'rejected', 'suspended'),
  isOnline: Joi.string().valid('true', 'false'),
});

export const analyticsQuerySchema = Joi.object({
  startDate: Joi.date().iso(),
  endDate: Joi.date().iso().min(Joi.ref('startDate')),
  days: Joi.number().integer().min(1).max(365).default(30),
  limit: Joi.number().integer().min(1).max(100).default(10),
});

// ==================== Body Schemas ====================

export const rejectReasonSchema = Joi.object({
  reason: Joi.string().required().min(5).max(500).messages({
    'string.empty': 'سبب الرفض مطلوب',
    'string.min': 'سبب الرفض يجب أن يكون 5 أحرف على الأقل',
    'string.max': 'سبب الرفض يجب ألا يتجاوز 500 حرف',
    'any.required': 'سبب الرفض مطلوب',
  }),
});

export const suspendReasonSchema = Joi.object({
  reason: Joi.string().required().min(5).max(500).messages({
    'string.empty': 'سبب الإيقاف مطلوب',
    'string.min': 'سبب الإيقاف يجب أن يكون 5 أحرف على الأقل',
    'string.max': 'سبب الإيقاف يجب ألا يتجاوز 500 حرف',
    'any.required': 'سبب الإيقاف مطلوب',
  }),
});

export const createZoneSchema = Joi.object({
  name: Joi.string().required().min(2).max(100).messages({
    'string.empty': 'اسم المنطقة مطلوب',
    'string.min': 'اسم المنطقة يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم المنطقة يجب ألا يتجاوز 100 حرف',
    'any.required': 'اسم المنطقة مطلوب',
  }),
  nameAr: Joi.string().required().min(2).max(100).messages({
    'string.empty': 'اسم المنطقة بالعربية مطلوب',
    'string.min': 'اسم المنطقة يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم المنطقة يجب ألا يتجاوز 100 حرف',
    'any.required': 'اسم المنطقة بالعربية مطلوب',
  }),
  deliveryFee: Joi.number().required().min(0).messages({
    'number.base': 'رسوم التوصيل يجب أن تكون رقماً',
    'number.min': 'رسوم التوصيل يجب ألا تكون سالبة',
    'any.required': 'رسوم التوصيل مطلوبة',
  }),
  minOrderAmount: Joi.number().required().min(0).messages({
    'number.base': 'الحد الأدنى للطلب يجب أن يكون رقماً',
    'number.min': 'الحد الأدنى للطلب يجب ألا يكون سالباً',
    'any.required': 'الحد الأدنى للطلب مطلوب',
  }),
  isActive: Joi.boolean().default(true),
  coordinates: Joi.object({
    type: Joi.string().valid('Polygon').required(),
    coordinates: Joi.array().items(
      Joi.array().items(
        Joi.array().length(2).items(Joi.number())
      )
    ),
  }),
});

export const updateZoneSchema = Joi.object({
  name: Joi.string().min(2).max(100),
  nameAr: Joi.string().min(2).max(100),
  deliveryFee: Joi.number().min(0),
  minOrderAmount: Joi.number().min(0),
  isActive: Joi.boolean(),
  coordinates: Joi.object({
    type: Joi.string().valid('Polygon'),
    coordinates: Joi.array().items(
      Joi.array().items(
        Joi.array().length(2).items(Joi.number())
      )
    ),
  }),
});

export const updateSettingsSchema = Joi.object({
  appName: Joi.string().max(100),
  appNameAr: Joi.string().max(100),
  supportEmail: Joi.string().email(),
  supportPhone: Joi.string().max(20),
  defaultDeliveryFee: Joi.number().min(0),
  minOrderAmount: Joi.number().min(0),
  platformFeePercentage: Joi.number().min(0).max(100),
  driverCommissionPercentage: Joi.number().min(0).max(100),
  maxDeliveryRadius: Joi.number().min(0),
  orderCancellationTimeout: Joi.number().min(0),
  maintenanceMode: Joi.boolean(),
  maintenanceMessage: Joi.string().max(500),
  socialLinks: Joi.object({
    facebook: Joi.string().uri().allow(''),
    twitter: Joi.string().uri().allow(''),
    instagram: Joi.string().uri().allow(''),
    whatsapp: Joi.string().allow(''),
  }),
  paymentSettings: Joi.object({
    cashOnDelivery: Joi.boolean(),
    onlinePayment: Joi.boolean(),
    walletPayment: Joi.boolean(),
  }),
  notificationSettings: Joi.object({
    emailNotifications: Joi.boolean(),
    pushNotifications: Joi.boolean(),
    smsNotifications: Joi.boolean(),
  }),
});
