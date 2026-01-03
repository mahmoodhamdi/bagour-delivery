import Joi from 'joi';

export const addAddressSchema = Joi.object({
  label: Joi.string()
    .valid('home', 'work', 'other')
    .required()
    .messages({
      'any.only': 'نوع العنوان يجب أن يكون: منزل، عمل، أو آخر',
      'any.required': 'نوع العنوان مطلوب',
    }),
  name: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.min': 'اسم العنوان يجب أن يكون على الأقل حرفين',
      'string.max': 'اسم العنوان يجب ألا يتجاوز 100 حرف',
      'any.required': 'اسم العنوان مطلوب',
    }),
  address: Joi.string()
    .min(5)
    .max(200)
    .required()
    .messages({
      'string.min': 'العنوان يجب أن يكون على الأقل 5 أحرف',
      'string.max': 'العنوان يجب ألا يتجاوز 200 حرف',
      'any.required': 'العنوان مطلوب',
    }),
  area: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.min': 'المنطقة يجب أن تكون على الأقل حرفين',
      'string.max': 'المنطقة يجب ألا تتجاوز 100 حرف',
      'any.required': 'المنطقة مطلوبة',
    }),
  city: Joi.string()
    .max(100)
    .default('الباجور')
    .messages({
      'string.max': 'المدينة يجب ألا تتجاوز 100 حرف',
    }),
  building: Joi.string()
    .max(50)
    .allow('')
    .optional()
    .messages({
      'string.max': 'رقم المبنى يجب ألا يتجاوز 50 حرف',
    }),
  floor: Joi.string()
    .max(20)
    .allow('')
    .optional()
    .messages({
      'string.max': 'الطابق يجب ألا يتجاوز 20 حرف',
    }),
  apartment: Joi.string()
    .max(20)
    .allow('')
    .optional()
    .messages({
      'string.max': 'رقم الشقة يجب ألا يتجاوز 20 حرف',
    }),
  landmark: Joi.string()
    .max(200)
    .allow('')
    .optional()
    .messages({
      'string.max': 'العلامة المميزة يجب ألا تتجاوز 200 حرف',
    }),
  coordinates: Joi.array()
    .items(Joi.number())
    .length(2)
    .required()
    .messages({
      'array.length': 'الإحداثيات يجب أن تحتوي على خط الطول والعرض',
      'any.required': 'موقع العنوان مطلوب',
    }),
  isDefault: Joi.boolean()
    .default(false),
});

export const updateAddressSchema = Joi.object({
  label: Joi.string()
    .valid('home', 'work', 'other')
    .messages({
      'any.only': 'نوع العنوان يجب أن يكون: منزل، عمل، أو آخر',
    }),
  name: Joi.string()
    .min(2)
    .max(100)
    .messages({
      'string.min': 'اسم العنوان يجب أن يكون على الأقل حرفين',
      'string.max': 'اسم العنوان يجب ألا يتجاوز 100 حرف',
    }),
  address: Joi.string()
    .min(5)
    .max(200)
    .messages({
      'string.min': 'العنوان يجب أن يكون على الأقل 5 أحرف',
      'string.max': 'العنوان يجب ألا يتجاوز 200 حرف',
    }),
  area: Joi.string()
    .min(2)
    .max(100)
    .messages({
      'string.min': 'المنطقة يجب أن تكون على الأقل حرفين',
      'string.max': 'المنطقة يجب ألا تتجاوز 100 حرف',
    }),
  city: Joi.string()
    .max(100)
    .messages({
      'string.max': 'المدينة يجب ألا تتجاوز 100 حرف',
    }),
  building: Joi.string()
    .max(50)
    .allow('')
    .messages({
      'string.max': 'رقم المبنى يجب ألا يتجاوز 50 حرف',
    }),
  floor: Joi.string()
    .max(20)
    .allow('')
    .messages({
      'string.max': 'الطابق يجب ألا يتجاوز 20 حرف',
    }),
  apartment: Joi.string()
    .max(20)
    .allow('')
    .messages({
      'string.max': 'رقم الشقة يجب ألا يتجاوز 20 حرف',
    }),
  landmark: Joi.string()
    .max(200)
    .allow('')
    .messages({
      'string.max': 'العلامة المميزة يجب ألا تتجاوز 200 حرف',
    }),
  coordinates: Joi.array()
    .items(Joi.number())
    .length(2)
    .messages({
      'array.length': 'الإحداثيات يجب أن تحتوي على خط الطول والعرض',
    }),
  isDefault: Joi.boolean(),
});

export const addressIdSchema = Joi.object({
  id: Joi.string()
    .required()
    .pattern(/^[a-fA-F0-9]{24}$/)
    .messages({
      'string.pattern.base': 'معرف العنوان غير صالح',
      'any.required': 'معرف العنوان مطلوب',
    }),
});

export const restaurantIdSchema = Joi.object({
  restaurantId: Joi.string()
    .required()
    .pattern(/^[a-fA-F0-9]{24}$/)
    .messages({
      'string.pattern.base': 'معرف المطعم غير صالح',
      'any.required': 'معرف المطعم مطلوب',
    }),
});
