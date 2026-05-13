import type {
  ApiResponse,
  MenuCategory,
  MenuItem,
  PaginatedResponse,
  Restaurant,
} from "@bagour/types";
import type { AxiosInstance } from "axios";

export interface RestaurantSearchQuery {
  q?: string;
  cuisine?: string;
  zone?: string;
  isOpen?: boolean;
  minRating?: number;
  maxDeliveryFee?: number;
  sort?: "rating" | "deliveryTime" | "deliveryFee" | "popularity";
  page?: number;
  limit?: number;
}

export interface NearbyQuery {
  lng: number;
  lat: number;
  /** Search radius in km. */
  radius?: number;
  limit?: number;
}

export interface RestaurantMenuResponse {
  categories: MenuCategory[];
  items: MenuItem[];
}

export const restaurantEndpoints = (http: AxiosInstance) => ({
  async search(query: RestaurantSearchQuery = {}): Promise<PaginatedResponse<Restaurant>> {
    const { data } = await http.get<PaginatedResponse<Restaurant>>("/api/v1/restaurants", {
      params: query,
    });
    return data;
  },

  async featured(): Promise<Restaurant[]> {
    const { data } = await http.get<ApiResponse<Restaurant[]>>("/api/v1/restaurants/featured");
    return data.data;
  },

  async nearby(query: NearbyQuery): Promise<Restaurant[]> {
    const { data } = await http.get<ApiResponse<Restaurant[]>>("/api/v1/restaurants/nearby", {
      params: query,
    });
    return data.data;
  },

  async bySlug(slug: string): Promise<Restaurant> {
    const { data } = await http.get<ApiResponse<Restaurant>>(
      `/api/v1/restaurants/${encodeURIComponent(slug)}`,
    );
    return data.data;
  },

  async menu(slug: string, options?: { categoryId?: string }): Promise<RestaurantMenuResponse> {
    const { data } = await http.get<ApiResponse<RestaurantMenuResponse>>(
      `/api/v1/restaurants/${encodeURIComponent(slug)}/menu`,
      { params: options },
    );
    return data.data;
  },
});

export type RestaurantEndpoints = ReturnType<typeof restaurantEndpoints>;
