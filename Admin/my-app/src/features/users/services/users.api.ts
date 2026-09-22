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

  // Which devices an `operator` account can act on — see admin-panel-api.md §1.1.
  // An operator with no devices assigned has zero access to content/vitrine endpoints.
  getDeviceAccess(id: number) {
    return httpClient.get<{ device_id: number[] }>(`/auth/users/${id}/devices`);
  },

  setDeviceAccess(id: number, deviceIds: number[]) {
    return httpClient.put<{ device_id: number[] }>(`/auth/users/${id}/devices`, { device_id: deviceIds });
  },
};
