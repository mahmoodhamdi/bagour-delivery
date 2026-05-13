import axios, {
  type AxiosInstance,
  type AxiosRequestConfig,
  type InternalAxiosRequestConfig,
} from "axios";

import { ApiError, toApiError } from "./errors";

export interface AuthTokenStore {
  /** Returns the current access token, or null if signed out. */
  getAccessToken: () => string | null | Promise<string | null>;
  /** Returns the refresh token if persisted client-side (rare for web with httpOnly cookies). */
  getRefreshToken?: () => string | null | Promise<string | null>;
  /** Persist a fresh access (and optionally refresh) token. */
  setTokens: (tokens: { accessToken: string; refreshToken?: string }) => void | Promise<void>;
  /** Clear any persisted tokens (called on terminal 401). */
  clear: () => void | Promise<void>;
}

export interface ApiClientOptions {
  baseURL: string;
  /** Default request timeout in ms. */
  timeoutMs?: number;
  /** Authorization header setup. Pass `null` to disable auth entirely (public APIs). */
  auth?: AuthTokenStore | null;
  /** Path to the refresh endpoint, relative to baseURL. Default `/api/v1/auth/refresh-token`. */
  refreshPath?: string;
  /** Optional hook fired right before the client signs the user out (after refresh fails). */
  onSignOut?: () => void | Promise<void>;
  /** Add custom headers to every request (e.g. locale, app version). */
  defaultHeaders?: Record<string, string>;
  /** Custom adapter — useful for tests with msw + jsdom that bypass adapter probing. */
  adapter?: AxiosRequestConfig["adapter"];
  /** Send credentials (cookies) on cross-origin requests. Default true for httpOnly refresh cookie. */
  withCredentials?: boolean;
}

const DEFAULT_TIMEOUT_MS = 30_000;
const DEFAULT_REFRESH_PATH = "/api/v1/auth/refresh-token";

/**
 * Create a configured axios instance for talking to the Bagour backend.
 *
 * Behavior:
 *  - Adds `Authorization: Bearer <token>` from the provided AuthTokenStore.
 *  - On 401, attempts a single refresh via `refreshPath` and replays the original request.
 *  - On refresh failure (or any other 401), calls `clear()` + `onSignOut()` and rethrows.
 *  - Normalizes all errors to `ApiError`.
 */
export function createAxiosInstance(opts: ApiClientOptions): AxiosInstance {
  const {
    baseURL,
    timeoutMs = DEFAULT_TIMEOUT_MS,
    auth,
    refreshPath = DEFAULT_REFRESH_PATH,
    onSignOut,
    defaultHeaders,
    adapter,
    withCredentials = true,
  } = opts;

  const instance = axios.create({
    baseURL,
    timeout: timeoutMs,
    withCredentials,
    adapter,
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      ...defaultHeaders,
    },
  });

  // Request: inject bearer token.
  instance.interceptors.request.use(async (config: InternalAxiosRequestConfig) => {
    if (auth) {
      const token = await auth.getAccessToken();
      if (token) {
        config.headers.set("Authorization", `Bearer ${token}`);
      }
    }
    return config;
  });

  // Response: normalize errors; transparently retry once on 401 after refresh.
  let refreshInFlight: Promise<string | null> | null = null;

  instance.interceptors.response.use(
    (response) => response,
    async (error: unknown) => {
      const apiErr = toApiError(error);

      // Only attempt refresh if (a) auth is wired, (b) it's a 401, and
      // (c) we haven't already retried this exact request.
      if (
        auth &&
        apiErr.statusCode === 401 &&
        axios.isAxiosError(error) &&
        error.config &&
        !(error.config as { _retried?: boolean })._retried &&
        // Don't recursively refresh the refresh call itself.
        !error.config.url?.includes(refreshPath)
      ) {
        try {
          refreshInFlight ??= refreshTokens(instance, auth, refreshPath);
          const newToken = await refreshInFlight;
          refreshInFlight = null;

          if (newToken) {
            const retryConfig = error.config;
            (retryConfig as { _retried?: boolean })._retried = true;
            retryConfig.headers.set("Authorization", `Bearer ${newToken}`);
            return await instance.request(retryConfig);
          }
        } catch {
          refreshInFlight = null;
        }

        // Refresh failed → terminal sign-out.
        await auth.clear();
        await onSignOut?.();
      }

      throw apiErr;
    },
  );

  return instance;
}

async function refreshTokens(
  instance: AxiosInstance,
  auth: AuthTokenStore,
  refreshPath: string,
): Promise<string | null> {
  const refreshToken = await auth.getRefreshToken?.();

  // For httpOnly cookie flows, refreshToken is null and the cookie travels automatically.
  const body = refreshToken ? { refreshToken } : {};

  const response = await instance.post<{
    success: boolean;
    data: { accessToken: string; refreshToken?: string };
  }>(refreshPath, body, { _retried: true } as unknown as AxiosRequestConfig);

  const tokens = response.data?.data;
  if (!tokens?.accessToken) {
    throw new ApiError({
      message: "Refresh response missing accessToken",
      statusCode: 0,
    });
  }

  await auth.setTokens({ accessToken: tokens.accessToken, refreshToken: tokens.refreshToken });
  return tokens.accessToken;
}
