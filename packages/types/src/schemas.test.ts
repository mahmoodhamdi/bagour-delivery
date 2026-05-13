import { describe, expect, it } from "vitest";

import {
  addressSchema,
  loginPayloadSchema,
  orderSchema,
  paginatedResponseSchema,
  restaurantSchema,
  registerPayloadSchema,
} from "./schemas";

describe("loginPayloadSchema", () => {
  it("accepts a well-formed payload", () => {
    expect(loginPayloadSchema.parse({ email: "a@b.co", password: "secret123" })).toEqual({
      email: "a@b.co",
      password: "secret123",
    });
  });

  it("rejects short passwords", () => {
    const r = loginPayloadSchema.safeParse({ email: "a@b.co", password: "123" });
    expect(r.success).toBe(false);
  });

  it("rejects malformed emails", () => {
    const r = loginPayloadSchema.safeParse({ email: "nope", password: "secret123" });
    expect(r.success).toBe(false);
  });
});

describe("registerPayloadSchema", () => {
  it("requires an Egyptian phone", () => {
    const r = registerPayloadSchema.safeParse({
      name: "Mahmoud",
      email: "m@b.co",
      phone: "+1 555 0100",
      password: "secret123",
      role: "customer",
    });
    expect(r.success).toBe(false);
  });

  it("accepts a valid Vodafone EG number", () => {
    const r = registerPayloadSchema.safeParse({
      name: "Mahmoud",
      email: "m@b.co",
      phone: "01012345678",
      password: "secret123",
      role: "customer",
    });
    expect(r.success).toBe(true);
  });
});

describe("addressSchema", () => {
  it("accepts a minimal address", () => {
    expect(
      addressSchema.parse({ street: "1 Main", area: "Bagour", city: "Monufia" }),
    ).toMatchObject({ street: "1 Main", area: "Bagour", city: "Monufia" });
  });

  it("rejects empty strings for required fields", () => {
    const r = addressSchema.safeParse({ street: "", area: "Bagour", city: "Monufia" });
    expect(r.success).toBe(false);
  });
});

describe("restaurantSchema", () => {
  it("parses a complete restaurant record", () => {
    const restaurant = {
      id: "r1",
      userId: "u1",
      name: "Koshary El Bagour",
      email: "owner@kosh.eg",
      phone: "01012345678",
      images: [],
      status: "approved" as const,
      isOpen: true,
      address: { street: "Main", area: "Bagour", city: "Monufia" },
      cuisineTypes: ["koshary"],
      tags: [],
      workingHours: [],
      rating: 4.6,
      totalReviews: 120,
      totalOrders: 800,
      minimumOrder: 30,
      deliveryTime: { min: 20, max: 35 },
      deliveryFee: 10,
      commissionRate: 0.15,
      features: {
        acceptsOnlinePayment: true,
        hasDelivery: true,
        hasPickup: false,
        hasDineIn: false,
      },
      createdAt: "2026-01-01T00:00:00.000Z",
      updatedAt: "2026-05-13T00:00:00.000Z",
    };
    expect(restaurantSchema.parse(restaurant).name).toBe("Koshary El Bagour");
  });
});

describe("orderSchema", () => {
  it("requires at least one item", () => {
    const r = orderSchema.safeParse({
      id: "o1",
      orderNumber: "BG-1",
      customerId: "c1",
      restaurantId: "r1",
      items: [],
      subtotal: 0,
      deliveryFee: 10,
      total: 10,
      status: "pending",
      paymentMethod: "cash",
      paymentStatus: "pending",
      deliveryAddress: { street: "S", area: "A", city: "C" },
      deliveryLocation: { type: "Point", coordinates: [0, 0] },
      createdAt: "2026-05-13T00:00:00.000Z",
      updatedAt: "2026-05-13T00:00:00.000Z",
    });
    expect(r.success).toBe(false);
  });
});

describe("paginatedResponseSchema", () => {
  it("validates a generic paginated payload", () => {
    const schema = paginatedResponseSchema(restaurantSchema);
    const r = schema.safeParse({
      success: true,
      data: [],
      pagination: {
        page: 1,
        limit: 20,
        total: 0,
        totalPages: 0,
        hasNextPage: false,
        hasPrevPage: false,
      },
    });
    expect(r.success).toBe(true);
  });
});
