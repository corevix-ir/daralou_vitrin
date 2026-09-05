/** Normalized shape both of the backend's error bodies collapse into. */
export class ApiError extends Error {
  readonly status: number;
  readonly fieldErrors?: Record<string, string>;

  constructor(status: number, message: string, fieldErrors?: Record<string, string>) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.fieldErrors = fieldErrors;
  }

  get isUnauthorized() {
    return this.status === 401;
  }

  get isForbidden() {
    return this.status === 403;
  }

  get isNotFound() {
    return this.status === 404;
  }
}

const STATUS_FALLBACK_MESSAGE: Record<number, string> = {
  400: "درخواست نامعتبر است",
  401: "کاربر احراز هویت نشده است",
  403: "دسترسی به این بخش برای شما مجاز نیست",
  404: "مورد درخواستی یافت نشد",
  500: "خطای داخلی سرور رخ داده است",
};

/**
 * The backend returns two different error envelopes depending on the
 * failure: `{ error: "..." }` for generic/auth failures, and
 * `{ errors: { field: "..." } }` for validation errors — see
 * vitrine-admin-api.md §6 and the register/create DTOs.
 */
export function toApiError(status: number, body: unknown): ApiError {
  if (body && typeof body === "object") {
    const record = body as Record<string, unknown>;

    if (typeof record.error === "string" && record.error.length > 0) {
      return new ApiError(status, record.error, undefined);
    }

    if (record.errors && typeof record.errors === "object") {
      const fieldErrors = record.errors as Record<string, string>;
      const firstMessage = Object.values(fieldErrors)[0];
      return new ApiError(
        status,
        firstMessage ?? STATUS_FALLBACK_MESSAGE[status] ?? "خطای ناشناخته",
        fieldErrors
      );
    }
  }

  return new ApiError(status, STATUS_FALLBACK_MESSAGE[status] ?? "خطای ناشناخته");
}
