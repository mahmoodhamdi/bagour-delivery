/**
 * Re-exported from `shared/constants/index.ts` so the web apps don't need
 * to walk relative paths. If shared/constants drifts, update this barrel.
 */

export const APP_CONFIG = {
  name: "Bagour Delivery",
  nameAr: "باجور ديليفري",
  version: "1.0.0",
  defaultLanguage: "ar" as const,
  supportedLanguages: ["ar", "en"] as const,
  currency: "EGP",
  currencySymbol: "ج.م",
  timezone: "Africa/Cairo",
} as const;

export const BAGOUR_LOCATION = {
  lat: 30.45,
  lng: 30.9667,
  name: "Bagour",
  nameAr: "باجور",
  governorate: "Monufia",
  governorateAr: "المنوفية",
} as const;

export const ORDER_STATUS_META = {
  pending: { label: "قيد الانتظار", labelEn: "Pending", color: "#F59E0B" },
  confirmed: { label: "مؤكد", labelEn: "Confirmed", color: "#3B82F6" },
  preparing: { label: "جاري التحضير", labelEn: "Preparing", color: "#8B5CF6" },
  ready: { label: "جاهز للاستلام", labelEn: "Ready", color: "#10B981" },
  picked_up: { label: "تم الاستلام", labelEn: "Picked Up", color: "#14B8A6" },
  on_the_way: { label: "في الطريق", labelEn: "On The Way", color: "#6366F1" },
  delivered: { label: "تم التوصيل", labelEn: "Delivered", color: "#22C55E" },
  cancelled: { label: "ملغي", labelEn: "Cancelled", color: "#EF4444" },
} as const;

export const PAYMENT_METHODS_META = {
  cash: { label: "الدفع عند الاستلام", labelEn: "Cash on Delivery", icon: "banknote" },
  card: { label: "بطاقة ائتمان", labelEn: "Credit Card", icon: "credit-card" },
  wallet: { label: "المحفظة", labelEn: "Wallet", icon: "wallet" },
} as const;

export const VEHICLE_TYPES_META = {
  motorcycle: { label: "دراجة نارية", labelEn: "Motorcycle", icon: "motorcycle" },
  bicycle: { label: "دراجة هوائية", labelEn: "Bicycle", icon: "bicycle" },
  car: { label: "سيارة", labelEn: "Car", icon: "car" },
} as const;

export const CUISINE_TYPES = [
  { key: "egyptian", label: "مصري", labelEn: "Egyptian" },
  { key: "grills", label: "مشويات", labelEn: "Grills" },
  { key: "seafood", label: "مأكولات بحرية", labelEn: "Seafood" },
  { key: "pizza", label: "بيتزا", labelEn: "Pizza" },
  { key: "burger", label: "برجر", labelEn: "Burger" },
  { key: "sandwiches", label: "ساندويتشات", labelEn: "Sandwiches" },
  { key: "shawarma", label: "شاورما", labelEn: "Shawarma" },
  { key: "koshary", label: "كشري", labelEn: "Koshary" },
  { key: "foul", label: "فول وفلافل", labelEn: "Foul & Falafel" },
  { key: "chicken", label: "دجاج", labelEn: "Chicken" },
  { key: "desserts", label: "حلويات", labelEn: "Desserts" },
  { key: "beverages", label: "مشروبات", labelEn: "Beverages" },
  { key: "oriental", label: "شرقي", labelEn: "Oriental" },
  { key: "healthy", label: "صحي", labelEn: "Healthy" },
  { key: "fast_food", label: "وجبات سريعة", labelEn: "Fast Food" },
] as const;

export const VALIDATION = {
  password: { minLength: 8, maxLength: 128 },
  phone: { egyptPattern: /^01[0125][0-9]{8}$/, length: 11 },
  otp: { length: 6 },
  name: { minLength: 2, maxLength: 50 },
  nationalId: { length: 14, pattern: /^[0-9]{14}$/ },
} as const;

export const PAGINATION = {
  defaultPage: 1,
  defaultLimit: 20,
  maxLimit: 100,
} as const;

export const TIMEOUTS = {
  api: 30_000,
  orderAccept: 30_000,
  locationUpdate: 10_000,
} as const;

export type CuisineKey = (typeof CUISINE_TYPES)[number]["key"];
