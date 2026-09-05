import { LoginForm } from "../components/login-form";
import { config } from "@/core/config/config";

export function LoginScreen() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 px-4 dark:bg-slate-950">
      <div className="w-full max-w-sm">
        <div className="mb-6 flex flex-col items-center gap-3">
          <KioskMark />
          <div className="text-center">
            <h1 className="text-base font-semibold text-slate-900 dark:text-slate-100">{config.appName}</h1>
            <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">پنل ادمین شبکه کیوسک‌های سازمانی</p>
          </div>
        </div>

        <div className="rounded-lg border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
          <LoginForm />
        </div>
      </div>
    </div>
  );
}

/** A small flat glyph of a kiosk screen split into showcase slots — no stock art needed. */
function KioskMark() {
  return (
    <div className="grid size-11 grid-cols-2 gap-1 rounded-md border border-slate-300 bg-white p-1.5 dark:border-slate-700 dark:bg-slate-900">
      <span className="col-span-2 rounded-sm bg-slate-800 dark:bg-slate-200" />
      <span className="rounded-sm bg-slate-300 dark:bg-slate-700" />
      <span className="rounded-sm bg-slate-300 dark:bg-slate-700" />
    </div>
  );
}
