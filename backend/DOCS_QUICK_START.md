# API Documentation - Quick Start Guide

## 🚀 Quick Access

| Documentation Type | URL | Best For |
|-------------------|-----|----------|
| **Swagger UI** | http://localhost:5000/api-docs | Interactive testing & exploration |
| **ReDoc** | http://localhost:5000/api-redoc | Clean reading & review |
| **Postman Collection** | `postman_collection.json` | Postman users |
| **OpenAPI JSON** | http://localhost:5000/api-docs.json | Tool integration |

## 📦 What's Included

### ✅ Swagger UI
- Interactive API testing directly from browser
- Try endpoints with real requests
- Built-in authentication support
- All request/response schemas documented
- Organized by tags/modules

### ✅ ReDoc
- Professional, clean documentation interface
- Perfect for reading and reviewing
- Arabic font support (Cairo)
- Searchable documentation
- Downloadable specs

### ✅ Postman Collection
- Pre-configured collection with all endpoints
- Auto-save tokens after login
- Collection variables for IDs
- Bearer token authentication setup
- Request grouping by modules

## 🔄 Regenerate Postman Collection

After updating API documentation:

```bash
npm run generate:postman
# or
npm run docs:export
```

## 📝 Documentation Files

All endpoint documentation is in YAML format:
```
backend/src/docs/
├── auth.yaml           # Authentication
├── customer.yaml       # Customer management
├── restaurants.yaml    # Restaurant browsing
├── menu.yaml          # Menu & items
├── orders.yaml        # Order management
├── driver.yaml        # Driver operations
├── reviews.yaml       # Reviews & ratings
├── coupons.yaml       # Coupons & discounts
├── payments.yaml      # Payment processing
├── transactions.yaml  # Financial transactions
├── notifications.yaml # Notifications
├── admin.yaml         # Admin dashboard
└── upload.yaml        # File uploads
```

## 🔐 Authentication

Protected endpoints require JWT token:

```
Authorization: Bearer <your_access_token>
```

### Login Endpoints:
- Customer: `POST /api/v1/auth/customer/login`
- Restaurant: `POST /api/v1/auth/restaurant/login`
- Driver: `POST /api/v1/auth/driver/login`
- Admin: `POST /api/v1/auth/admin/login`

### Using Token in Swagger:
1. Click "Authorize" 🔓 button at top
2. Enter your access token
3. Click "Authorize"
4. All requests will now include the token

## 📊 API Statistics

- **Total Endpoints:** 150+
- **Modules:** 14
- **Authentication Methods:** JWT Bearer
- **Response Format:** JSON
- **Supported Roles:** Customer, Restaurant, Driver, Admin

## 🎯 Common Workflows

### Customer Flow:
1. Register → `POST /auth/customer/register`
2. Login → `POST /auth/customer/login`
3. Browse Restaurants → `GET /restaurants`
4. View Menu → `GET /restaurants/:id/menu`
5. Create Order → `POST /orders`
6. Track Order → `GET /orders/:id`

### Restaurant Flow:
1. Login → `POST /auth/restaurant/login`
2. View Orders → `GET /restaurant/orders`
3. Update Order Status → `PATCH /restaurant/orders/:id/status`
4. Manage Menu → `POST /menu/items`

### Driver Flow:
1. Login → `POST /auth/driver/login`
2. Go Online → `PATCH /driver/online`
3. Accept Order → `PATCH /driver/orders/:id/accept`
4. Update Location → `POST /driver/location`
5. Complete Delivery → `PATCH /driver/orders/:id/complete`

## 💡 Tips

### Swagger UI:
- Use "Authorize" button once to authenticate all requests
- Click "Try it out" to test endpoints interactively
- Check "Schemas" section for data structures

### Postman:
- After login, access token is auto-saved to collection variables
- Use `{{accessToken}}` variable in headers
- All requests inherit authentication from collection

### ReDoc:
- Use search bar to find specific endpoints
- Click on schemas to see details
- Download button for offline access

## 🔧 Development

Start the backend server:
```bash
cd backend
npm run dev
```

Then access documentation at the URLs above.

## 📥 Export Options

### Download OpenAPI Spec:
```
http://localhost:5000/api-docs.json
```

Use this file with:
- Postman import
- Insomnia
- OpenAPI Generator (for SDKs)
- Any OpenAPI-compatible tool

## 🌍 Servers

- **Development:** http://localhost:5000/api/v1
- **Production:** https://api.bagour-delivery.com/api/v1

## 📧 Support

For issues or questions:
- Email: support@bagour-delivery.com
- GitHub Issues

---

**Note:** Make sure MongoDB is running and `.env` is configured before starting the server.
