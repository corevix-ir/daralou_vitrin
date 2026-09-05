export type UserRole = "admin" | "operator" | "user" | "device";

export interface LoginRequest {
  username: string;
  password: string;
}

export interface TokenResponse {
  access_token: string;
  refresh_token: string;
}

export interface UserProfile {
  id: number;
  /** Serialized as `status` by the backend (`DTO.ProfileResponse.IsActive`). */
  status: boolean;
  username: string;
  name: string;
  role: UserRole;
  location?: string;
  section?: string;
}
