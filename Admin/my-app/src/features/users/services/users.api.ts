import { httpClient } from "@/core/http/http-client";
import type { CreateUserPayload, ManagedUser, UpdateUserPayload } from "../model/user.types";

export const usersApi = {
  list() {
    return httpClient.get<ManagedUser[]>("/auth/users");
  },

  create(payload: CreateUserPayload) {
    return httpClient.post<{ message: string }>("/auth/users", payload);
  },

  update(id: number, payload: UpdateUserPayload) {
    return httpClient.put<{ message: string }>(`/auth/users/${id}`, payload);
  },

  remove(id: number) {
    return httpClient.delete<unknown>(`/auth/users/${id}`);
  },
};
