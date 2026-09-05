"use client";

import { useEffect, useMemo, useState } from "react";
import type { ContentListResponse, ContentSummary } from "../model/content.types";
import { ContentListItem } from "./content-list-item";
import { FullscreenLoader } from "@/shared/components/spinner";
import { EmptyState, ErrorState } from "@/shared/components/empty-state";
import { Button } from "@/shared/components/button";
import { ApiError } from "@/core/http/api-error";

/**
 * Reusable “pick a content to pin” list. The vitrine editor renders one of
 * these per tab (local content / scraped news) inside its picker drawer.
 */
export function ContentPickerList({
  fetchPage,
  onSelect,
  selectedContentId,
}: {
  fetchPage: (page: number) => Promise<ContentListResponse>;
  onSelect: (content: ContentSummary) => void;
  selectedContentId?: number;
}) {
  const [items, setItems] = useState<ContentSummary[]>([]);
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");

  async function loadPage(targetPage: number) {
    const response = await fetchPage(targetPage);
    setItems((current) => (targetPage === 1 ? response.content : [...current, ...response.content]));
    setTotal(response.total);
    setPage(response.page);
  }

  useEffect(() => {
    setLoading(true);
    setError(null);
    loadPage(1)
      .catch((err) => setError(err instanceof ApiError ? err.message : "بارگذاری محتوا ناموفق بود"))
      .finally(() => setLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [fetchPage]);

  async function handleLoadMore() {
    setLoadingMore(true);
    try {
      await loadPage(page + 1);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "بارگذاری محتوا ناموفق بود");
    } finally {
      setLoadingMore(false);
    }
  }

  const filtered = useMemo(() => {
    const query = search.trim().toLowerCase();
    if (!query) return items;
    return items.filter((item) => item.title.toLowerCase().includes(query));
  }, [items, search]);

  if (loading) return <FullscreenLoader />;
  if (error) return <div className="p-4"><ErrorState message={error} /></div>;

  return (
    <div className="flex flex-1 flex-col">
      <div className="border-b border-slate-100 p-3 dark:border-slate-800">
        <input
          value={search}
          onChange={(event) => setSearch(event.target.value)}
          placeholder="جستجو در موارد بارگذاری‌شده..."
          className="h-9 w-full rounded-md border border-slate-300 bg-white px-3 text-[13px] outline-none focus:border-slate-500 dark:border-slate-700 dark:bg-slate-950 dark:focus:border-slate-500"
        />
      </div>

      {filtered.length === 0 ? (
        <div className="p-4">
          <EmptyState title="موردی یافت نشد" />
        </div>
      ) : (
        <div className="flex-1">
          {filtered.map((item) => (
            <ContentListItem
              key={item.id}
              content={item}
              onClick={() => onSelect(item)}
              trailing={
                selectedContentId === item.id ? (
                  <span className="shrink-0 text-xs font-medium text-emerald-600 dark:text-emerald-400">انتخاب‌شده</span>
                ) : undefined
              }
            />
          ))}
        </div>
      )}

      {items.length < total && (
        <div className="border-t border-slate-100 p-3 dark:border-slate-800">
          <Button size="sm" className="w-full" loading={loadingMore} onClick={handleLoadMore}>
            بارگذاری بیشتر ({items.length} از {total})
          </Button>
        </div>
      )}
    </div>
  );
}
