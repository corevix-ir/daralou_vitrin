import { httpClient } from "@/core/http/http-client";
import type { LoginRequest, TokenResponse, UserProfile } from "../model/auth.types";

export const authApi = {
  login(payload: LoginRequest) {
    return httpClient.post<TokenResponse>("/auth/login", payload, { auth: false });
  },

  refresh(refreshToken: string) {
    return httpClient.post<TokenResponse>(
      "/auth/refresh",
      { refresh_token: refreshToken },
      { auth: false }
    );
  },

  logout() {
    return httpClient.post<{ message: string }>("/auth/logout");
  },

  profile() {
    return httpClient.get<UserProfile>("/auth/profile");
  },
};
