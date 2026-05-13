import { createAxiosInstance, type ApiClientOptions } from "./client";
import { bindEndpoints, type BagourApi } from "./endpoints";

export { ApiError, toApiError } from "./errors";
export type { ApiClientOptions, AuthTokenStore } from "./client";
export type { BagourApi } from "./endpoints";
export * from "./endpoints";

/**
 * Construct a fully-wired API client. One per app, typically created once
 * during bootstrap and passed via React context or Zustand.
 *
 * @example
 *   const api = createApiClient({
 *     baseURL: process.env.NEXT_PUBLIC_API_URL!,
 *     auth: tokenStore,
 *     onSignOut: () => router.push("/login"),
 *   });
 *   await api.auth.login({ email, password });
 */
export function createApiClient(options: ApiClientOptions): BagourApi {
  const http = createAxiosInstance(options);
  return bindEndpoints(http);
}
