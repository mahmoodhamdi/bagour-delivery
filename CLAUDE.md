# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bagour Delivery is a food delivery platform monorepo for Bagour city, Egypt. It consists of 6 projects serving 4 user roles:
- **customer** - Orders food via mobile app
- **restaurant** - Manages menu and accepts orders via web dashboard
- **driver** (also `delivery`) - Delivers orders via mobile app
- **admin** - Platform management via web dashboard

## Development Commands

### Backend (Node.js/Express/TypeScript)
```bash
cd backend
npm install && cp .env.example .env  # First time setup
npm run dev                           # Development server (port 5000)
npm run build                         # TypeScript compilation
npm test                              # Jest tests
npm run test:watch                    # Watch mode
npm run test:coverage                 # Jest with coverage report
npm run lint:fix                      # ESLint + fix
npm run seed                          # Database seeding
```

### Restaurant Dashboard (Next.js)
```bash
cd restaurant-dashboard
npm install
npm run dev    # Development server (port 3001)
npm run build  # Production build
npm run lint   # ESLint
```

### Admin Dashboard (Next.js)
```bash
cd admin-dashboard
npm install
npm run dev    # Development server (port 3002)
npm run build  # Production build
npm run lint   # ESLint
```

### Flutter Apps (Customer, Delivery & Restaurant)
```bash
cd customer-app  # or delivery-app or restaurant-app
flutter pub get
flutter run                           # Run on device/emulator
flutter test                          # Run all tests
flutter test test/widget_test.dart    # Single test file
flutter build apk                     # Android build
flutter build ios                     # iOS build
dart run build_runner build           # Generate Freezed/JSON code
dart run build_runner build --delete-conflicting-outputs  # Rebuild from scratch
```

### Docker Deployment
```bash
docker-compose up -d                  # Start all services
docker-compose up -d backend          # Start backend only
docker-compose logs -f backend        # View logs
```

## Architecture

### Monorepo Structure
- **backend/** - Express REST API with MongoDB (Mongoose)
- **customer-app/** - Flutter mobile app for ordering
- **delivery-app/** - Flutter mobile app for drivers (includes background location)
- **restaurant-app/** - Flutter mobile app for restaurant owners (includes fl_chart for analytics, audioplayers for order alerts)
- **restaurant-dashboard/** - Next.js 14 web panel with App Router
- **admin-dashboard/** - Next.js 14 web panel for platform admins
- **shared/** - TypeScript types shared across backend and dashboards

### Backend Architecture
Uses path aliases configured in tsconfig.json:
- `@controllers/*`, `@services/*`, `@models/*`, `@middleware/*`, `@validators/*`, `@utils/*`, `@config/*`, `@types/*`

Request flow: Routes → Validators (Joi) → Controllers → Services → Models

Key directories:
- `src/models/` - Mongoose models (User, Restaurant, Order, Driver, MenuItem, etc.)
- `src/controllers/` - Request handlers using service layer
- `src/services/` - Business logic (auth, restaurant, menu, order, upload, socket)
- `src/middleware/` - Auth, validation, error handling, file upload (multer)
- `src/validators/` - Joi schemas for request validation
- `src/__tests__/` - Jest tests organized by type (validators, services, integration)

### Frontend Architecture
**Dashboards (Next.js 14)**:
- App Router with route groups: `(auth)/` for login/register, `(dashboard)/` for main app
- Zustand stores in `src/stores/` for state management (auth, menu, orders)
- shadcn/ui components in `src/components/ui/`
- API service with axios in `src/lib/api.ts` - uses interceptors for auto token injection and 401 refresh handling
- Auth store pattern: `useAuthStore()` with `login()`, `logout()`, `checkAuth()`, persisted to localStorage

**Flutter Apps**:
- Riverpod for state management with StateNotifier pattern
- Freezed for immutable models (run `dart run build_runner build` after model changes)
- GoRouter for navigation (routes in `lib/config/routes.dart`)
- Services in `lib/services/`, Providers in `lib/providers/`
- Models generate `*.freezed.dart` and `*.g.dart` files (never edit these manually)
- API calls via `ApiService` singleton with Dio interceptors for auth
- Auth state via `AuthNotifier` with `flutter_secure_storage` for tokens

### Real-time Communication
Socket.io configured for live order updates. Room-based messaging pattern:
- `user:{userId}` - Personal notifications
- `restaurant:{restaurantId}` - Order notifications for restaurant
- `driver:{driverId}` - Delivery notifications
- `order:{orderId}` - Order status updates
- `drivers:online` - Available drivers pool
- `admin` - Admin monitoring

Helper functions in `@config/socket`:
```typescript
import { emitToUser, emitToRestaurant, emitToDriver, emitToOrder, getIO } from '@config/socket';
emitToUser(userId, 'order:status', { orderId, status });
emitToRestaurant(restaurantId, 'order:new', orderData);
getIO()?.to('drivers:online').emit('order:available', orderData);  // Broadcast to available drivers
```

Socket events emitted by server:
- `order:new` - New order for restaurant
- `order:status` - Order status update
- `order:driver_location` - Driver location during delivery
- `driver:status` - Driver online/offline status

Socket events clients can emit:
- `join:user`, `join:restaurant`, `join:driver`, `join:admin` - Join respective rooms
- `driver:online`, `driver:offline` - Toggle driver availability
- `driver:location` - Update driver location during delivery
- `order:subscribe`, `order:unsubscribe` - Track specific order updates

Chat events:
- `chat:message` - New message received (emitted to participants and order room)
- `chat:read` - Messages marked as read

### Order Status Flow
Order statuses progress in this sequence:
`pending` → `confirmed` → `preparing` → `ready` → `picked_up` → `on_the_way` → `delivered`

Or can be `cancelled` at any point before `delivered`. Order number format: `BAG-YYMMDD-XXXX` (e.g., `BAG-241215-0042`).

### Chat System
Order-based chat with three chat types per order:
- `customer_restaurant` - Between customer and restaurant
- `customer_driver` - Between customer and driver
- `restaurant_driver` - Between restaurant and driver

Message types: `text`, `image`, `location`. Chats are deactivated when order completes/cancels.

### Data Model Relationships
Key entities and their relationships:
- **User** - Base authentication entity. One User → one of (Customer, Restaurant owner, Driver)
- **Customer** - Has userId ref, manages addresses and favorites
- **Restaurant** - Has userId ref (owner), contains menu categories
- **Driver** - Has userId ref, tracks location and vehicle info
- **Order** - Links Customer, Restaurant, Driver. Contains order items (snapshots of menu items at time of order)
- **Chat** - Per-order, per-participant-pair (customer↔restaurant, customer↔driver, restaurant↔driver)
- **Payout** - Restaurant withdrawal requests. Tracks amount, method, status, account details

Payment methods: `cash`, `card`, `wallet`. Payment statuses: `pending`, `paid`, `failed`, `refunded`.
Payout statuses: `pending`, `processing`, `completed`, `rejected`.

## Key Patterns

### Backend Error Handling
Use typed error classes from `@utils/errors`:
```typescript
import { NotFoundError, BadRequestError, UnauthorizedError, ForbiddenError, ValidationError, ConflictError, TooManyRequestsError, ServiceUnavailableError } from '@utils/errors';
throw new NotFoundError('المطعم غير موجود');
throw new BadRequestError('البيانات غير صحيحة');
throw new ConflictError('البريد الإلكتروني مستخدم بالفعل');
```

### API Response Format
Use response helpers from `@utils/response`:
```typescript
import { sendSuccess, sendCreated, sendPaginated, sendError } from '@utils/response';
sendSuccess(res, data, 'تم بنجاح');
sendCreated(res, newItem, 'تم الإنشاء');
sendPaginated(res, items, { total, page, limit, pages });
```

### Form Validation
- Backend: Joi schemas in `src/validators/`
- Dashboards: React Hook Form + Zod
- Flutter: Form Builder with custom validators in `lib/utils/validators.dart`

### Authentication Middleware
Use middleware from `@middleware/auth`:
```typescript
import { authenticate, authorize, optionalAuth, verifyRestaurantOwner, verifyDriver } from '@middleware/auth';

// Require authentication
router.get('/profile', authenticate, getProfile);

// Require specific roles
router.post('/admin/users', authenticate, authorize('admin'), createUser);

// Optional auth (user may or may not be logged in)
router.get('/restaurants', optionalAuth, getRestaurants);

// Verify ownership
router.put('/restaurants/:id', authenticate, verifyRestaurantOwner, updateRestaurant);
```

### Adding New Backend Endpoints
1. Create/update validator in `src/validators/`
2. Add service method in `src/services/`
3. Add controller in `src/controllers/`
4. Add route in `src/routes/` with validation middleware
5. Export from barrel files (`index.ts`) in each directory

### Security Middleware
Available in `@middleware/rateLimiter` and `@middleware/sanitize`:
```typescript
import { authLimiter, otpLimiter, payoutLimiter, orderActionLimiter, analyticsLimiter } from '@middleware/rateLimiter';
import { sanitizeInput } from '@middleware/sanitize';

// Apply rate limiting to sensitive routes
router.post('/payouts', authenticate, payoutLimiter, validate(createPayoutSchema), createPayout);
```

### Environment Validation
Environment variables are validated at startup using `@config/validateEnv`:
- Required in production: MONGODB_URI, JWT_SECRET, JWT_REFRESH_SECRET, Cloudinary credentials
- Startup fails if required vars are missing in production mode

## API Structure

All backend routes are versioned under `/api/v1/`:
- `/api/v1/auth` - Authentication (login, register, refresh, password reset)
- `/api/v1/customers` - Customer profile and addresses
- `/api/v1/restaurants` - Restaurant listings and details
- `/api/v1/menu` - Menu items and categories
- `/api/v1/orders` - Order management
- `/api/v1/drivers` - Driver management
- `/api/v1/payments` - Payment processing (Paymob)
- `/api/v1/wallet` - Wallet operations
- `/api/v1/chats` - Real-time messaging
- `/api/v1/reviews` - Ratings and reviews
- `/api/v1/notifications` - Push notifications
- `/api/v1/coupons` - Discount codes
- `/api/v1/transactions` - Payment history
- `/api/v1/admin` - Admin operations
- `/api/v1/upload` - File uploads (Cloudinary)

Rate limiting:
- Auth routes: 10 req/15min (login, register, password reset)
- OTP routes: 3 req/10min (resend-otp, forgot-password)
- Payout routes: 5 req/15min (financial security)
- Analytics routes: 10 req/5min (heavy queries)
- Order actions: 30 req/min (accept, reject, status updates)
- General routes: 100 req/15min

### Driver Order Rejection
Drivers can reject assigned orders with a reason:
```typescript
PUT /api/v1/driver/orders/:orderId/reject
Body: { reason: string } // 10-500 characters required
```
When rejected:
- Order status resets to `ready` for reassignment
- Driver becomes available again
- Restaurant receives notification
- Order broadcast to available drivers

### Restaurant Analytics
```typescript
GET /api/v1/restaurants/analytics?period=week|month|year|custom&startDate=ISO&endDate=ISO
```
Returns: summary stats, charts (ordersByDay, ordersByHour, topItems, ordersByStatus), comparison with previous period.

### Restaurant Payout System
```typescript
GET /api/v1/restaurants/balance  // Get available balance
GET /api/v1/restaurants/payouts  // List payout history (paginated)
POST /api/v1/restaurants/payouts // Create withdrawal request
```
Payout methods: `bank_transfer`, `vodafone_cash`, `instapay`. Minimum withdrawal: 100 EGP.

### Authentication Flow
JWT-based with access + refresh tokens:
1. Login/Register returns `accessToken` (15min) and `refreshToken` (7d)
2. Access token sent in `Authorization: Bearer <token>` header
3. On 401, client calls `/api/v1/auth/refresh` with refresh token
4. Tokens stored: dashboards use localStorage, Flutter apps use `flutter_secure_storage`

## Environment Configuration

Backend requires `.env` with:
- MongoDB URI, JWT secrets (access + refresh)
- Cloudinary credentials (image uploads)
- Firebase config (auth + push notifications)
- Paymob keys (payment processing)
- Resend API key (email service)

Business settings configured via `.env`:
- `DEFAULT_COMMISSION=15` - Platform commission percentage
- `SERVICE_FEE=3` - Fixed service fee (EGP)
- `DELIVERY_FEE_PER_KM=2` - Delivery fee per kilometer (EGP)
- `MAX_DELIVERY_DISTANCE=10` - Maximum delivery radius (km)

CORS configured for ports: 3000 (customer web), 3001 (restaurant), 3002 (admin).

## Maps & Location

**Flutter apps use OpenStreetMap (free):**
- `flutter_map` with OpenStreetMap tiles for map display
- Nominatim API for geocoding (address ↔ coordinates)
- `geolocator` for device location
- `latlong2` for coordinate types

Google Maps is NOT used in Flutter apps (commented out in pubspec.yaml).

## Bilingual Support

All apps support Arabic (RTL) and English. Arabic error messages for user-facing errors. Cairo font for Arabic text in Flutter apps.

## Testing

### Backend Tests
```bash
cd backend
npm test                              # Run all tests
npm run test:watch                    # Watch mode
npm test -- --testPathPattern=auth    # Run specific test file
```
Tests use Jest + Supertest. Test files in `src/__tests__/` with `.test.ts` extension.

### Flutter Tests
```bash
cd customer-app  # or delivery-app or restaurant-app
flutter test                          # Run all tests
flutter test test/widget_test.dart    # Single test file
flutter test --coverage               # With coverage
```

## Production Infrastructure

### Health Check Endpoints
- `GET /health` - Full health status (database, memory, uptime)
- `GET /health/live` - Liveness probe (for Kubernetes)
- `GET /health/ready` - Readiness probe (checks database connection)

### Structured Logging
In production (`NODE_ENV=production`), logs are output as JSON for log aggregation:
```json
{"timestamp":"2024-01-20T10:00:00.000Z","level":"INFO","message":"HTTP Request","meta":{"method":"GET","url":"/health"},"service":"bagour-delivery-api"}
```

### Graceful Shutdown
Server handles SIGTERM/SIGINT signals and closes connections gracefully with a 10-second timeout.
