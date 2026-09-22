"use client";

import { useRef, useState } from "react";
import { uploadsApi, ALLOWED_IMAGE_TYPES, MAX_IMAGE_SIZE_BYTES } from "../services/uploads.api";
import { resolveMediaUrl } from "@/shared/utils/media-url";
import { ApiError } from "@/core/http/api-error";
import { Button } from "@/shared/components/button";
import { Spinner } from "@/shared/components/spinner";

export function ImageUploadField({
  value,
  onChange,
  onRemove,
}: {
  value: string;
  onChange: (url: string) => void;
  onRemove?: () => void;
}) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleFile(file: File) {
    setError(null);

    if (!ALLOWED_IMAGE_TYPES.includes(file.type)) {
      setError("فرمت تصویر پشتیبانی نمی‌شود (فقط jpg/png/gif/webp مجاز است)");
      return;
    }
    if (file.size > MAX_IMAGE_SIZE_BYTES) {
      setError("حجم تصویر نباید بیشتر از ۵ مگابایت باشد");
      return;
    }

    setUploading(true);
    try {
      const result = await uploadsApi.uploadImage(file);
      onChange(result.url);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "آپلود تصویر ناموفق بود");
    } finally {
      setUploading(false);
      if (inputRef.current) inputRef.current.value = "";
    }
  }

  return (
    <div className="flex items-center gap-3">
      <div className="flex size-16 shrink-0 items-center justify-center overflow-hidden rounded-md border border-slate-200 bg-slate-100 dark:border-slate-700 dark:bg-slate-800">
        {uploading ? (
          <Spinner />
        ) : value ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={resolveMediaUrl(value)} alt="" className="size-full object-cover" />
        ) : (
          <span className="px-1 text-center text-[10px] text-slate-400 dark:text-slate-500">بدون تصویر</span>
        )}
      </div>

      <div className="flex min-w-0 flex-1 flex-col gap-1">
        <div className="flex gap-2">
          <Button
            type="button"
            variant="secondary"
            size="sm"
            loading={uploading}
            onClick={() => inputRef.current?.click()}
          >
            {value ? "تعویض تصویر" : "انتخاب تصویر"}
          </Button>
          {onRemove && (
            <Button type="button" variant="danger" size="sm" onClick={onRemove}>
              حذف
            </Button>
          )}
        </div>
        {error && <p className="text-xs text-red-600 dark:text-red-400">{error}</p>}
      </div>

      <input
        ref={inputRef}
        type="file"
        accept="image/jpeg,image/png,image/gif,image/webp"
        className="hidden"
        onChange={(event) => {
          const file = event.target.files?.[0];
          if (file) handleFile(file);
        }}
      />
    </div>
  );
}
