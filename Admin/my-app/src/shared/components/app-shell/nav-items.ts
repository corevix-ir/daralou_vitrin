import type { UserRole } from "@/features/auth/model/auth.types";

export interface NavItem {
  href: string;
  label: string;
  /** Omit to show for every authenticated role. */
  roles?: UserRole[];
}

export const navItems: NavItem[] = [
  // GET /devices is open to operators too now — the backend auto-filters the list to
  // whatever devices were assigned via PUT /auth/users/{id}/devices (admin-panel-api.md §1.1).
  // Device CRUD/commands stay admin-only, gated inside the screen itself.
  { href: "/devices", label: "کیوسک‌ها", roles: ["admin", "operator"] },
  // User management is admin-only (admin-panel-api.md §2).
  { href: "/users", label: "کاربران", roles: ["admin"] },
];
