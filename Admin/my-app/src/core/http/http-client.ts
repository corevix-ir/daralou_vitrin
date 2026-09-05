import { config } from "@/core/config/config";
import { ApiError, toApiError } from "./api-error";

export type HttpMethod = "GET" | "POST" | "PUT" | "DELETE" | "PATCH";

export type QueryValue = string | number | boolean | undefined | null;

export interface RequestConfig {
  method: HttpMethod;
  path: string;
  query?: Record<string, QueryValue>;
  body?: unknown;
  headers?: Record<string, string>;
  /** Set to false for endpoints that must not carry/refresh a bearer token (login, refresh). Defaults to true. */
  auth?: boolean;
  signal?: AbortSignal;
}

export type RequestInterceptor = (
  config: RequestConfig
) => RequestConfig | Promise<RequestConfig>;

export type ResponseInterceptor = (
  response: Response,
  requestConfig: RequestConfig
) => void | Promise<void>;

/** Returns the new access token on success, or null if the session could not be refreshed. */
export type UnauthorizedHandler = () => Promise<string | null>;

function buildUrl(baseUrl: string, requestConfig: RequestConfig): string {
  const url = new URL(baseUrl + requestConfig.path);
  if (requestConfig.query) {
    for (const [key, value] of Object.entries(requestConfig.query)) {
      if (value === undefined || value === null) continue;
      url.searchParams.set(key, String(value));
    }
  }
  return url.toString();
}

/**
 * Thin fetch wrapper every network call in the app goes through. It is the
 * one place that knows how to attach/refresh auth headers, so features never
 * talk to `fetch` directly. Middleware is just a list of interceptor
 * functions — add logging, tracing, etc. here without touching call sites.
 */
class HttpClient {
  private requestInterceptors: RequestInterceptor[] = [];
  private responseInterceptors: ResponseInterceptor[] = [];
  private unauthorizedHandler: UnauthorizedHandler | null = null;
  private refreshInFlight: Promise<string | null> | null = null;

  constructor(private readonly baseUrl: string) {}

  /** Registers request middleware, returns an unsubscribe function. */
  useRequestInterceptor(interceptor: RequestInterceptor): () => void {
    this.requestInterceptors.push(interceptor);
    return () => {
      this.requestInterceptors = this.requestInterceptors.filter((i) => i !== interceptor);
    };
  }

  /** Registers response middleware (observing only), returns an unsubscribe function. */
  useResponseInterceptor(interceptor: ResponseInterceptor): () => void {
    this.responseInterceptors.push(interceptor);
    return () => {
      this.responseInterceptors = this.responseInterceptors.filter((i) => i !== interceptor);
    };
  }

  /** There is only ever one active session, so this is a single slot, not a list. */
  setUnauthorizedHandler(handler: UnauthorizedHandler | null) {
    this.unauthorizedHandler = handler;
  }

  get<T>(path: string, options: Omit<RequestConfig, "method" | "path"> = {}) {
    return this.request<T>({ ...options, method: "GET", path });
  }

  post<T>(path: string, body?: unknown, options: Omit<RequestConfig, "method" | "path" | "body"> = {}) {
    return this.request<T>({ ...options, method: "POST", path, body });
  }

  put<T>(path: string, body?: unknown, options: Omit<RequestConfig, "method" | "path" | "body"> = {}) {
    return this.request<T>({ ...options, method: "PUT", path, body });
  }

  delete<T>(path: string, options: Omit<RequestConfig, "method" | "path"> = {}) {
    return this.request<T>({ ...options, method: "DELETE", path });
  }

  async request<T>(requestConfig: RequestConfig): Promise<T> {
    let resolvedConfig = requestConfig;
    for (const interceptor of this.requestInterceptors) {
      resolvedConfig = await interceptor(resolvedConfig);
    }

    const response = await this.performFetch(resolvedConfig);

    if (response.status === 401 && resolvedConfig.auth !== false && this.unauthorizedHandler) {
      const newAccessToken = await this.runRefreshOnce();
      if (newAccessToken) {
        const retryConfig: RequestConfig = {
          ...resolvedConfig,
          headers: { ...resolvedConfig.headers, Authorization: `Bearer ${newAccessToken}` },
        };
        const retryResponse = await this.performFetch(retryConfig);
        return this.parseResponse<T>(retryResponse, retryConfig);
      }
    }

    return this.parseResponse<T>(response, resolvedConfig);
  }

  private runRefreshOnce(): Promise<string | null> {
    if (!this.refreshInFlight) {
      this.refreshInFlight = this.unauthorizedHandler!().finally(() => {
        this.refreshInFlight = null;
      });
    }
    return this.refreshInFlight;
  }

  private async performFetch(requestConfig: RequestConfig): Promise<Response> {
    const url = buildUrl(this.baseUrl, requestConfig);
    const hasBody = requestConfig.body !== undefined;

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), config.http.requestTimeoutMs);
    requestConfig.signal?.addEventListener("abort", () => controller.abort());

    try {
      return await fetch(url, {
        method: requestConfig.method,
        headers: {
          ...(hasBody ? { "Content-Type": "application/json" } : {}),
          ...requestConfig.headers,
        },
        body: hasBody ? JSON.stringify(requestConfig.body) : undefined,
        signal: controller.signal,
      });
    } catch {
      throw new ApiError(0, "ارتباط با سرور برقرار نشد. اتصال شبکه را بررسی کنید");
    } finally {
      clearTimeout(timeout);
    }
  }

  private async parseResponse<T>(response: Response, requestConfig: RequestConfig): Promise<T> {
    for (const interceptor of this.responseInterceptors) {
      await interceptor(response, requestConfig);
    }

    const text = await response.text();
    let data: unknown = null;
    if (text.length > 0) {
      try {
        data = JSON.parse(text);
      } catch {
        data = text;
      }
    }

    if (!response.ok) {
      throw toApiError(response.status, data);
    }

    return data as T;
  }
}

export const httpClient = new HttpClient(config.apiBaseUrl);

if (process.env.NODE_ENV !== "production") {
  httpClient.useResponseInterceptor((response, requestConfig) => {
    console.debug(`[http] ${requestConfig.method} ${requestConfig.path} → ${response.status}`);
  });
}
