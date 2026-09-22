"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { devicesApi } from "../services/devices.api";
import type { Device } from "../model/device.types";
import { DeviceStatusBadge } from "../components/device-status-badge";
import { DeviceCreateForm } from "../components/device-create-form";
import { DeviceEditForm } from "../components/device-edit-form";
import { ApiError } from "@/core/http/api-error";
import { FullscreenLoader } from "@/shared/components/spinner";
import { EmptyState, ErrorState } from "@/shared/components/empty-state";
import { Button } from "@/shared/components/button";
import { Drawer } from "@/shared/components/drawer";
import { ConfirmDialog } from "@/shared/components/confirm-dialog";
import { formatRelative } from "@/shared/utils/format";
import { useToast } from "@/shared/components/toast/toast-context";
import { useAuth } from "@/features/auth/context/auth-context";

export function DevicesScreen() {
  const router = useRouter();
  const toast = useToast();
  const { user } = useAuth();
  // Device CRUD + realtime commands stay admin-only even though the list itself
  // is now visible to operators too (admin-panel-api.md §1, §3).
  const isAdmin = user?.role === "admin";

  const [devices, setDevices] = useState<Device[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");

  const [createOpen, setCreateOpen] = useState(false);
  const [editingDevice, setEditingDevice] = useState<Device | null>(null);
  const [deletingDevice, setDeletingDevice] = useState<Device | null>(null);
  const [deleting, setDeleting] = useState(false);
  const [commandLoadingId, setCommandLoadingId] = useState<number | null>(null);

  async function load() {
    setError(null);
    setDevices(null);
    try {
      const result = await devicesApi.list();
      setDevices(result);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "دریافت لیست کیوسک‌ها ناموفق بود");
    }
  }

  useEffect(() => {
    load();
  }, []);

  const filtered = useMemo(() => {
    if (!devices) return [];
    const query = search.trim().toLowerCase();
    if (!query) return devices;
    return devices.filter((device) =>
      [device.name, device.location, device.section, device.mac_address, device.ip_address]
        .join(" ")
        .toLowerCase()
        .includes(query)
    );
  }, [devices, search]);

  async function handleSendCommand(device: Device) {
    setCommandLoadingId(device.id);
    try {
      await devicesApi.sendCommand(device.id, { type: "open_admin_panel", payload: {} });
      toast.show(`پنل ادمین روی «${device.name}» باز شد`, "success");
    } catch (err) {
      toast.show(err instanceof ApiError ? err.message : "ارسال دستور ناموفق بود", "error");
    } finally {
      setCommandLoadingId(null);
    }
  }

  async function handleDelete() {
    if (!deletingDevice) return;
    setDeleting(true);
    try {
      await devicesApi.remove(deletingDevice.id);
      toast.show("کیوسک حذف شد", "success");
      setDeletingDevice(null);
      load();
    } catch (err) {
      toast.show(err instanceof ApiError ? err.message : "حذف کیوسک ناموفق بود", "error");
    } finally {
      setDeleting(false);
    }
  }

  if (devices === null && !error) return <FullscreenLoader />;

  return (
    <div className="flex flex-col gap-4 p-4 sm:p-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <input
          value={search}
          onChange={(event) => setSearch(event.target.value)}
          placeholder="جستجو بر اساس نام، مکان، بخش یا MAC..."
          className="h-9 w-full rounded-md border border-slate-300 bg-white px-3 text-[13px] outline-none focus:border-slate-500 sm:w-72 dark:border-slate-700 dark:bg-slate-900 dark:focus:border-slate-500"
        />
        <div className="flex items-center justify-between gap-3 sm:justify-end">
          {devices && (
            <span className="text-xs text-slate-500 dark:text-slate-400">{devices.length} کیوسک ثبت‌شده</span>
          )}
          {isAdmin && (
            <Button variant="primary" size="sm" onClick={() => setCreateOpen(true)}>
              + افزودن کیوسک
            </Button>
          )}
        </div>
      </div>

      {error && <ErrorState message={error} onRetry={load} />}

      {devices && filtered.length === 0 && !error && (
        <EmptyState title={devices.length === 0 ? "هنوز کیوسکی ثبت نشده است" : "موردی با این جستجو یافت نشد"} />
      )}

      {filtered.length > 0 && (
        <>
          {/* Table — sm and up */}
          <div className="hidden overflow-x-auto rounded-lg border border-slate-200 sm:block dark:border-slate-800">
            <table className="w-full min-w-max text-start text-[13px]">
              <thead className="border-b border-slate-200 bg-slate-50 text-slate-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-400">
                <tr>
                  <th className="px-4 py-2.5 text-start font-medium">نام کیوسک</th>
                  <th className="px-4 py-2.5 text-start font-medium">مکان</th>
                  <th className="px-4 py-2.5 text-start font-medium">بخش</th>
                  <th className="px-4 py-2.5 text-start font-medium">آدرس MAC</th>
                  <th className="px-4 py-2.5 text-start font-medium">وضعیت</th>
                  <th className="px-4 py-2.5 text-start font-medium">آخرین اتصال</th>
                  <th className="px-4 py-2.5" />
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {filtered.map((device) => (
                  <tr key={device.id} className="bg-white dark:bg-slate-900">
                    <td className="px-4 py-2.5 font-medium text-slate-800 dark:text-slate-100">{device.name}</td>
                    <td className="max-w-48 truncate px-4 py-2.5 text-slate-600 dark:text-slate-300">
                      {device.location}
                    </td>
                    <td className="px-4 py-2.5 text-slate-600 dark:text-slate-300">{device.section || "—"}</td>
                    <td className="px-4 py-2.5 font-mono text-xs text-slate-500 dark:text-slate-400">
                      {device.mac_address}
                    </td>
                    <td className="px-4 py-2.5">
                      <DeviceStatusBadge status={device.status} />
                    </td>
                    <td className="px-4 py-2.5 text-slate-500 dark:text-slate-400">
                      {formatRelative(device.last_seen)}
                    </td>
                    <td className="px-4 py-2.5">
                      <div className="flex flex-wrap justify-end gap-1.5">
                        <Button size="sm" onClick={() => router.push(`/vitrine/${device.id}`)}>
                          تنظیم ویترین
                        </Button>
                        {isAdmin && (
                          <>
                            <Button size="sm" variant="secondary" onClick={() => setEditingDevice(device)}>
                              ویرایش
                            </Button>
                            <Button
                              size="sm"
                              variant="secondary"
                              loading={commandLoadingId === device.id}
                              onClick={() => handleSendCommand(device)}
                            >
                              باز کردن پنل
                            </Button>
                            <Button size="sm" variant="danger" onClick={() => setDeletingDevice(device)}>
                              حذف
                            </Button>
                          </>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Cards — below sm */}
          <div className="flex flex-col gap-3 sm:hidden">
            {filtered.map((device) => (
              <div
                key={device.id}
                className="rounded-lg border border-slate-200 bg-white p-3.5 dark:border-slate-800 dark:bg-slate-900"
              >
                <div className="flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <p className="truncate text-sm font-semibold text-slate-800 dark:text-slate-100">
                      {device.name}
                    </p>
                    <p className="truncate text-xs text-slate-500 dark:text-slate-400">{device.location}</p>
                  </div>
                  <DeviceStatusBadge status={device.status} />
                </div>
                <dl className="mt-3 grid grid-cols-2 gap-x-3 gap-y-1.5 text-xs">
                  <div>
                    <dt className="text-slate-400 dark:text-slate-500">بخش</dt>
                    <dd className="text-slate-700 dark:text-slate-200">{device.section || "—"}</dd>
                  </div>
                  <div>
                    <dt className="text-slate-400 dark:text-slate-500">آخرین اتصال</dt>
                    <dd className="text-slate-700 dark:text-slate-200">{formatRelative(device.last_seen)}</dd>
                  </div>
                  <div className="col-span-2">
                    <dt className="text-slate-400 dark:text-slate-500">MAC</dt>
                    <dd className="font-mono text-slate-700 dark:text-slate-200">{device.mac_address}</dd>
                  </div>
                </dl>
                <div className="mt-3 flex flex-wrap gap-1.5">
                  <Button size="sm" className="flex-1" onClick={() => router.push(`/vitrine/${device.id}`)}>
                    تنظیم ویترین
                  </Button>
                  {isAdmin && (
                    <>
                      <Button size="sm" variant="secondary" onClick={() => setEditingDevice(device)}>
                        ویرایش
                      </Button>
                      <Button
                        size="sm"
                        variant="secondary"
                        loading={commandLoadingId === device.id}
                        onClick={() => handleSendCommand(device)}
                      >
                        باز کردن پنل
                      </Button>
                      <Button size="sm" variant="danger" onClick={() => setDeletingDevice(device)}>
                        حذف
                      </Button>
                    </>
                  )}
                </div>
              </div>
            ))}
          </div>
        </>
      )}

      <Drawer open={createOpen} onClose={() => setCreateOpen(false)} title="افزودن کیوسک جدید">
        <DeviceCreateForm
          onSuccess={() => {
            setCreateOpen(false);
            toast.show("کیوسک با موفقیت ساخته شد", "success");
            load();
          }}
        />
      </Drawer>

      <Drawer open={editingDevice !== null} onClose={() => setEditingDevice(null)} title="ویرایش کیوسک">
        {editingDevice && (
          <DeviceEditForm
            device={editingDevice}
            onSuccess={() => {
              setEditingDevice(null);
              toast.show("تغییرات ذخیره شد", "success");
              load();
            }}
          />
        )}
      </Drawer>

      <ConfirmDialog
        open={deletingDevice !== null}
        title="حذف کیوسک"
        description={deletingDevice ? `آیا از حذف «${deletingDevice.name}» مطمئن هستید؟ این عملیات قابل بازگشت نیست.` : undefined}
        confirmLabel="حذف"
        danger
        loading={deleting}
        onConfirm={handleDelete}
        onCancel={() => setDeletingDevice(null)}
      />
    </div>
  );
}
