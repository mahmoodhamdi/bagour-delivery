import { beforeEach, describe, expect, it } from "vitest";

import type { OrderItem } from "@bagour/types";

import { selectCartCount, selectCartSubtotal, selectIsCartEmpty, useCartStore } from "./cart-store";

const fakeItem: OrderItem = {
  menuItemId: "i1",
  name: "Koshary",
  quantity: 1,
  price: 35,
  addons: [],
  options: [],
  itemTotal: 35,
};

describe("cart-store", () => {
  beforeEach(() => {
    localStorage.clear();
    useCartStore.setState({
      restaurantId: null,
      restaurantName: null,
      restaurantSlug: null,
      lines: [],
    });
  });

  it("starts empty", () => {
    const s = useCartStore.getState();
    expect(selectIsCartEmpty(s)).toBe(true);
    expect(selectCartCount(s)).toBe(0);
    expect(selectCartSubtotal(s)).toBe(0);
  });

  it("adds a line to a fresh cart", () => {
    const ok = useCartStore.getState().addLine({
      restaurantId: "r1",
      restaurantName: "Rest",
      restaurantSlug: "rest",
      line: { ...fakeItem },
    });
    expect(ok).toBe(true);
    const s = useCartStore.getState();
    expect(s.lines).toHaveLength(1);
    expect(s.lines[0]?.lineId).toBeTruthy();
    expect(selectCartCount(s)).toBe(1);
    expect(selectCartSubtotal(s)).toBe(35);
  });

  it("appends a second line from the same restaurant", () => {
    useCartStore.getState().addLine({
      restaurantId: "r1",
      restaurantName: "Rest",
      restaurantSlug: "rest",
      line: { ...fakeItem },
    });
    useCartStore.getState().addLine({
      restaurantId: "r1",
      restaurantName: "Rest",
      restaurantSlug: "rest",
      line: { ...fakeItem, quantity: 2, itemTotal: 70 },
    });
    const s = useCartStore.getState();
    expect(s.lines).toHaveLength(2);
    expect(selectCartCount(s)).toBe(3);
    expect(selectCartSubtotal(s)).toBe(105);
  });

  it("asks for confirmation when switching restaurants", () => {
    useCartStore.getState().addLine({
      restaurantId: "r1",
      restaurantName: "A",
      restaurantSlug: "a",
      line: { ...fakeItem },
    });

    // Decline → cart unchanged.
    const declined = useCartStore.getState().addLine(
      {
        restaurantId: "r2",
        restaurantName: "B",
        restaurantSlug: "b",
        line: { ...fakeItem },
      },
      { confirmReplace: () => false },
    );
    expect(declined).toBe(false);
    expect(useCartStore.getState().restaurantId).toBe("r1");

    // Accept → cart reset to the new restaurant.
    const accepted = useCartStore.getState().addLine(
      {
        restaurantId: "r2",
        restaurantName: "B",
        restaurantSlug: "b",
        line: { ...fakeItem },
      },
      { confirmReplace: () => true },
    );
    expect(accepted).toBe(true);
    const s = useCartStore.getState();
    expect(s.restaurantId).toBe("r2");
    expect(s.lines).toHaveLength(1);
  });

  it("updates line quantity + scales itemTotal", () => {
    useCartStore.getState().addLine({
      restaurantId: "r1",
      restaurantName: "Rest",
      restaurantSlug: "rest",
      line: { ...fakeItem, quantity: 2, itemTotal: 70 },
    });
    const line = useCartStore.getState().lines[0]!;
    useCartStore.getState().updateLineQuantity(line.lineId, 5);
    const updated = useCartStore.getState().lines[0]!;
    expect(updated.quantity).toBe(5);
    expect(updated.itemTotal).toBe(175);
  });

  it("removes the line when quantity drops to 0", () => {
    useCartStore.getState().addLine({
      restaurantId: "r1",
      restaurantName: "Rest",
      restaurantSlug: "rest",
      line: { ...fakeItem },
    });
    const line = useCartStore.getState().lines[0]!;
    useCartStore.getState().updateLineQuantity(line.lineId, 0);
    expect(useCartStore.getState().lines).toEqual([]);
  });

  it("clear() resets everything", () => {
    useCartStore.getState().addLine({
      restaurantId: "r1",
      restaurantName: "Rest",
      restaurantSlug: "rest",
      line: { ...fakeItem },
    });
    useCartStore.getState().clear();
    const s = useCartStore.getState();
    expect(s.restaurantId).toBeNull();
    expect(s.lines).toEqual([]);
  });
});
