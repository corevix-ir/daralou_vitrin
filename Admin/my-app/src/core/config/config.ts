/**
 * Single place for constants that would otherwise be sprinkled around as
 * magic strings/numbers: API location, storage keys, pagination defaults.
 */

const trimTrailingSlash = (value: string) => value.replace(/\/+$/, "");

export const config = {
  /** Go backend root — no version prefix, e.g. http://localhost:5749 */
  apiBaseUrl: trimTrailingSlash(
    process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:5749"
  ),

  auth: {
    accessTokenStorageKey: "vitrine_admin.access_token",
    refreshTokenStorageKey: "vitrine_admin.refresh_token",
  },

  pagination: {
    defaultPage: 1,
    defaultPageSize: 20,
  },

  http: {
    requestTimeoutMs: 15_000,
  },

  appName: "مدیریت ویترین کیوسک‌ها",
} as const;
