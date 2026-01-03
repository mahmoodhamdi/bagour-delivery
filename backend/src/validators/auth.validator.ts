import Joi from 'joi';

// Common validation patterns
const phonePattern = /^01[0125][0-9]{8}$/;
const passwordMinLength = 8;

// Customer Registration
export const customerRegisterSchema = Joi.object({
  name: Joi.string().min(2).max(50).required().messages({
    'string.empty': 'الاسم مطلوب',
    'string.min': 'الاسم يجب أن يكون حرفين على الأقل',
    'string.max': 'الاسم لا يمكن أن يتجاوز 50 حرف',
    'any.required': 'الاسم مطلوب',
  }),
  email: Joi.string().email().required().messages({
    'string.empty': 'البريد الإلكتروني مطلوب',
    'string.email': 'البريد الإلكتروني غير صالح',
    'any.required': 'البريد الإلكتروني مطلوب',
  }),
  phone: Joi.string().pattern(phonePattern).required().messages({
    'string.empty': 'رقم الهاتف مطلوب',
    'string.pattern.base': 'رقم الهاتف غير صالح',
    'any.required': 'رقم الهاتف مطلوب',
  }),
  password: Joi.string().min(passwordMinLength).required().messages({
    'string.empty': 'كلمة المرور مطلوبة',
    'string.min': `كلمة المرور يجب أن تكون ${passwordMinLength} أحرف على الأقل`,
    'any.required': 'كلمة المرور مطلوبة',
  }),
  referralCode: Joi.string().optional(),
});

// Restaurant Registration
export const restaurantRegisterSchema = Joi.object({
  // Owner info
  ownerName: Joi.string().min(2).max(50).required().messages({
    'string.empty': 'اسم المالك مطلوب',
    'string.min': 'الاسم يجب أن يكون حرفين على الأقل',
    'any.required': 'اسم المالك مطلوب',
  }),
  email: Joi.string().email().required().messages({
    'string.empty': 'البريد الإلكتروني مطلوب',
    'string.email': 'البريد الإلكتروني غير صالح',
    'any.required': 'البريد الإلكتروني مطلوب',
  }),
  phone: Joi.string().pattern(phonePattern).required().messages({
    'string.empty': 'رقم الهاتف مطلوب',
    'string.pattern.base': 'رقم الهاتف غير صالح',
    'any.required': 'رقم الهاتف مطلوب',
  }),
  password: Joi.string().min(passwordMinLength).required().messages({
    'string.empty': 'كلمة المرور مطلوبة',
    'string.min': `كلمة المرور يجب أن تكون ${passwordMinLength} أحرف على الأقل`,
    'any.required': 'كلمة المرور مطلوبة',
  }),

  // Restaurant info
  name: Joi.string().min(2).max(100).required().messages({
    'string.empty': 'اسم المطعم مطلوب',
    'string.min': 'اسم المطعم يجب أن يكون حرفين على الأقل',
    'any.required': 'اسم المطعم مطلوب',
  }),
  nameEn: Joi.string().min(2).max(100).optional(),
  description: Joi.string().max(500).optional(),
  cuisineTypes: Joi.array().items(Joi.string()).min(1).required().messages({
    'array.min': 'يجب اختيار نوع واحد على الأقل من المأكولات',
    'any.required': 'نوع المأكولات مطلوب',
  }),

  // Address
  address: Joi.object({
    street: Joi.string().required().messages({
      'string.empty': 'الشارع مطلوب',
      'any.required': 'الشارع مطلوب',
    }),
    area: Joi.string().required().messages({
      'string.empty': 'المنطقة مطلوبة',
      'any.required': 'المنطقة مطلوبة',
    }),
    city: Joi.string().default('باجور'),
    buildingNumber: Joi.string().optional(),
    landmark: Joi.string().optional(),
    location: Joi.object({
      lat: Joi.number().required(),
      lng: Joi.number().required(),
    }).optional(),
  }).required(),
});

// Driver Registration
export const driverRegisterSchema = Joi.object({
  name: Joi.string().min(2).max(50).required().messages({
    'string.empty': 'الاسم مطلوب',
    'string.min': 'الاسم يجب أن يكون حرفين على الأقل',
    'any.required': 'الاسم مطلوب',
  }),
  email: Joi.string().email().required().messages({
    'string.empty': 'البريد الإلكتروني مطلوب',
    'string.email': 'البريد الإلكتروني غير صالح',
    'any.required': 'البريد الإلكتروني مطلوب',
  }),
  phone: Joi.string().pattern(phonePattern).required().messages({
    'string.empty': 'رقم الهاتف مطلوب',
    'string.pattern.base': 'رقم الهاتف غير صالح',
    'any.required': 'رقم الهاتف مطلوب',
  }),
  password: Joi.string().min(passwordMinLength).required().messages({
    'string.empty': 'كلمة المرور مطلوبة',
    'string.min': `كلمة المرور يجب أن تكون ${passwordMinLength} أحرف على الأقل`,
    'any.required': 'كلمة المرور مطلوبة',
  }),
  nationalId: Joi.string()
    .pattern(/^[0-9]{14}$/)
    .required()
    .messages({
      'string.empty': 'الرقم القومي مطلوب',
      'string.pattern.base': 'الرقم القومي يجب أن يكون 14 رقم',
      'any.required': 'الرقم القومي مطلوب',
    }),
  vehicleType: Joi.string()
    .valid('motorcycle', 'bicycle', 'car')
    .required()
    .messages({
      'any.only': 'نوع المركبة غير صالح',
      'any.required': 'نوع المركبة مطلوب',
    }),
  vehicleModel: Joi.string().optional(),
  vehicleColor: Joi.string().optional(),
  vehiclePlateNumber: Joi.string().min(3).required().messages({
    'string.empty': 'رقم اللوحة مطلوب',
    'string.min': 'رقم اللوحة غير صالح',
    'any.required': 'رقم اللوحة مطلوب',
  }),
  licenseNumber: Joi.string().required().messages({
    'string.empty': 'رقم الرخصة مطلوب',
    'any.required': 'رقم الرخصة مطلوب',
  }),
  licenseExpiryDate: Joi.date().greater('now').required().messages({
    'date.greater': 'الرخصة منتهية الصلاحية',
    'any.required': 'تاريخ انتهاء الرخصة مطلوب',
  }),
});

// Login
export const loginSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.empty': 'البريد الإلكتروني مطلوب',
    'string.email': 'البريد الإلكتروني غير صالح',
    'any.required': 'البريد الإلكتروني مطلوب',
  }),
  password: Joi.string().required().messages({
    'string.empty': 'كلمة المرور مطلوبة',
    'any.required': 'كلمة المرور مطلوبة',
  }),
});

// Phone Login (for customers)
export const phoneLoginSchema = Joi.object({
  phone: Joi.string().pattern(phonePattern).required().messages({
    'string.empty': 'رقم الهاتف مطلوب',
    'string.pattern.base': 'رقم الهاتف غير صالح',
    'any.required': 'رقم الهاتف مطلوب',
  }),
});

// Verify OTP
export const verifyOtpSchema = Joi.object({
  phone: Joi.string().pattern(phonePattern).optional(),
  email: Joi.string().email().optional(),
  otp: Joi.string()
    .pattern(/^[0-9]{6}$/)
    .required()
    .messages({
      'string.empty': 'رمز التحقق مطلوب',
      'string.pattern.base': 'رمز التحقق يجب أن يكون 6 أرقام',
      'any.required': 'رمز التحقق مطلوب',
    }),
  type: Joi.string()
    .valid('phone_verification', 'email_verification', 'password_reset')
    .required(),
})
  .or('phone', 'email')
  .messages({
    'object.missing': 'يجب إدخال رقم الهاتف أو البريد الإلكتروني',
  });

// Resend OTP
export const resendOtpSchema = Joi.object({
  phone: Joi.string().pattern(phonePattern).optional(),
  email: Joi.string().email().optional(),
  type: Joi.string()
    .valid('phone_verification', 'email_verification', 'password_reset')
    .required(),
})
  .or('phone', 'email')
  .messages({
    'object.missing': 'يجب إدخال رقم الهاتف أو البريد الإلكتروني',
  });

// Forgot Password
export const forgotPasswordSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.empty': 'البريد الإلكتروني مطلوب',
    'string.email': 'البريد الإلكتروني غير صالح',
    'any.required': 'البريد الإلكتروني مطلوب',
  }),
});

// Reset Password
export const resetPasswordSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.empty': 'البريد الإلكتروني مطلوب',
    'string.email': 'البريد الإلكتروني غير صالح',
    'any.required': 'البريد الإلكتروني مطلوب',
  }),
  otp: Joi.string()
    .pattern(/^[0-9]{6}$/)
    .required()
    .messages({
      'string.empty': 'رمز التحقق مطلوب',
      'string.pattern.base': 'رمز التحقق يجب أن يكون 6 أرقام',
      'any.required': 'رمز التحقق مطلوب',
    }),
  newPassword: Joi.string().min(passwordMinLength).required().messages({
    'string.empty': 'كلمة المرور الجديدة مطلوبة',
    'string.min': `كلمة المرور يجب أن تكون ${passwordMinLength} أحرف على الأقل`,
    'any.required': 'كلمة المرور الجديدة مطلوبة',
  }),
  confirmPassword: Joi.string()
    .valid(Joi.ref('newPassword'))
    .required()
    .messages({
      'any.only': 'كلمات المرور غير متطابقة',
      'any.required': 'تأكيد كلمة المرور مطلوب',
    }),
});

// Change Password
export const changePasswordSchema = Joi.object({
  currentPassword: Joi.string().required().messages({
    'string.empty': 'كلمة المرور الحالية مطلوبة',
    'any.required': 'كلمة المرور الحالية مطلوبة',
  }),
  newPassword: Joi.string().min(passwordMinLength).required().messages({
    'string.empty': 'كلمة المرور الجديدة مطلوبة',
    'string.min': `كلمة المرور يجب أن تكون ${passwordMinLength} أحرف على الأقل`,
    'any.required': 'كلمة المرور الجديدة مطلوبة',
  }),
  confirmPassword: Joi.string()
    .valid(Joi.ref('newPassword'))
    .required()
    .messages({
      'any.only': 'كلمات المرور غير متطابقة',
      'any.required': 'تأكيد كلمة المرور مطلوب',
    }),
});

// Refresh Token
export const refreshTokenSchema = Joi.object({
  refreshToken: Joi.string().required().messages({
    'string.empty': 'رمز التحديث مطلوب',
    'any.required': 'رمز التحديث مطلوب',
  }),
});

// Update FCM Token
export const updateFcmTokenSchema = Joi.object({
  fcmToken: Joi.string().required().messages({
    'string.empty': 'رمز FCM مطلوب',
    'any.required': 'رمز FCM مطلوب',
  }),
  deviceType: Joi.string().valid('android', 'ios', 'web').optional(),
});

// Google Sign In
export const googleSignInSchema = Joi.object({
  idToken: Joi.string().required().messages({
    'string.empty': 'رمز Google مطلوب',
    'any.required': 'رمز Google مطلوب',
  }),
});
