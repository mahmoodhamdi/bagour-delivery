/**
 * Web-app-specific types that don't belong in `shared/types/` (since the
 * Flutter apps don't need them).
 */

import type { BaseUser } from "./user";

export interface AuthTokens {
  accessToken: string;
  refreshToken?: string;
  expiresIn?: number; // seconds
}

export interface AuthSession {
  user: BaseUser;
  tokens: AuthTokens;
  issuedAt: number; // epoch ms
}

export interface PushSubscriptionPayload {
  endpoint: string;
  keys: {
    p256dh: string;
    auth: string;
  };
  expirationTime?: number | null;
  userAgent?: string;
}

export interface WebPushBroadcast {
  title: string;
  body: string;
  icon?: string;
  badge?: string;
  data?: Record<string, unknown>;
  tag?: string;
  renotify?: boolean;
  silent?: boolean;
}

/** Socket.io event names emitted by the backend (best-effort catalog). */
export const SocketEvent = {
  // Order lifecycle (customer + restaurant + driver)
  ORDER_CREATED: "order:created",
  ORDER_CONFIRMED: "order:confirmed",
  ORDER_REJECTED: "order:rejected",
  ORDER_PREPARING: "order:preparing",
  ORDER_READY: "order:ready",
  ORDER_PICKED_UP: "order:picked_up",
  ORDER_ON_THE_WAY: "order:on_the_way",
  ORDER_DELIVERED: "order:delivered",
  ORDER_CANCELLED: "order:cancelled",

  // Driver-specific
  DRIVER_LOCATION_UPDATE: "driver:location",
  DRIVER_ASSIGNED: "driver:assigned",
  DRIVER_AVAILABLE: "driver:available",

  // Chat (future)
  CHAT_MESSAGE: "chat:message",
} as const;

export type SocketEventName = (typeof SocketEvent)[keyof typeof SocketEvent];

export interface DriverLocationUpdate {
  driverId: string;
  orderId?: string;
  coordinates: [number, number]; // [lng, lat]
  heading?: number; // degrees, 0=N
  speed?: number; // m/s
  accuracy?: number; // meters
  timestamp: string;
}

/** Web-specific Locale literal (subset of Constants.SUPPORTED_LANGUAGES). */
export type Locale = "ar" | "en";
