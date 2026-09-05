import { cn } from "@/shared/utils/cn";

export function Spinner({ className }: { className?: string }) {
  return (
    <span
      className={cn(
        "inline-block size-5 animate-spin rounded-full border-2 border-slate-300 border-t-slate-600 dark:border-slate-700 dark:border-t-slate-300",
        className
      )}
    />
  );
}

export function FullscreenLoader() {
  return (
    <div className="flex h-full min-h-40 w-full flex-1 items-center justify-center">
      <Spinner className="size-6" />
    </div>
  );
}
