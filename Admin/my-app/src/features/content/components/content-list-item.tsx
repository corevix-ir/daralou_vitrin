import { resolveMediaUrl } from "@/shared/utils/media-url";
import { formatDate } from "@/shared/utils/format";
import type { ContentSummary } from "../model/content.types";

export function ContentListItem({
  content,
  onClick,
  trailing,
}: {
  content: ContentSummary;
  onClick?: () => void;
  trailing?: React.ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="flex w-full items-center gap-3 border-b border-slate-100 px-4 py-3 text-start hover:bg-slate-50 dark:border-slate-800 dark:hover:bg-slate-800/60 cursor-pointer"
    >
      <div className="size-12 shrink-0 overflow-hidden rounded-md bg-slate-100 dark:bg-slate-800">
        {content.main_img && (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={resolveMediaUrl(content.main_img)}
            alt=""
            className="size-full object-cover"
            loading="lazy"
          />
        )}
      </div>
      <div className="min-w-0 flex-1">
        <p className="truncate text-[13px] font-medium text-slate-800 dark:text-slate-100">{content.title}</p>
        {content.summary && (
          <p className="truncate text-xs text-slate-500 dark:text-slate-400">{content.summary}</p>
        )}
        <p className="mt-0.5 text-[11px] text-slate-400 dark:text-slate-500">{formatDate(content.created_at)}</p>
      </div>
      {trailing}
    </button>
  );
}
