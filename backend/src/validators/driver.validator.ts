import Joi from 'joi';

export const updateProfileSchema = Joi.object({
  vehicleColor: Joi.string().max(50).messages({
    'string.max': 'لون المركبة يجب أن لا يتجاوز 50 حرف',
  }),
  vehicleModel: Joi.string().max(100).messages({
    'string.max': 'موديل المركبة يجب أن لا يتجاوز 100 حرف',
  }),
  vehicleImage: Joi.string().uri().messages({
    'string.uri': 'رابط صورة المركبة غير صالح',
  }),
  preferredZones: Joi.array()
    .items(Joi.string().regex(/^[0-9a-fA-F]{24}$/))
    .max(5)
    .messages({
      'array.max': 'يمكنك اختيار 5 مناطق كحد أقصى',
    }),
});

export const updateAvatarSchema = Joi.object({
  avatar: Joi.string().uri().required().messages({
    'string.uri': 'رابط الصورة غير صالح',
    'any.required': 'رابط الصورة مطلوب',
  }),
});

export const updateLocationSchema = Joi.object({
  latitude: Joi.number().min(-90).max(90).required().messages({
    'number.min': 'خط العرض يجب أن يكون بين -90 و 90',
    'number.max': 'خط العرض يجب أن يكون بين -90 و 90',
    'any.required': 'خط العرض مطلوب',
  }),
  longitude: Joi.number().min(-180).max(180).required().messages({
    'number.min': 'خط الطول يجب أن يكون بين -180 و 180',
    'number.max': 'خط الطول يجب أن يكون بين -180 و 180',
    'any.required': 'خط الطول مطلوب',
  }),
});

export const toggleOnlineSchema = Joi.object({
  isOnline: Joi.boolean().required().messages({
    'boolean.base': 'قيمة الحالة يجب أن تكون صحيحة أو خاطئة',
    'any.required': 'حالة الاتصال مطلوبة',
  }),
});

export const toggleAvailabilitySchema = Joi.object({
  isAvailable: Joi.boolean().required().messages({
    'boolean.base': 'قيمة التوفر يجب أن تكون صحيحة أو خاطئة',
    'any.required': 'حالة التوفر مطلوبة',
  }),
});

export const updateDocumentsSchema = Joi.object({
  nationalIdImage: Joi.string().uri().messages({
    'string.uri': 'رابط صورة البطاقة غير صالح',
  }),
  nationalIdBackImage: Joi.string().uri().messages({
    'string.uri': 'رابط صورة ظهر البطاقة غير صالح',
  }),
  licenseImage: Joi.string().uri().messages({
    'string.uri': 'رابط صورة الرخصة غير صالح',
  }),
  licenseExpiryDate: Joi.date().greater('now').messages({
    'date.greater': 'تاريخ انتهاء الرخصة يجب أن يكون في المستقبل',
  }),
}).min(1).messages({
  'object.min': 'يجب تحديث مستند واحد على الأقل',
});
