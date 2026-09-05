"use client";

import { FormEvent, useState } from "react";
import { devicesApi } from "../services/devices.api";
import { ApiError } from "@/core/http/api-error";
import { Field, TextInput } from "@/shared/components/form-field";
import { Button } from "@/shared/components/button";

export function DeviceCreateForm({ onSuccess }: { onSuccess: () => void }) {
  const [name, setName] = useState("");
  const [location, setLocation] = useState("");
  const [section, setSection] = useState("");
  const [macAddress, setMacAddress] = useState("");
  const [ipAddress, setIpAddress] = useState("");
  const [kioskUsername, setKioskUsername] = useState("");
  const [kioskPassword, setKioskPassword] = useState("");
  const [kioskName, setKioskName] = useState("");

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  async function handleSubmit(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setError(null);
    setFieldErrors({});

    try {
      await devicesApi.create({
        name,
        location,
        section: section || undefined,
        // Backend requires exactly 12 chars with no separators — strip `:`/`-` for convenience.
        mac_address: macAddress.replace(/[:\-\s]/g, "").toUpperCase(),
        ip_address: ipAddress || undefined,
        user: {
          username: kioskUsername.trim(),
          password: kioskPassword,
          role: "device",
          name: kioskName.trim(),
        },
      });
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

      <Field label="مکان" hint="حداقل ۲۰ و حداکثر ۲۰۰ کاراکتر" error={fieldErrors.location}>
        <TextInput value={location} onChange={(e) => setLocation(e.target.value)} required minLength={20} maxLength={200} />
      </Field>

      <Field label="بخش (اختیاری)">
        <TextInput value={section} onChange={(e) => setSection(e.target.value)} />
      </Field>

      <Field label="آدرس MAC" hint="۱۲ کاراکتر، با یا بدون : — مثل AA:BB:CC:DD:EE:FF" error={fieldErrors.mac_address}>
        <TextInput value={macAddress} onChange={(e) => setMacAddress(e.target.value)} required />
      </Field>

      <Field label="آدرس IP (اختیاری)" error={fieldErrors.ip_address}>
        <TextInput value={ipAddress} onChange={(e) => setIpAddress(e.target.value)} />
      </Field>

      <div className="border-t border-slate-200 pt-4 dark:border-slate-800">
        <p className="mb-3 text-xs font-medium text-slate-500 dark:text-slate-400">
          حساب ورود این کیوسک به سیستم
        </p>
        <div className="flex flex-col gap-4">
          <Field label="نام کاربری کیوسک">
            <TextInput value={kioskUsername} onChange={(e) => setKioskUsername(e.target.value)} required minLength={3} maxLength={20} />
          </Field>
          <Field label="رمز عبور کیوسک" hint="حداقل ۸ کاراکتر">
            <TextInput
              type="password"
              value={kioskPassword}
              onChange={(e) => setKioskPassword(e.target.value)}
              required
              minLength={8}
            />
          </Field>
          <Field label="نام نمایشی کیوسک">
            <TextInput value={kioskName} onChange={(e) => setKioskName(e.target.value)} required />
          </Field>
        </div>
      </div>

      {error && (
        <p className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-700 dark:border-red-900 dark:bg-red-950/40 dark:text-red-400">
          {error}
        </p>
      )}

      <Button type="submit" variant="primary" loading={submitting} className="w-full">
        ساخت کیوسک
      </Button>
    </form>
  );
}
