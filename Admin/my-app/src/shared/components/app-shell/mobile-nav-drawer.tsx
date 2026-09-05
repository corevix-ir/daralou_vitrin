"use client";

import { Drawer } from "@/shared/components/drawer";
import { config } from "@/core/config/config";
import { SidebarNav } from "./sidebar-nav";

export function MobileNavDrawer({ open, onClose }: { open: boolean; onClose: () => void }) {
  return (
    <Drawer open={open} onClose={onClose} title={config.appName}>
      <SidebarNav onNavigate={onClose} showHeader={false} />
    </Drawer>
  );
}
