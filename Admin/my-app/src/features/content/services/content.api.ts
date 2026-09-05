import { httpClient } from "@/core/http/http-client";
import { config } from "@/core/config/config";
import type {
  ContentDetail,
  ContentListResponse,
  CreateContentPayload,
  UpdateContentPayload,
} from "../model/content.types";

export const contentApi = {
  local(deviceId: number, page: number = config.pagination.defaultPage, size: number = config.pagination.defaultPageSize) {
    return httpClient.get<ContentListResponse>("/contents/local", {
      query: { device_id: deviceId, page, size },
    });
  },

  scrap(page: number = config.pagination.defaultPage, size: number = config.pagination.defaultPageSize) {
    return httpClient.get<ContentListResponse>("/contents/scrap", { query: { page, size } });
  },

  detail(contentId: number, deviceId: number) {
    return httpClient.get<ContentDetail>(`/contents/${contentId}`, { query: { device_id: deviceId } });
  },

  create(payload: CreateContentPayload) {
    return httpClient.post<{ message: string }>("/contents", payload);
  },

  update(contentId: number, payload: UpdateContentPayload) {
    return httpClient.put<{ message: string }>(`/contents/${contentId}`, payload);
  },

  remove(contentId: number) {
    return httpClient.delete<unknown>(`/contents/${contentId}`);
  },
};
