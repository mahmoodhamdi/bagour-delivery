# Bagour Delivery - توصيل الباجور

A complete food delivery platform for Bagour city, Monufia, Egypt.

## Tech Stack

| Component | Technology |
|-----------|------------|
| Backend | Node.js + Express.js + TypeScript + MongoDB |
| Mobile Apps | Flutter + Riverpod |
| Web Dashboards | Next.js 14 + TypeScript + Tailwind + shadcn/ui |
| Real-time | Socket.io |
| Authentication | JWT + Firebase Auth |
| Maps | Google Maps API |
| Notifications | Firebase Cloud Messaging |
| Storage | Cloudinary |
| Payment | Paymob |

## Project Structure

```
bagour-delivery/
├── backend/                 # Node.js REST API
├── customer-app/           # Flutter customer mobile app
├── delivery-app/           # Flutter delivery driver app
├── restaurant-dashboard/   # Next.js restaurant owner panel
├── admin-dashboard/        # Next.js admin panel
├── shared/                 # Shared types and utilities
└── docs/                   # Documentation
```

## User Roles

- **Customer (العميل)**: Browse restaurants, place orders, track deliveries
- **Restaurant Owner (صاحب المطعم)**: Manage menu, accept orders, view statistics
- **Delivery Driver (السائق)**: Accept deliveries, navigate, update status
- **Admin (المدير)**: Full platform management

## Getting Started

### Prerequisites

- Node.js 18+
- Flutter 3.x
- MongoDB
- Docker (optional)

### Backend Setup

```bash
cd backend
npm install
cp .env.example .env
# Configure your .env file
npm run dev
```

### Customer App Setup

```bash
cd customer-app
flutter pub get
flutter run
```

### Delivery App Setup

```bash
cd delivery-app
flutter pub get
flutter run
```

### Restaurant Dashboard Setup

```bash
cd restaurant-dashboard
npm install
npm run dev
# Runs on http://localhost:3001
```

### Admin Dashboard Setup

```bash
cd admin-dashboard
npm install
npm run dev
# Runs on http://localhost:3002
```

## API Documentation

API documentation is available at `/api/docs` when running the backend in development mode.

## License

Proprietary - All rights reserved
