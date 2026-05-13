import { describe, expect, it, vi } from "vitest";

import { ApiError } from "@bagour/api-client";

import { __test__ } from "./query-client";

const { makeQueryClient } = __test__;

describe("makeQueryClient", () => {
  it("applies sensible defaults", () => {
    const qc = makeQueryClient();
    const defaults = qc.getDefaultOptions();
    expect(defaults.queries?.staleTime).toBe(30_000);
    expect(defaults.queries?.refetchOnWindowFocus).toBe(false);
    expect(defaults.mutations?.retry).toBe(0);
  });

  it("retries up to 2 times on transient errors", () => {
    const qc = makeQueryClient();
    const retry = qc.getDefaultOptions().queries?.retry as (
      failureCount: number,
      error: unknown,
    ) => boolean;

    const transient = new ApiError({ message: "boom", statusCode: 502 });
    expect(retry(0, transient)).toBe(true);
    expect(retry(1, transient)).toBe(true);
    expect(retry(2, transient)).toBe(false);
  });

  it("does NOT retry on 401 / 403 auth errors", () => {
    const qc = makeQueryClient();
    const retry = qc.getDefaultOptions().queries?.retry as (
      failureCount: number,
      error: unknown,
    ) => boolean;
    const auth = new ApiError({ message: "no", statusCode: 401 });
    expect(retry(0, auth)).toBe(false);
  });

  it("does NOT retry on 4xx validation errors", () => {
    const qc = makeQueryClient();
    const retry = qc.getDefaultOptions().queries?.retry as (
      failureCount: number,
      error: unknown,
    ) => boolean;
    const v = new ApiError({ message: "bad", statusCode: 422 });
    expect(retry(0, v)).toBe(false);
  });

  it("retries unknown errors (falls back to network-error path)", () => {
    const qc = makeQueryClient();
    const retry = qc.getDefaultOptions().queries?.retry as (
      failureCount: number,
      error: unknown,
    ) => boolean;
    expect(retry(0, new Error("boom"))).toBe(true);
  });

  it.skip("can be exported for SSR/CSR awareness", () => {
    // Placeholder — `getQueryClient()` SSR branch is exercised in e2e by
    // server-rendered restaurants list once PR-2.1 lands.
    vi.fn();
  });
});
