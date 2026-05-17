// Exercise the api-client against the live backend to make sure
// every endpoint's shape lines up with the wrapper expectations.
import { createApiClient } from "@bagour/api-client";

const TOKENS = {};

const api = createApiClient({
  baseURL: "http://localhost:5001",
  auth: {
    getAccessToken: () => TOKENS.accessToken ?? null,
    getRefreshToken: () => TOKENS.refreshToken ?? null,
    setTokens: (t) => Object.assign(TOKENS, t),
    clear: () => { TOKENS.accessToken = null; TOKENS.refreshToken = null; },
  },
});

const runs = [];
const record = (name, p) => runs.push(p.then(r => ({ name, ok: true, summary: summarize(r) }), e => ({ name, ok: false, err: e?.message ?? String(e) })));

function summarize(r) {
  if (Array.isArray(r)) return `array(len=${r.length})`;
  if (r && typeof r === 'object') {
    if (Array.isArray(r.data)) return `paginated(len=${r.data.length}, totalPages=${r.pagination?.totalPages}, hasNext=${r.pagination?.hasNextPage})`;
    if (r.user) return `auth(user=${r.user.name}, role=${r.user.role}, hasAccess=${!!r.tokens?.accessToken})`;
    if (r.name) return `entity(name=${r.name})`;
    if (r.categories) return `menu(cats=${r.categories.length}, items=${r.items?.length})`;
    return `object(${Object.keys(r).slice(0,5).join(',')})`;
  }
  return String(r);
}

// 1) Featured restaurants (was the crash)
record('restaurants.featured', api.restaurants.featured());
// 2) Search (paginated)
record('restaurants.search', api.restaurants.search({ limit: 5 }));
// 3) Nearby (needs geo)
record('restaurants.nearby', api.restaurants.nearby({ lat: 30.426, lng: 30.965, radius: 10 }));

// Login then exercise authed endpoints
const customerLogin = await api.auth.login({ email: 'ahmed@test.com', password: 'Test@123' });
TOKENS.accessToken = customerLogin.tokens.accessToken;
TOKENS.refreshToken = customerLogin.tokens.refreshToken;
runs.push({ name: 'auth.login(customer)', ok: !!TOKENS.accessToken, summary: `user=${customerLogin.user.name}, role=${customerLogin.user.role}` });

record('customer.profile', api.customer.profile());
record('customer.addresses', api.customer.addresses());
record('customer.favorites', api.customer.favorites());
record('orders.myOrders', api.orders.myOrders({ limit: 5 }));

// Pick the first featured slug → bySlug + menu
const featured = await api.restaurants.featured();
if (featured[0]) {
  record('restaurants.bySlug', api.restaurants.bySlug(featured[0].slug));
  record('restaurants.menu', api.restaurants.menu(featured[0].slug));
}

// Driver flow
const driverLogin = await api.auth.login({ email: 'driver1@test.com', password: 'Test@123' });
TOKENS.accessToken = driverLogin.tokens.accessToken;
TOKENS.refreshToken = driverLogin.tokens.refreshToken;
runs.push({ name: 'auth.login(driver)', ok: !!TOKENS.accessToken, summary: `user=${driverLogin.user.name}, role=${driverLogin.user.role}` });

record('driver.profile', api.drivers.profile());
record('driver.stats', api.drivers.stats());
record('driver.myOrders', api.drivers.myOrders({}));
record('driver.availableOrders', api.drivers.availableOrders({ lat: 30.426, lng: 30.965, maxDistance: 10 }));

const results = await Promise.all(runs);
let pass = 0, fail = 0;
for (const r of results) {
  if (r.ok) { pass++; console.log(`PASS  ${r.name.padEnd(28)} ${r.summary}`); }
  else { fail++; console.log(`FAIL  ${r.name.padEnd(28)} ${r.err}`); }
}
console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
