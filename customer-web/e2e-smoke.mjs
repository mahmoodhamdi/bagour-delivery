/**
 * End-to-end smoke test. Walks the order lifecycle through every actor:
 *   customer → restaurant → driver → completion.
 *
 * Uses raw axios for restaurant + admin endpoints (which aren't exposed
 * via @bagour/api-client yet) and the typed client for everything else.
 */
import { createApiClient } from "@bagour/api-client";

// Use fetch (built-in) instead of pulling axios as a dev dependency.
const httpJson = async (method, url, headers, body) => {
  const res = await fetch(url, {
    method,
    headers: { "Content-Type": "application/json", ...headers },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  const json = text ? JSON.parse(text) : null;
  if (!res.ok) {
    const err = new Error(json?.message || `HTTP ${res.status}`);
    err.status = res.status;
    err.body = json;
    throw err;
  }
  return { data: json };
};
const axios = {
  get: (url, opts = {}) => httpJson("GET", url + (opts.params ? `?${new URLSearchParams(opts.params)}` : ""), opts.headers),
  put: (url, body, opts = {}) => httpJson("PUT", url, opts.headers, body),
  post: (url, body, opts = {}) => httpJson("POST", url, opts.headers, body),
};

const BASE = "http://localhost:5001";

function makeApi() {
  const tokens = {};
  const api = createApiClient({
    baseURL: BASE,
    auth: {
      getAccessToken: () => tokens.accessToken ?? null,
      getRefreshToken: () => tokens.refreshToken ?? null,
      setTokens: (t) => Object.assign(tokens, t),
      clear: () => { tokens.accessToken = null; tokens.refreshToken = null; },
    },
  });
  return { api, tokens };
}

const log = (label, ok, detail = "") => {
  const tag = ok ? "PASS" : "FAIL";
  console.log(`${tag}  ${label.padEnd(34)} ${detail}`);
  return ok;
};

async function main() {
  let pass = 0, fail = 0;
  const tally = (ok) => ok ? pass++ : fail++;

  // ── 1. Customer logs in ────────────────────────────────────────────────
  const customer = makeApi();
  let cLogin;
  try {
    cLogin = await customer.api.auth.login({ email: "ahmed@test.com", password: "Test@123" });
    customer.tokens.accessToken = cLogin.tokens.accessToken;
    customer.tokens.refreshToken = cLogin.tokens.refreshToken;
    tally(log("customer login", true, cLogin.user.name));
  } catch (e) {
    tally(log("customer login", false, e.message));
    return;
  }

  // ── 2. Customer browses + picks the restaurant owned by restaurant1@test.com.
  // (Smoke test uses Bagouri Kitchen — its owner is the seeded restaurant1
  // user, which is the account we log in as for the restaurant role below.)
  const restaurants = await customer.api.restaurants.search({ limit: 10 });
  const r =
    restaurants.data.find((x) => x.slug.startsWith("bagouri-kitchen")) ?? restaurants.data[0];
  tally(log("browse restaurants", !!r, `${restaurants.data.length} restaurants, picked ${r.name}`));
  const menu = await customer.api.restaurants.menu(r.slug);
  tally(log("fetch menu", menu.items.length > 0, `${menu.items.length} items`));

  // ── 3. Customer creates an order ────────────────────────────────────────
  const item = menu.items[0];
  const addresses = await customer.api.customer.addresses();
  const addr = addresses[0];
  let order;
  try {
    order = await customer.api.orders.create({
      restaurantId: r.id,
      items: [{ menuItemId: item.id, quantity: 1 }],
      paymentMethod: "cash",
      deliveryAddress: {
        name: addr.name ?? addr.label ?? "Home",
        address: addr.address ?? addr.street ?? "Test address",
        area: addr.area ?? "Test area",
        city: addr.city ?? "Bagour",
        phone: "01000000001",
        coordinates: addr.location?.coordinates ?? [30.965, 30.426],
      },
    });
    tally(log("create order", !!order.id, `#${order.orderNumber} ${order.status}`));
  } catch (e) {
    tally(log("create order", false, e.message));
    if (e.fieldErrors) console.log("Field errors:", JSON.stringify(e.fieldErrors, null, 2));
    return;
  }

  // ── 4. Restaurant logs in and finds the order ──────────────────────────
  const restaurantUser = makeApi();
  const rLogin = await restaurantUser.api.auth.login({
    email: "restaurant1@test.com", password: "Test@123",
  });
  restaurantUser.tokens.accessToken = rLogin.tokens.accessToken;
  restaurantUser.tokens.refreshToken = rLogin.tokens.refreshToken;
  tally(log("restaurant login", true, rLogin.user.name));

  // Pull pending orders directly via axios (no typed client for restaurant orders yet)
  const rOrdersResp = await axios.get(`${BASE}/api/v1/restaurant/orders`, {
    headers: { Authorization: `Bearer ${rLogin.tokens.accessToken}` },
    params: { status: "pending", limit: 10 },
  });
  const pending = rOrdersResp.data.data.find((o) => o.id === order.id || o._id === order.id);
  tally(log("restaurant sees order", !!pending, pending ? `#${pending.orderNumber}` : "not found"));

  // ── 5. Restaurant confirms → preparing → ready ─────────────────────────
  const headers = { Authorization: `Bearer ${rLogin.tokens.accessToken}` };
  try {
    await axios.put(`${BASE}/api/v1/restaurant/orders/${order.id}/confirm`, { note: "smoke test" }, { headers });
    tally(log("restaurant confirms", true));
    await axios.put(`${BASE}/api/v1/restaurant/orders/${order.id}/preparing`, { note: "" }, { headers });
    tally(log("restaurant preparing", true));
    await axios.put(`${BASE}/api/v1/restaurant/orders/${order.id}/ready`, { note: "" }, { headers });
    tally(log("restaurant ready", true));
  } catch (e) {
    tally(log("restaurant transitions", false, e.response?.data?.message || e.message));
  }

  // ── 6. Driver logs in, goes online, finds the order ────────────────────
  const driver = makeApi();
  const dLogin = await driver.api.auth.login({ email: "driver1@test.com", password: "Test@123" });
  driver.tokens.accessToken = dLogin.tokens.accessToken;
  driver.tokens.refreshToken = dLogin.tokens.refreshToken;
  tally(log("driver login", true, dLogin.user.name));

  // Driver must be online + available
  try {
    await driver.api.drivers.toggleOnline(true);
    await driver.api.drivers.toggleAvailability(true);
    tally(log("driver online + available", true));
  } catch (e) {
    tally(log("driver online", false, e.message));
  }

  const available = await driver.api.drivers.availableOrders({ lat: 30.426, lng: 30.965, maxDistance: 50 });
  const offered = available.find((o) => o.id === order.id || o._id === order.id);
  tally(log("driver sees order", !!offered, offered ? `#${offered.orderNumber}` : `${available.length} others available`));

  // ── 7. Driver accepts → picked-up → on-the-way → delivered ─────────────
  try {
    const accepted = await driver.api.drivers.acceptOrder(order.id);
    // Backend transitions the order to either accepted_by_driver or stays
    // in `ready` while bookkeeping the assignment. Either is fine — the
    // subsequent picked_up call is the real proof the driver took ownership.
    tally(log("driver accepts", !!accepted.id, accepted.status));
    const picked = await driver.api.drivers.markPickedUp(order.id, "got it");
    tally(log("driver picked up", picked.status === "picked_up", picked.status));
    const onTheWay = await driver.api.drivers.markOnTheWay(order.id);
    tally(log("driver on the way", onTheWay.status === "on_the_way", onTheWay.status));
    const delivered = await driver.api.drivers.markDelivered(order.id, { note: "delivered" });
    tally(log("driver delivered", delivered.status === "delivered", delivered.status));
  } catch (e) {
    tally(log("driver transitions", false, e.message || e.fieldErrors));
  }

  // ── 8. Customer sees completed order ───────────────────────────────────
  const myOrders = await customer.api.orders.myOrders({ limit: 5 });
  const finalOrder = myOrders.data.find((o) => o.id === order.id);
  tally(log("customer sees final order", finalOrder?.status === "delivered", finalOrder?.status));

  console.log(`\n${pass} passed, ${fail} failed`);
  process.exit(fail ? 1 : 0);
}

main().catch((e) => {
  console.error("Smoke crashed:", e);
  process.exit(1);
});
