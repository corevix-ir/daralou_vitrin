import type { UserRole } from "@/features/auth/model/auth.types";

export interface NavItem {
  href: string;
  label: string;
  /** Omit to show for every authenticated role. */
  roles?: UserRole[];
}

export const navItems: NavItem[] = [
  // Device CRUD + listing is admin-only on the backend (admin-panel-api.md §1, §3) —
  // operators have no entry point into the device list, only direct vitrine access.
  { href: "/devices", label: "کیوسک‌ها", roles: ["admin"] },
  // User management is admin-only (admin-panel-api.md §2).
  { href: "/users", label: "کاربران", roles: ["admin"] },
];
