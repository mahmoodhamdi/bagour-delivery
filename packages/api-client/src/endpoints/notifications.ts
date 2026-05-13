import type {
  ApiResponse,
  Notification,
  PaginatedResponse,
  PushSubscriptionPayload,
} from "@bagour/types";
import type { AxiosInstance } from "axios";

export const notificationEndpoints = (http: AxiosInstance) => ({
  async list(
    query: { page?: number; limit?: number; unreadOnly?: boolean } = {},
  ): Promise<PaginatedResponse<Notification>> {
    const { data } = await http.get<PaginatedResponse<Notification>>("/api/v1/notifications", {
      params: query,
    });
    return data;
  },

  async unreadCount(): Promise<{ count: number }> {
    const { data } = await http.get<ApiResponse<{ count: number }>>(
      "/api/v1/notifications/unread-count",
    );
    return data.data;
  },

  async markRead(id: string): Promise<{ message: string }> {
    const { data } = await http.put<ApiResponse<{ message: string }>>(
      `/api/v1/notifications/${encodeURIComponent(id)}/read`,
    );
    return data.data;
  },

  async markAllRead(): Promise<{ message: string }> {
    const { data } = await http.put<ApiResponse<{ message: string }>>(
      "/api/v1/notifications/read-all",
    );
    return data.data;
  },

  async remove(id: string): Promise<{ message: string }> {
    const { data } = await http.delete<ApiResponse<{ message: string }>>(
      `/api/v1/notifications/${encodeURIComponent(id)}`,
    );
    return data.data;
  },

  /**
   * Web Push subscription endpoints. The backend implementation lands in
   * Phase 8; until then, callers should expect a 404. The shape here is
   * what the backend will conform to.
   */
  async subscribePush(payload: PushSubscriptionPayload): Promise<{ message: string }> {
    const { data } = await http.post<ApiResponse<{ message: string }>>(
      "/api/v1/notifications/push/subscribe",
      payload,
    );
    return data.data;
  },

  async unsubscribePush(endpoint: string): Promise<{ message: string }> {
    const { data } = await http.post<ApiResponse<{ message: string }>>(
      "/api/v1/notifications/push/unsubscribe",
      { endpoint },
    );
    return data.data;
  },
});

export type NotificationEndpoints = ReturnType<typeof notificationEndpoints>;
