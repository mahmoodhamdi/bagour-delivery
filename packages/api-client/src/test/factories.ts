/**
 * Test data factories. Each factory returns a fully-typed instance of the
 * shape with sensible defaults. Override fields as needed.
 *
 *   import { makeRestaurant } from "@bagour/api-client/factories";
 *   const r = makeRestaurant({ name: "Test", rating: 5 });
 */

import type { AuthTokens, BaseUser, Customer, Driver, Order, Restaurant } from "@bagour/types";

const NOW = "2026-05-13T12:00:00.000Z";

let userCounter = 0;
let restaurantCounter = 0;
let orderCounter = 0;

const nextId = (prefix: string, counter: { value: number }) => {
  counter.value += 1;
  return `${prefix}_${counter.value.toString().padStart(6, "0")}`;
};

const userCtr = { value: 0 };
const restaurantCtr = { value: 0 };
const orderCtr = { value: 0 };
const driverCtr = { value: 0 };

export function makeBaseUser(overrides: Partial<BaseUser> = {}): BaseUser {
  userCounter += 1;
  const id = overrides.id ?? nextId("user", userCtr);
  return {
    id,
    email: overrides.email ?? `${id}@bagour.test`,
    phone: overrides.phone ?? "01012345678",
    name: overrides.name ?? `Test User ${userCounter}`,
    role: overrides.role ?? "customer",
    isActive: overrides.isActive ?? true,
    isBlocked: overrides.isBlocked ?? false,
    isEmailVerified: overrides.isEmailVerified ?? true,
    isPhoneVerified: overrides.isPhoneVerified ?? true,
    fcmTokens: overrides.fcmTokens ?? [],
    avatar: overrides.avatar,
    lastLogin: overrides.lastLogin,
    createdAt: overrides.createdAt ?? NOW,
    updatedAt: overrides.updatedAt ?? NOW,
  };
}

export function makeAuthTokens(overrides: Partial<AuthTokens> = {}): AuthTokens {
  return {
    accessToken: overrides.accessToken ?? "test-access-token",
    refreshToken: overrides.refreshToken ?? "test-refresh-token",
    expiresIn: overrides.expiresIn ?? 3600,
  };
}

export function makeCustomer(overrides: Partial<Customer> = {}): Customer {
  const id = overrides.id ?? nextId("cust", userCtr);
  return {
    id,
    userId: overrides.userId ?? id,
    user: overrides.user,
    addresses: overrides.addresses ?? [],
    favoriteRestaurants: overrides.favoriteRestaurants ?? [],
    totalOrders: overrides.totalOrders ?? 0,
    totalSpent: overrides.totalSpent ?? 0,
    loyaltyPoints: overrides.loyaltyPoints ?? 0,
    referralCode: overrides.referralCode ?? "BAG-TEST",
    referredBy: overrides.referredBy,
  };
}

export function makeRestaurant(overrides: Partial<Restaurant> = {}): Restaurant {
  restaurantCounter += 1;
  const id = overrides.id ?? nextId("rest", restaurantCtr);
  return {
    id,
    userId: overrides.userId ?? `user_${id}`,
    name: overrides.name ?? `Restaurant ${restaurantCounter}`,
    nameEn: overrides.nameEn,
    description: overrides.description,
    descriptionEn: overrides.descriptionEn,
    email: overrides.email ?? `${id}@bagour.test`,
    phone: overrides.phone ?? "01012345678",
    logo: overrides.logo,
    coverImage: overrides.coverImage,
    images: overrides.images ?? [],
    status: overrides.status ?? "approved",
    isOpen: overrides.isOpen ?? true,
    address: overrides.address ?? { street: "Main", area: "Bagour", city: "Monufia" },
    cuisineTypes: overrides.cuisineTypes ?? ["egyptian"],
    tags: overrides.tags ?? [],
    workingHours: overrides.workingHours ?? [],
    rating: overrides.rating ?? 4.5,
    totalReviews: overrides.totalReviews ?? 0,
    totalOrders: overrides.totalOrders ?? 0,
    minimumOrder: overrides.minimumOrder ?? 30,
    deliveryTime: overrides.deliveryTime ?? { min: 20, max: 35 },
    deliveryFee: overrides.deliveryFee ?? 10,
    commissionRate: overrides.commissionRate ?? 0.15,
    features: overrides.features ?? {
      acceptsOnlinePayment: true,
      hasDelivery: true,
      hasPickup: false,
      hasDineIn: false,
    },
    createdAt: overrides.createdAt ?? NOW,
    updatedAt: overrides.updatedAt ?? NOW,
  };
}

export function makeOrder(overrides: Partial<Order> = {}): Order {
  orderCounter += 1;
  const id = overrides.id ?? nextId("ord", orderCtr);
  const orderNumber = overrides.orderNumber ?? `BG-${orderCounter.toString().padStart(5, "0")}`;
  return {
    id,
    orderNumber,
    customerId: overrides.customerId ?? "cust_test",
    restaurantId: overrides.restaurantId ?? "rest_test",
    driverId: overrides.driverId,
    items: overrides.items ?? [
      {
        menuItemId: "item_1",
        name: "Koshary",
        quantity: 1,
        price: 35,
        addons: [],
        options: [],
        itemTotal: 35,
      },
    ],
    subtotal: overrides.subtotal ?? 35,
    deliveryFee: overrides.deliveryFee ?? 10,
    serviceFee: overrides.serviceFee ?? 0,
    tax: overrides.tax ?? 0,
    discount: overrides.discount ?? 0,
    tip: overrides.tip ?? 0,
    total: overrides.total ?? 45,
    commission: overrides.commission ?? 0,
    restaurantEarnings: overrides.restaurantEarnings ?? 0,
    driverEarnings: overrides.driverEarnings ?? 0,
    status: overrides.status ?? "pending",
    statusHistory: overrides.statusHistory ?? [{ status: "pending", timestamp: NOW }],
    paymentMethod: overrides.paymentMethod ?? "cash",
    paymentStatus: overrides.paymentStatus ?? "pending",
    paymentReference: overrides.paymentReference,
    deliveryAddress: overrides.deliveryAddress ?? {
      street: "Main",
      area: "Bagour",
      city: "Monufia",
    },
    deliveryLocation: overrides.deliveryLocation ?? {
      type: "Point",
      coordinates: [30.9667, 30.45],
    },
    deliveryInstructions: overrides.deliveryInstructions,
    estimatedDeliveryTime: overrides.estimatedDeliveryTime,
    actualDeliveryTime: overrides.actualDeliveryTime,
    estimatedPickupTime: overrides.estimatedPickupTime,
    actualPickupTime: overrides.actualPickupTime,
    couponId: overrides.couponId,
    couponCode: overrides.couponCode,
    notes: overrides.notes,
    cancelReason: overrides.cancelReason,
    cancelledBy: overrides.cancelledBy,
    rating: overrides.rating,
    isScheduled: overrides.isScheduled ?? false,
    scheduledFor: overrides.scheduledFor,
    createdAt: overrides.createdAt ?? NOW,
    updatedAt: overrides.updatedAt ?? NOW,
  };
}

export function makeDriver(overrides: Partial<Driver> = {}): Driver {
  const id = overrides.id ?? nextId("drv", driverCtr);
  return {
    id,
    userId: overrides.userId ?? `user_${id}`,
    nationalId: overrides.nationalId ?? "12345678901234",
    dateOfBirth: overrides.dateOfBirth ?? "1995-01-01T00:00:00.000Z",
    vehicleType: overrides.vehicleType ?? "motorcycle",
    vehicleModel: overrides.vehicleModel,
    vehicleColor: overrides.vehicleColor,
    vehiclePlateNumber: overrides.vehiclePlateNumber ?? "ABC1234",
    licenseNumber: overrides.licenseNumber ?? "LIC123",
    licenseExpiryDate: overrides.licenseExpiryDate ?? "2028-01-01T00:00:00.000Z",
    documents: overrides.documents ?? {},
    status: overrides.status ?? "approved",
    rejectionReason: overrides.rejectionReason,
    isOnline: overrides.isOnline ?? false,
    isAvailable: overrides.isAvailable ?? false,
    currentLocation: overrides.currentLocation,
    currentOrderId: overrides.currentOrderId,
    rating: overrides.rating ?? 4.7,
    totalReviews: overrides.totalReviews ?? 0,
    totalDeliveries: overrides.totalDeliveries ?? 0,
    totalEarnings: overrides.totalEarnings ?? 0,
    walletBalance: overrides.walletBalance ?? 0,
    bankDetails: overrides.bankDetails,
    zones: overrides.zones ?? [],
    createdAt: overrides.createdAt ?? NOW,
    updatedAt: overrides.updatedAt ?? NOW,
  };
}
