import { authEndpoints, type AuthEndpoints } from "./auth";
import { couponEndpoints, type CouponEndpoints } from "./coupons";
import { customerEndpoints, type CustomerEndpoints } from "./customers";
import { driverEndpoints, type DriverEndpoints } from "./drivers";
import { notificationEndpoints, type NotificationEndpoints } from "./notifications";
import { orderEndpoints, type OrderEndpoints } from "./orders";
import { restaurantEndpoints, type RestaurantEndpoints } from "./restaurants";
import { reviewEndpoints, type ReviewEndpoints } from "./reviews";
import { uploadEndpoints, type UploadEndpoints } from "./uploads";

import type { AxiosInstance } from "axios";

export interface BagourApi {
  http: AxiosInstance;
  auth: AuthEndpoints;
  customer: CustomerEndpoints;
  restaurants: RestaurantEndpoints;
  orders: OrderEndpoints;
  drivers: DriverEndpoints;
  coupons: CouponEndpoints;
  notifications: NotificationEndpoints;
  reviews: ReviewEndpoints;
  uploads: UploadEndpoints;
}

export const bindEndpoints = (http: AxiosInstance): BagourApi => ({
  http,
  auth: authEndpoints(http),
  customer: customerEndpoints(http),
  restaurants: restaurantEndpoints(http),
  orders: orderEndpoints(http),
  drivers: driverEndpoints(http),
  coupons: couponEndpoints(http),
  notifications: notificationEndpoints(http),
  reviews: reviewEndpoints(http),
  uploads: uploadEndpoints(http),
});

export type {
  AuthEndpoints,
  CouponEndpoints,
  CustomerEndpoints,
  DriverEndpoints,
  NotificationEndpoints,
  OrderEndpoints,
  RestaurantEndpoints,
  ReviewEndpoints,
  UploadEndpoints,
};

export * from "./auth";
export * from "./coupons";
export * from "./customers";
export * from "./drivers";
export * from "./notifications";
export * from "./orders";
export * from "./restaurants";
export * from "./reviews";
export * from "./uploads";
