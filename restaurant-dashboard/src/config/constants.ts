export const APP_CONFIG = {
  name: 'Bagour Delivery - Restaurant Dashboard',
  nameAr: 'باجور ديليفري - لوحة تحكم المطعم',
  version: '1.0.0',
  description: 'Restaurant management dashboard for Bagour Delivery',
};

export const API_CONFIG = {
  baseUrl: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api/v1',
  socketUrl: process.env.NEXT_PUBLIC_SOCKET_URL || 'http://localhost:5000',
  timeout: 30000,
};

export const STORAGE_KEYS = {
  accessToken: 'access_token',
  refreshToken: 'refresh_token',
  restaurantData: 'restaurant_data',
  theme: 'theme',
  language: 'language',
};

export const PAGINATION = {
  defaultPageSize: 20,
  ordersPageSize: 15,
  menuPageSize: 30,
};

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

export const MENU_ITEM_STATUSES = {
  available: { label: 'متاح', labelEn: 'Available', color: 'green' },
  unavailable: { label: 'غير متاح', labelEn: 'Unavailable', color: 'red' },
  out_of_stock: { label: 'نفذ المخزون', labelEn: 'Out of Stock', color: 'orange' },
} as const;

export const DAYS_OF_WEEK = [
  { key: 'sunday', label: 'الأحد', labelEn: 'Sunday' },
  { key: 'monday', label: 'الإثنين', labelEn: 'Monday' },
  { key: 'tuesday', label: 'الثلاثاء', labelEn: 'Tuesday' },
  { key: 'wednesday', label: 'الأربعاء', labelEn: 'Wednesday' },
  { key: 'thursday', label: 'الخميس', labelEn: 'Thursday' },
  { key: 'friday', label: 'الجمعة', labelEn: 'Friday' },
  { key: 'saturday', label: 'السبت', labelEn: 'Saturday' },
] as const;

export const ROUTES = {
  // Auth routes
  login: '/login',
  register: '/register',
  forgotPassword: '/forgot-password',

  // Dashboard routes
  dashboard: '/dashboard',
  orders: '/dashboard/orders',
  menu: '/dashboard/menu',
  analytics: '/dashboard/analytics',
  settings: '/dashboard/settings',
  profile: '/dashboard/profile',
};

export const API_ENDPOINTS = {
  // Auth
  login: '/auth/restaurant/login',
  register: '/auth/restaurant/register',
  verifyOtp: '/auth/verify-otp',
  resendOtp: '/auth/resend-otp',
  forgotPassword: '/auth/forgot-password',
  resetPassword: '/auth/reset-password',
  refreshToken: '/auth/refresh-token',
  logout: '/auth/logout',

  // Restaurant
  profile: '/restaurants/profile',
  updateProfile: '/restaurants/profile',
  updateWorkingHours: '/restaurants/working-hours',
  toggleOpen: '/restaurants/toggle-open',
  uploadImages: '/restaurants/images',

  // Menu
  categories: '/restaurants/menu/categories',
  menuItems: '/restaurants/menu/items',
  toggleItemAvailability: '/restaurants/menu/items/toggle',

  // Orders
  orders: '/restaurants/orders',
  orderDetails: '/restaurants/orders/:id',
  updateOrderStatus: '/restaurants/orders/:id/status',
  acceptOrder: '/restaurants/orders/:id/accept',
  rejectOrder: '/restaurants/orders/:id/reject',

  // Analytics
  analytics: '/restaurants/analytics',
  earnings: '/restaurants/earnings',

  // Notifications
  notifications: '/restaurants/notifications',
  registerFcm: '/restaurants/fcm-token',
};
