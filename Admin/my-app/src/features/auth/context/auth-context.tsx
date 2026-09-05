"use client";

import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import { httpClient } from "@/core/http/http-client";
import { tokenStorage } from "@/core/storage/token-storage";
import { authApi } from "../services/auth.api";
import type { LoginRequest, UserProfile } from "../model/auth.types";

type AuthStatus = "loading" | "authenticated" | "unauthenticated";

interface AuthContextValue {
  user: UserProfile | null;
  status: AuthStatus;
  login: (payload: LoginRequest) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<UserProfile | null>(null);
  const [status, setStatus] = useState<AuthStatus>("loading");

  const clearSession = useCallback(() => {
    tokenStorage.clear();
    setUser(null);
    setStatus("unauthenticated");
  }, []);

  useEffect(() => {
    const unsubscribeRequest = httpClient.useRequestInterceptor((requestConfig) => {
      if (requestConfig.auth === false) return requestConfig;
      const token = tokenStorage.getAccessToken();
      if (!token) return requestConfig;
      return {
        ...requestConfig,
        headers: { ...requestConfig.headers, Authorization: `Bearer ${token}` },
      };
    });

    httpClient.setUnauthorizedHandler(async () => {
      const refreshToken = tokenStorage.getRefreshToken();
      if (!refreshToken) {
        clearSession();
        return null;
      }
      try {
        const tokens = await authApi.refresh(refreshToken);
        tokenStorage.setTokens(tokens.access_token, tokens.refresh_token);
        return tokens.access_token;
      } catch {
        clearSession();
        return null;
      }
    });

    (async () => {
      const accessToken = tokenStorage.getAccessToken();
      if (!accessToken) {
        setStatus("unauthenticated");
        return;
      }
      try {
        const profile = await authApi.profile();
        setUser(profile);
        setStatus("authenticated");
      } catch {
        clearSession();
      }
    })();

    return () => {
      unsubscribeRequest();
      httpClient.setUnauthorizedHandler(null);
    };
  }, [clearSession]);

  const login = useCallback(async (payload: LoginRequest) => {
    const tokens = await authApi.login(payload);
    tokenStorage.setTokens(tokens.access_token, tokens.refresh_token);
    const profile = await authApi.profile();
    setUser(profile);
    setStatus("authenticated");
  }, []);

  const logout = useCallback(async () => {
    try {
      await authApi.logout();
    } catch {
      // Token might already be dead server-side; local session still gets cleared below.
    }
    clearSession();
  }, [clearSession]);

  const value = useMemo(() => ({ user, status, login, logout }), [user, status, login, logout]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
