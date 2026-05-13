import type {
  ApiResponse,
  Order,
  OrderItem,
  OrderStatus,
  PaginatedResponse,
  PaymentMethod,
} from "@bagour/types";
import type { AxiosInstance } from "axios";

export interface CreateOrderPayload {
  restaurantId: string;
  items: Pick<
    OrderItem,
    "menuItemId" | "quantity" | "addons" | "options" | "specialInstructions"
  >[];
  addressId?: string;
  deliveryAddress?: Order["deliveryAddress"];
  deliveryLocation?: Order["deliveryLocation"];
  paymentMethod: PaymentMethod;
  couponCode?: string;
  notes?: string;
  deliveryInstructions?: string;
  tip?: number;
  isScheduled?: boolean;
  scheduledFor?: string;
}

export interface OrderListQuery {
  status?: OrderStatus | OrderStatus[];
  from?: string;
  to?: string;
  page?: number;
  limit?: number;
}

export interface RateOrderPayload {
  restaurant?: number;
  driver?: number;
  food?: number;
  overall?: number;
  comment?: string;
}

export const orderEndpoints = (http: AxiosInstance) => ({
  // ── Customer ──────────────────────────────────────────────────────────────
  async create(payload: CreateOrderPayload): Promise<Order> {
    const { data } = await http.post<ApiResponse<Order>>("/api/v1/orders", payload);
    return data.data;
  },

  async myOrders(query: OrderListQuery = {}): Promise<PaginatedResponse<Order>> {
    const { data } = await http.get<PaginatedResponse<Order>>("/api/v1/orders", { params: query });
    return data;
  },

  async byId(id: string): Promise<Order> {
    const { data } = await http.get<ApiResponse<Order>>(`/api/v1/orders/${encodeURIComponent(id)}`);
    return data.data;
  },

  async cancel(id: string, reason: string): Promise<Order> {
    const { data } = await http.put<ApiResponse<Order>>(
      `/api/v1/orders/${encodeURIComponent(id)}/cancel`,
      { reason },
    );
    return data.data;
  },

  async rate(id: string, payload: RateOrderPayload): Promise<Order> {
    const { data } = await http.post<ApiResponse<Order>>(
      `/api/v1/orders/${encodeURIComponent(id)}/rate`,
      payload,
    );
    return data.data;
  },

  async reorder(id: string): Promise<Order> {
    const { data } = await http.post<ApiResponse<Order>>(
      `/api/v1/orders/${encodeURIComponent(id)}/reorder`,
    );
    return data.data;
  },
});

export type OrderEndpoints = ReturnType<typeof orderEndpoints>;
