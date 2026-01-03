# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bagour Delivery is a food delivery platform monorepo for Bagour city, Egypt. It consists of 6 projects serving 4 user roles (Customer, Restaurant Owner, Delivery Driver, Admin).

## Development Commands

### Backend (Node.js/Express/TypeScript)
```bash
cd backend
npm install && cp .env.example .env  # First time setup
npm run dev                           # Development server (port 5000)
npm run build                         # TypeScript compilation
npm test                              # Jest tests
npm run test:watch                    # Watch mode
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

### Flutter Apps (Customer & Delivery)
```bash
cd customer-app  # or delivery-app
flutter pub get
flutter run                           # Run on device/emulator
flutter test                          # Run all tests
flutter test test/widget_test.dart    # Single test file
flutter build apk                     # Android build
flutter build ios                     # iOS build
dart run build_runner build           # Generate Freezed/JSON code
dart run build_runner build --delete-conflicting-outputs  # Rebuild from scratch
```

## Architecture

### Monorepo Structure
- **backend/** - Express REST API with MongoDB (Mongoose)
- **customer-app/** - Flutter mobile app for ordering
- **delivery-app/** - Flutter mobile app for drivers (includes background location)
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

### Frontend Architecture
**Dashboards (Next.js 14)**:
- App Router with route groups: `(auth)/` for login/register, `(dashboard)/` for main app
- Zustand stores in `src/stores/` for state management
- shadcn/ui components in `src/components/ui/`
- API service with axios in `src/services/api.ts` or `src/lib/api.ts`

**Flutter Apps**:
- Riverpod for state management with StateNotifier pattern
- Freezed for immutable models (run `dart run build_runner build` after model changes)
- GoRouter for navigation (routes in `lib/config/routes.dart`)
- Services in `lib/services/`, Providers in `lib/providers/`
- Models generate `*.freezed.dart` and `*.g.dart` files (never edit these manually)

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
import { emitToUser, emitToRestaurant, emitToDriver, emitToOrder } from '@config/socket';
emitToUser(userId, 'order:status', { orderId, status });
emitToRestaurant(restaurantId, 'order:new', orderData);
```

## Key Patterns

### Backend Error Handling
Use typed error classes from `@utils/errors`:
```typescript
import { NotFoundError, BadRequestError, UnauthorizedError, ForbiddenError, ValidationError, ConflictError } from '@utils/errors';
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

## Environment Configuration

Backend requires `.env` with:
- MongoDB URI, JWT secrets (access + refresh)
- Cloudinary credentials (image uploads)
- Firebase config (auth + push notifications)
- Paymob keys (payment processing)
- Google Maps API key

CORS configured for ports: 3000 (customer web), 3001 (restaurant), 3002 (admin).

## Bilingual Support

All apps support Arabic (RTL) and English. Arabic error messages for user-facing errors. Cairo font for Arabic text in Flutter apps.

## Current Development Status

See PROJECT_PROGRESS.md for detailed milestone tracking.
