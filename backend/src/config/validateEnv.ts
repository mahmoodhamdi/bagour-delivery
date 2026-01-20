import Joi from 'joi';

/**
 * Environment variable validation schema
 * Ensures all required environment variables are present and valid
 */
const envSchema = Joi.object({
  // Server (required)
  NODE_ENV: Joi.string().valid('development', 'production', 'test').default('development'),
  PORT: Joi.number().port().default(5000),
  API_VERSION: Joi.string().default('v1'),

  // MongoDB (required)
  MONGODB_URI: Joi.string().uri({ scheme: ['mongodb', 'mongodb+srv'] }).required().messages({
    'any.required': 'MONGODB_URI is required',
    'string.uri': 'MONGODB_URI must be a valid MongoDB connection string',
  }),

  // JWT (required for production)
  JWT_SECRET: Joi.string().min(32).when('NODE_ENV', {
    is: 'production',
    then: Joi.required().messages({
      'any.required': 'JWT_SECRET is required in production',
      'string.min': 'JWT_SECRET must be at least 32 characters in production',
    }),
    otherwise: Joi.optional(),
  }),
  JWT_EXPIRES_IN: Joi.string().default('15m'),
  JWT_REFRESH_SECRET: Joi.string().min(32).when('NODE_ENV', {
    is: 'production',
    then: Joi.required(),
    otherwise: Joi.optional(),
  }),
  JWT_REFRESH_EXPIRES_IN: Joi.string().default('30d'),

  // Cloudinary (optional in development)
  CLOUDINARY_CLOUD_NAME: Joi.string().when('NODE_ENV', {
    is: 'production',
    then: Joi.required(),
    otherwise: Joi.optional().allow(''),
  }),
  CLOUDINARY_API_KEY: Joi.string().when('NODE_ENV', {
    is: 'production',
    then: Joi.required(),
    otherwise: Joi.optional().allow(''),
  }),
  CLOUDINARY_API_SECRET: Joi.string().when('NODE_ENV', {
    is: 'production',
    then: Joi.required(),
    otherwise: Joi.optional().allow(''),
  }),

  // Firebase (optional but recommended for push notifications)
  FIREBASE_PROJECT_ID: Joi.string().optional().allow(''),
  FIREBASE_PRIVATE_KEY: Joi.string().optional().allow(''),
  FIREBASE_CLIENT_EMAIL: Joi.string().email().optional().allow(''),

  // Paymob (optional in development)
  PAYMOB_API_KEY: Joi.string().optional().allow(''),
  PAYMOB_INTEGRATION_ID: Joi.string().optional().allow(''),
  PAYMOB_IFRAME_ID: Joi.string().optional().allow(''),
  PAYMOB_HMAC_SECRET: Joi.string().optional().allow(''),

  // Maps (free - OpenStreetMap, no key required)
  NOMINATIM_BASE_URL: Joi.string().uri().default('https://nominatim.openstreetmap.org'),
  OSRM_BASE_URL: Joi.string().uri().default('https://router.project-osrm.org'),

  // Email (Resend)
  RESEND_API_KEY: Joi.string().optional().allow(''),
  RESEND_FROM_EMAIL: Joi.string().email().optional(),

  // App Settings
  DEFAULT_COMMISSION: Joi.number().min(0).max(100).default(15),
  SERVICE_FEE: Joi.number().min(0).default(3),
  DELIVERY_FEE_PER_KM: Joi.number().min(0).default(2),
  MAX_DELIVERY_DISTANCE: Joi.number().min(1).max(100).default(10),

  // Frontend URLs (for CORS)
  CUSTOMER_APP_URL: Joi.string().uri().default('http://localhost:3000'),
  RESTAURANT_DASHBOARD_URL: Joi.string().uri().default('http://localhost:3001'),
  ADMIN_DASHBOARD_URL: Joi.string().uri().default('http://localhost:3002'),

  // Rate Limiting
  RATE_LIMIT_WINDOW_MS: Joi.number().min(1000).default(900000),
  RATE_LIMIT_MAX_REQUESTS: Joi.number().min(1).default(100),
}).unknown(true); // Allow other env variables

export interface ValidatedEnv {
  NODE_ENV: 'development' | 'production' | 'test';
  PORT: number;
  API_VERSION: string;
  MONGODB_URI: string;
  JWT_SECRET?: string;
  JWT_EXPIRES_IN: string;
  JWT_REFRESH_SECRET?: string;
  JWT_REFRESH_EXPIRES_IN: string;
  CLOUDINARY_CLOUD_NAME?: string;
  CLOUDINARY_API_KEY?: string;
  CLOUDINARY_API_SECRET?: string;
  FIREBASE_PROJECT_ID?: string;
  FIREBASE_PRIVATE_KEY?: string;
  FIREBASE_CLIENT_EMAIL?: string;
  PAYMOB_API_KEY?: string;
  PAYMOB_INTEGRATION_ID?: string;
  PAYMOB_IFRAME_ID?: string;
  PAYMOB_HMAC_SECRET?: string;
  NOMINATIM_BASE_URL: string;
  OSRM_BASE_URL: string;
  RESEND_API_KEY?: string;
  RESEND_FROM_EMAIL?: string;
  DEFAULT_COMMISSION: number;
  SERVICE_FEE: number;
  DELIVERY_FEE_PER_KM: number;
  MAX_DELIVERY_DISTANCE: number;
  CUSTOMER_APP_URL: string;
  RESTAURANT_DASHBOARD_URL: string;
  ADMIN_DASHBOARD_URL: string;
  RATE_LIMIT_WINDOW_MS: number;
  RATE_LIMIT_MAX_REQUESTS: number;
}

/**
 * Validate environment variables
 * Call this function at application startup
 * @throws Error if validation fails
 */
export function validateEnv(): ValidatedEnv {
  const { error, value } = envSchema.validate(process.env, {
    abortEarly: false, // Report all errors, not just the first one
  });

  if (error) {
    const errorMessages = error.details.map((detail) => `  - ${detail.message}`).join('\n');
    console.error('\n❌ Environment validation failed:\n');
    console.error(errorMessages);
    console.error('\nPlease check your .env file and ensure all required variables are set.\n');

    // In production, exit immediately on env validation failure
    if (process.env.NODE_ENV === 'production') {
      process.exit(1);
    }

    throw new Error(`Environment validation failed:\n${errorMessages}`);
  }

  console.log('✅ Environment variables validated successfully');
  return value as ValidatedEnv;
}

/**
 * Check if running in production mode
 */
export function isProduction(): boolean {
  return process.env.NODE_ENV === 'production';
}

/**
 * Check if running in development mode
 */
export function isDevelopment(): boolean {
  return process.env.NODE_ENV === 'development';
}

/**
 * Check if running in test mode
 */
export function isTest(): boolean {
  return process.env.NODE_ENV === 'test';
}
