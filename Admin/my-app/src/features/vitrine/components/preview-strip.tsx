import { resolveMediaUrl } from "@/shared/utils/media-url";
import { Badge } from "@/shared/components/badge";
import type { VitrinePreviewItem } from "../model/vitrine.types";

export function PreviewStrip({ items }: { items: VitrinePreviewItem[] }) {
  const sorted = [...items].sort((a, b) => a.position - b.position);

  return (
    <div className="flex gap-3 overflow-x-auto pb-1">
      {sorted.map((item) => (
        <div
          key={item.position}
          className="w-44 shrink-0 overflow-hidden rounded-lg border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900"
        >
          <div className="aspect-video w-full bg-slate-100 dark:bg-slate-800">
            {item.content.main_img && (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={resolveMediaUrl(item.content.main_img)} alt="" className="size-full object-cover" />
            )}
          </div>
          <div className="flex flex-col gap-1.5 p-2.5">
            <div className="flex items-center justify-between text-[11px] text-slate-400 dark:text-slate-500">
              <span>جایگاه {item.position}</span>
              <Badge tone={item.is_auto ? "neutral" : "green"}>{item.is_auto ? "خودکار" : "دستی"}</Badge>
            </div>
            <p className="line-clamp-2 text-xs font-medium text-slate-800 dark:text-slate-100">
              {item.content.title}
            </p>
          </div>
        </div>
      ))}
    </div>
  );
}
