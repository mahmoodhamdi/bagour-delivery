import type { AxiosInstance } from "axios";

import type {
  ApiResponse,
  AuthTokens,
  BaseUser,
  ForgotPasswordPayload,
  LoginPayload,
  OtpVerifyPayload,
  RegisterPayload,
  ResetPasswordPayload,
} from "@bagour/types";

export interface LoginResponse {
  user: BaseUser;
  tokens: AuthTokens;
}

export interface RegisterResponse {
  /** Backend returns the user record but no tokens until OTP verified. */
  user: BaseUser;
  message: string;
}

export interface GoogleSignInPayload {
  idToken: string;
  role?: "customer" | "driver";
}

export interface ChangePasswordPayload {
  currentPassword: string;
  newPassword: string;
}

export const authEndpoints = (http: AxiosInstance) => ({
  async register(payload: RegisterPayload): Promise<RegisterResponse> {
    const { data } = await http.post<ApiResponse<RegisterResponse>>(
      "/api/v1/auth/register",
      payload,
    );
    return data.data;
  },

  async verifyEmail(payload: OtpVerifyPayload): Promise<LoginResponse> {
    const { data } = await http.post<ApiResponse<LoginResponse>>(
      "/api/v1/auth/verify-email",
      payload,
    );
    return data.data;
  },

  async resendOtp(payload: { email: string }): Promise<{ message: string }> {
    const { data } = await http.post<ApiResponse<{ message: string }>>(
      "/api/v1/auth/resend-otp",
      payload,
    );
    return data.data;
  },

  async login(payload: LoginPayload): Promise<LoginResponse> {
    const { data } = await http.post<ApiResponse<LoginResponse>>("/api/v1/auth/login", payload);
    return data.data;
  },

  async google(payload: GoogleSignInPayload): Promise<LoginResponse> {
    const { data } = await http.post<ApiResponse<LoginResponse>>("/api/v1/auth/google", payload);
    return data.data;
  },

  async forgotPassword(payload: ForgotPasswordPayload): Promise<{ message: string }> {
    const { data } = await http.post<ApiResponse<{ message: string }>>(
      "/api/v1/auth/forgot-password",
      payload,
    );
    return data.data;
  },

  async resetPassword(payload: ResetPasswordPayload): Promise<{ message: string }> {
    const { data } = await http.post<ApiResponse<{ message: string }>>(
      "/api/v1/auth/reset-password",
      payload,
    );
    return data.data;
  },

  async changePassword(payload: ChangePasswordPayload): Promise<{ message: string }> {
    const { data } = await http.post<ApiResponse<{ message: string }>>(
      "/api/v1/auth/change-password",
      payload,
    );
    return data.data;
  },

  async refresh(refreshToken?: string): Promise<AuthTokens> {
    const { data } = await http.post<ApiResponse<AuthTokens>>(
      "/api/v1/auth/refresh-token",
      refreshToken ? { refreshToken } : {},
    );
    return data.data;
  },

  async updateFcmToken(fcmToken: string): Promise<{ message: string }> {
    const { data } = await http.post<ApiResponse<{ message: string }>>(
      "/api/v1/auth/update-fcm-token",
      { fcmToken },
    );
    return data.data;
  },

  async logout(): Promise<{ message: string }> {
    const { data } = await http.post<ApiResponse<{ message: string }>>("/api/v1/auth/logout");
    return data.data;
  },

  async me(): Promise<BaseUser> {
    const { data } = await http.get<ApiResponse<BaseUser>>("/api/v1/auth/me");
    return data.data;
  },
});

export type AuthEndpoints = ReturnType<typeof authEndpoints>;
