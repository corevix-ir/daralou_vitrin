"use client";

import { useState } from "react";
import { useRouter, usePathname } from "next/navigation";
import { useAuth } from "@/features/auth/context/auth-context";
import { Badge } from "@/shared/components/badge";
import { roleLabels } from "@/shared/utils/role-labels";

function pageTitle(pathname: string): string {
  if (pathname.startsWith("/devices")) return "کیوسک‌ها";
  if (pathname.startsWith("/vitrine")) return "تنظیم ویترین";
  if (pathname.startsWith("/users")) return "کاربران";
  return "";
}

export function Topbar({ onMenuClick }: { onMenuClick: () => void }) {
  const { user, logout } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  const [loggingOut, setLoggingOut] = useState(false);

  async function handleLogout() {
    setLoggingOut(true);
    await logout();
    router.replace("/login");
  }

  return (
    <header className="flex h-14 shrink-0 items-center justify-between gap-3 border-b border-slate-200 bg-white px-3 sm:px-5 dark:border-slate-800 dark:bg-slate-900">
      <div className="flex min-w-0 items-center gap-2">
        <button
          onClick={onMenuClick}
          aria-label="باز کردن منو"
          className="flex size-8 shrink-0 items-center justify-center rounded-md text-slate-600 hover:bg-slate-100 lg:hidden dark:text-slate-300 dark:hover:bg-slate-800 cursor-pointer"
        >
          <span className="flex flex-col gap-[3px]">
            <span className="h-[1.5px] w-4 bg-current" />
            <span className="h-[1.5px] w-4 bg-current" />
            <span className="h-[1.5px] w-4 bg-current" />
          </span>
        </button>
        <h1 className="truncate text-sm font-semibold text-slate-800 dark:text-slate-100">{pageTitle(pathname)}</h1>
      </div>

      {user && (
        <div className="flex shrink-0 items-center gap-2 sm:gap-3">
          <div className="hidden items-center gap-2 text-[13px] sm:flex">
            <span className="text-slate-700 dark:text-slate-200">{user.name}</span>
          </div>
          <Badge tone="blue">{roleLabels[user.role]}</Badge>
          <button
            onClick={handleLogout}
            disabled={loggingOut}
            className="rounded-md border border-slate-300 px-2.5 py-1.5 text-xs font-medium text-slate-600 hover:bg-slate-50 disabled:opacity-60 dark:border-slate-700 dark:text-slate-300 dark:hover:bg-slate-800 cursor-pointer"
          >
            خروج
          </button>
        </div>
      )}
    </header>
  );
}
