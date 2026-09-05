import { config } from "@/core/config/config";

/**
 * The backend returns media paths relative to itself (e.g. `/static/news/x.jpg`),
 * not absolute URLs — resolve against the API host so <img> can load them.
 */
export function resolveMediaUrl(path: string | null | undefined): string {
  if (!path) return "";
  if (path.startsWith("http://") || path.startsWith("https://")) return path;
  return `${config.apiBaseUrl}${path.startsWith("/") ? "" : "/"}${path}`;
}
