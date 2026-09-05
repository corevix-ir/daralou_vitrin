"use client";

import { useCallback, useState } from "react";
import { Drawer } from "@/shared/components/drawer";
import { Tabs } from "@/shared/components/tabs";
import { ContentPickerList } from "@/features/content/components/content-picker-list";
import { contentApi } from "@/features/content/services/content.api";
import type { ContentSource, ContentSummary } from "@/features/content/model/content.types";

type PickerTab = "local" | "scrap";

export function ContentPickerDrawer({
  open,
  onClose,
  deviceId,
  position,
  onPick,
}: {
  open: boolean;
  onClose: () => void;
  deviceId: number;
  position: number | null;
  onPick: (content: ContentSummary, source: ContentSource) => void;
}) {
  const [tab, setTab] = useState<PickerTab>("local");

  const fetchLocal = useCallback((page: number) => contentApi.local(deviceId, page), [deviceId]);
  const fetchScrap = useCallback((page: number) => contentApi.scrap(page), []);

  return (
    <Drawer open={open} onClose={onClose} title={position ? `انتخاب محتوا برای جایگاه ${position}` : "انتخاب محتوا"}>
      <div className="flex flex-col">
        <div className="border-b border-slate-100 p-3 dark:border-slate-800">
          <Tabs
            value={tab}
            onChange={setTab}
            options={[
              { value: "local", label: "محتوای این دستگاه" },
              { value: "scrap", label: "اخبار سایت" },
            ]}
          />
        </div>

        {tab === "local" ? (
          <ContentPickerList
            fetchPage={fetchLocal}
            onSelect={(content) => onPick(content, "daralouOperator")}
          />
        ) : (
          <ContentPickerList fetchPage={fetchScrap} onSelect={(content) => onPick(content, "daralouWeb")} />
        )}
      </div>
    </Drawer>
  );
}
