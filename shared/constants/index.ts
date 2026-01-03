// App Configuration
export const APP_CONFIG = {
  name: 'Bagour Delivery',
  nameAr: 'باجور ديليفري',
  version: '1.0.0',
  defaultLanguage: 'ar' as const,
  supportedLanguages: ['ar', 'en'] as const,
  currency: 'EGP',
  currencySymbol: 'ج.م',
  timezone: 'Africa/Cairo',
};

// Bagour City Location
export const BAGOUR_LOCATION = {
  lat: 30.4500,
  lng: 30.9667,
  name: 'Bagour',
  nameAr: 'باجور',
  governorate: 'Monufia',
  governorateAr: 'المنوفية',
};

// Order Statuses
export const ORDER_STATUSES = {
  pending: { label: 'قيد الانتظار', labelEn: 'Pending', color: '#F59E0B' },
  confirmed: { label: 'مؤكد', labelEn: 'Confirmed', color: '#3B82F6' },
  preparing: { label: 'جاري التحضير', labelEn: 'Preparing', color: '#8B5CF6' },
  ready: { label: 'جاهز للاستلام', labelEn: 'Ready', color: '#10B981' },
  picked_up: { label: 'تم الاستلام', labelEn: 'Picked Up', color: '#14B8A6' },
  on_the_way: { label: 'في الطريق', labelEn: 'On The Way', color: '#6366F1' },
  delivered: { label: 'تم التوصيل', labelEn: 'Delivered', color: '#22C55E' },
  cancelled: { label: 'ملغي', labelEn: 'Cancelled', color: '#EF4444' },
} as const;

// User Roles
export const USER_ROLES = {
  customer: { label: 'عميل', labelEn: 'Customer' },
  restaurant: { label: 'مطعم', labelEn: 'Restaurant' },
  driver: { label: 'سائق', labelEn: 'Driver' },
  admin: { label: 'مسؤول', labelEn: 'Admin' },
} as const;

// Restaurant Statuses
export const RESTAURANT_STATUSES = {
  pending: { label: 'قيد المراجعة', labelEn: 'Pending', color: '#F59E0B' },
  approved: { label: 'موافق عليه', labelEn: 'Approved', color: '#22C55E' },
  rejected: { label: 'مرفوض', labelEn: 'Rejected', color: '#EF4444' },
  suspended: { label: 'موقوف', labelEn: 'Suspended', color: '#6B7280' },
} as const;

// Driver Statuses
export const DRIVER_STATUSES = {
  pending: { label: 'قيد المراجعة', labelEn: 'Pending', color: '#F59E0B' },
  approved: { label: 'موافق عليه', labelEn: 'Approved', color: '#22C55E' },
  rejected: { label: 'مرفوض', labelEn: 'Rejected', color: '#EF4444' },
  suspended: { label: 'موقوف', labelEn: 'Suspended', color: '#6B7280' },
} as const;

// Vehicle Types
export const VEHICLE_TYPES = {
  motorcycle: { label: 'دراجة نارية', labelEn: 'Motorcycle', icon: 'motorcycle' },
  bicycle: { label: 'دراجة هوائية', labelEn: 'Bicycle', icon: 'bicycle' },
  car: { label: 'سيارة', labelEn: 'Car', icon: 'car' },
} as const;

// Payment Methods
export const PAYMENT_METHODS = {
  cash: { label: 'الدفع عند الاستلام', labelEn: 'Cash on Delivery', icon: 'cash' },
  card: { label: 'بطاقة ائتمان', labelEn: 'Credit Card', icon: 'card' },
  wallet: { label: 'المحفظة', labelEn: 'Wallet', icon: 'wallet' },
} as const;

// Days of Week
export const DAYS_OF_WEEK = [
  { key: 'sunday', label: 'الأحد', labelEn: 'Sunday' },
  { key: 'monday', label: 'الإثنين', labelEn: 'Monday' },
  { key: 'tuesday', label: 'الثلاثاء', labelEn: 'Tuesday' },
  { key: 'wednesday', label: 'الأربعاء', labelEn: 'Wednesday' },
  { key: 'thursday', label: 'الخميس', labelEn: 'Thursday' },
  { key: 'friday', label: 'الجمعة', labelEn: 'Friday' },
  { key: 'saturday', label: 'السبت', labelEn: 'Saturday' },
] as const;

// Cuisine Types
export const CUISINE_TYPES = [
  { key: 'egyptian', label: 'مصري', labelEn: 'Egyptian' },
  { key: 'grills', label: 'مشويات', labelEn: 'Grills' },
  { key: 'seafood', label: 'مأكولات بحرية', labelEn: 'Seafood' },
  { key: 'pizza', label: 'بيتزا', labelEn: 'Pizza' },
  { key: 'burger', label: 'برجر', labelEn: 'Burger' },
  { key: 'sandwiches', label: 'ساندويتشات', labelEn: 'Sandwiches' },
  { key: 'shawarma', label: 'شاورما', labelEn: 'Shawarma' },
  { key: 'koshary', label: 'كشري', labelEn: 'Koshary' },
  { key: 'foul', label: 'فول وفلافل', labelEn: 'Foul & Falafel' },
  { key: 'chicken', label: 'دجاج', labelEn: 'Chicken' },
  { key: 'desserts', label: 'حلويات', labelEn: 'Desserts' },
  { key: 'beverages', label: 'مشروبات', labelEn: 'Beverages' },
  { key: 'oriental', label: 'شرقي', labelEn: 'Oriental' },
  { key: 'healthy', label: 'صحي', labelEn: 'Healthy' },
  { key: 'fast_food', label: 'وجبات سريعة', labelEn: 'Fast Food' },
] as const;

// Validation Rules
export const VALIDATION = {
  password: {
    minLength: 8,
    maxLength: 128,
  },
  phone: {
    egyptPattern: /^01[0125][0-9]{8}$/,
    length: 11,
  },
  otp: {
    length: 6,
  },
  name: {
    minLength: 2,
    maxLength: 50,
  },
  nationalId: {
    length: 14,
    pattern: /^[0-9]{14}$/,
  },
} as const;

// Pagination Defaults
export const PAGINATION = {
  defaultPage: 1,
  defaultLimit: 20,
  maxLimit: 100,
} as const;

// Timeouts (in milliseconds)
export const TIMEOUTS = {
  api: 30000,
  orderAccept: 60000,
  locationUpdate: 10000,
} as const;
