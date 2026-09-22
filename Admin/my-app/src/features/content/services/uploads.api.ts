import { httpClient } from "@/core/http/http-client";

export const ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"];
export const MAX_IMAGE_SIZE_BYTES = 5 * 1024 * 1024;

export const uploadsApi = {
  uploadImage(file: File) {
    const formData = new FormData();
    formData.append("image", file);
    return httpClient.post<{ url: string }>("/uploads/images", formData);
  },
};
