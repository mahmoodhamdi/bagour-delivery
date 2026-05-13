import { z } from "zod";

export const checkoutFormSchema = z.object({
  addressId: z.string().min(1, "Checkout.errors.addressRequired"),
  paymentMethod: z.enum(["cash", "card"]),
  notes: z.string().max(300).optional(),
  deliveryInstructions: z.string().max(300).optional(),
  couponCode: z.string().optional(),
  tip: z.number().min(0).max(500).optional(),
});

export type CheckoutFormValues = z.infer<typeof checkoutFormSchema>;
