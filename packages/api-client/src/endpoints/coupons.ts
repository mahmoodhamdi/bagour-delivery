import type { ApiResponse, Coupon } from "@bagour/types";
import type { AxiosInstance } from "axios";

export interface ValidateCouponPayload {
  code: string;
  restaurantId?: string;
  subtotal?: number;
}

export interface CouponValidation {
  coupon: Coupon;
  discount: number;
  isValid: boolean;
  reason?: string;
}

export const couponEndpoints = (http: AxiosInstance) => ({
  async available(): Promise<Coupon[]> {
    const { data } = await http.get<ApiResponse<Coupon[]>>("/api/v1/coupons");
    return data.data;
  },

  async validate(payload: ValidateCouponPayload): Promise<CouponValidation> {
    const { data } = await http.post<ApiResponse<CouponValidation>>(
      "/api/v1/coupons/validate",
      payload,
    );
    return data.data;
  },
});

export type CouponEndpoints = ReturnType<typeof couponEndpoints>;
