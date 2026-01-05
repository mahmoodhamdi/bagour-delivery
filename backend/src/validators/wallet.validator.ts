import Joi from 'joi';

export const topupWalletSchema = Joi.object({
  amount: Joi.number()
    .positive()
    .min(10)
    .max(10000)
    .required()
    .messages({
      'number.base': 'المبلغ يجب أن يكون رقماً',
      'number.positive': 'المبلغ يجب أن يكون موجباً',
      'number.min': 'الحد الأدنى للشحن 10 جنيه',
      'number.max': 'الحد الأقصى للشحن 10000 جنيه',
      'any.required': 'المبلغ مطلوب',
    }),
  paymentMethod: Joi.string()
    .valid('card', 'mobile_wallet')
    .required()
    .messages({
      'string.base': 'طريقة الدفع يجب أن تكون نصاً',
      'any.only': 'طريقة الدفع يجب أن تكون بطاقة أو محفظة إلكترونية',
      'any.required': 'طريقة الدفع مطلوبة',
    }),
  phoneNumber: Joi.string()
    .pattern(/^01[0125][0-9]{8}$/)
    .when('paymentMethod', {
      is: 'mobile_wallet',
      then: Joi.required(),
      otherwise: Joi.optional(),
    })
    .messages({
      'string.pattern.base': 'رقم الهاتف غير صحيح',
      'any.required': 'رقم الهاتف مطلوب للمحفظة الإلكترونية',
    }),
});

export const getTransactionsSchema = Joi.object({
  page: Joi.number().integer().min(1).default(1).messages({
    'number.base': 'رقم الصفحة يجب أن يكون رقماً',
    'number.integer': 'رقم الصفحة يجب أن يكون عدداً صحيحاً',
    'number.min': 'رقم الصفحة يجب أن يكون 1 على الأقل',
  }),
  limit: Joi.number().integer().min(1).max(100).default(20).messages({
    'number.base': 'عدد العناصر يجب أن يكون رقماً',
    'number.integer': 'عدد العناصر يجب أن يكون عدداً صحيحاً',
    'number.min': 'عدد العناصر يجب أن يكون 1 على الأقل',
    'number.max': 'عدد العناصر يجب ألا يزيد عن 100',
  }),
  type: Joi.string()
    .valid('topup', 'order_payment', 'refund')
    .optional()
    .messages({
      'string.base': 'نوع المعاملة يجب أن يكون نصاً',
      'any.only': 'نوع المعاملة يجب أن يكون شحن أو دفع طلب أو استرجاع',
    }),
  startDate: Joi.date().optional().messages({
    'date.base': 'تاريخ البداية غير صحيح',
  }),
  endDate: Joi.date().optional().greater(Joi.ref('startDate')).messages({
    'date.base': 'تاريخ النهاية غير صحيح',
    'date.greater': 'تاريخ النهاية يجب أن يكون بعد تاريخ البداية',
  }),
});

export const confirmTopupSchema = Joi.object({
  transactionId: Joi.string().required().messages({
    'string.base': 'رقم المعاملة يجب أن يكون نصاً',
    'any.required': 'رقم المعاملة مطلوب',
  }),
});
