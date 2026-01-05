export const APP_CONFIG = {
  name: 'Bagour Delivery - Admin Dashboard',
  nameAr: 'باجور ديليفري - لوحة تحكم المسؤول',
  version: '1.0.0',
  description: 'Admin management dashboard for Bagour Delivery',
};

export const API_CONFIG = {
  baseUrl: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api/v1',
  socketUrl: process.env.NEXT_PUBLIC_SOCKET_URL || 'http://localhost:5000',
  timeout: 30000,
};

export const STORAGE_KEYS = {
  accessToken: 'admin_access_token',
  refreshToken: 'admin_refresh_token',
  adminData: 'admin_data',
  theme: 'theme',
  language: 'language',
};

export const PAGINATION = {
  defaultPageSize: 20,
  usersPageSize: 25,
  ordersPageSize: 15,
  restaurantsPageSize: 20,
};

export const USER_ROLES = {
  admin: { label: 'مسؤول', labelEn: 'Admin', color: 'purple' },
  customer: { label: 'عميل', labelEn: 'Customer', color: 'blue' },
  restaurant: { label: 'مطعم', labelEn: 'Restaurant', color: 'orange' },
  driver: { label: 'سائق', labelEn: 'Driver', color: 'green' },
} as const;

export const ORDER_STATUSES = {
  pending: { label: 'قيد الانتظار', labelEn: 'Pending', color: 'orange' },
  confirmed: { label: 'مؤكد', labelEn: 'Confirmed', color: 'blue' },
  preparing: { label: 'جاري التحضير', labelEn: 'Preparing', color: 'purple' },
  ready: { label: 'جاهز', labelEn: 'Ready', color: 'green' },
  picked_up: { label: 'تم الاستلام', labelEn: 'Picked Up', color: 'teal' },
  on_the_way: { label: 'في الطريق', labelEn: 'On The Way', color: 'indigo' },
  delivered: { label: 'تم التوصيل', labelEn: 'Delivered', color: 'green' },
  cancelled: { label: 'ملغي', labelEn: 'Cancelled', color: 'red' },
} as const;

export const RESTAURANT_STATUSES = {
  pending: { label: 'قيد المراجعة', labelEn: 'Pending', color: 'orange' },
  approved: { label: 'موافق عليه', labelEn: 'Approved', color: 'green' },
  rejected: { label: 'مرفوض', labelEn: 'Rejected', color: 'red' },
  suspended: { label: 'موقوف', labelEn: 'Suspended', color: 'gray' },
} as const;

export const DRIVER_STATUSES = {
  pending: { label: 'قيد المراجعة', labelEn: 'Pending', color: 'orange' },
  approved: { label: 'موافق عليه', labelEn: 'Approved', color: 'green' },
  rejected: { label: 'مرفوض', labelEn: 'Rejected', color: 'red' },
  suspended: { label: 'موقوف', labelEn: 'Suspended', color: 'gray' },
} as const;

export const TRANSACTION_TYPES = {
  order_payment: { label: 'دفع طلب', labelEn: 'Order Payment' },
  refund: { label: 'استرداد', labelEn: 'Refund' },
  driver_payout: { label: 'دفع للسائق', labelEn: 'Driver Payout' },
  restaurant_payout: { label: 'دفع للمطعم', labelEn: 'Restaurant Payout' },
  commission: { label: 'عمولة', labelEn: 'Commission' },
} as const;

export const ROUTES = {
  // Auth
  login: '/login',

  // Dashboard
  dashboard: '/dashboard',
  users: '/dashboard/users',
  restaurants: '/dashboard/restaurants',
  drivers: '/dashboard/drivers',
  orders: '/dashboard/orders',
  coupons: '/dashboard/coupons',
  zones: '/dashboard/zones',
  analytics: '/dashboard/analytics',
  settings: '/dashboard/settings',
};

export const API_ENDPOINTS = {
  // Auth - Unified endpoint with role parameter
  login: '/auth/login',
  refreshToken: '/auth/refresh-token',
  logout: '/auth/logout',

  // Users
  users: '/admin/users',
  userDetails: '/admin/users/:id',
  blockUser: '/admin/users/:id/block',

  // Restaurants
  restaurants: '/admin/restaurants',
  restaurantDetails: '/admin/restaurants/:id',
  approveRestaurant: '/admin/restaurants/:id/approve',
  rejectRestaurant: '/admin/restaurants/:id/reject',
  suspendRestaurant: '/admin/restaurants/:id/suspend',

  // Drivers
  drivers: '/admin/drivers',
  driverDetails: '/admin/drivers/:id',
  approveDriver: '/admin/drivers/:id/approve',
  rejectDriver: '/admin/drivers/:id/reject',
  suspendDriver: '/admin/drivers/:id/suspend',

  // Orders
  orders: '/admin/orders',
  orderDetails: '/admin/orders/:id',

  // Coupons
  coupons: '/admin/coupons',
  couponDetails: '/admin/coupons/:id',

  // Zones
  zones: '/admin/zones',
  zoneDetails: '/admin/zones/:id',

  // Analytics
  analytics: '/admin/analytics',
  dashboardStats: '/admin/analytics/dashboard',
  revenueReport: '/admin/analytics/revenue',

  // Settings
  settings: '/admin/settings',

  // Transactions
  transactions: '/admin/transactions',
};
