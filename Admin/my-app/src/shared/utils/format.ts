/**
 * Jalali (Persian) calendar via the `fa-IR` locale, Latin digits — the
 * combination most Iranian back-office tools use, since Jalali is what
 * operators expect but Latin digits stay unambiguous in tables/inputs.
 */
const dateTimeFormatter = new Intl.DateTimeFormat("fa-IR", {
  calendar: "persian",
  numberingSystem: "latn",
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
  hour: "2-digit",
  minute: "2-digit",
});

const dateFormatter = new Intl.DateTimeFormat("fa-IR", {
  calendar: "persian",
  numberingSystem: "latn",
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
});

export function formatDateTime(iso: string | null | undefined): string {
  if (!iso) return "—";
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return "—";
  return dateTimeFormatter.format(date);
}

export function formatDate(iso: string | null | undefined): string {
  if (!iso) return "—";
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return "—";
  return dateFormatter.format(date);
}

/** "۳ دقیقه پیش" style relative label, used for device last_seen. */
export function formatRelative(iso: string | null | undefined): string {
  if (!iso) return "—";
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return "—";

  const diffMs = Date.now() - date.getTime();
  const diffMinutes = Math.round(diffMs / 60_000);

  if (diffMinutes < 1) return "لحظاتی پیش";
  if (diffMinutes < 60) return `${diffMinutes} دقیقه پیش`;
  const diffHours = Math.round(diffMinutes / 60);
  if (diffHours < 24) return `${diffHours} ساعت پیش`;
  const diffDays = Math.round(diffHours / 24);
  if (diffDays < 30) return `${diffDays} روز پیش`;
  return formatDate(iso);
}
