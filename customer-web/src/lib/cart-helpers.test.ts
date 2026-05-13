import { describe, expect, it } from "vitest";

import { canAddAddon, computeItemTotal, findMissingRequiredOptions } from "./cart-helpers";

import type { MenuItem, MenuOption } from "@bagour/types";

const stubItem = (overrides: Partial<MenuItem> = {}): MenuItem => ({
  id: "i1",
  restaurantId: "r1",
  categoryId: "c1",
  name: "Koshary",
  price: 35,
  preparationTime: 15,
  images: [],
  isAvailable: true,
  isNewItem: false,
  isFeatured: false,
  addons: [],
  options: [],
  tags: [],
  allergens: [],
  order: 0,
  createdAt: "2026-05-13T00:00:00.000Z",
  updatedAt: "2026-05-13T00:00:00.000Z",
  ...overrides,
});

describe("computeItemTotal", () => {
  it("base × quantity when no extras", () => {
    expect(computeItemTotal({ menuItem: stubItem(), quantity: 2, addons: [], options: [] })).toBe(
      70,
    );
  });

  it("uses discountPrice when present", () => {
    expect(
      computeItemTotal({
        menuItem: stubItem({ price: 50, discountPrice: 35 }),
        quantity: 2,
        addons: [],
        options: [],
      }),
    ).toBe(70);
  });

  it("adds options + addons to base", () => {
    expect(
      computeItemTotal({
        menuItem: stubItem({ price: 35 }),
        quantity: 1,
        addons: [{ name: "Extra cheese", price: 8 }],
        options: [{ optionName: "Size", choice: "Large", price: 12 }],
      }),
    ).toBe(35 + 12 + 8);
  });

  it("multiplies the whole bundle by quantity", () => {
    expect(
      computeItemTotal({
        menuItem: stubItem({ price: 20 }),
        quantity: 3,
        addons: [{ name: "Sauce", price: 5 }],
        options: [{ optionName: "Spice", choice: "Hot", price: 0 }],
      }),
    ).toBe(75);
  });
});

const sizeOption: MenuOption = {
  name: "Size",
  required: true,
  maxSelections: 1,
  choices: [
    { name: "Small", price: 0, isDefault: true },
    { name: "Large", price: 10 },
  ],
};

const sauceOption: MenuOption = {
  name: "Sauce",
  required: false,
  maxSelections: 1,
  choices: [{ name: "Mild", price: 0 }],
};

describe("findMissingRequiredOptions", () => {
  it("returns missing required option names", () => {
    expect(findMissingRequiredOptions([sizeOption, sauceOption], [])).toEqual(["Size"]);
  });

  it("ignores optional groups", () => {
    expect(findMissingRequiredOptions([sauceOption], [])).toEqual([]);
  });

  it("returns [] when all required groups have a selection", () => {
    expect(
      findMissingRequiredOptions([sizeOption], [{ optionName: "Size", choice: "Small", price: 0 }]),
    ).toEqual([]);
  });
});

describe("canAddAddon", () => {
  it("true for an available, unselected addon", () => {
    expect(canAddAddon({ name: "Cheese", price: 5, isAvailable: true }, [])).toBe(true);
  });

  it("false when out of stock", () => {
    expect(canAddAddon({ name: "Cheese", price: 5, isAvailable: false }, [])).toBe(false);
  });

  it("false when already selected", () => {
    expect(
      canAddAddon({ name: "Cheese", price: 5, isAvailable: true }, [{ name: "Cheese", price: 5 }]),
    ).toBe(false);
  });
});
