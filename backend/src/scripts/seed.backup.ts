import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import { config } from '../config';
import { logger } from '../utils/logger';
import {
  User,
  Customer,
  Driver,
  Restaurant,
  MenuCategory,
  MenuItem,
  Zone,
  Setting,
  defaultSettings,
} from '../models';
import { Order } from '../models/Order';
import { Coupon } from '../models/Coupon';
import { Review } from '../models/Review';
import { Notification } from '../models/Notification';
import { Transaction } from '../models/Transaction';

// Bagour city center coordinates
const BAGOUR_CENTER = { lat: 30.4167, lng: 30.9667 };

// Helper to generate random coordinates near Bagour
const randomNearbyCoords = (offsetKm = 3) => {
  const latOffset = (Math.random() - 0.5) * (offsetKm / 111);
  const lngOffset = (Math.random() - 0.5) * (offsetKm / 85);
  return [BAGOUR_CENTER.lng + lngOffset, BAGOUR_CENTER.lat + latOffset];
};

// Helper to generate order number
const generateOrderNumber = (date: Date, index: number) => {
  const dateStr = date.toISOString().split('T')[0].replace(/-/g, '');
  return `ORD-${dateStr}-${String(index).padStart(3, '0')}`;
};

const seedDatabase = async () => {
  try {
    // Connect to database
    await mongoose.connect(config.mongoUri);
    logger.info('Connected to MongoDB');

    // Clear existing data
    logger.info('Clearing existing data...');
    await Promise.all([
      User.deleteMany({}),
      Customer.deleteMany({}),
      Driver.deleteMany({}),
      Restaurant.deleteMany({}),
      MenuCategory.deleteMany({}),
      MenuItem.deleteMany({}),
      Zone.deleteMany({}),
      Setting.deleteMany({}),
      Order.deleteMany({}),
      Coupon.deleteMany({}),
      Review.deleteMany({}),
      Notification.deleteMany({}),
      Transaction.deleteMany({}),
    ]);

    // ==================== SETTINGS ====================
    logger.info('Seeding settings...');
    await Setting.insertMany(defaultSettings);

    // ==================== ADMIN USER ====================
    logger.info('Seeding admin user...');
    const hashedPassword = await bcrypt.hash('Admin@123', 12);
    const adminUser = await User.create({
      role: 'admin',
      email: 'admin@bagour-delivery.com',
      phone: '+201000000000',
      password: hashedPassword,
      name: 'مدير النظام',
      isEmailVerified: true,
      isPhoneVerified: true,
      isActive: true,
    });

    // ==================== ZONES ====================
    logger.info('Seeding delivery zones...');
    const zones = await Zone.insertMany([
      {
        name: 'Bagour City Center',
        nameAr: 'وسط الباجور',
        coordinates: {
          type: 'Polygon',
          coordinates: [[
            [30.95, 30.40],
            [30.98, 30.40],
            [30.98, 30.43],
            [30.95, 30.43],
            [30.95, 30.40],
          ]],
        },
        deliveryFee: 10,
        minimumOrder: 30,
        isActive: true,
      },
      {
        name: 'East Bagour',
        nameAr: 'شرق الباجور',
        coordinates: {
          type: 'Polygon',
          coordinates: [[
            [30.98, 30.40],
            [31.01, 30.40],
            [31.01, 30.43],
            [30.98, 30.43],
            [30.98, 30.40],
          ]],
        },
        deliveryFee: 15,
        minimumOrder: 40,
        isActive: true,
      },
      {
        name: 'West Bagour',
        nameAr: 'غرب الباجور',
        coordinates: {
          type: 'Polygon',
          coordinates: [[
            [30.92, 30.40],
            [30.95, 30.40],
            [30.95, 30.43],
            [30.92, 30.43],
            [30.92, 30.40],
          ]],
        },
        deliveryFee: 15,
        minimumOrder: 40,
        isActive: true,
      },
    ]);

    // ==================== CUSTOMERS ====================
    logger.info('Seeding customers...');
    const customerData = [
      { name: 'أحمد محمد', email: 'ahmed@test.com', phone: '+201111111111' },
      { name: 'محمد علي', email: 'mohamed@test.com', phone: '+201111111112' },
      { name: 'فاطمة حسن', email: 'fatma@test.com', phone: '+201111111113' },
      { name: 'سارة أحمد', email: 'sara@test.com', phone: '+201111111114' },
      { name: 'علي إبراهيم', email: 'ali@test.com', phone: '+201111111115' },
      { name: 'نور الدين', email: 'nour@test.com', phone: '+201111111116' },
      { name: 'ياسمين محمود', email: 'yasmin@test.com', phone: '+201111111117' },
      { name: 'كريم سعيد', email: 'karim@test.com', phone: '+201111111118' },
      { name: 'هدى عبدالله', email: 'hoda@test.com', phone: '+201111111119' },
      { name: 'عمر خالد', email: 'omar@test.com', phone: '+201111111120' },
    ];

    const customers: { user: mongoose.Document; customer: mongoose.Document }[] = [];
    const testPassword = await bcrypt.hash('Test@123', 12);

    for (const data of customerData) {
      const user = await User.create({
        role: 'customer',
        email: data.email,
        phone: data.phone,
        password: testPassword,
        name: data.name,
        isEmailVerified: true,
        isPhoneVerified: true,
        isActive: true,
      });

      const customer = await Customer.create({
        userId: user._id,
        addresses: [
          {
            label: 'home',
            name: 'المنزل',
            address: 'شارع الجمهورية، الباجور',
            area: 'وسط البلد',
            city: 'الباجور',
            location: {
              type: 'Point',
              coordinates: randomNearbyCoords(),
            },
            isDefault: true,
          },
          {
            label: 'work',
            name: 'العمل',
            address: 'شارع النيل، الباجور',
            area: 'حي الشرق',
            city: 'الباجور',
            location: {
              type: 'Point',
              coordinates: randomNearbyCoords(),
            },
            isDefault: false,
          },
        ],
        loyaltyPoints: Math.floor(Math.random() * 500),
      });

      customers.push({ user, customer });
    }

    // ==================== RESTAURANTS ====================
    logger.info('Seeding restaurants...');
    const restaurantData = [
      {
        name: 'Bagouri Kitchen',
        nameAr: 'مطبخ الباجوري',
        desc: 'Best local food in Bagour',
        descAr: 'أفضل الأكلات المحلية في الباجور',
        cuisine: ['مصري', 'شرقي'],
        priceRange: 2,
      },
      {
        name: 'Shawarma Palace',
        nameAr: 'قصر الشاورما',
        desc: 'Premium shawarma and grills',
        descAr: 'شاورما ومشويات فاخرة',
        cuisine: ['شامي', 'مشويات'],
        priceRange: 2,
      },
      {
        name: 'Pizza House',
        nameAr: 'بيتزا هاوس',
        desc: 'Fresh Italian pizza',
        descAr: 'بيتزا إيطالية طازجة',
        cuisine: ['إيطالي', 'بيتزا'],
        priceRange: 3,
      },
      {
        name: 'Koshary Station',
        nameAr: 'محطة الكشري',
        desc: 'Authentic Egyptian koshary',
        descAr: 'كشري مصري أصيل',
        cuisine: ['مصري'],
        priceRange: 1,
      },
      {
        name: 'Seafood Corner',
        nameAr: 'ركن المأكولات البحرية',
        desc: 'Fresh seafood daily',
        descAr: 'مأكولات بحرية طازجة يومياً',
        cuisine: ['مأكولات بحرية'],
        priceRange: 3,
      },
    ];

    const restaurants: { user: mongoose.Document; restaurant: mongoose.Document }[] = [];

    for (let i = 0; i < restaurantData.length; i++) {
      const data = restaurantData[i];
      const user = await User.create({
        role: 'restaurant',
        email: `restaurant${i + 1}@test.com`,
        phone: `+20122222222${i}`,
        password: testPassword,
        name: `صاحب ${data.nameAr}`,
        isEmailVerified: true,
        isPhoneVerified: true,
        isActive: true,
      });

      const restaurant = await Restaurant.create({
        userId: user._id,
        name: data.name,
        nameAr: data.nameAr,
        slug: data.name.toLowerCase().replace(/\s+/g, '-'),
        description: data.desc,
        descriptionAr: data.descAr,
        logo: `https://via.placeholder.com/200?text=${encodeURIComponent(data.name)}`,
        coverImage: `https://via.placeholder.com/800x400?text=${encodeURIComponent(data.name)}`,
        categories: data.cuisine,
        priceRange: data.priceRange as 1 | 2 | 3,
        address: 'شارع النيل، وسط البلد، الباجور',
        area: 'وسط البلد',
        location: {
          type: 'Point',
          coordinates: randomNearbyCoords(2),
        },
        phone: `0122222222${i}`,
        minimumOrder: 30 + i * 10,
        deliveryFee: 10 + i * 2,
        estimatedDeliveryTime: {
          min: 20 + i * 5,
          max: 35 + i * 5,
        },
        rating: Math.round((3.5 + Math.random() * 1.5) * 10) / 10,
        totalRatings: Math.floor(Math.random() * 200) + 50,
        isApproved: true,
        approvedAt: new Date(),
        approvedBy: adminUser._id,
        isActive: true,
        workingHours: [
          { day: 0, isOpen: true, shifts: [{ open: '09:00', close: '23:00' }] },
          { day: 1, isOpen: true, shifts: [{ open: '09:00', close: '23:00' }] },
          { day: 2, isOpen: true, shifts: [{ open: '09:00', close: '23:00' }] },
          { day: 3, isOpen: true, shifts: [{ open: '09:00', close: '23:00' }] },
          { day: 4, isOpen: true, shifts: [{ open: '09:00', close: '23:00' }] },
          { day: 5, isOpen: true, shifts: [{ open: '12:00', close: '23:00' }] },
          { day: 6, isOpen: true, shifts: [{ open: '09:00', close: '23:00' }] },
        ],
      });

      restaurants.push({ user, restaurant });
    }

    // ==================== MENU CATEGORIES & ITEMS ====================
    logger.info('Seeding menu categories and items...');
    const menuData: Record<string, { categories: string[]; items: { cat: number; name: string; nameAr: string; price: number; popular?: boolean }[] }> = {
      0: { // Bagouri Kitchen
        categories: ['المشويات', 'الأرز والمكرونة', 'السلطات', 'المشروبات'],
        items: [
          { cat: 0, name: 'Mixed Grill', nameAr: 'مشويات مشكلة', price: 120, popular: true },
          { cat: 0, name: 'Grilled Chicken', nameAr: 'فراخ مشوية', price: 70 },
          { cat: 0, name: 'Kofta', nameAr: 'كفتة', price: 80 },
          { cat: 0, name: 'Kebab', nameAr: 'كباب', price: 90, popular: true },
          { cat: 1, name: 'Rice with Meat', nameAr: 'أرز باللحم', price: 60 },
          { cat: 1, name: 'Pasta', nameAr: 'مكرونة', price: 40 },
          { cat: 2, name: 'Green Salad', nameAr: 'سلطة خضراء', price: 20 },
          { cat: 2, name: 'Tahini', nameAr: 'طحينة', price: 15 },
          { cat: 3, name: 'Cola', nameAr: 'كولا', price: 10 },
          { cat: 3, name: 'Water', nameAr: 'مياه', price: 5 },
        ],
      },
      1: { // Shawarma Palace
        categories: ['الشاورما', 'المشويات', 'الوجبات', 'المشروبات'],
        items: [
          { cat: 0, name: 'Chicken Shawarma', nameAr: 'شاورما فراخ', price: 25, popular: true },
          { cat: 0, name: 'Meat Shawarma', nameAr: 'شاورما لحم', price: 35, popular: true },
          { cat: 0, name: 'Mixed Shawarma', nameAr: 'شاورما مكس', price: 40 },
          { cat: 1, name: 'Grilled Kofta', nameAr: 'كفتة مشوية', price: 70 },
          { cat: 2, name: 'Shawarma Meal', nameAr: 'وجبة شاورما', price: 50 },
          { cat: 2, name: 'Family Meal', nameAr: 'وجبة عائلية', price: 150, popular: true },
          { cat: 3, name: 'Fresh Juice', nameAr: 'عصير طازج', price: 15 },
          { cat: 3, name: 'Ayran', nameAr: 'عيران', price: 10 },
        ],
      },
      2: { // Pizza House
        categories: ['البيتزا', 'المقبلات', 'الحلويات', 'المشروبات'],
        items: [
          { cat: 0, name: 'Margherita', nameAr: 'مارجريتا', price: 60 },
          { cat: 0, name: 'Pepperoni', nameAr: 'بيبروني', price: 80, popular: true },
          { cat: 0, name: 'Supreme', nameAr: 'سوبريم', price: 100, popular: true },
          { cat: 0, name: 'BBQ Chicken', nameAr: 'دجاج باربكيو', price: 90 },
          { cat: 1, name: 'Garlic Bread', nameAr: 'خبز بالثوم', price: 25 },
          { cat: 1, name: 'Mozzarella Sticks', nameAr: 'أصابع موتزاريلا', price: 40 },
          { cat: 2, name: 'Chocolate Cake', nameAr: 'كيك شوكولاتة', price: 35 },
          { cat: 3, name: 'Pepsi', nameAr: 'بيبسي', price: 10 },
        ],
      },
      3: { // Koshary Station
        categories: ['الكشري', 'الإضافات', 'المشروبات'],
        items: [
          { cat: 0, name: 'Small Koshary', nameAr: 'كشري صغير', price: 15 },
          { cat: 0, name: 'Medium Koshary', nameAr: 'كشري وسط', price: 25, popular: true },
          { cat: 0, name: 'Large Koshary', nameAr: 'كشري كبير', price: 35, popular: true },
          { cat: 0, name: 'Super Koshary', nameAr: 'كشري سوبر', price: 45 },
          { cat: 1, name: 'Extra Pasta', nameAr: 'مكرونة إضافية', price: 5 },
          { cat: 1, name: 'Extra Sauce', nameAr: 'صلصة إضافية', price: 3 },
          { cat: 1, name: 'Extra Onions', nameAr: 'بصل إضافي', price: 5 },
          { cat: 2, name: 'Tea', nameAr: 'شاي', price: 5 },
          { cat: 2, name: 'Soda', nameAr: 'مشروب غازي', price: 8 },
        ],
      },
      4: { // Seafood Corner
        categories: ['الأسماك المشوية', 'الأسماك المقلية', 'المقبلات', 'المشروبات'],
        items: [
          { cat: 0, name: 'Grilled Tilapia', nameAr: 'بلطي مشوي', price: 80, popular: true },
          { cat: 0, name: 'Grilled Sea Bass', nameAr: 'قاروص مشوي', price: 150 },
          { cat: 1, name: 'Fried Shrimp', nameAr: 'جمبري مقلي', price: 120, popular: true },
          { cat: 1, name: 'Fried Calamari', nameAr: 'كاليماري مقلي', price: 90 },
          { cat: 2, name: 'Seafood Soup', nameAr: 'شوربة سي فود', price: 40 },
          { cat: 2, name: 'Green Salad', nameAr: 'سلطة خضراء', price: 25 },
          { cat: 3, name: 'Lemon Juice', nameAr: 'عصير ليمون', price: 15 },
          { cat: 3, name: 'Water', nameAr: 'مياه', price: 5 },
        ],
      },
    };

    const allMenuItems: mongoose.Document[] = [];

    for (let r = 0; r < restaurants.length; r++) {
      const rest = restaurants[r].restaurant;
      const menu = menuData[r];

      // Create categories
      const cats: mongoose.Document[] = [];
      for (let c = 0; c < menu.categories.length; c++) {
        const cat = await MenuCategory.create({
          restaurantId: rest._id,
          name: menu.categories[c],
          nameAr: menu.categories[c],
          sortOrder: c + 1,
          isActive: true,
        });
        cats.push(cat);
      }

      // Create items
      for (const item of menu.items) {
        const menuItem = await MenuItem.create({
          restaurantId: rest._id,
          categoryId: cats[item.cat]._id,
          name: item.name,
          nameAr: item.nameAr,
          description: `Delicious ${item.name}`,
          descriptionAr: `${item.nameAr} لذيذ`,
          price: item.price,
          image: `https://via.placeholder.com/300?text=${encodeURIComponent(item.name)}`,
          preparationTime: 10 + Math.floor(Math.random() * 20),
          isAvailable: true,
          isPopular: item.popular || false,
          addons: [
            { name: 'Extra portion', nameAr: 'حصة إضافية', price: Math.ceil(item.price * 0.3), isAvailable: true, maxQuantity: 2 },
          ],
        });
        allMenuItems.push(menuItem);
      }
    }

    // ==================== DRIVERS ====================
    logger.info('Seeding drivers...');
    const driverData = [
      { name: 'محمود السائق', vehicle: 'motorcycle', plate: 'م ن و 123', status: 'approved' },
      { name: 'أحمد التوصيل', vehicle: 'motorcycle', plate: 'م ن و 456', status: 'approved' },
      { name: 'علي الدراجة', vehicle: 'bicycle', plate: '-', status: 'approved' },
      { name: 'خالد السيارة', vehicle: 'car', plate: 'م ن و 789', status: 'approved' },
      { name: 'سامي الجديد', vehicle: 'motorcycle', plate: 'م ن و 999', status: 'pending' },
    ];

    const drivers: { user: mongoose.Document; driver: mongoose.Document }[] = [];

    for (let i = 0; i < driverData.length; i++) {
      const data = driverData[i];
      const user = await User.create({
        role: 'delivery',
        email: `driver${i + 1}@test.com`,
        phone: `+20133333333${i}`,
        password: testPassword,
        name: data.name,
        isEmailVerified: true,
        isPhoneVerified: true,
        isActive: true,
      });

      const driver = await Driver.create({
        userId: user._id,
        nationalId: `2990101234567${i}`,
        nationalIdImage: 'https://via.placeholder.com/400x300',
        nationalIdBackImage: 'https://via.placeholder.com/400x300',
        licenseNumber: `DL${100000 + i}`,
        licenseImage: 'https://via.placeholder.com/400x300',
        licenseExpiryDate: new Date('2027-12-31'),
        vehicleType: data.vehicle as 'motorcycle' | 'car' | 'bicycle',
        vehiclePlate: data.plate,
        vehicleColor: ['أحمر', 'أسود', 'أبيض', 'أزرق'][i % 4],
        vehicleModel: data.vehicle === 'motorcycle' ? 'Honda 2023' : data.vehicle === 'car' ? 'Toyota Corolla' : 'BMX',
        currentLocation: {
          type: 'Point',
          coordinates: randomNearbyCoords(),
        },
        isOnline: data.status === 'approved',
        isAvailable: data.status === 'approved',
        isApproved: data.status === 'approved',
        approvedAt: data.status === 'approved' ? new Date() : undefined,
        approvedBy: data.status === 'approved' ? adminUser._id : undefined,
        status: data.status as 'pending' | 'approved',
        isActive: true,
        rating: 4 + Math.random(),
        totalRatings: Math.floor(Math.random() * 100) + 20,
        totalDeliveries: Math.floor(Math.random() * 500),
        totalEarnings: Math.floor(Math.random() * 10000),
        currentBalance: Math.floor(Math.random() * 2000),
        preferredZones: [zones[0]._id],
      });

      drivers.push({ user, driver });
    }

    // ==================== COUPONS ====================
    logger.info('Seeding coupons...');
    await Coupon.insertMany([
      {
        code: 'WELCOME20',
        description: '20% off your first order',
        descriptionAr: 'خصم 20% على طلبك الأول',
        discountType: 'percentage',
        discountValue: 20,
        minimumOrder: 50,
        maximumDiscount: 50,
        usageLimit: 1000,
        usedCount: 156,
        perUserLimit: 1,
        validFrom: new Date(),
        validUntil: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000), // 90 days
        isActive: true,
      },
      {
        code: 'SAVE10',
        description: '10 EGP off orders above 100 EGP',
        descriptionAr: 'خصم 10 جنيه على الطلبات فوق 100 جنيه',
        discountType: 'fixed',
        discountValue: 10,
        minimumOrder: 100,
        maximumDiscount: 10,
        usageLimit: 500,
        usedCount: 89,
        perUserLimit: 3,
        validFrom: new Date(),
        validUntil: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
        isActive: true,
      },
      {
        code: 'FREEDEL',
        description: 'Free delivery on any order',
        descriptionAr: 'توصيل مجاني على أي طلب',
        discountType: 'fixed',
        discountValue: 15,
        minimumOrder: 0,
        maximumDiscount: 15,
        usageLimit: 200,
        usedCount: 45,
        perUserLimit: 2,
        validFrom: new Date(),
        validUntil: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000), // 14 days
        isActive: true,
      },
      {
        code: 'EXPIRED50',
        description: 'Expired coupon for testing',
        descriptionAr: 'كوبون منتهي للاختبار',
        discountType: 'percentage',
        discountValue: 50,
        minimumOrder: 0,
        maximumDiscount: 100,
        usageLimit: 100,
        usedCount: 0,
        validFrom: new Date(Date.now() - 60 * 24 * 60 * 60 * 1000),
        validUntil: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // Expired 30 days ago
        isActive: false,
      },
    ]);

    // ==================== ORDERS ====================
    logger.info('Seeding orders...');
    const orderStatuses = ['pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'on_the_way', 'delivered', 'cancelled'];
    const orders: mongoose.Document[] = [];

    for (let i = 0; i < 50; i++) {
      const customer = customers[i % customers.length];
      const rest = restaurants[i % restaurants.length];
      const driver = drivers[i % 3]; // Only approved drivers
      const status = orderStatuses[Math.min(i % 8, 7)];
      const isDelivered = status === 'delivered';
      const isCancelled = status === 'cancelled';
      const hasDriver = ['picked_up', 'on_the_way', 'delivered'].includes(status);

      // Get menu items for this restaurant
      const restMenuItems = await MenuItem.find({ restaurantId: rest.restaurant._id }).limit(3);

      const items = restMenuItems.map((item) => ({
        menuItemId: item._id,
        name: (item as unknown as { name: string }).name,
        nameAr: (item as unknown as { nameAr: string }).nameAr,
        quantity: 1 + Math.floor(Math.random() * 2),
        unitPrice: (item as unknown as { price: number }).price,
        totalPrice: (item as unknown as { price: number }).price * (1 + Math.floor(Math.random() * 2)),
        selectedAddons: [],
        selectedVariations: [],
      }));

      const subtotal = items.reduce((sum, item) => sum + item.totalPrice, 0);
      const deliveryFee = 10 + Math.floor(Math.random() * 10);
      const serviceFee = Math.round(subtotal * 0.05);
      const total = subtotal + deliveryFee + serviceFee;

      const orderDate = new Date(Date.now() - (50 - i) * 24 * 60 * 60 * 1000);

      const order = await Order.create({
        orderNumber: generateOrderNumber(orderDate, i + 1),
        customerId: customer.customer._id,
        restaurantId: rest.restaurant._id,
        driverId: hasDriver ? driver.driver._id : undefined,
        items,
        deliveryAddress: {
          name: 'المنزل',
          address: 'شارع الجمهورية، الباجور',
          area: 'وسط البلد',
          building: String(Math.floor(Math.random() * 100)),
          floor: String(Math.floor(Math.random() * 5)),
          apartment: String(Math.floor(Math.random() * 10)),
          phone: (customer.user as unknown as { phone: string }).phone,
          location: {
            type: 'Point',
            coordinates: randomNearbyCoords(),
          },
        },
        subtotal,
        deliveryFee,
        serviceFee,
        discount: 0,
        couponDiscount: 0,
        total,
        status,
        paymentMethod: ['cash', 'card', 'wallet'][i % 3] as 'cash' | 'card' | 'wallet',
        paymentStatus: isDelivered || i % 5 === 0 ? 'paid' : 'pending',
        customerNotes: i % 3 === 0 ? 'الرجاء الاتصال عند الوصول' : undefined,
        estimatedDeliveryTime: new Date(orderDate.getTime() + 45 * 60 * 1000),
        driverEarnings: hasDriver ? Math.round(deliveryFee * 0.8) : 0,
        restaurantEarnings: isDelivered ? Math.round(subtotal * 0.85) : 0,
        platformEarnings: isDelivered ? Math.round(subtotal * 0.15) + serviceFee : 0,
        createdAt: orderDate,
        updatedAt: orderDate,
      });

      orders.push(order);

      // Create review for delivered orders
      if (isDelivered && i % 2 === 0) {
        await Review.create({
          orderId: order._id,
          customerId: customer.customer._id,
          restaurantId: rest.restaurant._id,
          driverId: driver.driver._id,
          restaurantRating: 3 + Math.floor(Math.random() * 3),
          foodRating: 3 + Math.floor(Math.random() * 3),
          driverRating: 4 + Math.floor(Math.random() * 2),
          comment: ['طعام ممتاز!', 'خدمة سريعة', 'جيد جداً', 'سأطلب مرة أخرى'][i % 4],
          isVisible: true,
          isReported: false,
          createdAt: new Date(orderDate.getTime() + 2 * 60 * 60 * 1000),
        });
      }

      // Create transactions for delivered orders
      if (isDelivered) {
        const driverAmount = Math.round(deliveryFee * 0.8);
        await Transaction.create({
          toUserId: driver.user._id,
          type: 'driver_payout',
          amount: driverAmount,
          fee: 0,
          netAmount: driverAmount,
          orderId: order._id,
          notes: `أرباح توصيل طلب ${(order as unknown as { orderNumber: string }).orderNumber}`,
          status: 'completed',
          createdAt: orderDate,
        });

        const restaurantAmount = Math.round(subtotal * 0.85);
        await Transaction.create({
          toUserId: rest.user._id,
          type: 'restaurant_payout',
          amount: restaurantAmount,
          fee: 0,
          netAmount: restaurantAmount,
          orderId: order._id,
          notes: `أرباح طلب ${(order as unknown as { orderNumber: string }).orderNumber}`,
          status: 'completed',
          createdAt: orderDate,
        });
      }
    }

    // ==================== NOTIFICATIONS ====================
    logger.info('Seeding notifications...');
    const notificationTemplates = [
      { type: 'order', title: 'تم تأكيد طلبك', body: 'طلبك قيد التحضير الآن' },
      { type: 'order', title: 'طلبك جاهز', body: 'السائق في طريقه لاستلام طلبك' },
      { type: 'promotional', title: 'عرض خاص!', body: 'احصل على خصم 20% على طلبك القادم' },
      { type: 'system', title: 'تحديث التطبيق', body: 'تم إضافة ميزات جديدة للتطبيق' },
    ];

    for (const customer of customers.slice(0, 5)) {
      for (const template of notificationTemplates) {
        await Notification.create({
          userId: customer.user._id,
          type: template.type,
          title: template.title,
          titleAr: template.title,
          body: template.body,
          bodyAr: template.body,
          isRead: Math.random() > 0.5,
          createdAt: new Date(Date.now() - Math.random() * 7 * 24 * 60 * 60 * 1000),
        });
      }
    }

    // ==================== SUMMARY ====================
    logger.info('');
    logger.info('========================================');
    logger.info('Database seeded successfully!');
    logger.info('========================================');
    logger.info('');
    logger.info('TEST ACCOUNTS:');
    logger.info('==============');
    logger.info('Admin:      admin@bagour-delivery.com / Admin@123');
    logger.info('Customer:   ahmed@test.com / Test@123');
    logger.info('Restaurant: restaurant1@test.com / Test@123');
    logger.info('Driver:     driver1@test.com / Test@123');
    logger.info('');
    logger.info('SEEDED DATA:');
    logger.info('============');
    logger.info(`- ${customerData.length} Customers`);
    logger.info(`- ${restaurantData.length} Restaurants`);
    logger.info(`- ${allMenuItems.length} Menu Items`);
    logger.info(`- ${driverData.length} Drivers (${driverData.filter(d => d.status === 'approved').length} approved)`);
    logger.info(`- ${zones.length} Delivery Zones`);
    logger.info(`- 4 Coupons`);
    logger.info(`- ${orders.length} Orders`);
    logger.info('');

    process.exit(0);
  } catch (error) {
    logger.error('Error seeding database:', error);
    process.exit(1);
  }
};

seedDatabase();
