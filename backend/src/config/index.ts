import dotenv from 'dotenv';

dotenv.config();

export const config = {
  // Server
  nodeEnv: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '5000', 10),
  apiVersion: process.env.API_VERSION || 'v1',

  // MongoDB
  mongoUri: process.env.MONGODB_URI || 'mongodb://localhost:27017/bagour-delivery',

  // JWT
  jwt: {
    secret: process.env.JWT_SECRET || 'default-secret-change-in-production',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    accessSecret: process.env.JWT_SECRET || 'default-secret-change-in-production',
    accessExpiry: process.env.JWT_EXPIRES_IN || '15m',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'default-refresh-secret',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
    refreshExpiry: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
  },

  // Cloudinary
  cloudinary: {
    cloudName: process.env.CLOUDINARY_CLOUD_NAME || '',
    apiKey: process.env.CLOUDINARY_API_KEY || '',
    apiSecret: process.env.CLOUDINARY_API_SECRET || '',
  },

  // Firebase
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID || '',
    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n') || '',
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL || '',
  },

  // Paymob
  paymob: {
    apiKey: process.env.PAYMOB_API_KEY || '',
    integrationId: process.env.PAYMOB_INTEGRATION_ID || '',
    iframeId: process.env.PAYMOB_IFRAME_ID || '',
    hmacSecret: process.env.PAYMOB_HMAC_SECRET || '',
  },

  // Google Cloud & Maps
  googleMapsApiKey: process.env.GOOGLE_MAPS_API_KEY || '',
  googleCloudApiKey: process.env.GOOGLE_CLOUD_API_KEY || '',

  // Resend (Email Service)
  resend: {
    apiKey: process.env.RESEND_API_KEY || '',
    fromEmail: process.env.RESEND_FROM_EMAIL || 'onboarding@resend.dev',
  },

  // App Settings
  defaultCommission: parseInt(process.env.DEFAULT_COMMISSION || '15', 10),
  serviceFee: parseInt(process.env.SERVICE_FEE || '3', 10),
  deliveryFeePerKm: parseInt(process.env.DELIVERY_FEE_PER_KM || '2', 10),
  maxDeliveryDistance: parseInt(process.env.MAX_DELIVERY_DISTANCE || '10', 10),

  // Frontend URLs
  corsOrigins: [
    process.env.CUSTOMER_APP_URL || 'http://localhost:3000',
    process.env.RESTAURANT_DASHBOARD_URL || 'http://localhost:3001',
    process.env.ADMIN_DASHBOARD_URL || 'http://localhost:3002',
  ],

  // Rate Limiting
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10),
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
  },
};

export default config;
