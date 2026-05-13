/**
 * Zod schemas — runtime validators for the wire types in @bagour/types.
 *
 * Apps validate at trust boundaries (API responses, form submissions,
 * deserialized localStorage). For perf, apps may skip validation on read
 * paths after dev — these schemas pull their weight during dev + tests.
 */

import { z } from "zod";

// -------------------------------------------------------------- common ----

export const isoDateString = z.string().datetime({ offset: true });

export const objectIdString = z.string().min(1).max(64);

export const pointSchema = z.object({
  type: z.literal("Point"),
  coordinates: z.tuple([z.number(), z.number()]),
});

export const paginationMetaSchema = z.object({
  page: z.number().int().nonnegative(),
  limit: z.number().int().positive(),
  total: z.number().int().nonnegative(),
  totalPages: z.number().int().nonnegative(),
  hasNextPage: z.boolean(),
  hasPrevPage: z.boolean(),
});

export const apiErrorSchema = z.object({
  success: z.literal(false),
  message: z.string(),
  errors: z.record(z.string(), z.array(z.string())).optional(),
  statusCode: z.number().int().optional(),
});

export const apiResponseSchema = <T extends z.ZodTypeAny>(data: T) =>
  z.object({
    success: z.boolean(),
    data,
    message: z.string().optional(),
  });

export const paginatedResponseSchema = <T extends z.ZodTypeAny>(item: T) =>
  z.object({
    success: z.boolean(),
    data: z.array(item),
    pagination: paginationMetaSchema,
  });

// --------------------------------------------------------------- user ----

export const userRoleSchema = z.enum(["customer", "restaurant", "driver", "admin"]);

export const baseUserSchema = z.object({
  id: objectIdString,
  email: z.string().email(),
  phone: z.string(),
  name: z.string(),
  role: userRoleSchema,
  avatar: z.string().url().optional(),
  isActive: z.boolean(),
  isBlocked: z.boolean(),
  isEmailVerified: z.boolean(),
  isPhoneVerified: z.boolean(),
  fcmTokens: z.array(z.string()).default([]),
  lastLogin: isoDateString.optional(),
  createdAt: isoDateString,
  updatedAt: isoDateString,
});

export const addressSchema = z.object({
  id: objectIdString.optional(),
  label: z.string().optional(),
  street: z.string().min(1),
  area: z.string().min(1),
  city: z.string().min(1),
  buildingNumber: z.string().optional(),
  floor: z.string().optional(),
  apartment: z.string().optional(),
  landmark: z.string().optional(),
  isDefault: z.boolean().optional(),
  location: pointSchema.optional(),
});

export const customerSchema = z.object({
  id: objectIdString,
  userId: objectIdString,
  user: baseUserSchema.optional(),
  addresses: z.array(addressSchema).default([]),
  favoriteRestaurants: z.array(objectIdString).default([]),
  totalOrders: z.number().int().nonnegative(),
  totalSpent: z.number().nonnegative(),
  loyaltyPoints: z.number().int().nonnegative(),
  referralCode: z.string(),
  referredBy: objectIdString.optional(),
});

// ----------------------------------------------------------- restaurant ----

export const dayOfWeekSchema = z.enum([
  "sunday",
  "monday",
  "tuesday",
  "wednesday",
  "thursday",
  "friday",
  "saturday",
]);

export const workingHoursSchema = z.object({
  day: dayOfWeekSchema,
  isOpen: z.boolean(),
  openTime: z.string().regex(/^\d{2}:\d{2}$/),
  closeTime: z.string().regex(/^\d{2}:\d{2}$/),
});

export const restaurantSchema = z.object({
  id: objectIdString,
  userId: objectIdString,
  name: z.string().min(1),
  nameEn: z.string().optional(),
  description: z.string().optional(),
  descriptionEn: z.string().optional(),
  email: z.string().email(),
  phone: z.string(),
  logo: z.string().url().optional(),
  coverImage: z.string().url().optional(),
  images: z.array(z.string().url()).default([]),
  status: z.enum(["pending", "approved", "rejected", "suspended"]),
  isOpen: z.boolean(),
  address: addressSchema,
  cuisineTypes: z.array(z.string()).default([]),
  tags: z.array(z.string()).default([]),
  workingHours: z.array(workingHoursSchema).default([]),
  rating: z.number().min(0).max(5),
  totalReviews: z.number().int().nonnegative(),
  totalOrders: z.number().int().nonnegative(),
  minimumOrder: z.number().nonnegative(),
  deliveryTime: z.object({ min: z.number().int().nonnegative(), max: z.number().int().nonnegative() }),
  deliveryFee: z.number().nonnegative(),
  commissionRate: z.number().min(0).max(1),
  features: z.object({
    acceptsOnlinePayment: z.boolean(),
    hasDelivery: z.boolean(),
    hasPickup: z.boolean(),
    hasDineIn: z.boolean(),
  }),
  createdAt: isoDateString,
  updatedAt: isoDateString,
});

export const menuCategorySchema = z.object({
  id: objectIdString,
  restaurantId: objectIdString,
  name: z.string(),
  nameEn: z.string().optional(),
  description: z.string().optional(),
  image: z.string().url().optional(),
  order: z.number().int(),
  isActive: z.boolean(),
});

export const menuAddonSchema = z.object({
  name: z.string(),
  nameEn: z.string().optional(),
  price: z.number().nonnegative(),
  isAvailable: z.boolean(),
});

export const menuOptionSchema = z.object({
  name: z.string(),
  nameEn: z.string().optional(),
  required: z.boolean(),
  maxSelections: z.number().int().positive(),
  choices: z
    .array(
      z.object({
        name: z.string(),
        nameEn: z.string().optional(),
        price: z.number().nonnegative(),
        isDefault: z.boolean().optional(),
      }),
    )
    .min(1),
});

export const menuItemSchema = z.object({
  id: objectIdString,
  restaurantId: objectIdString,
  categoryId: objectIdString,
  name: z.string(),
  nameEn: z.string().optional(),
  description: z.string().optional(),
  descriptionEn: z.string().optional(),
  price: z.number().nonnegative(),
  discountPrice: z.number().nonnegative().optional(),
  image: z.string().url().optional(),
  images: z.array(z.string().url()).default([]),
  preparationTime: z.number().int().nonnegative(),
  calories: z.number().nonnegative().optional(),
  isAvailable: z.boolean(),
  isNewItem: z.boolean(),
  isFeatured: z.boolean(),
  addons: z.array(menuAddonSchema).default([]),
  options: z.array(menuOptionSchema).default([]),
  tags: z.array(z.string()).default([]),
  allergens: z.array(z.string()).default([]),
  order: z.number().int(),
  createdAt: isoDateString,
  updatedAt: isoDateString,
});

// --------------------------------------------------------------- order ----

export const orderStatusSchema = z.enum([
  "pending",
  "confirmed",
  "preparing",
  "ready",
  "picked_up",
  "on_the_way",
  "delivered",
  "cancelled",
]);

export const paymentMethodSchema = z.enum(["cash", "card", "wallet"]);
export const paymentStatusSchema = z.enum(["pending", "paid", "failed", "refunded"]);

export const orderItemSchema = z.object({
  menuItemId: objectIdString,
  name: z.string(),
  nameEn: z.string().optional(),
  quantity: z.number().int().positive(),
  price: z.number().nonnegative(),
  discountPrice: z.number().nonnegative().optional(),
  image: z.string().url().optional(),
  addons: z.array(z.object({ name: z.string(), price: z.number().nonnegative() })).default([]),
  options: z
    .array(z.object({ name: z.string(), choice: z.string(), price: z.number().nonnegative() }))
    .default([]),
  specialInstructions: z.string().optional(),
  itemTotal: z.number().nonnegative(),
});

export const orderSchema = z.object({
  id: objectIdString,
  orderNumber: z.string(),
  customerId: objectIdString,
  restaurantId: objectIdString,
  driverId: objectIdString.optional(),
  items: z.array(orderItemSchema).min(1),
  subtotal: z.number().nonnegative(),
  deliveryFee: z.number().nonnegative(),
  serviceFee: z.number().nonnegative().default(0),
  tax: z.number().nonnegative().default(0),
  discount: z.number().nonnegative().default(0),
  tip: z.number().nonnegative().default(0),
  total: z.number().nonnegative(),
  commission: z.number().nonnegative().default(0),
  restaurantEarnings: z.number().nonnegative().default(0),
  driverEarnings: z.number().nonnegative().default(0),
  status: orderStatusSchema,
  statusHistory: z
    .array(
      z.object({
        status: orderStatusSchema,
        timestamp: isoDateString,
        note: z.string().optional(),
        updatedBy: objectIdString.optional(),
      }),
    )
    .default([]),
  paymentMethod: paymentMethodSchema,
  paymentStatus: paymentStatusSchema,
  paymentReference: z.string().optional(),
  deliveryAddress: addressSchema,
  deliveryLocation: pointSchema,
  deliveryInstructions: z.string().optional(),
  estimatedDeliveryTime: isoDateString.optional(),
  actualDeliveryTime: isoDateString.optional(),
  estimatedPickupTime: isoDateString.optional(),
  actualPickupTime: isoDateString.optional(),
  couponId: objectIdString.optional(),
  couponCode: z.string().optional(),
  notes: z.string().optional(),
  cancelReason: z.string().optional(),
  cancelledBy: z.enum(["customer", "restaurant", "driver", "admin"]).optional(),
  rating: z
    .object({
      restaurant: z.number().min(0).max(5).optional(),
      driver: z.number().min(0).max(5).optional(),
      food: z.number().min(0).max(5).optional(),
      overall: z.number().min(0).max(5).optional(),
      comment: z.string().optional(),
    })
    .optional(),
  isScheduled: z.boolean().default(false),
  scheduledFor: isoDateString.optional(),
  createdAt: isoDateString,
  updatedAt: isoDateString,
});

// -------------------------------------------------------------- driver ----

export const driverSchema = z.object({
  id: objectIdString,
  userId: objectIdString,
  nationalId: z.string(),
  dateOfBirth: isoDateString,
  vehicleType: z.enum(["motorcycle", "bicycle", "car"]),
  vehicleModel: z.string().optional(),
  vehicleColor: z.string().optional(),
  vehiclePlateNumber: z.string(),
  licenseNumber: z.string(),
  licenseExpiryDate: isoDateString,
  documents: z.object({
    nationalIdFront: z.string().url().optional(),
    nationalIdBack: z.string().url().optional(),
    driverLicenseFront: z.string().url().optional(),
    driverLicenseBack: z.string().url().optional(),
    vehicleLicense: z.string().url().optional(),
    vehicleImage: z.string().url().optional(),
  }),
  status: z.enum(["pending", "approved", "rejected", "suspended"]),
  rejectionReason: z.string().optional(),
  isOnline: z.boolean(),
  isAvailable: z.boolean(),
  currentLocation: z
    .object({
      type: z.literal("Point"),
      coordinates: z.tuple([z.number(), z.number()]),
      updatedAt: isoDateString,
    })
    .optional(),
  currentOrderId: objectIdString.optional(),
  rating: z.number().min(0).max(5),
  totalReviews: z.number().int().nonnegative(),
  totalDeliveries: z.number().int().nonnegative(),
  totalEarnings: z.number().nonnegative(),
  walletBalance: z.number(),
  bankDetails: z
    .object({
      bankName: z.string(),
      accountNumber: z.string(),
      accountHolderName: z.string(),
    })
    .optional(),
  zones: z.array(objectIdString).default([]),
  createdAt: isoDateString,
  updatedAt: isoDateString,
});

// ----------------------------------------------------------------- web ----

export const authTokensSchema = z.object({
  accessToken: z.string().min(1),
  refreshToken: z.string().optional(),
  expiresIn: z.number().int().positive().optional(),
});

export const authSessionSchema = z.object({
  user: baseUserSchema,
  tokens: authTokensSchema,
  issuedAt: z.number().int().nonnegative(),
});

export const pushSubscriptionPayloadSchema = z.object({
  endpoint: z.string().url(),
  keys: z.object({ p256dh: z.string().min(1), auth: z.string().min(1) }),
  expirationTime: z.number().int().nullable().optional(),
  userAgent: z.string().optional(),
});

export const driverLocationUpdateSchema = z.object({
  driverId: objectIdString,
  orderId: objectIdString.optional(),
  coordinates: z.tuple([z.number(), z.number()]),
  heading: z.number().min(0).max(360).optional(),
  speed: z.number().nonnegative().optional(),
  accuracy: z.number().nonnegative().optional(),
  timestamp: isoDateString,
});

// ------------------------------------------------------- form payloads ----

export const loginPayloadSchema = z.object({
  email: z.string().email("invalid_email"),
  password: z.string().min(8, "password_too_short"),
});

export const registerPayloadSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  phone: z.string().regex(/^01[0125][0-9]{8}$/, "invalid_phone"),
  password: z.string().min(8),
  role: z.enum(["customer", "driver"]),
});

export const otpVerifyPayloadSchema = z.object({
  email: z.string().email(),
  otp: z.string().length(6).regex(/^\d{6}$/),
});

export const forgotPasswordPayloadSchema = z.object({
  email: z.string().email(),
});

export const resetPasswordPayloadSchema = z.object({
  email: z.string().email(),
  otp: z.string().length(6).regex(/^\d{6}$/),
  newPassword: z.string().min(8),
});

export type LoginPayload = z.infer<typeof loginPayloadSchema>;
export type RegisterPayload = z.infer<typeof registerPayloadSchema>;
export type OtpVerifyPayload = z.infer<typeof otpVerifyPayloadSchema>;
export type ForgotPasswordPayload = z.infer<typeof forgotPasswordPayloadSchema>;
export type ResetPasswordPayload = z.infer<typeof resetPasswordPayloadSchema>;
