"use client";

import { useCallback, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { vitrineApi } from "../services/vitrine.api";
import { devicesApi } from "@/features/devices/services/devices.api";
import { DeviceStatusBadge } from "@/features/devices/components/device-status-badge";
import type { Device } from "@/features/devices/model/device.types";
import type { ContentSource, ContentSummary } from "@/features/content/model/content.types";
import type { SlotMap, VitrinePreview } from "../model/vitrine.types";
import { SlotGrid } from "../components/slot-grid";
import { SizeControl } from "../components/size-control";
import { ContentPickerDrawer } from "../components/content-picker-drawer";
import { PreviewStrip } from "../components/preview-strip";
import { LocalContentManager } from "@/features/content/components/local-content-manager";
import { ApiError } from "@/core/http/api-error";
import { FullscreenLoader } from "@/shared/components/spinner";
import { ErrorState } from "@/shared/components/empty-state";
import { Button } from "@/shared/components/button";
import { Card, CardBody, CardHeader, CardTitle } from "@/shared/components/card";
import { useToast } from "@/shared/components/toast/toast-context";

function buildSlots(items: { position: number; source: ContentSource; content: ContentSummary }[]): SlotMap {
  const slots: SlotMap = {};
  for (const item of items) {
    slots[item.position] = item;
  }
  return slots;
}

export function VitrineEditorScreen({ deviceId }: { deviceId: number }) {
  const router = useRouter();
  const toast = useToast();

  const [device, setDevice] = useState<Device | null>(null);
  const [size, setSize] = useState(5);
  const [slots, setSlots] = useState<SlotMap>({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  const [pickerPosition, setPickerPosition] = useState<number | null>(null);

  const [preview, setPreview] = useState<VitrinePreview | null>(null);
  const [previewLoading, setPreviewLoading] = useState(false);

  const loadVitrine = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [config] = await Promise.all([
        vitrineApi.get(deviceId),
        // Best-effort — 403 for operators (device list is admin-only) shouldn't block the editor.
        devicesApi
          .list()
          .then((devices) => setDevice(devices.find((d) => d.id === deviceId) ?? null))
          .catch(() => setDevice(null)),
      ]);
      setSize(config.size);
      setSlots(buildSlots(config.items));
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "دریافت تنظیمات ویترین ناموفق بود");
    } finally {
      setLoading(false);
    }
  }, [deviceId]);

  useEffect(() => {
    loadVitrine();
  }, [loadVitrine]);

  function handleSizeChange(nextSize: number) {
    setSize(nextSize);
    setSlots((current) => {
      const dropped = Object.keys(current).some((key) => Number(key) > nextSize && current[Number(key)]);
      if (dropped) toast.show(`جایگاه‌های بزرگ‌تر از ${nextSize} از چینش حذف شدند`, "info");
      const next: SlotMap = {};
      for (const [key, value] of Object.entries(current)) {
        if (Number(key) <= nextSize) next[Number(key)] = value;
      }
      return next;
    });
  }

  function handlePicked(content: ContentSummary, source: ContentSource) {
    if (pickerPosition === null) return;
    setSlots((current) => ({ ...current, [pickerPosition]: { position: pickerPosition, source, content } }));
    setPickerPosition(null);
  }

  function handleClear(position: number) {
    setSlots((current) => ({ ...current, [position]: null }));
  }

  async function handlePreview() {
    setPreviewLoading(true);
    try {
      const result = await vitrineApi.preview(deviceId);
      setPreview(result);
    } catch (err) {
      toast.show(err instanceof ApiError ? err.message : "دریافت پیش‌نمایش ناموفق بود", "error");
    } finally {
      setPreviewLoading(false);
    }
  }

  async function handleSave() {
    setSaving(true);
    try {
      const items = Object.values(slots)
        .filter((item): item is NonNullable<typeof item> => item !== null)
        .map((item) => ({ position: item.position, content_id: item.content.id }));

      await vitrineApi.save(deviceId, { size, items });
      toast.show("تنظیمات ویترین با موفقیت ذخیره شد", "success");
      await handlePreview();
    } catch (err) {
      toast.show(err instanceof ApiError ? err.message : "ذخیره‌سازی ناموفق بود", "error");
    } finally {
      setSaving(false);
    }
  }

  if (loading) return <FullscreenLoader />;
  if (error) return <div className="p-4 sm:p-6"><ErrorState message={error} onRetry={loadVitrine} /></div>;

  return (
    <div className="flex flex-col gap-5 p-4 sm:p-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <button
            onClick={() => router.back()}
            className="rounded-md border border-slate-300 px-2.5 py-1.5 text-xs font-medium text-slate-600 hover:bg-slate-50 dark:border-slate-700 dark:text-slate-300 dark:hover:bg-slate-800 cursor-pointer"
          >
            بازگشت
          </button>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-sm font-semibold text-slate-800 dark:text-slate-100">
                {device?.name ?? `کیوسک #${deviceId}`}
              </h2>
              {device && <DeviceStatusBadge status={device.status} />}
            </div>
            {device && (
              <p className="text-xs text-slate-500 dark:text-slate-400">
                {device.location}
                {device.section ? ` · ${device.section}` : ""}
              </p>
            )}
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <SizeControl size={size} onChange={handleSizeChange} />
          <Button variant="secondary" loading={previewLoading} onClick={handlePreview}>
            پیش‌نمایش
          </Button>
          <Button variant="primary" loading={saving} onClick={handleSave}>
            ذخیره تغییرات
          </Button>
        </div>
      </div>

      <SlotGrid size={size} slots={slots} onPick={setPickerPosition} onClear={handleClear} />

      <Card>
        <CardHeader>
          <CardTitle>محتوای اختصاصی این کیوسک</CardTitle>
        </CardHeader>
        <CardBody>
          <LocalContentManager deviceId={deviceId} />
        </CardBody>
      </Card>

      {preview && (
        <Card>
          <CardHeader>
            <CardTitle>پیش‌نمایش نهایی ویترین</CardTitle>
          </CardHeader>
          <CardBody>
            <PreviewStrip items={preview.items} />
          </CardBody>
        </Card>
      )}

      <ContentPickerDrawer
        open={pickerPosition !== null}
        onClose={() => setPickerPosition(null)}
        deviceId={deviceId}
        position={pickerPosition}
        onPick={handlePicked}
      />
    </div>
  );
}
