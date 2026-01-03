import Joi from 'joi';

// Common patterns
const phonePattern = /^01[0125][0-9]{8}$/;
const timePattern = /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/;

// ========== Restaurant Profile ==========

export const updateProfileSchema = Joi.object({
  name: Joi.string().min(2).max(100).messages({
    'string.min': 'اسم المطعم يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم المطعم لا يمكن أن يتجاوز 100 حرف',
  }),
  nameAr: Joi.string().min(2).max(100).messages({
    'string.min': 'اسم المطعم بالعربية يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم المطعم بالعربية لا يمكن أن يتجاوز 100 حرف',
  }),
  description: Joi.string().max(500).allow('').messages({
    'string.max': 'الوصف لا يمكن أن يتجاوز 500 حرف',
  }),
  descriptionAr: Joi.string().max(500).allow('').messages({
    'string.max': 'الوصف بالعربية لا يمكن أن يتجاوز 500 حرف',
  }),
  phone: Joi.string().pattern(phonePattern).messages({
    'string.pattern.base': 'رقم الهاتف غير صالح',
  }),
  whatsapp: Joi.string().pattern(phonePattern).allow('').messages({
    'string.pattern.base': 'رقم الواتساب غير صالح',
  }),
  address: Joi.string().min(5).max(200).messages({
    'string.min': 'العنوان يجب أن يكون 5 أحرف على الأقل',
    'string.max': 'العنوان لا يمكن أن يتجاوز 200 حرف',
  }),
  area: Joi.string().min(2).max(50).messages({
    'string.min': 'المنطقة يجب أن تكون حرفين على الأقل',
    'string.max': 'المنطقة لا يمكن أن تتجاوز 50 حرف',
  }),
  categories: Joi.array().items(Joi.string()).max(10).messages({
    'array.max': 'لا يمكن إضافة أكثر من 10 تصنيفات',
  }),
  tags: Joi.array().items(Joi.string()).max(20).messages({
    'array.max': 'لا يمكن إضافة أكثر من 20 وسم',
  }),
  priceRange: Joi.number().valid(1, 2, 3).messages({
    'any.only': 'نطاق السعر غير صالح',
  }),
});

export const updateLocationSchema = Joi.object({
  address: Joi.string().min(5).max(200).required().messages({
    'string.empty': 'العنوان مطلوب',
    'string.min': 'العنوان يجب أن يكون 5 أحرف على الأقل',
    'any.required': 'العنوان مطلوب',
  }),
  area: Joi.string().min(2).max(50).required().messages({
    'string.empty': 'المنطقة مطلوبة',
    'any.required': 'المنطقة مطلوبة',
  }),
  coordinates: Joi.object({
    lat: Joi.number().min(-90).max(90).required().messages({
      'number.min': 'خط العرض غير صالح',
      'number.max': 'خط العرض غير صالح',
      'any.required': 'خط العرض مطلوب',
    }),
    lng: Joi.number().min(-180).max(180).required().messages({
      'number.min': 'خط الطول غير صالح',
      'number.max': 'خط الطول غير صالح',
      'any.required': 'خط الطول مطلوب',
    }),
  }).required().messages({
    'any.required': 'الإحداثيات مطلوبة',
  }),
});

// ========== Working Hours ==========

const shiftSchema = Joi.object({
  open: Joi.string().pattern(timePattern).required().messages({
    'string.pattern.base': 'وقت الفتح غير صالح (صيغة HH:MM)',
    'any.required': 'وقت الفتح مطلوب',
  }),
  close: Joi.string().pattern(timePattern).required().messages({
    'string.pattern.base': 'وقت الإغلاق غير صالح (صيغة HH:MM)',
    'any.required': 'وقت الإغلاق مطلوب',
  }),
});

const dayHoursSchema = Joi.object({
  day: Joi.number().min(0).max(6).required().messages({
    'number.min': 'اليوم غير صالح',
    'number.max': 'اليوم غير صالح',
    'any.required': 'اليوم مطلوب',
  }),
  isOpen: Joi.boolean().required().messages({
    'any.required': 'حالة اليوم مطلوبة',
  }),
  shifts: Joi.array().items(shiftSchema).when('isOpen', {
    is: true,
    then: Joi.array().min(1).required().messages({
      'array.min': 'يجب إضافة فترة عمل واحدة على الأقل',
    }),
    otherwise: Joi.array().optional(),
  }),
});

export const updateWorkingHoursSchema = Joi.object({
  workingHours: Joi.array().items(dayHoursSchema).length(7).required().messages({
    'array.length': 'يجب تحديد ساعات العمل لجميع أيام الأسبوع',
    'any.required': 'ساعات العمل مطلوبة',
  }),
});

// ========== Delivery Settings ==========

export const updateDeliverySettingsSchema = Joi.object({
  minimumOrder: Joi.number().min(0).messages({
    'number.min': 'الحد الأدنى للطلب لا يمكن أن يكون سالباً',
  }),
  deliveryFee: Joi.number().min(0).messages({
    'number.min': 'رسوم التوصيل لا يمكن أن تكون سالبة',
  }),
  freeDeliveryAbove: Joi.number().min(0).allow(null).messages({
    'number.min': 'حد التوصيل المجاني لا يمكن أن يكون سالباً',
  }),
  estimatedDeliveryTime: Joi.object({
    min: Joi.number().min(5).max(120).required().messages({
      'number.min': 'الحد الأدنى لوقت التوصيل 5 دقائق',
      'number.max': 'الحد الأقصى لوقت التوصيل 120 دقيقة',
    }),
    max: Joi.number().min(10).max(180).required().messages({
      'number.min': 'الحد الأدنى لوقت التوصيل 10 دقائق',
      'number.max': 'الحد الأقصى لوقت التوصيل 180 دقيقة',
    }),
  }),
  acceptsCash: Joi.boolean(),
  acceptsOnlinePayment: Joi.boolean(),
  autoAcceptOrders: Joi.boolean(),
});

// ========== Toggle Status ==========

export const togglePauseSchema = Joi.object({
  isPaused: Joi.boolean().required().messages({
    'any.required': 'حالة الإيقاف مطلوبة',
  }),
  pauseReason: Joi.string().max(200).when('isPaused', {
    is: true,
    then: Joi.string().optional(),
    otherwise: Joi.forbidden(),
  }),
});

// ========== Menu Categories ==========

export const createCategorySchema = Joi.object({
  name: Joi.string().min(2).max(50).required().messages({
    'string.empty': 'اسم القسم مطلوب',
    'string.min': 'اسم القسم يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم القسم لا يمكن أن يتجاوز 50 حرف',
    'any.required': 'اسم القسم مطلوب',
  }),
  nameAr: Joi.string().min(2).max(50).required().messages({
    'string.empty': 'اسم القسم بالعربية مطلوب',
    'string.min': 'اسم القسم بالعربية يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم القسم بالعربية لا يمكن أن يتجاوز 50 حرف',
    'any.required': 'اسم القسم بالعربية مطلوب',
  }),
  description: Joi.string().max(200).allow('').messages({
    'string.max': 'الوصف لا يمكن أن يتجاوز 200 حرف',
  }),
  descriptionAr: Joi.string().max(200).allow('').messages({
    'string.max': 'الوصف بالعربية لا يمكن أن يتجاوز 200 حرف',
  }),
  sortOrder: Joi.number().min(0).default(0),
  isActive: Joi.boolean().default(true),
});

export const updateCategorySchema = Joi.object({
  name: Joi.string().min(2).max(50).messages({
    'string.min': 'اسم القسم يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم القسم لا يمكن أن يتجاوز 50 حرف',
  }),
  nameAr: Joi.string().min(2).max(50).messages({
    'string.min': 'اسم القسم بالعربية يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم القسم بالعربية لا يمكن أن يتجاوز 50 حرف',
  }),
  description: Joi.string().max(200).allow('').messages({
    'string.max': 'الوصف لا يمكن أن يتجاوز 200 حرف',
  }),
  descriptionAr: Joi.string().max(200).allow('').messages({
    'string.max': 'الوصف بالعربية لا يمكن أن يتجاوز 200 حرف',
  }),
  sortOrder: Joi.number().min(0),
  isActive: Joi.boolean(),
});

export const reorderCategoriesSchema = Joi.object({
  categories: Joi.array().items(
    Joi.object({
      id: Joi.string().required(),
      sortOrder: Joi.number().min(0).required(),
    })
  ).min(1).required().messages({
    'array.min': 'يجب تحديد قسم واحد على الأقل',
    'any.required': 'الأقسام مطلوبة',
  }),
});

// ========== Menu Items ==========

const addonSchema = Joi.object({
  name: Joi.string().min(2).max(50).required().messages({
    'string.empty': 'اسم الإضافة مطلوب',
    'string.min': 'اسم الإضافة يجب أن يكون حرفين على الأقل',
    'any.required': 'اسم الإضافة مطلوب',
  }),
  nameAr: Joi.string().min(2).max(50).required().messages({
    'string.empty': 'اسم الإضافة بالعربية مطلوب',
    'any.required': 'اسم الإضافة بالعربية مطلوب',
  }),
  price: Joi.number().min(0).required().messages({
    'number.min': 'سعر الإضافة لا يمكن أن يكون سالباً',
    'any.required': 'سعر الإضافة مطلوب',
  }),
  isAvailable: Joi.boolean().default(true),
  maxQuantity: Joi.number().min(1).max(10).default(5),
});

const variationOptionSchema = Joi.object({
  name: Joi.string().min(1).max(50).required().messages({
    'string.empty': 'اسم الخيار مطلوب',
    'any.required': 'اسم الخيار مطلوب',
  }),
  nameAr: Joi.string().min(1).max(50).required().messages({
    'string.empty': 'اسم الخيار بالعربية مطلوب',
    'any.required': 'اسم الخيار بالعربية مطلوب',
  }),
  price: Joi.number().min(0).default(0),
});

const variationSchema = Joi.object({
  name: Joi.string().min(2).max(50).required().messages({
    'string.empty': 'اسم الاختيار مطلوب',
    'any.required': 'اسم الاختيار مطلوب',
  }),
  nameAr: Joi.string().min(2).max(50).required().messages({
    'string.empty': 'اسم الاختيار بالعربية مطلوب',
    'any.required': 'اسم الاختيار بالعربية مطلوب',
  }),
  isRequired: Joi.boolean().default(false),
  options: Joi.array().items(variationOptionSchema).min(2).required().messages({
    'array.min': 'يجب إضافة خيارين على الأقل',
    'any.required': 'الخيارات مطلوبة',
  }),
});

export const createMenuItemSchema = Joi.object({
  categoryId: Joi.string().required().messages({
    'string.empty': 'القسم مطلوب',
    'any.required': 'القسم مطلوب',
  }),
  name: Joi.string().min(2).max(100).required().messages({
    'string.empty': 'اسم الصنف مطلوب',
    'string.min': 'اسم الصنف يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم الصنف لا يمكن أن يتجاوز 100 حرف',
    'any.required': 'اسم الصنف مطلوب',
  }),
  nameAr: Joi.string().min(2).max(100).required().messages({
    'string.empty': 'اسم الصنف بالعربية مطلوب',
    'string.min': 'اسم الصنف بالعربية يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم الصنف بالعربية لا يمكن أن يتجاوز 100 حرف',
    'any.required': 'اسم الصنف بالعربية مطلوب',
  }),
  description: Joi.string().max(500).allow('').messages({
    'string.max': 'الوصف لا يمكن أن يتجاوز 500 حرف',
  }),
  descriptionAr: Joi.string().max(500).allow('').messages({
    'string.max': 'الوصف بالعربية لا يمكن أن يتجاوز 500 حرف',
  }),
  price: Joi.number().min(0).required().messages({
    'number.min': 'السعر لا يمكن أن يكون سالباً',
    'any.required': 'السعر مطلوب',
  }),
  discountPrice: Joi.number().min(0).allow(null).messages({
    'number.min': 'سعر الخصم لا يمكن أن يكون سالباً',
  }),
  discountEndsAt: Joi.date().allow(null),
  preparationTime: Joi.number().min(0).max(120).messages({
    'number.min': 'وقت التحضير لا يمكن أن يكون سالباً',
    'number.max': 'وقت التحضير لا يمكن أن يتجاوز 120 دقيقة',
  }),
  calories: Joi.number().min(0).messages({
    'number.min': 'السعرات الحرارية لا يمكن أن تكون سالبة',
  }),
  servingSize: Joi.string().max(50).allow(''),
  addons: Joi.array().items(addonSchema).max(20).default([]).messages({
    'array.max': 'لا يمكن إضافة أكثر من 20 إضافة',
  }),
  variations: Joi.array().items(variationSchema).max(10).default([]).messages({
    'array.max': 'لا يمكن إضافة أكثر من 10 اختيارات',
  }),
  tags: Joi.array().items(Joi.string()).max(10).default([]).messages({
    'array.max': 'لا يمكن إضافة أكثر من 10 وسوم',
  }),
  isAvailable: Joi.boolean().default(true),
  isPopular: Joi.boolean().default(false),
  sortOrder: Joi.number().min(0).default(0),
});

export const updateMenuItemSchema = Joi.object({
  categoryId: Joi.string(),
  name: Joi.string().min(2).max(100).messages({
    'string.min': 'اسم الصنف يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم الصنف لا يمكن أن يتجاوز 100 حرف',
  }),
  nameAr: Joi.string().min(2).max(100).messages({
    'string.min': 'اسم الصنف بالعربية يجب أن يكون حرفين على الأقل',
    'string.max': 'اسم الصنف بالعربية لا يمكن أن يتجاوز 100 حرف',
  }),
  description: Joi.string().max(500).allow(''),
  descriptionAr: Joi.string().max(500).allow(''),
  price: Joi.number().min(0).messages({
    'number.min': 'السعر لا يمكن أن يكون سالباً',
  }),
  discountPrice: Joi.number().min(0).allow(null),
  discountEndsAt: Joi.date().allow(null),
  preparationTime: Joi.number().min(0).max(120),
  calories: Joi.number().min(0),
  servingSize: Joi.string().max(50).allow(''),
  addons: Joi.array().items(addonSchema).max(20),
  variations: Joi.array().items(variationSchema).max(10),
  tags: Joi.array().items(Joi.string()).max(10),
  isAvailable: Joi.boolean(),
  isPopular: Joi.boolean(),
  sortOrder: Joi.number().min(0),
});

export const toggleItemAvailabilitySchema = Joi.object({
  isAvailable: Joi.boolean().required().messages({
    'any.required': 'حالة التوفر مطلوبة',
  }),
});

export const bulkUpdateItemsSchema = Joi.object({
  items: Joi.array().items(
    Joi.object({
      id: Joi.string().required(),
      isAvailable: Joi.boolean(),
      sortOrder: Joi.number().min(0),
    })
  ).min(1).required().messages({
    'array.min': 'يجب تحديد صنف واحد على الأقل',
    'any.required': 'الأصناف مطلوبة',
  }),
});

// ========== Public Restaurant Queries ==========

export const searchRestaurantsSchema = Joi.object({
  q: Joi.string().max(100),
  category: Joi.string(),
  area: Joi.string(),
  priceRange: Joi.number().valid(1, 2, 3),
  isOpen: Joi.boolean(),
  sortBy: Joi.string().valid('rating', 'distance', 'deliveryTime', 'minimumOrder'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc'),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(50).default(20),
  lat: Joi.number().min(-90).max(90),
  lng: Joi.number().min(-180).max(180),
  maxDistance: Joi.number().min(0).max(50).default(10), // km
});

export const getRestaurantMenuSchema = Joi.object({
  categoryId: Joi.string(),
  isAvailable: Joi.boolean(),
  search: Joi.string().max(50),
});
