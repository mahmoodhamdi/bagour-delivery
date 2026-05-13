import type { Address, ApiResponse, Customer, Restaurant } from "@bagour/types";
import type { AxiosInstance } from "axios";

export type AddressPayload = Omit<Address, "id">;

export const customerEndpoints = (http: AxiosInstance) => ({
  async profile(): Promise<Customer> {
    const { data } = await http.get<ApiResponse<Customer>>("/api/v1/customer/profile");
    return data.data;
  },

  async loyaltyPoints(): Promise<{ points: number; tier?: string }> {
    const { data } = await http.get<ApiResponse<{ points: number; tier?: string }>>(
      "/api/v1/customer/loyalty-points",
    );
    return data.data;
  },

  async addresses(): Promise<Address[]> {
    const { data } = await http.get<ApiResponse<Address[]>>("/api/v1/customer/addresses");
    return data.data;
  },

  async defaultAddress(): Promise<Address | null> {
    const { data } = await http.get<ApiResponse<Address | null>>(
      "/api/v1/customer/addresses/default",
    );
    return data.data;
  },

  async addAddress(payload: AddressPayload): Promise<Address> {
    const { data } = await http.post<ApiResponse<Address>>("/api/v1/customer/addresses", payload);
    return data.data;
  },

  async updateAddress(id: string, payload: Partial<AddressPayload>): Promise<Address> {
    const { data } = await http.put<ApiResponse<Address>>(
      `/api/v1/customer/addresses/${encodeURIComponent(id)}`,
      payload,
    );
    return data.data;
  },

  async deleteAddress(id: string): Promise<{ message: string }> {
    const { data } = await http.delete<ApiResponse<{ message: string }>>(
      `/api/v1/customer/addresses/${encodeURIComponent(id)}`,
    );
    return data.data;
  },

  async setDefaultAddress(id: string): Promise<Address> {
    const { data } = await http.patch<ApiResponse<Address>>(
      `/api/v1/customer/addresses/${encodeURIComponent(id)}/default`,
    );
    return data.data;
  },

  async favorites(): Promise<Restaurant[]> {
    const { data } = await http.get<ApiResponse<Restaurant[]>>("/api/v1/customer/favorites");
    return data.data;
  },

  async addFavorite(restaurantId: string): Promise<{ message: string }> {
    const { data } = await http.post<ApiResponse<{ message: string }>>(
      `/api/v1/customer/favorites/${encodeURIComponent(restaurantId)}`,
    );
    return data.data;
  },

  async removeFavorite(restaurantId: string): Promise<{ message: string }> {
    const { data } = await http.delete<ApiResponse<{ message: string }>>(
      `/api/v1/customer/favorites/${encodeURIComponent(restaurantId)}`,
    );
    return data.data;
  },

  async isFavorite(restaurantId: string): Promise<{ isFavorite: boolean }> {
    const { data } = await http.get<ApiResponse<{ isFavorite: boolean }>>(
      `/api/v1/customer/favorites/${encodeURIComponent(restaurantId)}/check`,
    );
    return data.data;
  },
});

export type CustomerEndpoints = ReturnType<typeof customerEndpoints>;
