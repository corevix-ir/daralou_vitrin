"use client";

import { useEffect, useMemo, useState } from "react";
import { usersApi } from "../services/users.api";
import type { ManagedUser } from "../model/user.types";
import { UserCreateForm } from "../components/user-create-form";
import { UserEditForm } from "../components/user-edit-form";
import { useAuth } from "@/features/auth/context/auth-context";
import { roleLabels } from "@/shared/utils/role-labels";
import { ApiError } from "@/core/http/api-error";
import { FullscreenLoader } from "@/shared/components/spinner";
import { EmptyState, ErrorState } from "@/shared/components/empty-state";
import { Button } from "@/shared/components/button";
import { Badge } from "@/shared/components/badge";
import { Drawer } from "@/shared/components/drawer";
import { ConfirmDialog } from "@/shared/components/confirm-dialog";
import { useToast } from "@/shared/components/toast/toast-context";

export function UsersScreen() {
  const { user: currentUser } = useAuth();
  const toast = useToast();

  const [users, setUsers] = useState<ManagedUser[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");

  const [createOpen, setCreateOpen] = useState(false);
  const [editingUser, setEditingUser] = useState<ManagedUser | null>(null);
  const [deletingUser, setDeletingUser] = useState<ManagedUser | null>(null);
  const [deleting, setDeleting] = useState(false);

  async function load() {
    setError(null);
    setUsers(null);
    try {
      setUsers(await usersApi.list());
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "دریافت لیست کاربران ناموفق بود");
    }
  }

  useEffect(() => {
    load();
  }, []);

  const filtered = useMemo(() => {
    if (!users) return [];
    const query = search.trim().toLowerCase();
    if (!query) return users;
    return users.filter((u) => [u.username, u.name].join(" ").toLowerCase().includes(query));
  }, [users, search]);

  async function handleDelete() {
    if (!deletingUser) return;
    setDeleting(true);
    try {
      await usersApi.remove(deletingUser.id);
      toast.show("کاربر حذف شد", "success");
      setDeletingUser(null);
      load();
    } catch (err) {
      toast.show(err instanceof ApiError ? err.message : "حذف کاربر ناموفق بود", "error");
    } finally {
      setDeleting(false);
    }
  }

  if (users === null && !error) return <FullscreenLoader />;

  return (
    <div className="flex flex-col gap-4 p-4 sm:p-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <input
          value={search}
          onChange={(event) => setSearch(event.target.value)}
          placeholder="جستجو بر اساس نام یا نام کاربری..."
          className="h-9 w-full rounded-md border border-slate-300 bg-white px-3 text-[13px] outline-none focus:border-slate-500 sm:w-72 dark:border-slate-700 dark:bg-slate-900 dark:focus:border-slate-500"
        />
        <div className="flex items-center justify-between gap-3 sm:justify-end">
          {users && <span className="text-xs text-slate-500 dark:text-slate-400">{users.length} کاربر</span>}
          <Button variant="primary" size="sm" onClick={() => setCreateOpen(true)}>
            + افزودن کاربر
          </Button>
        </div>
      </div>

      {error && <ErrorState message={error} onRetry={load} />}

      {users && filtered.length === 0 && !error && (
        <EmptyState title={users.length === 0 ? "هنوز کاربری ثبت نشده است" : "موردی با این جستجو یافت نشد"} />
      )}

      {filtered.length > 0 && (
        <>
          {/* Table — sm and up */}
          <div className="hidden overflow-x-auto rounded-lg border border-slate-200 sm:block dark:border-slate-800">
            <table className="w-full min-w-max text-start text-[13px]">
              <thead className="border-b border-slate-200 bg-slate-50 text-slate-500 dark:border-slate-800 dark:bg-slate-900/60 dark:text-slate-400">
                <tr>
                  <th className="px-4 py-2.5 text-start font-medium">نام کاربری</th>
                  <th className="px-4 py-2.5 text-start font-medium">نام کامل</th>
                  <th className="px-4 py-2.5 text-start font-medium">نقش</th>
                  <th className="px-4 py-2.5 text-start font-medium">وضعیت</th>
                  <th className="px-4 py-2.5" />
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {filtered.map((u) => (
                  <tr key={u.id} className="bg-white dark:bg-slate-900">
                    <td className="px-4 py-2.5 font-mono text-xs text-slate-600 dark:text-slate-300">{u.username}</td>
                    <td className="px-4 py-2.5 font-medium text-slate-800 dark:text-slate-100">{u.name}</td>
                    <td className="px-4 py-2.5">
                      <Badge tone="blue">{roleLabels[u.role]}</Badge>
                    </td>
                    <td className="px-4 py-2.5">
                      <Badge tone={u.status ? "green" : "neutral"} dot>
                        {u.status ? "فعال" : "غیرفعال"}
                      </Badge>
                    </td>
                    <td className="px-4 py-2.5">
                      <div className="flex flex-wrap justify-end gap-1.5">
                        <Button size="sm" variant="secondary" onClick={() => setEditingUser(u)}>
                          ویرایش
                        </Button>
                        <Button
                          size="sm"
                          variant="danger"
                          disabled={u.id === currentUser?.id}
                          onClick={() => setDeletingUser(u)}
                        >
                          حذف
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Cards — below sm */}
          <div className="flex flex-col gap-3 sm:hidden">
            {filtered.map((u) => (
              <div
                key={u.id}
                className="rounded-lg border border-slate-200 bg-white p-3.5 dark:border-slate-800 dark:bg-slate-900"
              >
                <div className="flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <p className="truncate text-sm font-semibold text-slate-800 dark:text-slate-100">{u.name}</p>
                    <p className="truncate font-mono text-xs text-slate-500 dark:text-slate-400">{u.username}</p>
                  </div>
                  <Badge tone={u.status ? "green" : "neutral"} dot>
                    {u.status ? "فعال" : "غیرفعال"}
                  </Badge>
                </div>
                <div className="mt-2">
                  <Badge tone="blue">{roleLabels[u.role]}</Badge>
                </div>
                <div className="mt-3 flex flex-wrap gap-1.5">
                  <Button size="sm" className="flex-1" variant="secondary" onClick={() => setEditingUser(u)}>
                    ویرایش
                  </Button>
                  <Button
                    size="sm"
                    variant="danger"
                    disabled={u.id === currentUser?.id}
                    onClick={() => setDeletingUser(u)}
                  >
                    حذف
                  </Button>
                </div>
              </div>
            ))}
          </div>
        </>
      )}

      <Drawer open={createOpen} onClose={() => setCreateOpen(false)} title="افزودن کاربر جدید">
        <UserCreateForm
          onSuccess={() => {
            setCreateOpen(false);
            toast.show("کاربر با موفقیت ساخته شد", "success");
            load();
          }}
        />
      </Drawer>

      <Drawer open={editingUser !== null} onClose={() => setEditingUser(null)} title="ویرایش کاربر">
        {editingUser && (
          <UserEditForm
            user={editingUser}
            onSuccess={() => {
              setEditingUser(null);
              toast.show("تغییرات ذخیره شد", "success");
              load();
            }}
          />
        )}
      </Drawer>

      <ConfirmDialog
        open={deletingUser !== null}
        title="حذف کاربر"
        description={deletingUser ? `آیا از حذف «${deletingUser.name}» مطمئن هستید؟ این عملیات قابل بازگشت نیست.` : undefined}
        confirmLabel="حذف"
        danger
        loading={deleting}
        onConfirm={handleDelete}
        onCancel={() => setDeletingUser(null)}
      />
    </div>
  );
}
