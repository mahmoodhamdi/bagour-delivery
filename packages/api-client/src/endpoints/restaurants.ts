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
    const { data } = await http.get<Partial<PaginatedResponse<Restaurant>>>(
      "/api/v1/restaurants",
      { params: query },
    );
    // Some deployments of the backend return a flat `{success, data: T[]}` without
    // pagination metadata. Synthesize sensible defaults so callers can rely on
    // `data.pagination.hasNextPage` without crashing.
    const items = (data.data ?? []) as Restaurant[];
    const page = query.page ?? 1;
    const limit = query.limit ?? items.length;
    return {
      success: data.success ?? true,
      data: items,
      pagination: data.pagination ?? {
        page,
        limit,
        total: items.length,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: page > 1,
      },
    };
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
