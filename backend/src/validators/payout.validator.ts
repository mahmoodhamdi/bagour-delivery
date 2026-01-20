import Joi from 'joi';

export const createPayoutSchema = Joi.object({
  amount: Joi.number().min(100).required().messages({
    'number.min': 'الحد الأدنى للسحب 100 جنيه',
    'number.base': 'المبلغ يجب أن يكون رقماً',
    'any.required': 'المبلغ مطلوب',
  }),
  method: Joi.string()
    .valid('bank_transfer', 'vodafone_cash', 'instapay')
    .required()
    .messages({
      'any.only': 'طريقة السحب غير صالحة',
      'any.required': 'طريقة السحب مطلوبة',
    }),
  accountDetails: Joi.object({
    bankName: Joi.string().when('...method', {
      is: 'bank_transfer',
      then: Joi.required().messages({
        'any.required': 'اسم البنك مطلوب',
      }),
      otherwise: Joi.optional(),
    }),
    accountNumber: Joi.string().when('...method', {
      is: 'bank_transfer',
      then: Joi.required().messages({
        'any.required': 'رقم الحساب مطلوب',
      }),
      otherwise: Joi.optional(),
    }),
    accountHolderName: Joi.string().when('...method', {
      is: 'bank_transfer',
      then: Joi.required().messages({
        'any.required': 'اسم صاحب الحساب مطلوب',
      }),
      otherwise: Joi.optional(),
    }),
    phoneNumber: Joi.string()
      .pattern(/^01[0125][0-9]{8}$/)
      .when('...method', {
        is: Joi.valid('vodafone_cash', 'instapay'),
        then: Joi.required().messages({
          'any.required': 'رقم الهاتف مطلوب',
        }),
        otherwise: Joi.optional(),
      })
      .messages({
        'string.pattern.base': 'رقم الهاتف غير صالح',
      }),
    ipaAddress: Joi.string().optional(),
  }).required().messages({
    'any.required': 'تفاصيل الحساب مطلوبة',
  }),
  notes: Joi.string().max(500).optional().messages({
    'string.max': 'الملاحظات يجب ألا تتجاوز 500 حرف',
  }),
});

export const updatePayoutStatusSchema = Joi.object({
  status: Joi.string()
    .valid('processing', 'completed', 'rejected')
    .required()
    .messages({
      'any.only': 'حالة الطلب غير صالحة',
      'any.required': 'حالة الطلب مطلوبة',
    }),
  adminNotes: Joi.string().max(500).optional().messages({
    'string.max': 'ملاحظات الإدارة يجب ألا تتجاوز 500 حرف',
  }),
});
