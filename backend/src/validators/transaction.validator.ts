import Joi from 'joi';

// ==================== Driver Schemas ====================

// Request withdrawal schema
export const requestWithdrawalSchema = Joi.object({
  amount: Joi.number().min(50).required().messages({
    'number.base': 'المبلغ يجب أن يكون رقماً',
    'number.min': 'الحد الأدنى للسحب 50 ج.م',
    'any.required': 'المبلغ مطلوب',
  }),
  bankName: Joi.string().required().messages({
    'string.empty': 'اسم البنك مطلوب',
    'any.required': 'اسم البنك مطلوب',
  }),
  accountNumber: Joi.string().min(10).required().messages({
    'string.empty': 'رقم الحساب مطلوب',
    'string.min': 'رقم الحساب غير صحيح',
    'any.required': 'رقم الحساب مطلوب',
  }),
  accountName: Joi.string().required().messages({
    'string.empty': 'اسم صاحب الحساب مطلوب',
    'any.required': 'اسم صاحب الحساب مطلوب',
  }),
});

// ==================== Admin Schemas ====================

// Get transactions query schema
export const getTransactionsQuerySchema = Joi.object({
  type: Joi.string()
    .valid('order_payment', 'restaurant_payout', 'driver_payout', 'refund', 'withdrawal', 'bonus')
    .optional(),
  status: Joi.string()
    .valid('pending', 'processing', 'completed', 'failed')
    .optional(),
  userId: Joi.string().optional(),
  orderId: Joi.string().optional(),
  startDate: Joi.date().optional(),
  endDate: Joi.date().optional(),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  sortBy: Joi.string()
    .valid('createdAt', 'amount', 'status', 'type')
    .default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc'),
});

// Process withdrawal schema
export const processWithdrawalSchema = Joi.object({
  approved: Joi.boolean().required().messages({
    'boolean.base': 'حالة الموافقة يجب أن تكون صحيحة أو خاطئة',
    'any.required': 'حالة الموافقة مطلوبة',
  }),
  notes: Joi.string().max(500).optional(),
});

// Batch process payouts schema
export const batchProcessPayoutsSchema = Joi.object({
  transactionIds: Joi.array().items(Joi.string()).min(1).required().messages({
    'array.min': 'يجب تحديد معاملة واحدة على الأقل',
    'any.required': 'معرفات المعاملات مطلوبة',
  }),
  approved: Joi.boolean().required().messages({
    'boolean.base': 'حالة الموافقة يجب أن تكون صحيحة أو خاطئة',
    'any.required': 'حالة الموافقة مطلوبة',
  }),
});

// Update transaction status schema
export const updateTransactionStatusSchema = Joi.object({
  status: Joi.string()
    .valid('pending', 'processing', 'completed', 'failed')
    .required()
    .messages({
      'any.only': 'حالة المعاملة غير صالحة',
      'any.required': 'حالة المعاملة مطلوبة',
    }),
  notes: Joi.string().max(500).optional(),
});

// Pending payouts query schema
export const getPendingPayoutsQuerySchema = Joi.object({
  type: Joi.string()
    .valid('restaurant_payout', 'driver_payout', 'withdrawal')
    .default('withdrawal'),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
});
