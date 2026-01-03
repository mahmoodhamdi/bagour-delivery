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
flutter run              # Run on device/emulator
flutter test             # Run tests
flutter test test/widget_test.dart  # Single test
flutter build apk        # Android build
flutter build ios        # iOS build
```

## Architecture

### Monorepo Structure
- **backend/** - Express REST API with MongoDB (Mongoose)
- **customer-app/** - Flutter mobile app for ordering
- **delivery-app/** - Flutter mobile app for drivers (includes background location)
- **restaurant-dashboard/** - Next.js web panel for restaurant owners
- **admin-dashboard/** - Next.js web panel for platform admins
- **shared/** - TypeScript types used across backend and dashboards

### Backend Architecture
Uses path aliases (`@controllers/*`, `@services/*`, `@models/*`, etc.) configured in tsconfig.json.

Request flow: Routes → Validators (Joi) → Controllers → Services → Models

Key directories:
- `src/models/` - 13 Mongoose models (User, Restaurant, Order, Driver, etc.)
- `src/controllers/` - Request handlers using service layer
- `src/services/` - Business logic (auth.service.ts handles JWT, OTP, registration)
- `src/middleware/` - Auth, validation, error handling
- `src/validators/` - Joi schemas for request validation

### Frontend State Management
- **Dashboards**: Zustand with localStorage persistence for auth state
- **Flutter Apps**: Riverpod with StateNotifier pattern, Freezed for immutable models

### Real-time Communication
Socket.io configured for live order updates between all platforms.

## Key Patterns

### Backend Error Handling
Custom `AppError` class with HTTP status codes. Arabic error messages for user-facing errors.

```typescript
throw new AppError('رسالة الخطأ', StatusCodes.BAD_REQUEST);
```

### API Response Format
Use response helpers from `@utils/response`:
```typescript
sendSuccess(res, data, 'Success message');
sendError(res, 'Error message', statusCode);
```

### Flutter Navigation
GoRouter with type-safe routes. Route definitions in `lib/core/routes/`.

### Form Validation
- Backend: Joi schemas in `src/validators/`
- Dashboards: React Hook Form + Zod
- Flutter: Form Builder with custom validators

## Environment Configuration

Backend requires `.env` with:
- MongoDB URI
- JWT secrets (access + refresh tokens)
- Cloudinary credentials (image uploads)
- Firebase config (auth + push notifications)
- Paymob keys (payment processing)
- Google Maps API key

Frontend CORS configured for ports 3000 (customer), 3001 (restaurant), 3002 (admin).

## Bilingual Support

All apps support Arabic (RTL) and English. Cairo font for Arabic text in Flutter apps.

## Current Development Status

Phase 1 (Project Foundation) is complete. Phase 2 (Authentication) is in progress. See PROJECT_PROGRESS.md for detailed milestone tracking.
