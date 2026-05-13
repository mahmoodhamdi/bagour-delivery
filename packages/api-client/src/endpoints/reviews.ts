import type { ApiResponse, PaginatedResponse, Review } from "@bagour/types";
import type { AxiosInstance } from "axios";

export interface CreateReviewPayload {
  orderId: string;
  type: "restaurant" | "driver";
  rating: number;
  comment?: string;
  images?: string[];
}

export const reviewEndpoints = (http: AxiosInstance) => ({
  async forRestaurant(
    restaurantId: string,
    page = 1,
    limit = 20,
  ): Promise<PaginatedResponse<Review>> {
    const { data } = await http.get<PaginatedResponse<Review>>(
      `/api/v1/restaurants/${encodeURIComponent(restaurantId)}/reviews`,
      { params: { page, limit } },
    );
    return data;
  },

  async myReviews(page = 1, limit = 20): Promise<PaginatedResponse<Review>> {
    const { data } = await http.get<PaginatedResponse<Review>>("/api/v1/customer/reviews", {
      params: { page, limit },
    });
    return data;
  },

  async create(payload: CreateReviewPayload): Promise<Review> {
    const { data } = await http.post<ApiResponse<Review>>("/api/v1/reviews", payload);
    return data.data;
  },
});

export type ReviewEndpoints = ReturnType<typeof reviewEndpoints>;
