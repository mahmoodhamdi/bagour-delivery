import type { ApiResponse, Driver, DriverDocuments, Order, PaginatedResponse } from "@bagour/types";
import type { AxiosInstance } from "axios";

import { normalizePaginated, unwrap } from "./_shared";

export interface UpdateLocationPayload {
  coordinates: [number, number]; // [lng, lat]
  heading?: number;
  speed?: number;
  accuracy?: number;
}

export interface AvailableOrdersQuery {
  lat: number;
  lng: number;
  /** Search radius in km. */
  maxDistance?: number;
}

export interface DriverStats {
  totalDeliveries: number;
  totalEarnings: number;
  rating: number;
  totalReviews: number;
  walletBalance: number;
  pendingPayouts: number;
}

export const driverEndpoints = (http: AxiosInstance) => ({
  async profile(): Promise<Driver> {
    const { data } = await http.get<ApiResponse<Driver>>("/api/v1/driver/profile");
    return data.data;
  },

  async updateProfile(
    payload: Partial<Pick<Driver, "vehicleModel" | "vehicleColor" | "vehiclePlateNumber">>,
  ): Promise<Driver> {
    const { data } = await http.patch<ApiResponse<Driver>>("/api/v1/driver/profile", payload);
    return data.data;
  },

  async updateAvatar(avatar: string): Promise<Driver> {
    const { data } = await http.put<ApiResponse<Driver>>("/api/v1/driver/avatar", { avatar });
    return data.data;
  },

  async updateLocation(payload: UpdateLocationPayload): Promise<{ message: string }> {
    const { data } = await http.put<ApiResponse<{ message: string }>>(
      "/api/v1/driver/location",
      payload,
    );
    return data.data;
  },

  async toggleOnline(isOnline: boolean): Promise<Driver> {
    const { data } = await http.put<ApiResponse<Driver>>("/api/v1/driver/online", { isOnline });
    return data.data;
  },

  async toggleAvailability(isAvailable: boolean): Promise<Driver> {
    const { data } = await http.put<ApiResponse<Driver>>("/api/v1/driver/availability", {
      isAvailable,
    });
    return data.data;
  },

  async stats(): Promise<DriverStats> {
    const { data } = await http.get<ApiResponse<DriverStats>>("/api/v1/driver/stats");
    return data.data;
  },

  async updateDocuments(documents: Partial<DriverDocuments>): Promise<Driver> {
    const { data } = await http.put<ApiResponse<Driver>>("/api/v1/driver/documents", { documents });
    return data.data;
  },

  /**
   * Driver dashboard's "available orders" feed. Backend requires the driver's
   * current location to filter by distance; the UI should pass live geo from
   * the browser Geolocation API.
   */
  async availableOrders(query: AvailableOrdersQuery): Promise<Order[]> {
    const { data } = await http.get<ApiResponse<unknown>>("/api/v1/driver/orders/available", {
      params: query,
    });
    const body = data.data;
    if (Array.isArray(body)) return body as Order[];
    return unwrap<Order[]>(body, "orders") ?? [];
  },

  async myOrders(
    query: { status?: string; page?: number; limit?: number } = {},
  ): Promise<PaginatedResponse<Order>> {
    const { data } = await http.get<unknown>("/api/v1/driver/orders", { params: query });
    return normalizePaginated<Order>(data as never, query);
  },

  async acceptOrder(id: string): Promise<Order> {
    const { data } = await http.put<ApiResponse<unknown>>(
      `/api/v1/driver/orders/${encodeURIComponent(id)}/accept`,
    );
    return unwrap<Order>(data.data, "order");
  },

  async rejectOrder(id: string, reason?: string): Promise<{ message: string }> {
    const { data } = await http.put<ApiResponse<{ message: string }>>(
      `/api/v1/driver/orders/${encodeURIComponent(id)}/reject`,
      { reason },
    );
    return data.data;
  },

  async markPickedUp(id: string, note?: string): Promise<Order> {
    const { data } = await http.put<ApiResponse<unknown>>(
      `/api/v1/driver/orders/${encodeURIComponent(id)}/picked-up`,
      note ? { note } : {},
    );
    return unwrap<Order>(data.data, "order");
  },

  async markOnTheWay(id: string, note?: string): Promise<Order> {
    const { data } = await http.put<ApiResponse<unknown>>(
      `/api/v1/driver/orders/${encodeURIComponent(id)}/on-the-way`,
      note ? { note } : {},
    );
    return unwrap<Order>(data.data, "order");
  },

  async markDelivered(id: string, payload?: { proofUrl?: string; note?: string }): Promise<Order> {
    const { data } = await http.put<ApiResponse<unknown>>(
      `/api/v1/driver/orders/${encodeURIComponent(id)}/delivered`,
      payload ?? {},
    );
    return unwrap<Order>(data.data, "order");
  },
});

export type DriverEndpoints = ReturnType<typeof driverEndpoints>;
