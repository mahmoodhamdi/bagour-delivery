import type { PaginatedResponse, PaginationMeta } from "@bagour/types";

/**
 * The backend wraps payloads with a named key, e.g.
 *   `{ success, message, data: { restaurant: {...} } }`
 *
 * Older deployments occasionally returned the unwrapped value directly. We
 * tolerate both — try the named key first, fall back to the payload as-is.
 */
export const unwrap = <T>(payload: unknown, key: string): T => {
  if (payload && typeof payload === "object" && key in (payload as Record<string, unknown>)) {
    return (payload as Record<string, unknown>)[key] as T;
  }
  return payload as T;
};

interface BackendPagination {
  total?: number;
  page?: number;
  limit?: number;
  pages?: number;
  totalPages?: number;
  hasNextPage?: boolean;
  hasPrevPage?: boolean;
}

/**
 * The backend ships pagination as `{ total, page, limit, pages }` but the
 * shared `PaginationMeta` contract demands `{ totalPages, hasNextPage,
 * hasPrevPage }`. Derive the missing fields so callers never need to.
 */
export const normalizePagination = (
  raw: BackendPagination | undefined,
  fallback: { page: number; limit: number; itemCount: number },
): PaginationMeta => {
  const page = raw?.page ?? fallback.page;
  const limit = raw?.limit ?? fallback.limit;
  const total = raw?.total ?? fallback.itemCount;
  const totalPages = raw?.totalPages ?? raw?.pages ?? (limit > 0 ? Math.ceil(total / limit) : 1);
  return {
    page,
    limit,
    total,
    totalPages,
    hasNextPage: raw?.hasNextPage ?? page < totalPages,
    hasPrevPage: raw?.hasPrevPage ?? page > 1,
  };
};

interface BackendPaginatedResponse<T> {
  success?: boolean;
  data?: T[];
  pagination?: BackendPagination;
}

/**
 * Normalize a paginated response into the `PaginatedResponse<T>` contract.
 * Tolerates missing pagination metadata (synthesizes single-page defaults).
 */
export const normalizePaginated = <T>(
  payload: BackendPaginatedResponse<T> | undefined,
  fallbackQuery: { page?: number; limit?: number },
): PaginatedResponse<T> => {
  const items = (payload?.data ?? []) as T[];
  return {
    success: payload?.success ?? true,
    data: items,
    pagination: normalizePagination(payload?.pagination, {
      page: fallbackQuery.page ?? 1,
      limit: fallbackQuery.limit ?? items.length,
      itemCount: items.length,
    }),
  };
};
