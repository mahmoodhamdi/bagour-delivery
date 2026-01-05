import swaggerJsdoc from 'swagger-jsdoc';
import { Express } from 'express';
import swaggerUi from 'swagger-ui-express';
import redoc from 'redoc-express';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Bagour Delivery API',
      version: '1.0.0',
      description: `
# Bagour Delivery Platform API Documentation

Complete API documentation for the Bagour Delivery food ordering and delivery platform.

## Overview
This API serves 4 user roles:
- **Customer**: Browse restaurants, place orders, track delivery
- **Restaurant Owner**: Manage menu, handle orders, view analytics
- **Driver**: Accept deliveries, update status, manage earnings
- **Admin**: Platform management, approvals, analytics

## Authentication
All protected endpoints require a Bearer token in the Authorization header:
\`\`\`
Authorization: Bearer <access_token>
\`\`\`

## Base URL
- Development: \`http://localhost:5000/api/v1\`
- Production: \`https://api.bagour-delivery.com/api/v1\`

## Rate Limiting
- 100 requests per 15 minutes for unauthenticated requests
- 500 requests per 15 minutes for authenticated requests

## Response Format
All responses follow this structure:
\`\`\`json
{
  "success": true,
  "message": "Success message",
  "data": { ... }
}
\`\`\`

## Error Response Format
\`\`\`json
{
  "success": false,
  "message": "Error message in Arabic",
  "error": {
    "code": "ERROR_CODE",
    "details": { ... }
  }
}
\`\`\`
      `,
      contact: {
        name: 'Bagour Delivery Support',
        email: 'support@bagour-delivery.com',
      },
      license: {
        name: 'Proprietary',
      },
    },
    servers: [
      {
        url: 'http://localhost:5000/api/v1',
        description: 'Development server',
      },
      {
        url: 'https://api.bagour-delivery.com/api/v1',
        description: 'Production server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Enter your JWT token',
        },
      },
      schemas: {
        // Common Schemas
        Error: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            message: { type: 'string', example: 'خطأ في البيانات' },
            error: {
              type: 'object',
              properties: {
                code: { type: 'string', example: 'VALIDATION_ERROR' },
                details: { type: 'object' },
              },
            },
          },
        },
        Pagination: {
          type: 'object',
          properties: {
            total: { type: 'number', example: 100 },
            page: { type: 'number', example: 1 },
            limit: { type: 'number', example: 10 },
            pages: { type: 'number', example: 10 },
          },
        },
        Location: {
          type: 'object',
          properties: {
            type: { type: 'string', enum: ['Point'], example: 'Point' },
            coordinates: {
              type: 'array',
              items: { type: 'number' },
              example: [30.9667, 30.4167],
              description: '[longitude, latitude]',
            },
          },
        },

        // User & Auth
        User: {
          type: 'object',
          properties: {
            _id: { type: 'string', example: '507f1f77bcf86cd799439011' },
            name: { type: 'string', example: 'أحمد محمد' },
            email: { type: 'string', format: 'email', example: 'ahmed@example.com' },
            phone: { type: 'string', example: '+201234567890' },
            role: { type: 'string', enum: ['customer', 'restaurant', 'driver', 'delivery', 'admin'] },
            avatar: { type: 'string', format: 'uri' },
            isActive: { type: 'boolean', example: true },
            isVerified: { type: 'boolean', example: true },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        LoginRequest: {
          type: 'object',
          required: ['email', 'password'],
          properties: {
            email: { type: 'string', format: 'email', example: 'user@example.com' },
            password: { type: 'string', format: 'password', minLength: 6, example: 'password123' },
          },
        },
        LoginResponse: {
          type: 'object',
          properties: {
            user: { $ref: '#/components/schemas/User' },
            accessToken: { type: 'string' },
            refreshToken: { type: 'string' },
          },
        },
        RegisterCustomer: {
          type: 'object',
          required: ['name', 'email', 'phone', 'password'],
          properties: {
            name: { type: 'string', minLength: 2, maxLength: 50, example: 'أحمد محمد' },
            email: { type: 'string', format: 'email', example: 'ahmed@example.com' },
            phone: { type: 'string', pattern: '^\\+20[0-9]{10}$', example: '+201234567890' },
            password: { type: 'string', format: 'password', minLength: 6, example: 'password123' },
          },
        },

        // Customer
        Customer: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            userId: { $ref: '#/components/schemas/User' },
            addresses: {
              type: 'array',
              items: { $ref: '#/components/schemas/Address' },
            },
            favoriteRestaurants: {
              type: 'array',
              items: { type: 'string' },
            },
            loyaltyPoints: { type: 'number', example: 150 },
          },
        },
        Address: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            label: { type: 'string', example: 'المنزل' },
            street: { type: 'string', example: 'شارع النيل' },
            building: { type: 'string', example: '15' },
            floor: { type: 'string', example: '3' },
            apartment: { type: 'string', example: '12' },
            area: { type: 'string', example: 'باجور' },
            city: { type: 'string', example: 'المنوفية' },
            landmark: { type: 'string', example: 'بجوار مسجد النور' },
            location: { $ref: '#/components/schemas/Location' },
            isDefault: { type: 'boolean', example: true },
          },
        },

        // Restaurant
        Restaurant: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            userId: { type: 'string' },
            name: { type: 'string', example: 'مطعم الباجوري' },
            nameAr: { type: 'string', example: 'مطعم الباجوري' },
            slug: { type: 'string', example: 'bagouri-restaurant' },
            description: { type: 'string' },
            descriptionAr: { type: 'string' },
            logo: { type: 'string', format: 'uri' },
            coverImage: { type: 'string', format: 'uri' },
            cuisineType: {
              type: 'array',
              items: { type: 'string' },
              example: ['مصري', 'شرقي'],
            },
            phone: { type: 'string', example: '+201234567890' },
            address: {
              type: 'object',
              properties: {
                street: { type: 'string' },
                area: { type: 'string' },
                city: { type: 'string' },
              },
            },
            location: { $ref: '#/components/schemas/Location' },
            rating: { type: 'number', minimum: 0, maximum: 5, example: 4.5 },
            totalRatings: { type: 'number', example: 120 },
            minimumOrder: { type: 'number', example: 50 },
            deliveryFee: { type: 'number', example: 10 },
            deliveryTime: { type: 'string', example: '30-45' },
            isOpen: { type: 'boolean', example: true },
            isActive: { type: 'boolean', example: true },
            isApproved: { type: 'boolean', example: true },
            status: { type: 'string', enum: ['pending', 'approved', 'rejected', 'suspended'] },
            workingHours: {
              type: 'object',
              additionalProperties: {
                type: 'object',
                properties: {
                  open: { type: 'string', example: '09:00' },
                  close: { type: 'string', example: '23:00' },
                  isClosed: { type: 'boolean' },
                },
              },
            },
          },
        },

        // Menu
        MenuCategory: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            restaurantId: { type: 'string' },
            name: { type: 'string', example: 'المشويات' },
            nameAr: { type: 'string', example: 'المشويات' },
            description: { type: 'string' },
            image: { type: 'string', format: 'uri' },
            sortOrder: { type: 'number', example: 1 },
            isActive: { type: 'boolean', example: true },
          },
        },
        MenuItem: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            restaurantId: { type: 'string' },
            categoryId: { type: 'string' },
            name: { type: 'string', example: 'شاورما لحم' },
            nameAr: { type: 'string', example: 'شاورما لحم' },
            description: { type: 'string' },
            descriptionAr: { type: 'string' },
            price: { type: 'number', example: 45 },
            discountPrice: { type: 'number', example: 40 },
            image: { type: 'string', format: 'uri' },
            images: {
              type: 'array',
              items: { type: 'string', format: 'uri' },
            },
            preparationTime: { type: 'number', example: 15, description: 'Minutes' },
            calories: { type: 'number', example: 450 },
            isAvailable: { type: 'boolean', example: true },
            isPopular: { type: 'boolean', example: false },
            addons: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  _id: { type: 'string' },
                  name: { type: 'string', example: 'جبنة إضافية' },
                  nameAr: { type: 'string' },
                  price: { type: 'number', example: 5 },
                  isAvailable: { type: 'boolean' },
                },
              },
            },
            variations: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  _id: { type: 'string' },
                  name: { type: 'string', example: 'الحجم' },
                  nameAr: { type: 'string' },
                  required: { type: 'boolean' },
                  options: {
                    type: 'array',
                    items: {
                      type: 'object',
                      properties: {
                        _id: { type: 'string' },
                        name: { type: 'string', example: 'كبير' },
                        nameAr: { type: 'string' },
                        price: { type: 'number', example: 10 },
                      },
                    },
                  },
                },
              },
            },
          },
        },

        // Order
        Order: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            orderNumber: { type: 'string', example: 'ORD-20260104-001' },
            customerId: { $ref: '#/components/schemas/Customer' },
            restaurantId: { $ref: '#/components/schemas/Restaurant' },
            driverId: { $ref: '#/components/schemas/Driver' },
            items: {
              type: 'array',
              items: { $ref: '#/components/schemas/OrderItem' },
            },
            deliveryAddress: { $ref: '#/components/schemas/Address' },
            subtotal: { type: 'number', example: 150 },
            deliveryFee: { type: 'number', example: 10 },
            serviceFee: { type: 'number', example: 7.5 },
            discount: { type: 'number', example: 0 },
            couponDiscount: { type: 'number', example: 15 },
            total: { type: 'number', example: 152.5 },
            status: {
              type: 'string',
              enum: ['pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'on_the_way', 'delivered', 'cancelled'],
              example: 'pending',
            },
            paymentMethod: { type: 'string', enum: ['cash', 'card', 'wallet'], example: 'cash' },
            paymentStatus: { type: 'string', enum: ['pending', 'paid', 'failed', 'refunded'], example: 'pending' },
            customerNotes: { type: 'string' },
            estimatedDeliveryTime: { type: 'string', format: 'date-time' },
            createdAt: { type: 'string', format: 'date-time' },
            updatedAt: { type: 'string', format: 'date-time' },
          },
        },
        OrderItem: {
          type: 'object',
          properties: {
            menuItemId: { type: 'string' },
            name: { type: 'string', example: 'شاورما لحم' },
            nameAr: { type: 'string' },
            quantity: { type: 'number', example: 2 },
            unitPrice: { type: 'number', example: 45 },
            totalPrice: { type: 'number', example: 90 },
            selectedAddons: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  name: { type: 'string' },
                  price: { type: 'number' },
                  quantity: { type: 'number' },
                },
              },
            },
            selectedVariations: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  name: { type: 'string' },
                  option: { type: 'string' },
                  price: { type: 'number' },
                },
              },
            },
            specialInstructions: { type: 'string' },
          },
        },
        CreateOrder: {
          type: 'object',
          required: ['restaurantId', 'items', 'deliveryAddress', 'paymentMethod'],
          properties: {
            restaurantId: { type: 'string' },
            items: {
              type: 'array',
              minItems: 1,
              items: {
                type: 'object',
                required: ['menuItemId', 'quantity'],
                properties: {
                  menuItemId: { type: 'string' },
                  quantity: { type: 'number', minimum: 1 },
                  selectedAddons: {
                    type: 'array',
                    items: {
                      type: 'object',
                      properties: {
                        addonId: { type: 'string' },
                        quantity: { type: 'number', minimum: 1 },
                      },
                    },
                  },
                  selectedVariations: {
                    type: 'array',
                    items: {
                      type: 'object',
                      properties: {
                        variationId: { type: 'string' },
                        optionId: { type: 'string' },
                      },
                    },
                  },
                  specialInstructions: { type: 'string' },
                },
              },
            },
            deliveryAddress: {
              type: 'object',
              required: ['street', 'area'],
              properties: {
                street: { type: 'string' },
                building: { type: 'string' },
                floor: { type: 'string' },
                apartment: { type: 'string' },
                area: { type: 'string' },
                landmark: { type: 'string' },
                latitude: { type: 'number' },
                longitude: { type: 'number' },
              },
            },
            paymentMethod: { type: 'string', enum: ['cash', 'card', 'wallet'] },
            couponCode: { type: 'string' },
            customerNotes: { type: 'string' },
            isScheduled: { type: 'boolean' },
            scheduledFor: { type: 'string', format: 'date-time' },
          },
        },

        // Driver
        Driver: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            userId: { $ref: '#/components/schemas/User' },
            nationalId: { type: 'string' },
            licenseNumber: { type: 'string' },
            licenseExpiryDate: { type: 'string', format: 'date' },
            vehicleType: { type: 'string', enum: ['motorcycle', 'car', 'bicycle'] },
            vehiclePlate: { type: 'string' },
            vehicleColor: { type: 'string' },
            vehicleModel: { type: 'string' },
            currentLocation: { $ref: '#/components/schemas/Location' },
            isOnline: { type: 'boolean' },
            isAvailable: { type: 'boolean' },
            isBusy: { type: 'boolean' },
            isApproved: { type: 'boolean' },
            status: { type: 'string', enum: ['pending', 'approved', 'rejected', 'suspended'] },
            rating: { type: 'number', minimum: 0, maximum: 5 },
            totalDeliveries: { type: 'number' },
            totalEarnings: { type: 'number' },
            currentBalance: { type: 'number' },
          },
        },

        // Review
        Review: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            orderId: { type: 'string' },
            customerId: { $ref: '#/components/schemas/Customer' },
            restaurantId: { type: 'string' },
            driverId: { type: 'string' },
            restaurantRating: { type: 'number', minimum: 1, maximum: 5 },
            foodRating: { type: 'number', minimum: 1, maximum: 5 },
            driverRating: { type: 'number', minimum: 1, maximum: 5 },
            comment: { type: 'string' },
            images: {
              type: 'array',
              items: { type: 'string', format: 'uri' },
            },
            restaurantReply: { type: 'string' },
            repliedAt: { type: 'string', format: 'date-time' },
            isVisible: { type: 'boolean' },
            isReported: { type: 'boolean' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },

        // Coupon
        Coupon: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            code: { type: 'string', example: 'WELCOME20' },
            description: { type: 'string' },
            descriptionAr: { type: 'string', example: 'خصم 20% على أول طلب' },
            discountType: { type: 'string', enum: ['percentage', 'fixed'] },
            discountValue: { type: 'number', example: 20 },
            minimumOrder: { type: 'number', example: 50 },
            maximumDiscount: { type: 'number', example: 50 },
            usageLimit: { type: 'number', example: 100 },
            usedCount: { type: 'number', example: 45 },
            perUserLimit: { type: 'number', example: 1 },
            validFrom: { type: 'string', format: 'date-time' },
            validUntil: { type: 'string', format: 'date-time' },
            isActive: { type: 'boolean' },
          },
        },

        // Zone
        Zone: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            name: { type: 'string', example: 'Central Bagour' },
            nameAr: { type: 'string', example: 'وسط باجور' },
            coordinates: {
              type: 'object',
              properties: {
                type: { type: 'string', enum: ['Polygon'] },
                coordinates: {
                  type: 'array',
                  items: {
                    type: 'array',
                    items: {
                      type: 'array',
                      items: { type: 'number' },
                    },
                  },
                },
              },
            },
            deliveryFee: { type: 'number', example: 10 },
            minimumOrder: { type: 'number', example: 30 },
            isActive: { type: 'boolean' },
          },
        },

        // Notification
        Notification: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            userId: { type: 'string' },
            type: { type: 'string', enum: ['order', 'promotional', 'system'] },
            title: { type: 'string' },
            titleAr: { type: 'string' },
            body: { type: 'string' },
            bodyAr: { type: 'string' },
            data: { type: 'object' },
            isRead: { type: 'boolean' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },

        // Transaction
        Transaction: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            userId: { type: 'string' },
            userType: { type: 'string', enum: ['driver', 'restaurant'] },
            type: { type: 'string', enum: ['earning', 'withdrawal', 'payout', 'refund', 'commission'] },
            amount: { type: 'number' },
            balanceAfter: { type: 'number' },
            orderId: { type: 'string' },
            description: { type: 'string' },
            status: { type: 'string', enum: ['pending', 'completed', 'failed', 'cancelled'] },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },

        // Settings
        Settings: {
          type: 'object',
          properties: {
            defaultDeliveryFee: { type: 'number' },
            serviceFeePercentage: { type: 'number' },
            platformCommission: { type: 'number' },
            driverCommission: { type: 'number' },
            minimumWithdrawal: { type: 'number' },
            orderCancellationWindow: { type: 'number', description: 'Minutes' },
            maintenanceMode: { type: 'boolean' },
          },
        },
      },
      responses: {
        UnauthorizedError: {
          description: 'Access token is missing or invalid',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: {
                success: false,
                message: 'غير مصرح',
                error: { code: 'UNAUTHORIZED' },
              },
            },
          },
        },
        ForbiddenError: {
          description: 'Access denied - insufficient permissions',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: {
                success: false,
                message: 'ليس لديك صلاحية لهذا الإجراء',
                error: { code: 'FORBIDDEN' },
              },
            },
          },
        },
        NotFoundError: {
          description: 'Resource not found',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: {
                success: false,
                message: 'المورد غير موجود',
                error: { code: 'NOT_FOUND' },
              },
            },
          },
        },
        ValidationError: {
          description: 'Validation error',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: {
                success: false,
                message: 'خطأ في البيانات المدخلة',
                error: { code: 'VALIDATION_ERROR', details: {} },
              },
            },
          },
        },
      },
    },
    tags: [
      { name: 'Auth', description: 'Authentication & Authorization endpoints' },
      { name: 'Customer', description: 'Customer profile and address management' },
      { name: 'Restaurants', description: 'Restaurant browsing and search' },
      { name: 'Restaurant Dashboard', description: 'Restaurant owner management endpoints' },
      { name: 'Menu', description: 'Menu categories and items management' },
      { name: 'Orders', description: 'Order management for all roles' },
      { name: 'Driver', description: 'Driver profile and delivery management' },
      { name: 'Reviews', description: 'Customer reviews and ratings' },
      { name: 'Coupons', description: 'Coupon management and validation' },
      { name: 'Payments', description: 'Payment processing' },
      { name: 'Transactions', description: 'Earnings, withdrawals, and payouts' },
      { name: 'Notifications', description: 'Push notifications management' },
      { name: 'Admin', description: 'Admin dashboard and platform management' },
      { name: 'Upload', description: 'File upload endpoints' },
    ],
  },
  apis: ['./src/docs/*.yaml'], // Path to API documentation files
};

const swaggerSpec = swaggerJsdoc(options);

export const setupSwagger = (app: Express): void => {
  // Serve Swagger UI
  app.use(
    '/api-docs',
    swaggerUi.serve,
    swaggerUi.setup(swaggerSpec, {
      customCss: '.swagger-ui .topbar { display: none }',
      customSiteTitle: 'Bagour Delivery API Docs',
      swaggerOptions: {
        persistAuthorization: true,
        docExpansion: 'none',
        filter: true,
        tagsSorter: 'alpha',
        operationsSorter: 'alpha',
      },
    })
  );

  // Serve raw OpenAPI JSON
  app.get('/api-docs.json', (_req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.send(swaggerSpec);
  });

  // Serve Redoc documentation
  app.get(
    '/api-redoc',
    redoc({
      title: 'Bagour Delivery API Documentation',
      specUrl: '/api-docs.json',
      redocOptions: {
        theme: {
          colors: {
            primary: {
              main: '#10b981',
            },
          },
          typography: {
            fontFamily: 'Cairo, sans-serif',
            fontSize: '14px',
            headings: {
              fontFamily: 'Cairo, sans-serif',
            },
          },
        },
        hideDownloadButton: false,
        hideHostname: false,
        expandResponses: '200,201',
        requiredPropsFirst: true,
        sortPropsAlphabetically: true,
        noAutoAuth: false,
        pathInMiddlePanel: true,
        nativeScrollbars: false,
        expandSingleSchemaField: true,
      },
    })
  );
};

export default swaggerSpec;
