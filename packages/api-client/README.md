# @bagour/api-client

Typed HTTP client for the Bagour Delivery REST API. Wraps axios, layers in JWT refresh, normalizes errors, and ships MSW handlers + factories for tests.

## Quick start

```ts
import { createApiClient } from "@bagour/api-client";

const api = createApiClient({
  baseURL: process.env.NEXT_PUBLIC_API_URL!,
  auth: {
    getAccessToken: () => sessionStore.getState().accessToken,
    setTokens: ({ accessToken }) => sessionStore.setState({ accessToken }),
    clear: () => sessionStore.setState({ accessToken: null }),
  },
  onSignOut: () => router.push("/login"),
});

const { user, tokens } = await api.auth.login({ email, password });
const restaurants = await api.restaurants.search({ cuisine: "koshary" });
const order = await api.orders.create({ restaurantId, items, paymentMethod: "cash" });
```

## What's wired

| Namespace           | Endpoints                                                                                                                                         |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `api.auth`          | register, verifyEmail, resendOtp, login, google, forgotPassword, resetPassword, changePassword, refresh, updateFcmToken, logout, me               |
| `api.customer`      | profile, loyaltyPoints, addresses (CRUD + default), favorites                                                                                     |
| `api.restaurants`   | search, featured, nearby, bySlug, menu                                                                                                            |
| `api.orders`        | create, myOrders, byId, cancel, rate, reorder                                                                                                     |
| `api.drivers`       | profile, updateProfile/avatar/location/online/availability/documents, stats, availableOrders, myOrders, accept/reject/pickup/on-the-way/delivered |
| `api.coupons`       | available, validate                                                                                                                               |
| `api.notifications` | list, unreadCount, markRead, markAllRead, remove, subscribePush, unsubscribePush                                                                  |
| `api.reviews`       | forRestaurant, myReviews, create                                                                                                                  |
| `api.uploads`       | upload, deleteUpload                                                                                                                              |

Restaurant-owner and admin endpoints will be added when the customer-web + driver-web cover them — the admin/restaurant dashboards already have their own clients today.

## Token refresh

The client intercepts 401s, calls `/api/v1/auth/refresh-token` once, retries the original request, and falls back to `auth.clear()` + `onSignOut()` if the refresh itself fails. For httpOnly cookie flows, leave `getRefreshToken` undefined — the browser sends the cookie automatically when `withCredentials: true` (the default).

## Error handling

All errors are normalized to `ApiError`:

```ts
try {
  await api.orders.create(payload);
} catch (e) {
  if (e instanceof ApiError) {
    if (e.isAuthError) router.push("/login");
    else if (e.fieldErrors) showFormErrors(e.fieldErrors);
    else if (e.isRetryable) retry();
    else toast(e.message);
  }
}
```

## Testing with MSW

```ts
import { setupServer } from "msw/node";
import { createDefaultHandlers } from "@bagour/api-client/test-handlers";
import { makeRestaurant } from "@bagour/api-client/factories";

const server = setupServer(...createDefaultHandlers());
beforeAll(() => server.listen());

// Override a specific handler in a test:
server.use(
  http.get("*/api/v1/restaurants/featured", () =>
    HttpResponse.json({ success: true, data: [makeRestaurant({ name: "Test" })] }),
  ),
);
```

## Tests

```bash
pnpm --filter @bagour/api-client test
```

The suite covers: endpoint binding, bearer injection, 401→refresh→retry, refresh-failure sign-out, error normalization (4xx/5xx/network), and default-header forwarding.
