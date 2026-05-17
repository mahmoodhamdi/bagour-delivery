// Probe admin-dashboard backend interactions end-to-end.
const BASE = "http://localhost:5001/api/v1";

async function call(method, url, headers = {}, body) {
  const res = await fetch(`${BASE}${url}`, {
    method,
    headers: { "Content-Type": "application/json", ...headers },
    body: body ? JSON.stringify(body) : undefined,
  });
  const j = await res.json().catch(() => ({}));
  return { status: res.status, body: j };
}

const log = (label, ok, detail = "") => {
  console.log(`${ok ? "PASS" : "FAIL"}  ${label.padEnd(36)} ${detail}`);
  return ok;
};
let pass = 0, fail = 0;
const t = (ok) => ok ? pass++ : fail++;

// 1) Login
const login = await call("POST", "/auth/login", {}, { email: "admin@bagour-delivery.com", password: "Admin@123", role: "admin" });
t(log("admin login", login.status === 200 && !!login.body.data?.accessToken, `role=${login.body.data?.user?.role}`));
const auth = { Authorization: `Bearer ${login.body.data.accessToken}` };

// 2) Dashboard endpoints (admin-dashboard UI calls these)
const endpoints = [
  ["dashboardStats", "/admin/dashboard/stats"],
  ["recentOrders", "/admin/dashboard/recent-orders?limit=5"],
  ["topRestaurants", "/admin/dashboard/top-restaurants?limit=5"],
  ["revenueChart", "/admin/dashboard/revenue-chart"],
  ["users", "/admin/users?limit=5"],
  ["restaurants", "/admin/restaurants?limit=5"],
  ["drivers", "/admin/drivers?limit=5"],
  ["orders", "/admin/orders?limit=5"],
  ["zones", "/admin/zones"],
  ["coupons", "/admin/coupons?limit=5"],
  ["settings", "/admin/settings"],
  ["transactions", "/admin/transactions?limit=5"],
  ["popularItems", "/admin/analytics/popular-items"],
  ["customerStats", "/admin/analytics/customers"],
  ["financialSummary", "/admin/analytics/financial"],
  ["ordersAnalytics", "/admin/analytics/orders"],
  ["me", "/auth/me"],
];
for (const [label, path] of endpoints) {
  const r = await call("GET", path, auth);
  const detail = r.status === 200
    ? (Array.isArray(r.body.data) ? `array(${r.body.data.length})` : typeof r.body.data === "object" ? `obj(${Object.keys(r.body.data ?? {}).slice(0,4).join(",")})` : String(r.body.data))
    : r.body.message || r.body.error?.code;
  t(log(label, r.status === 200, `${r.status} ${detail}`));
}

console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
