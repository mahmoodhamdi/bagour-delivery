import Joi from 'joi';

// Phone pattern for Egyptian numbers
const phonePattern = /^01[0125][0-9]{8}$/;

// ==================== Order Creation ====================

// Order item schema
const orderItemSchema = Joi.object({
  menuItemId: Joi.string().required().messages({
    'string.empty': 'معرف الصنف مطلوب',
    'any.required': 'معرف الصنف مطلوب',
  }),
  quantity: Joi.number().integer().min(1).max(99).required().messages({
    'number.base': 'الكمية يجب أن تكون رقماً',
    'number.min': 'الكمية يجب أن تكون 1 على الأقل',
    'number.max': 'الكمية لا يمكن أن تتجاوز 99',
    'any.required': 'الكمية مطلوبة',
  }),
  selectedAddons: Joi.array()
    .items(
      Joi.object({
        addonId: Joi.string().required(),
        quantity: Joi.number().integer().min(1).max(10).default(1),
      })
    )
    .optional(),
  selectedVariations: Joi.array()
    .items(
      Joi.object({
        variationId: Joi.string().required(),
        optionId: Joi.string().required(),
      })
    )
    .optional(),
  specialInstructions: Joi.string().max(500).allow('').optional(),
});

// Delivery address schema
const deliveryAddressSchema = Joi.object({
  name: Joi.string().max(100).required().messages({
    'string.empty': 'اسم العنوان مطلوب',
    'any.required': 'اسم العنوان مطلوب',
  }),
  address: Joi.string().max(500).required().messages({
    'string.empty': 'العنوان مطلوب',
    'any.required': 'العنوان مطلوب',
  }),
  area: Joi.string().max(100).required().messages({
    'string.empty': 'المنطقة مطلوبة',
    'any.required': 'المنطقة مطلوبة',
  }),
  building: Joi.string().max(50).allow('').optional(),
  floor: Joi.string().max(20).allow('').optional(),
  apartment: Joi.string().max(20).allow('').optional(),
  landmark: Joi.string().max(200).allow('').optional(),
  phone: Joi.string().pattern(phonePattern).required().messages({
    'string.empty': 'رقم الهاتف مطلوب',
    'string.pattern.base': 'رقم الهاتف غير صالح',
    'any.required': 'رقم الهاتف مطلوب',
  }),
  location: Joi.object({
    type: Joi.string().valid('Point').default('Point'),
    coordinates: Joi.array().items(Joi.number()).length(2).required(),
  }).required().messages({
    'any.required': 'الموقع مطلوب',
  }),
});

// Create order schema
export const createOrderSchema = Joi.object({
  restaurantId: Joi.string().required().messages({
    'string.empty': 'معرف المطعم مطلوب',
    'any.required': 'معرف المطعم مطلوب',
  }),
  items: Joi.array().items(orderItemSchema).min(1).required().messages({
    'array.min': 'يجب إضافة صنف واحد على الأقل',
    'any.required': 'الأصناف مطلوبة',
  }),
  deliveryAddress: deliveryAddressSchema.required(),
  paymentMethod: Joi.string()
    .valid('cash', 'card', 'wallet')
    .required()
    .messages({
      'any.only': 'طريقة الدفع غير صالحة',
      'any.required': 'طريقة الدفع مطلوبة',
    }),
  couponCode: Joi.string().max(50).allow('').optional(),
  customerNotes: Joi.string().max(500).allow('').optional(),
  isScheduled: Joi.boolean().optional(),
  scheduledFor: Joi.date().greater('now').when('isScheduled', {
    is: true,
    then: Joi.required().messages({
      'any.required': 'وقت التوصيل المجدول مطلوب',
      'date.greater': 'وقت التوصيل المجدول يجب أن يكون في المستقبل',
    }),
    otherwise: Joi.optional(),
  }),
});

// ==================== Order Status Updates ====================

// Cancel order schema
export const cancelOrderSchema = Joi.object({
  reason: Joi.string().min(3).max(500).required().messages({
    'string.empty': 'سبب الإلغاء مطلوب',
    'string.min': 'سبب الإلغاء يجب أن يكون 3 أحرف على الأقل',
    'any.required': 'سبب الإلغاء مطلوب',
  }),
});

// Rate order schema
export const rateOrderSchema = Joi.object({
  restaurant: Joi.number().min(1).max(5).optional().messages({
    'number.min': 'التقييم يجب أن يكون 1 على الأقل',
    'number.max': 'التقييم لا يمكن أن يتجاوز 5',
  }),
  driver: Joi.number().min(1).max(5).optional().messages({
    'number.min': 'التقييم يجب أن يكون 1 على الأقل',
    'number.max': 'التقييم لا يمكن أن يتجاوز 5',
  }),
  food: Joi.number().min(1).max(5).optional().messages({
    'number.min': 'التقييم يجب أن يكون 1 على الأقل',
    'number.max': 'التقييم لا يمكن أن يتجاوز 5',
  }),
  comment: Joi.string().max(1000).allow('').optional(),
}).or('restaurant', 'driver', 'food').messages({
  'object.missing': 'يجب تقديم تقييم واحد على الأقل',
});

// Reject order schema (restaurant)
export const rejectOrderSchema = Joi.object({
  reason: Joi.string().min(3).max(500).required().messages({
    'string.empty': 'سبب الرفض مطلوب',
    'string.min': 'سبب الرفض يجب أن يكون 3 أحرف على الأقل',
    'any.required': 'سبب الرفض مطلوب',
  }),
});

// Status update note schema
export const statusNoteSchema = Joi.object({
  note: Joi.string().max(500).allow('').optional(),
});

// ==================== Query Schemas ====================

// Get orders query schema
export const getOrdersQuerySchema = Joi.object({
  status: Joi.alternatives()
    .try(
      Joi.string().valid(
        'pending',
        'confirmed',
        'preparing',
        'ready',
        'picked_up',
        'on_the_way',
        'delivered',
        'cancelled'
      ),
      Joi.array().items(
        Joi.string().valid(
          'pending',
          'confirmed',
          'preparing',
          'ready',
          'picked_up',
          'on_the_way',
          'delivered',
          'cancelled'
        )
      )
    )
    .optional(),
  paymentStatus: Joi.string()
    .valid('pending', 'paid', 'failed', 'refunded')
    .optional(),
  startDate: Joi.date().optional(),
  endDate: Joi.date().optional(),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  sortBy: Joi.string()
    .valid('createdAt', 'total', 'status')
    .default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc'),
});

// ==================== Driver Schemas ====================

// Driver location schema
export const driverLocationSchema = Joi.object({
  lat: Joi.number().min(-90).max(90).required().messages({
    'number.base': 'خط العرض يجب أن يكون رقماً',
    'any.required': 'خط العرض مطلوب',
  }),
  lng: Joi.number().min(-180).max(180).required().messages({
    'number.base': 'خط الطول يجب أن يكون رقماً',
    'any.required': 'خط الطول مطلوب',
  }),
  maxDistance: Joi.number().min(1).max(50).default(10),
});

// ==================== Admin Schemas ====================

// Assign driver schema
export const assignDriverSchema = Joi.object({
  driverId: Joi.string().required().messages({
    'string.empty': 'معرف السائق مطلوب',
    'any.required': 'معرف السائق مطلوب',
  }),
});

// Admin order query schema
export const adminOrdersQuerySchema = Joi.object({
  status: Joi.alternatives()
    .try(
      Joi.string().valid(
        'pending',
        'confirmed',
        'preparing',
        'ready',
        'picked_up',
        'on_the_way',
        'delivered',
        'cancelled'
      ),
      Joi.array().items(
        Joi.string().valid(
          'pending',
          'confirmed',
          'preparing',
          'ready',
          'picked_up',
          'on_the_way',
          'delivered',
          'cancelled'
        )
      )
    )
    .optional(),
  restaurantId: Joi.string().optional(),
  customerId: Joi.string().optional(),
  driverId: Joi.string().optional(),
  paymentStatus: Joi.string()
    .valid('pending', 'paid', 'failed', 'refunded')
    .optional(),
  paymentMethod: Joi.string().valid('cash', 'card', 'wallet').optional(),
  startDate: Joi.date().optional(),
  endDate: Joi.date().optional(),
  orderNumber: Joi.string().optional(),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  sortBy: Joi.string()
    .valid('createdAt', 'total', 'status')
    .default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc'),
});
