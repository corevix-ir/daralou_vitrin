import { SidebarNav } from "./sidebar-nav";

/** Static sidebar — only rendered from `lg` up. Below that, `MobileNavDrawer` takes over. */
export function Sidebar() {
  return (
    <aside className="hidden w-56 shrink-0 border-e border-slate-200 bg-white lg:flex lg:h-screen dark:border-slate-800 dark:bg-slate-900">
      <SidebarNav />
    </aside>
  );
}
