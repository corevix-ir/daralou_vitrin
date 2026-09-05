import { HTMLAttributes } from "react";
import { cn } from "@/shared/utils/cn";

type Tone = "neutral" | "green" | "amber" | "red" | "blue";

const toneClasses: Record<Tone, string> = {
  neutral: "bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300",
  green: "bg-emerald-50 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-400",
  amber: "bg-amber-50 text-amber-700 dark:bg-amber-950 dark:text-amber-400",
  red: "bg-red-50 text-red-700 dark:bg-red-950 dark:text-red-400",
  blue: "bg-blue-50 text-blue-700 dark:bg-blue-950 dark:text-blue-400",
};

interface BadgeProps extends HTMLAttributes<HTMLSpanElement> {
  tone?: Tone;
  dot?: boolean;
}

export function Badge({ tone = "neutral", dot, className, children, ...rest }: BadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 rounded px-1.5 py-0.5 text-xs font-medium",
        toneClasses[tone],
        className
      )}
      {...rest}
    >
      {dot && <span className="size-1.5 rounded-full bg-current" />}
      {children}
    </span>
  );
}
