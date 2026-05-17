import type {
  ApiResponse,
  Order,
  OrderStatus,
  PaginatedResponse,
  PaymentMethod,
} from "@bagour/types";
import type { AxiosInstance } from "axios";

import { normalizePaginated, unwrap } from "./_shared";

/**
 * Address shape the checkout form already has on hand — keeping it
 * customer-friendly so the UI layer doesn't have to know about backend
 * field names. The api-client maps this to the backend payload below.
 */
export interface OrderDeliveryAddressInput {
  name: string;
  address: string;
  area: string;
  city?: string;
  building?: string;
  floor?: string;
  apartment?: string;
  landmark?: string;
  phone: string;
  /** `[lng, lat]` — same orientation as GeoJSON. */
  coordinates: [number, number];
}

export interface CreateOrderItemInput {
  menuItemId: string;
  quantity: number;
  /** Selected addon IDs with optional quantity (default 1). */
  addons?: { addonId: string; quantity?: number }[];
  /** Selected variation option IDs. */
  variations?: { variationId: string; optionId: string }[];
  specialInstructions?: string;
}

export interface CreateOrderPayload {
  restaurantId: string;
  items: CreateOrderItemInput[];
  deliveryAddress: OrderDeliveryAddressInput;
  paymentMethod: PaymentMethod;
  couponCode?: string;
  customerNotes?: string;
  isScheduled?: boolean;
  scheduledFor?: string;
}

interface BackendOrderRequest {
  restaurantId: string;
  items: {
    menuItemId: string;
    quantity: number;
    selectedAddons?: { addonId: string; quantity: number }[];
    selectedVariations?: { variationId: string; optionId: string }[];
    specialInstructions?: string;
  }[];
  deliveryAddress: {
    name: string;
    address: string;
    area: string;
    building?: string;
    floor?: string;
    apartment?: string;
    landmark?: string;
    phone: string;
    location: { type: "Point"; coordinates: [number, number] };
  };
  paymentMethod: PaymentMethod;
  couponCode?: string;
  customerNotes?: string;
  isScheduled?: boolean;
  scheduledFor?: string;
}

const toBackendOrder = (input: CreateOrderPayload): BackendOrderRequest => ({
  restaurantId: input.restaurantId,
  items: input.items.map((it) => {
    const out: BackendOrderRequest["items"][number] = {
      menuItemId: it.menuItemId,
      quantity: it.quantity,
    };
    if (it.addons?.length) {
      out.selectedAddons = it.addons.map((a) => ({ addonId: a.addonId, quantity: a.quantity ?? 1 }));
    }
    if (it.variations?.length) out.selectedVariations = it.variations;
    if (it.specialInstructions) out.specialInstructions = it.specialInstructions;
    return out;
  }),
  deliveryAddress: {
    name: input.deliveryAddress.name,
    address: input.deliveryAddress.address,
    area: input.deliveryAddress.area,
    building: input.deliveryAddress.building,
    floor: input.deliveryAddress.floor,
    apartment: input.deliveryAddress.apartment,
    landmark: input.deliveryAddress.landmark,
    phone: input.deliveryAddress.phone,
    location: { type: "Point", coordinates: input.deliveryAddress.coordinates },
  },
  paymentMethod: input.paymentMethod,
  couponCode: input.couponCode,
  customerNotes: input.customerNotes,
  isScheduled: input.isScheduled,
  scheduledFor: input.scheduledFor,
});

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
    const { data } = await http.post<ApiResponse<unknown>>(
      "/api/v1/orders",
      toBackendOrder(payload),
    );
    return unwrap<Order>(data.data, "order");
  },

  async myOrders(query: OrderListQuery = {}): Promise<PaginatedResponse<Order>> {
    const { data } = await http.get<unknown>("/api/v1/orders", { params: query });
    return normalizePaginated<Order>(data as never, query);
  },

  async byId(id: string): Promise<Order> {
    const { data } = await http.get<ApiResponse<unknown>>(
      `/api/v1/orders/${encodeURIComponent(id)}`,
    );
    return unwrap<Order>(data.data, "order");
  },

  async cancel(id: string, reason: string): Promise<Order> {
    const { data } = await http.put<ApiResponse<unknown>>(
      `/api/v1/orders/${encodeURIComponent(id)}/cancel`,
      { reason },
    );
    return unwrap<Order>(data.data, "order");
  },

  async rate(id: string, payload: RateOrderPayload): Promise<Order> {
    const { data } = await http.post<ApiResponse<unknown>>(
      `/api/v1/orders/${encodeURIComponent(id)}/rate`,
      payload,
    );
    return unwrap<Order>(data.data, "order");
  },

  async reorder(id: string): Promise<Order> {
    const { data } = await http.post<ApiResponse<unknown>>(
      `/api/v1/orders/${encodeURIComponent(id)}/reorder`,
    );
    return unwrap<Order>(data.data, "order");
  },
});

export type OrderEndpoints = ReturnType<typeof orderEndpoints>;
