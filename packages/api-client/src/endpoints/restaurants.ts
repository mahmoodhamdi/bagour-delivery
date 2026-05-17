import type {
  ApiResponse,
  MenuCategory,
  MenuItem,
  PaginatedResponse,
  Restaurant,
} from "@bagour/types";
import type { AxiosInstance } from "axios";

import { normalizePaginated, unwrap } from "./_shared";

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
    const { data } = await http.get<unknown>("/api/v1/restaurants", { params: query });
    return normalizePaginated<Restaurant>(data as never, query);
  },

  async featured(): Promise<Restaurant[]> {
    const { data } = await http.get<ApiResponse<unknown>>("/api/v1/restaurants/featured");
    const body = data.data;
    if (Array.isArray(body)) return body as Restaurant[];
    return unwrap<Restaurant[]>(body, "restaurants") ?? [];
  },

  async nearby(query: NearbyQuery): Promise<Restaurant[]> {
    // Backend expects `maxDistance` (km), client surface uses `radius` for clarity.
    const params = {
      lat: query.lat,
      lng: query.lng,
      maxDistance: query.radius,
      limit: query.limit,
    };
    const { data } = await http.get<ApiResponse<unknown>>("/api/v1/restaurants/nearby", {
      params,
    });
    const body = data.data;
    if (Array.isArray(body)) return body as Restaurant[];
    return unwrap<Restaurant[]>(body, "restaurants") ?? [];
  },

  async bySlug(slug: string): Promise<Restaurant> {
    const { data } = await http.get<ApiResponse<unknown>>(
      `/api/v1/restaurants/${encodeURIComponent(slug)}`,
    );
    return unwrap<Restaurant>(data.data, "restaurant");
  },

  async menu(slug: string, options?: { categoryId?: string }): Promise<RestaurantMenuResponse> {
    interface BackendMenuCategory extends MenuCategory {
      items?: MenuItem[];
    }
    interface BackendMenuResponse {
      categories?: MenuCategory[];
      items?: MenuItem[];
      menu?: BackendMenuCategory[];
    }
    const { data } = await http.get<ApiResponse<BackendMenuResponse>>(
      `/api/v1/restaurants/${encodeURIComponent(slug)}/menu`,
      { params: options },
    );
    const body = data.data;
    // Newer backend variant ships `{ menu: [{ ...category, items: [...] }] }`.
    // Flatten into `{ categories, items }` so the UI keeps the same shape.
    if (body.menu) {
      const categories: MenuCategory[] = body.menu.map(({ items: _items, ...cat }) => cat);
      const items: MenuItem[] = body.menu.flatMap((c) => c.items ?? []);
      return { categories, items };
    }
    return { categories: body.categories ?? [], items: body.items ?? [] };
  },
});

export type RestaurantEndpoints = ReturnType<typeof restaurantEndpoints>;
