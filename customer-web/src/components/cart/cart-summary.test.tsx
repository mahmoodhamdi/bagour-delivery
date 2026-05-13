import { render, screen } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { describe, expect, it } from "vitest";

import messagesEn from "../../../messages/en.json";

import { CartSummary, computeTotals } from "./cart-summary";

function setup(props: Parameters<typeof CartSummary>[0]) {
  return render(
    <NextIntlClientProvider locale="en" messages={messagesEn}>
      <CartSummary {...props} />
    </NextIntlClientProvider>,
  );
}

describe("computeTotals", () => {
  it("adds delivery + subtotal", () => {
    expect(computeTotals({ subtotal: 50, deliveryFee: 10 })).toBe(60);
  });
  it("respects service fee + tax", () => {
    expect(computeTotals({ subtotal: 50, deliveryFee: 10, serviceFee: 5, tax: 2 })).toBe(67);
  });
  it("subtracts discount", () => {
    expect(computeTotals({ subtotal: 50, deliveryFee: 10, discount: 15 })).toBe(45);
  });
});

describe("CartSummary", () => {
  it("renders the breakdown rows + total", () => {
    setup({ subtotal: 50, deliveryFee: 10, serviceFee: 5, discount: 15 });
    const summary = screen.getByTestId("cart-summary");
    expect(summary).toHaveTextContent(/Subtotal/i);
    expect(summary).toHaveTextContent(/Delivery/i);
    expect(summary).toHaveTextContent(/Service/i);
    expect(summary).toHaveTextContent(/Discount/i);
    expect(screen.getByTestId("cart-summary-total")).toBeInTheDocument();
  });

  it("hides zero-value rows", () => {
    setup({ subtotal: 50, deliveryFee: 10 });
    expect(screen.getByTestId("cart-summary")).not.toHaveTextContent(/Service fee/i);
    expect(screen.getByTestId("cart-summary")).not.toHaveTextContent(/Discount/i);
  });
});
