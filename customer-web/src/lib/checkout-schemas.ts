import { z } from "zod";

// Egyptian mobile (e.g. 010xxxxxxxx, 011xxxxxxxx, 012xxxxxxxx, 015xxxxxxxx).
const phonePattern = /^01[0125][0-9]{8}$/;

export const checkoutFormSchema = z.object({
  addressId: z.string().min(1, "Checkout.errors.addressRequired"),
  phone: z.string().regex(phonePattern, "Checkout.errors.phoneInvalid"),
  paymentMethod: z.enum(["cash", "card"]),
  notes: z.string().max(300).optional(),
  deliveryInstructions: z.string().max(300).optional(),
  couponCode: z.string().optional(),
  tip: z.number().min(0).max(500).optional(),
});

export type CheckoutFormValues = z.infer<typeof checkoutFormSchema>;
