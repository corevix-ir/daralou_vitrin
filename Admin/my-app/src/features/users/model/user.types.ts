import type { UserRole } from "@/features/auth/model/auth.types";

export interface ManagedUser {
  id: number;
  /** Serialized as `status` by the backend, same quirk as `/auth/profile`. */
  status: boolean;
  username: string;
  name: string;
  role: UserRole;
  location?: string;
  section?: string;
}

export interface CreateUserPayload {
  username: string;
  password: string;
  role: UserRole;
  name: string;
}

export interface UpdateUserPayload {
  name?: string;
  is_active?: boolean;
  role?: UserRole;
  password?: string;
}
