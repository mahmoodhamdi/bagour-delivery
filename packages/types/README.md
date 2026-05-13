# @bagour/types

Single import surface for shared TypeScript types, constants, and Zod schemas used by `customer-web` and `driver-web`.

## What's inside

```
src/
├── user.ts           # BaseUser, Address, Customer
├── restaurant.ts     # Restaurant, MenuCategory, MenuItem, MenuOption, MenuAddon
├── driver.ts         # Driver, DriverDocuments
├── order.ts          # Order, OrderItem, status enums
├── common.ts         # ApiResponse, PaginatedResponse, Coupon, Zone, Review, Notification, Transaction
├── web.ts            # AuthSession, PushSubscriptionPayload, SocketEvent catalog, DriverLocationUpdate
├── constants.ts      # APP_CONFIG, BAGOUR_LOCATION, ORDER_STATUS_META, etc.
└── schemas.ts        # Zod runtime validators for all of the above + form payload schemas
```

## Usage

```ts
import type { Restaurant, Order, AuthSession } from "@bagour/types";
import { loginPayloadSchema } from "@bagour/types/schemas";
import { APP_CONFIG } from "@bagour/types/constants";

const result = loginPayloadSchema.safeParse(formData);
```

## Why dates are strings here

The wire format from the backend is JSON, so timestamps arrive as ISO-8601 strings. Apps that need `Date` objects should call `new Date(...)` at the consumption site — keeping the types as `string` avoids serialization headaches at component boundaries.

## Compared to `shared/types/`

`shared/types/` is the Flutter-flavored canonical source. This package re-shapes those types for TypeScript-first web consumption (string timestamps, web-only types added, Zod schemas alongside). If `shared/types/` grows, mirror the change here.

## Tests

```bash
pnpm --filter @bagour/types test
```

Schema parsing is verified with a small Vitest suite. Add a test whenever you extend a schema with cross-field validation or new required fields.
