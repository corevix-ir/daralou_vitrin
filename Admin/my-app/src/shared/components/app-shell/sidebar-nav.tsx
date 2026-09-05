"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/shared/utils/cn";
import { useAuth } from "@/features/auth/context/auth-context";
import { config } from "@/core/config/config";
import { navItems } from "./nav-items";

/** Shared nav content — rendered as a static aside on desktop and inside a Drawer on mobile. */
export function SidebarNav({
  onNavigate,
  showHeader = true,
}: {
  onNavigate?: () => void;
  showHeader?: boolean;
}) {
  const pathname = usePathname();
  const { user } = useAuth();

  const visibleItems = navItems.filter((item) => !item.roles || (user && item.roles.includes(user.role)));

  return (
    <div className="flex h-full flex-col">
      {showHeader && (
        <div className="flex h-14 shrink-0 items-center gap-2 border-b border-slate-200 px-4 dark:border-slate-800">
          <span className="grid size-6 grid-cols-2 gap-0.5 rounded border border-slate-300 p-1 dark:border-slate-600">
            <span className="col-span-2 rounded-[1px] bg-slate-800 dark:bg-slate-200" />
            <span className="rounded-[1px] bg-slate-300 dark:bg-slate-600" />
            <span className="rounded-[1px] bg-slate-300 dark:bg-slate-600" />
          </span>
          <span className="truncate text-[13px] font-semibold text-slate-800 dark:text-slate-100">
            {config.appName}
          </span>
        </div>
      )}

      <nav className="flex flex-1 flex-col gap-0.5 p-2">
        {visibleItems.map((item) => {
          const active = pathname === item.href || pathname.startsWith(`${item.href}/`);
          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={onNavigate}
              className={cn(
                "rounded-md px-3 py-2 text-[13px] font-medium transition-colors",
                active
                  ? "bg-slate-100 text-slate-900 dark:bg-slate-800 dark:text-slate-100"
                  : "text-slate-600 hover:bg-slate-50 dark:text-slate-400 dark:hover:bg-slate-800/60"
              )}
            >
              {item.label}
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
