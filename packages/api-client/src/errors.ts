import axios, { type AxiosError } from "axios";

import type { ApiErrorBody } from "@bagour/types";

/**
 * Normalized API error. Throw this from the client so consumers can
 * `catch (e) { if (e instanceof ApiError) ... }` without sniffing axios.
 */
export class ApiError extends Error {
  readonly statusCode: number;
  readonly fieldErrors?: Record<string, string[]>;
  readonly isNetworkError: boolean;
  override readonly cause?: unknown;

  constructor(args: {
    message: string;
    statusCode: number;
    fieldErrors?: Record<string, string[]>;
    isNetworkError?: boolean;
    cause?: unknown;
  }) {
    super(args.message);
    this.name = "ApiError";
    this.statusCode = args.statusCode;
    this.fieldErrors = args.fieldErrors;
    this.isNetworkError = args.isNetworkError ?? false;
    this.cause = args.cause;
  }

  /** True when the user can recover by retrying (network, 5xx, 408, 429). */
  get isRetryable(): boolean {
    if (this.isNetworkError) return true;
    if (this.statusCode === 408 || this.statusCode === 429) return true;
    return this.statusCode >= 500;
  }

  /** True when the user must re-authenticate (401/403). */
  get isAuthError(): boolean {
    return this.statusCode === 401 || this.statusCode === 403;
  }
}

/** Convert an axios error or unknown thrown value into a typed ApiError. */
export function toApiError(err: unknown): ApiError {
  if (err instanceof ApiError) return err;

  if (axios.isAxiosError(err)) {
    const axiosErr = err as AxiosError<ApiErrorBody>;
    const data = axiosErr.response?.data;
    return new ApiError({
      message: data?.message ?? axiosErr.message ?? "Network error",
      statusCode: axiosErr.response?.status ?? 0,
      fieldErrors: data?.errors,
      isNetworkError: !axiosErr.response,
      cause: err,
    });
  }

  return new ApiError({
    message: err instanceof Error ? err.message : "Unknown error",
    statusCode: 0,
    isNetworkError: true,
    cause: err,
  });
}
