import { resolveMediaUrl } from "@/shared/utils/media-url";
import { Badge } from "@/shared/components/badge";
import { Button } from "@/shared/components/button";
import type { VitrineItem } from "../model/vitrine.types";

const sourceLabel: Record<string, string> = {
  daralouOperator: "لوکال",
  daralouWeb: "اسکرپ‌شده",
};

export function SlotCard({
  position,
  item,
  onPick,
  onClear,
}: {
  position: number;
  item: VitrineItem | null;
  onPick: () => void;
  onClear: () => void;
}) {
  return (
    <div className="flex flex-col overflow-hidden rounded-lg border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900">
      <div className="flex items-center justify-between border-b border-slate-100 px-3 py-1.5 dark:border-slate-800">
        <span className="text-[11px] font-medium text-slate-400 dark:text-slate-500">جایگاه {position}</span>
        {item && <Badge tone={item.source === "daralouOperator" ? "blue" : "amber"}>{sourceLabel[item.source]}</Badge>}
      </div>

      {item ? (
        <div className="flex flex-1 flex-col">
          <div className="aspect-video w-full overflow-hidden bg-slate-100 dark:bg-slate-800">
            {item.content.main_img && (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={resolveMediaUrl(item.content.main_img)} alt="" className="size-full object-cover" />
            )}
          </div>
          <div className="flex flex-1 flex-col gap-2 p-3">
            <p className="line-clamp-2 text-[13px] font-medium text-slate-800 dark:text-slate-100">
              {item.content.title}
            </p>
            <div className="mt-auto flex gap-2">
              <Button size="sm" variant="secondary" className="flex-1" onClick={onPick}>
                تغییر
              </Button>
              <Button size="sm" variant="danger" onClick={onClear}>
                حذف
              </Button>
            </div>
          </div>
        </div>
      ) : (
        <button
          type="button"
          onClick={onPick}
          className="flex flex-1 flex-col items-center justify-center gap-2 border-2 border-dashed border-slate-200 p-4 text-center hover:border-slate-300 hover:bg-slate-50 dark:border-slate-800 dark:hover:border-slate-700 dark:hover:bg-slate-800/40 cursor-pointer"
        >
          <span className="text-xs font-medium text-slate-500 dark:text-slate-400">+ انتخاب محتوا</span>
          <span className="text-[11px] text-slate-400 dark:text-slate-500">
            در صورت خالی ماندن، به‌طور خودکار با آخرین اخبار پر می‌شود
          </span>
        </button>
      )}
    </div>
  );
}
