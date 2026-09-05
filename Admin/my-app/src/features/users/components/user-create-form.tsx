"use client";

import { FormEvent, useState } from "react";
import { usersApi } from "../services/users.api";
import type { UserRole } from "@/features/auth/model/auth.types";
import { ApiError } from "@/core/http/api-error";
import { Field, TextInput, Select } from "@/shared/components/form-field";
import { Button } from "@/shared/components/button";

// Kiosk (`device`) accounts are created together with their device via POST /devices,
// not from here — see admin-panel-api.md §2.
const assignableRoles: { value: UserRole; label: string }[] = [
  { value: "admin", label: "ادمین" },
  { value: "operator", label: "اپراتور" },
  { value: "user", label: "کاربر" },
];

export function UserCreateForm({ onSuccess }: { onSuccess: () => void }) {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [role, setRole] = useState<UserRole>("operator");

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  async function handleSubmit(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setError(null);
    setFieldErrors({});

    try {
      await usersApi.create({ username: username.trim(), password, role, name: name.trim() });
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
      <Field label="نام کاربری" hint="۳ تا ۲۰ کاراکتر، فقط حروف و عدد انگلیسی" error={fieldErrors.username}>
        <TextInput value={username} onChange={(e) => setUsername(e.target.value)} required minLength={3} maxLength={20} />
      </Field>

      <Field label="رمز عبور" hint="حداقل ۸ کاراکتر" error={fieldErrors.password}>
        <TextInput type="password" value={password} onChange={(e) => setPassword(e.target.value)} required minLength={8} />
      </Field>

      <Field label="نام کامل" error={fieldErrors.name}>
        <TextInput value={name} onChange={(e) => setName(e.target.value)} required />
      </Field>

      <Field label="نقش">
        <Select value={role} onChange={(e) => setRole(e.target.value as UserRole)}>
          {assignableRoles.map((r) => (
            <option key={r.value} value={r.value}>
              {r.label}
            </option>
          ))}
        </Select>
      </Field>

      {error && (
        <p className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-700 dark:border-red-900 dark:bg-red-950/40 dark:text-red-400">
          {error}
        </p>
      )}

      <Button type="submit" variant="primary" loading={submitting} className="w-full">
        ساخت کاربر
      </Button>
    </form>
  );
}
