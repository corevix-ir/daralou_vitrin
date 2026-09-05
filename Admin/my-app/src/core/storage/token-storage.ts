import { config } from "@/core/config/config";

const isBrowser = typeof window !== "undefined";

/**
 * The backend has no cookie support (CORS is header-only, no credentials —
 * see Bootstrap/App.go), so tokens live in localStorage and are attached
 * manually on every request. This is the only module allowed to touch that
 * storage key directly.
 */
export const tokenStorage = {
  getAccessToken(): string | null {
    return isBrowser ? window.localStorage.getItem(config.auth.accessTokenStorageKey) : null;
  },

  getRefreshToken(): string | null {
    return isBrowser ? window.localStorage.getItem(config.auth.refreshTokenStorageKey) : null;
  },

  setTokens(accessToken: string, refreshToken: string): void {
    if (!isBrowser) return;
    window.localStorage.setItem(config.auth.accessTokenStorageKey, accessToken);
    window.localStorage.setItem(config.auth.refreshTokenStorageKey, refreshToken);
  },

  clear(): void {
    if (!isBrowser) return;
    window.localStorage.removeItem(config.auth.accessTokenStorageKey);
    window.localStorage.removeItem(config.auth.refreshTokenStorageKey);
  },
};
