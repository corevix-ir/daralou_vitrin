import { httpClient } from "@/core/http/http-client";
import type {
  CreateDevicePayload,
  Device,
  DeviceCommandPayload,
  UpdateDevicePayload,
} from "../model/device.types";

export const devicesApi = {
  list() {
    return httpClient.get<Device[]>("/devices");
  },

  create(payload: CreateDevicePayload) {
    return httpClient.post<{ message: string }>("/devices", payload);
  },

  update(id: number, payload: UpdateDevicePayload) {
    return httpClient.put<{ message: string }>(`/devices/${id}`, payload);
  },

  remove(id: number) {
    return httpClient.delete<unknown>(`/devices/${id}`);
  },

  sendCommand(id: number, payload: DeviceCommandPayload) {
    return httpClient.post<{ message: string }>(`/devices/${id}/commands`, payload);
  },
};
