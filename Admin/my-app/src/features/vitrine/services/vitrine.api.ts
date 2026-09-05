import { httpClient } from "@/core/http/http-client";
import type { VitrineConfig, VitrinePreview, VitrineSavePayload } from "../model/vitrine.types";

export const vitrineApi = {
  get(deviceId: number) {
    return httpClient.get<VitrineConfig>(`/devices/${deviceId}/vitrine`);
  },

  save(deviceId: number, payload: VitrineSavePayload) {
    return httpClient.put<{ message: string }>(`/devices/${deviceId}/vitrine`, payload);
  },

  preview(deviceId: number) {
    return httpClient.get<VitrinePreview>(`/devices/${deviceId}/vitrine/preview`);
  },
};
