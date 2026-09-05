"use client";

import { useEffect, useState } from "react";
import { contentApi } from "../services/content.api";
import type { ContentSummary } from "../model/content.types";
import { ContentForm, ContentFormValues } from "./content-form";
import { ApiError } from "@/core/http/api-error";
import { resolveMediaUrl } from "@/shared/utils/media-url";
import { formatDate } from "@/shared/utils/format";
import { FullscreenLoader } from "@/shared/components/spinner";
import { EmptyState, ErrorState } from "@/shared/components/empty-state";
import { Button } from "@/shared/components/button";
import { Drawer } from "@/shared/components/drawer";
import { ConfirmDialog } from "@/shared/components/confirm-dialog";
import { useToast } from "@/shared/components/toast/toast-context";

const emptyValues: ContentFormValues = {
  title: "",
  summary: "",
  body: "",
  mainImg: "",
  imgList: [""],
  startDate: "",
  endDate: "",
};

function toIsoOrNull(dateInput: string): string | null {
  return dateInput ? new Date(dateInput).toISOString() : null;
}

export function LocalContentManager({ deviceId }: { deviceId: number }) {
  const toast = useToast();

  const [items, setItems] = useState<ContentSummary[] | null>(null);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [error, setError] = useState<string | null>(null);

  const [createOpen, setCreateOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<ContentSummary | null>(null);
  const [editingValues, setEditingValues] = useState<ContentFormValues | null>(null);
  const [editingLoading, setEditingLoading] = useState(false);
  const [deletingItem, setDeletingItem] = useState<ContentSummary | null>(null);
  const [deleting, setDeleting] = useState(false);

  async function load(targetPage = 1) {
    setError(null);
    if (targetPage === 1) setItems(null);
    try {
      const result = await contentApi.local(deviceId, targetPage);
      setItems((current) => (targetPage === 1 ? result.content : [...(current ?? []), ...result.content]));
      setTotal(result.total);
      setPage(result.page);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "دریافت محتوای این کیوسک ناموفق بود");
    }
  }

  useEffect(() => {
    load(1);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [deviceId]);

  useEffect(() => {
    if (!editingItem) {
      setEditingValues(null);
      return;
    }
    setEditingLoading(true);
    contentApi
      .detail(editingItem.id, deviceId)
      .then((detail) => {
        setEditingValues({
          title: detail.title,
          summary: detail.summary ?? "",
          body: detail.body,
          mainImg: detail.main_img_url,
          imgList: detail.extra_img_list.length > 0 ? detail.extra_img_list : [""],
          startDate: detail.start_date ? detail.start_date.slice(0, 10) : "",
          endDate: detail.end_date ? detail.end_date.slice(0, 10) : "",
        });
      })
      .catch((err) => {
        toast.show(err instanceof ApiError ? err.message : "دریافت جزئیات محتوا ناموفق بود", "error");
        setEditingItem(null);
      })
      .finally(() => setEditingLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [editingItem, deviceId]);

  async function handleCreate(values: ContentFormValues) {
    await contentApi.create({
      title: values.title,
      body: values.body,
      summary: values.summary || undefined,
      main_img: values.mainImg,
      img_list: values.imgList,
      device_id: [deviceId],
      start_date: toIsoOrNull(values.startDate),
      end_date: toIsoOrNull(values.endDate),
    });
    setCreateOpen(false);
    toast.show("محتوای جدید ساخته شد", "success");
    load(1);
  }

  async function handleUpdate(values: ContentFormValues) {
    if (!editingItem) return;
    await contentApi.update(editingItem.id, {
      title: values.title,
      body: values.body,
      summary: values.summary || undefined,
      main_img: values.mainImg,
      img_list: values.imgList,
      start_date: toIsoOrNull(values.startDate),
      end_date: toIsoOrNull(values.endDate),
    });
    setEditingItem(null);
    toast.show("تغییرات ذخیره شد", "success");
    load(1);
  }

  async function handleDelete() {
    if (!deletingItem) return;
    setDeleting(true);
    try {
      await contentApi.remove(deletingItem.id);
      toast.show("محتوا حذف شد", "success");
      setDeletingItem(null);
      load(1);
    } catch (err) {
      toast.show(err instanceof ApiError ? err.message : "حذف محتوا ناموفق بود", "error");
    } finally {
      setDeleting(false);
    }
  }

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center justify-between">
        <p className="text-xs text-slate-500 dark:text-slate-400">
          {items ? `${total} محتوای اختصاصی این کیوسک` : "در حال بارگذاری..."}
        </p>
        <Button size="sm" variant="secondary" onClick={() => setCreateOpen(true)}>
          + محتوای جدید
        </Button>
      </div>

      {error && <ErrorState message={error} onRetry={() => load(1)} />}

      {items === null && !error && <FullscreenLoader />}

      {items && items.length === 0 && !error && (
        <EmptyState title="هنوز محتوای اختصاصی برای این کیوسک ساخته نشده است" />
      )}

      {items && items.length > 0 && (
        <div className="flex flex-col gap-2">
          {items.map((item) => (
            <div
              key={item.id}
              className="flex items-center gap-3 rounded-md border border-slate-200 bg-white p-2.5 dark:border-slate-800 dark:bg-slate-900"
            >
              <div className="size-10 shrink-0 overflow-hidden rounded bg-slate-100 dark:bg-slate-800">
                {item.main_img && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={resolveMediaUrl(item.main_img)} alt="" className="size-full object-cover" />
                )}
              </div>
              <div className="min-w-0 flex-1">
                <p className="truncate text-[13px] font-medium text-slate-800 dark:text-slate-100">{item.title}</p>
                <p className="text-[11px] text-slate-400 dark:text-slate-500">{formatDate(item.created_at)}</p>
              </div>
              <div className="flex shrink-0 gap-1.5">
                <Button size="sm" variant="secondary" onClick={() => setEditingItem(item)}>
                  ویرایش
                </Button>
                <Button size="sm" variant="danger" onClick={() => setDeletingItem(item)}>
                  حذف
                </Button>
              </div>
            </div>
          ))}

          {items.length < total && (
            <Button size="sm" variant="secondary" onClick={() => load(page + 1)}>
              بارگذاری بیشتر ({items.length} از {total})
            </Button>
          )}
        </div>
      )}

      <Drawer open={createOpen} onClose={() => setCreateOpen(false)} title="ساخت محتوای جدید">
        <ContentForm defaultValues={emptyValues} onSubmit={handleCreate} submitLabel="ساخت محتوا" />
      </Drawer>

      <Drawer open={editingItem !== null} onClose={() => setEditingItem(null)} title="ویرایش محتوا">
        {editingLoading || !editingValues ? (
          <FullscreenLoader />
        ) : (
          <ContentForm defaultValues={editingValues} onSubmit={handleUpdate} submitLabel="ذخیره تغییرات" />
        )}
      </Drawer>

      <ConfirmDialog
        open={deletingItem !== null}
        title="حذف محتوا"
        description={deletingItem ? `آیا از حذف «${deletingItem.title}» مطمئن هستید؟` : undefined}
        confirmLabel="حذف"
        danger
        loading={deleting}
        onConfirm={handleDelete}
        onCancel={() => setDeletingItem(null)}
      />
    </div>
  );
}
