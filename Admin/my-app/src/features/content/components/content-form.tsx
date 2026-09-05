"use client";

import { FormEvent, useState } from "react";
import { ApiError } from "@/core/http/api-error";
import { Field, TextInput, TextArea } from "@/shared/components/form-field";
import { Button } from "@/shared/components/button";

export interface ContentFormValues {
  title: string;
  summary: string;
  body: string;
  mainImg: string;
  imgList: string[];
  startDate: string;
  endDate: string;
}

export function ContentForm({
  defaultValues,
  onSubmit,
  submitLabel,
}: {
  defaultValues: ContentFormValues;
  onSubmit: (values: ContentFormValues) => Promise<void>;
  submitLabel: string;
}) {
  const [values, setValues] = useState(defaultValues);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  function updateImg(index: number, value: string) {
    setValues((current) => ({
      ...current,
      imgList: current.imgList.map((img, i) => (i === index ? value : img)),
    }));
  }

  function addImgRow() {
    setValues((current) => ({ ...current, imgList: [...current.imgList, ""] }));
  }

  function removeImgRow(index: number) {
    setValues((current) => ({ ...current, imgList: current.imgList.filter((_, i) => i !== index) }));
  }

  async function handleSubmit(event: FormEvent) {
    event.preventDefault();

    const cleanedImgList = values.imgList.map((img) => img.trim()).filter(Boolean);
    if (cleanedImgList.length === 0) {
      setError("حداقل یک تصویر برای محتوا لازم است");
      return;
    }

    setSubmitting(true);
    setError(null);
    setFieldErrors({});

    try {
      await onSubmit({ ...values, imgList: cleanedImgList });
    } catch (err) {
      if (err instanceof ApiError) {
        setError(err.message);
        setFieldErrors(err.fieldErrors ?? {});
      } else {
        setError("خطای غیرمنتظره‌ای رخ داد");
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-4 p-4" noValidate>
      <Field label="عنوان" error={fieldErrors.title}>
        <TextInput
          value={values.title}
          onChange={(e) => setValues((v) => ({ ...v, title: e.target.value }))}
          required
        />
      </Field>

      <Field label="خلاصه (اختیاری)">
        <TextInput
          value={values.summary}
          onChange={(e) => setValues((v) => ({ ...v, summary: e.target.value }))}
        />
      </Field>

      <Field label="متن کامل" hint="۲۰ تا ۲۰۰۰ کاراکتر" error={fieldErrors.body}>
        <TextArea
          value={values.body}
          onChange={(e) => setValues((v) => ({ ...v, body: e.target.value }))}
          required
          minLength={20}
          maxLength={2000}
        />
      </Field>

      <Field
        label="تصویر اصلی (آدرس URL)"
        hint="در حال حاضر آپلود فایل پشتیبانی نمی‌شود — آدرس تصویر از قبل هاست‌شده را وارد کنید"
        error={fieldErrors.main_img}
      >
        <TextInput
          value={values.mainImg}
          onChange={(e) => setValues((v) => ({ ...v, mainImg: e.target.value }))}
          required
          placeholder="/static/uploads/xyz.jpg"
        />
      </Field>

      <Field label="تصاویر بیشتر (آدرس URL)">
        <div className="flex flex-col gap-2">
          {values.imgList.map((img, index) => (
            <div key={index} className="flex gap-2">
              <TextInput
                value={img}
                onChange={(e) => updateImg(index, e.target.value)}
                placeholder="/static/uploads/xyz.jpg"
              />
              <Button type="button" variant="secondary" size="sm" onClick={() => removeImgRow(index)}>
                حذف
              </Button>
            </div>
          ))}
          <Button type="button" variant="secondary" size="sm" onClick={addImgRow} className="self-start">
            + افزودن تصویر
          </Button>
        </div>
      </Field>

      <div className="grid grid-cols-2 gap-3">
        <Field label="تاریخ شروع (اختیاری)">
          <TextInput
            type="date"
            value={values.startDate}
            onChange={(e) => setValues((v) => ({ ...v, startDate: e.target.value }))}
          />
        </Field>
        <Field label="تاریخ پایان (اختیاری)">
          <TextInput
            type="date"
            value={values.endDate}
            onChange={(e) => setValues((v) => ({ ...v, endDate: e.target.value }))}
          />
        </Field>
      </div>

      {error && (
        <p className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-700 dark:border-red-900 dark:bg-red-950/40 dark:text-red-400">
          {error}
        </p>
      )}

      <Button type="submit" variant="primary" loading={submitting} className="w-full">
        {submitLabel}
      </Button>
    </form>
  );
}
