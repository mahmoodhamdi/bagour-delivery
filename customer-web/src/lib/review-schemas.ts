import { z } from "zod";

const rating = z.number().int().min(1).max(5);

export const reviewFormSchema = z.object({
  restaurant: rating,
  driver: rating,
  food: rating,
  overall: rating,
  comment: z.string().trim().max(500, "Reviews.errors.commentTooLong"),
});

export type ReviewFormValues = z.infer<typeof reviewFormSchema>;
