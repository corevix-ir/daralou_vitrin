"use client";

import { useEffect, useState } from "react";
import { usersApi } from "../services/users.api";
import type { ManagedUser } from "../model/user.types";
import { devicesApi } from "@/features/devices/services/devices.api";
import type { Device } from "@/features/devices/model/device.types";
import { ApiError } from "@/core/http/api-error";
import { FullscreenLoader } from "@/shared/components/spinner";
import { ErrorState } from "@/shared/components/empty-state";
import { Button } from "@/shared/components/button";

export function OperatorDeviceAccessForm({ user, onSuccess }: { user: ManagedUser; onSuccess: () => void }) {
  const [devices, setDevices] = useState<Device[] | null>(null);
  const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set());
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  async function load() {
    setError(null);
    setDevices(null);
    try {
      const [deviceList, access] = await Promise.all([devicesApi.list(), usersApi.getDeviceAccess(user.id)]);
      setDevices(deviceList);
      setSelectedIds(new Set(access.device_id));
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "دریافت اطلاعات دسترسی ناموفق بود");
    }
  }

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user.id]);

  function toggle(id: number) {
    setSelectedIds((current) => {
      const next = new Set(current);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }

  async function handleSave() {
    setSaving(true);
    setError(null);
    try {
      await usersApi.setDeviceAccess(user.id, Array.from(selectedIds));
      onSuccess();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "ذخیره دسترسی‌ها ناموفق بود");
    } finally {
      setSaving(false);
    }
  }

  if (devices === null && !error) return <FullscreenLoader />;

  return (
    <div className="flex flex-col gap-4 p-4">
      <p className="text-xs text-slate-500 dark:text-slate-400">
        «{user.name}» فقط به کیوسک‌هایی که این‌جا انتخاب می‌کنید دسترسی خواهد داشت (نه ویترین، نه محتوا، نه
        هیچ‌چیز دیگری روی بقیه‌ی کیوسک‌ها). اگر هیچ‌کدام انتخاب نشود، این اپراتور به هیچ کیوسکی دسترسی نخواهد
        داشت.
      </p>

      {error && <ErrorState message={error} onRetry={load} />}

      {devices && devices.length === 0 && !error && (
        <p className="text-sm text-slate-500 dark:text-slate-400">هنوز کیوسکی ثبت نشده است.</p>
      )}

      {devices && devices.length > 0 && (
        <div className="flex flex-col divide-y divide-slate-100 rounded-md border border-slate-200 dark:divide-slate-800 dark:border-slate-800">
          {devices.map((device) => (
            <label
              key={device.id}
              className="flex cursor-pointer items-center gap-3 px-3 py-2.5 text-[13px] hover:bg-slate-50 dark:hover:bg-slate-800/60"
            >
              <input
                type="checkbox"
                checked={selectedIds.has(device.id)}
                onChange={() => toggle(device.id)}
                className="size-4 rounded border-slate-300 dark:border-slate-600"
              />
              <div className="min-w-0 flex-1">
                <p className="truncate font-medium text-slate-800 dark:text-slate-100">{device.name}</p>
                <p className="truncate text-xs text-slate-500 dark:text-slate-400">{device.location}</p>
              </div>
            </label>
          ))}
        </div>
      )}

      <Button variant="primary" loading={saving} onClick={handleSave} className="w-full">
        ذخیره دسترسی‌ها
      </Button>
    </div>
  );
}
