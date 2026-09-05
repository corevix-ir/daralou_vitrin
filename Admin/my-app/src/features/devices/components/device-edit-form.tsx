"use client";

import { FormEvent, useState } from "react";
import { devicesApi } from "../services/devices.api";
import type { Device } from "../model/device.types";
import { ApiError } from "@/core/http/api-error";
import { Field, TextInput, Select } from "@/shared/components/form-field";
import { Button } from "@/shared/components/button";

export function DeviceEditForm({ device, onSuccess }: { device: Device; onSuccess: () => void }) {
  const [name, setName] = useState(device.name);
  const [status, setStatus] = useState(device.status);
  const [location, setLocation] = useState(device.location);
  const [section, setSection] = useState(device.section);
  const [ipAddress, setIpAddress] = useState(device.ip_address);

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  async function handleSubmit(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setError(null);
    setFieldErrors({});

    try {
      await devicesApi.update(device.id, { name, status, location, section, ip_address: ipAddress });
      onSuccess();
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
      <Field label="نام کیوسک" error={fieldErrors.name}>
        <TextInput value={name} onChange={(e) => setName(e.target.value)} required />
      </Field>

      <Field label="وضعیت">
        <Select value={status} onChange={(e) => setStatus(e.target.value)}>
          <option value="active">فعال</option>
          <option value="offline">آفلاین</option>
          <option value="maintenance">در حال تعمیر</option>
        </Select>
      </Field>

      <Field label="مکان" error={fieldErrors.location}>
        <TextInput value={location} onChange={(e) => setLocation(e.target.value)} required />
      </Field>

      <Field label="بخش">
        <TextInput value={section} onChange={(e) => setSection(e.target.value)} />
      </Field>

      <Field label="آدرس IP" error={fieldErrors.ip_address}>
        <TextInput value={ipAddress} onChange={(e) => setIpAddress(e.target.value)} />
      </Field>

      {error && (
        <p className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-700 dark:border-red-900 dark:bg-red-950/40 dark:text-red-400">
          {error}
        </p>
      )}

      <Button type="submit" variant="primary" loading={submitting} className="w-full">
        ذخیره تغییرات
      </Button>
    </form>
  );
}
