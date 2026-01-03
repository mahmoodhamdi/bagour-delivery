import Joi from 'joi';

// Phone pattern for Egyptian numbers
const phonePattern = /^01[0125][0-9]{8}$/;

// Initiate payment schema
export const initiatePaymentSchema = Joi.object({
  orderId: Joi.string().required().messages({
    'string.empty': 'معرف الطلب مطلوب',
    'any.required': 'معرف الطلب مطلوب',
  }),
});

// Initiate wallet payment schema
export const initiateWalletPaymentSchema = Joi.object({
  orderId: Joi.string().required().messages({
    'string.empty': 'معرف الطلب مطلوب',
    'any.required': 'معرف الطلب مطلوب',
  }),
  phoneNumber: Joi.string().pattern(phonePattern).required().messages({
    'string.empty': 'رقم الهاتف مطلوب',
    'string.pattern.base': 'رقم الهاتف غير صالح',
    'any.required': 'رقم الهاتف مطلوب',
  }),
});

// Refund schema
export const refundSchema = Joi.object({
  orderId: Joi.string().required().messages({
    'string.empty': 'معرف الطلب مطلوب',
    'any.required': 'معرف الطلب مطلوب',
  }),
  amount: Joi.number().positive().optional().messages({
    'number.base': 'المبلغ يجب أن يكون رقماً',
    'number.positive': 'المبلغ يجب أن يكون موجباً',
  }),
});
