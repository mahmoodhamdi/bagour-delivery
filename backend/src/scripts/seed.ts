import mongoose from 'mongoose';
import { config } from '../config';
import { logger } from '../utils/logger';
import { User, Customer, Driver, Restaurant, MenuCategory, MenuItem, Zone, Setting, defaultSettings } from '../models';

const seedDatabase = async () => {
  try {
    // Connect to database
    await mongoose.connect(config.mongoUri);
    logger.info('Connected to MongoDB');

    // Clear existing data (optional - comment out in production)
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
    ]);

    // Seed Settings
    logger.info('Seeding settings...');
    await Setting.insertMany(defaultSettings);

    // Seed Admin User
    logger.info('Seeding admin user...');
    const adminUser = await User.create({
      role: 'admin',
      email: 'admin@bagour.com',
      phone: '01000000000',
      password: 'Admin@123',
      name: 'Admin User',
      isEmailVerified: true,
      isPhoneVerified: true,
    });

    // Seed Test Customer
    logger.info('Seeding test customer...');
    const customerUser = await User.create({
      role: 'customer',
      email: 'customer@test.com',
      phone: '01111111111',
      password: 'Test@123',
      name: 'Test Customer',
      isEmailVerified: true,
      isPhoneVerified: true,
    });

    const customer = await Customer.create({
      userId: customerUser._id,
      addresses: [
        {
          label: 'home',
          name: 'البيت',
          address: 'شارع الجمهورية، الباجور',
          area: 'وسط البلد',
          city: 'الباجور',
          location: {
            type: 'Point',
            coordinates: [30.7133, 30.4167], // Bagour coordinates
          },
          isDefault: true,
        },
      ],
    });

    // Seed Test Restaurant Owner
    logger.info('Seeding test restaurant...');
    const restaurantUser = await User.create({
      role: 'restaurant',
      email: 'restaurant@test.com',
      phone: '01222222222',
      password: 'Test@123',
      name: 'Test Restaurant Owner',
      isEmailVerified: true,
      isPhoneVerified: true,
    });

    const restaurant = await Restaurant.create({
      userId: restaurantUser._id,
      name: 'Bagour Kitchen',
      nameAr: 'مطبخ الباجور',
      description: 'Best local food in Bagour',
      descriptionAr: 'أفضل الأكلات المحلية في الباجور',
      logo: 'https://via.placeholder.com/200',
      coverImage: 'https://via.placeholder.com/800x400',
      categories: ['Egyptian', 'Grills', 'Sandwiches'],
      tags: ['popular', 'fast-delivery'],
      priceRange: 2,
      address: 'شارع النيل، الباجور',
      area: 'وسط البلد',
      location: {
        type: 'Point',
        coordinates: [30.7133, 30.4167],
      },
      phone: '01222222222',
      minimumOrder: 30,
      deliveryFee: 10,
      freeDeliveryAbove: 100,
      isApproved: true,
      approvedAt: new Date(),
      approvedBy: adminUser._id,
      isActive: true,
    });

    // Seed Menu Categories
    logger.info('Seeding menu categories...');
    const categories = await MenuCategory.insertMany([
      {
        restaurantId: restaurant._id,
        name: 'Grills',
        nameAr: 'مشويات',
        sortOrder: 1,
      },
      {
        restaurantId: restaurant._id,
        name: 'Sandwiches',
        nameAr: 'ساندوتشات',
        sortOrder: 2,
      },
      {
        restaurantId: restaurant._id,
        name: 'Drinks',
        nameAr: 'مشروبات',
        sortOrder: 3,
      },
    ]);

    // Seed Menu Items
    logger.info('Seeding menu items...');
    await MenuItem.insertMany([
      // Grills
      {
        restaurantId: restaurant._id,
        categoryId: categories[0]._id,
        name: 'Mixed Grill',
        nameAr: 'مشويات مشكلة',
        description: 'A variety of grilled meats',
        descriptionAr: 'تشكيلة من اللحوم المشوية',
        price: 120,
        image: 'https://via.placeholder.com/300',
        preparationTime: 25,
        isPopular: true,
        addons: [
          { name: 'Extra Meat', nameAr: 'لحم إضافي', price: 30, isAvailable: true, maxQuantity: 3 },
          { name: 'Extra Rice', nameAr: 'رز إضافي', price: 10, isAvailable: true, maxQuantity: 2 },
        ],
        variations: [
          {
            name: 'Size',
            nameAr: 'الحجم',
            isRequired: true,
            options: [
              { name: 'Regular', nameAr: 'عادي', price: 0 },
              { name: 'Large', nameAr: 'كبير', price: 40 },
            ],
          },
        ],
      },
      {
        restaurantId: restaurant._id,
        categoryId: categories[0]._id,
        name: 'Grilled Chicken',
        nameAr: 'فراخ مشوية',
        description: 'Half grilled chicken',
        descriptionAr: 'نص فرخة مشوية',
        price: 60,
        image: 'https://via.placeholder.com/300',
        preparationTime: 20,
      },
      // Sandwiches
      {
        restaurantId: restaurant._id,
        categoryId: categories[1]._id,
        name: 'Shawarma',
        nameAr: 'شاورما',
        description: 'Chicken shawarma sandwich',
        descriptionAr: 'ساندوتش شاورما فراخ',
        price: 25,
        image: 'https://via.placeholder.com/300',
        preparationTime: 10,
        isPopular: true,
        variations: [
          {
            name: 'Type',
            nameAr: 'النوع',
            isRequired: true,
            options: [
              { name: 'Chicken', nameAr: 'فراخ', price: 0 },
              { name: 'Meat', nameAr: 'لحمة', price: 10 },
            ],
          },
        ],
      },
      // Drinks
      {
        restaurantId: restaurant._id,
        categoryId: categories[2]._id,
        name: 'Cola',
        nameAr: 'كولا',
        price: 10,
        image: 'https://via.placeholder.com/300',
      },
      {
        restaurantId: restaurant._id,
        categoryId: categories[2]._id,
        name: 'Water',
        nameAr: 'مياه',
        price: 5,
        image: 'https://via.placeholder.com/300',
      },
    ]);

    // Seed Test Driver
    logger.info('Seeding test driver...');
    const driverUser = await User.create({
      role: 'delivery',
      email: 'driver@test.com',
      phone: '01333333333',
      password: 'Test@123',
      name: 'Test Driver',
      isEmailVerified: true,
      isPhoneVerified: true,
    });

    await Driver.create({
      userId: driverUser._id,
      nationalId: '12345678901234',
      nationalIdImage: 'https://via.placeholder.com/400x300',
      licenseNumber: 'ABC123',
      licenseImage: 'https://via.placeholder.com/400x300',
      licenseExpiryDate: new Date('2025-12-31'),
      vehicleType: 'motorcycle',
      vehiclePlate: 'م ن و 123',
      vehicleColor: 'Red',
      vehicleModel: 'Honda 2023',
      isApproved: true,
      approvedAt: new Date(),
      approvedBy: adminUser._id,
      isActive: true,
    });

    // Seed Zone
    logger.info('Seeding delivery zone...');
    await Zone.create({
      name: 'Bagour City Center',
      nameAr: 'وسط الباجور',
      center: {
        type: 'Point',
        coordinates: [30.7133, 30.4167],
      },
      radius: 5000, // 5km radius
      deliveryFee: 10,
      minimumOrder: 30,
      freeDeliveryAbove: 100,
      estimatedDeliveryTime: {
        min: 20,
        max: 45,
      },
      isActive: true,
    });

    logger.info('Database seeded successfully!');
    logger.info('');
    logger.info('Test Accounts:');
    logger.info('==============');
    logger.info('Admin: admin@bagour.com / Admin@123');
    logger.info('Customer: customer@test.com / Test@123');
    logger.info('Restaurant: restaurant@test.com / Test@123');
    logger.info('Driver: driver@test.com / Test@123');

    process.exit(0);
  } catch (error) {
    logger.error('Error seeding database:', error);
    process.exit(1);
  }
};

seedDatabase();
