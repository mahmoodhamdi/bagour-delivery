import type { ApiResponse } from "@bagour/types";
import type { AxiosInstance } from "axios";

export type UploadKind =
  | "avatar"
  | "restaurant-logo"
  | "restaurant-cover"
  | "menu-item"
  | "review-image"
  | "driver-document"
  | "delivery-proof";

export interface UploadResponse {
  url: string;
  publicId?: string;
  width?: number;
  height?: number;
  bytes?: number;
}

export const uploadEndpoints = (http: AxiosInstance) => ({
  /**
   * Upload via multipart/form-data. The backend forwards to Cloudinary.
   * Caller provides a File or Blob.
   */
  async upload(kind: UploadKind, file: File | Blob): Promise<UploadResponse> {
    const form = new FormData();
    form.append("file", file);

    const { data } = await http.post<ApiResponse<UploadResponse>>(`/api/v1/upload/${kind}`, form, {
      headers: { "Content-Type": "multipart/form-data" },
    });
    return data.data;
  },

  async deleteUpload(publicId: string): Promise<{ message: string }> {
    const { data } = await http.delete<ApiResponse<{ message: string }>>(
      `/api/v1/upload/${encodeURIComponent(publicId)}`,
    );
    return data.data;
  },
});

export type UploadEndpoints = ReturnType<typeof uploadEndpoints>;
