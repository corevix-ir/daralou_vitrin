import { Badge } from "@/shared/components/badge";
import type { DeviceStatus } from "../model/device.types";

const statusMeta: Record<string, { label: string; tone: "green" | "neutral" | "amber" }> = {
  active: { label: "فعال", tone: "green" },
  offline: { label: "آفلاین", tone: "neutral" },
  maintenance: { label: "در حال تعمیر", tone: "amber" },
};

export function DeviceStatusBadge({ status }: { status: DeviceStatus }) {
  const meta = statusMeta[status] ?? { label: status, tone: "neutral" as const };
  return (
    <Badge tone={meta.tone} dot>
      {meta.label}
    </Badge>
  );
}
