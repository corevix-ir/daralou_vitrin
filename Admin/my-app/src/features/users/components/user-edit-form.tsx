"use client";

import { FormEvent, useState } from "react";
import { usersApi } from "../services/users.api";
import type { ManagedUser } from "../model/user.types";
import type { UserRole } from "@/features/auth/model/auth.types";
import { roleLabels } from "@/shared/utils/role-labels";
import { ApiError } from "@/core/http/api-error";
import { Field, TextInput, Select } from "@/shared/components/form-field";
import { Button } from "@/shared/components/button";

const assignableRoles: UserRole[] = ["admin", "operator", "user"];

export function UserEditForm({ user, onSuccess }: { user: ManagedUser; onSuccess: () => void }) {
  const [name, setName] = useState(user.name);
  const [role, setRole] = useState<UserRole>(user.role);
  const [isActive, setIsActive] = useState(user.status);
  const [password, setPassword] = useState("");

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  // A pre-existing `device` account should stay visible in its own select, but is never
  // something you'd newly assign from here — kiosk accounts come from POST /devices.
  const roleOptions = assignableRoles.includes(user.role) ? assignableRoles : [user.role, ...assignableRoles];

  async function handleSubmit(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setError(null);
    setFieldErrors({});

    try {
      await usersApi.update(user.id, {
        name,
        role,
        is_active: isActive,
        ...(password ? { password } : {}),
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
      <Field label="نام کاربری">
        <TextInput value={user.username} disabled className="opacity-60" />
      </Field>

      <Field label="نام کامل" error={fieldErrors.name}>
        <TextInput value={name} onChange={(e) => setName(e.target.value)} required />
      </Field>

      <Field label="نقش">
        <Select value={role} onChange={(e) => setRole(e.target.value as UserRole)}>
          {roleOptions.map((r) => (
            <option key={r} value={r}>
              {roleLabels[r]}
            </option>
          ))}
        </Select>
      </Field>

      <Field label="رمز عبور جدید (اختیاری)" hint="برای عدم تغییر، خالی بگذارید">
        <TextInput type="password" value={password} onChange={(e) => setPassword(e.target.value)} minLength={8} />
      </Field>

      <label className="flex items-center gap-2 text-[13px] text-slate-700 dark:text-slate-200">
        <input
          type="checkbox"
          checked={isActive}
          onChange={(e) => setIsActive(e.target.checked)}
          className="size-4 rounded border-slate-300 dark:border-slate-600"
        />
        حساب کاربری فعال است
      </label>

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
