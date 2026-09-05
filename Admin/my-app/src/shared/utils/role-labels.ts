import type { UserRole } from "@/features/auth/model/auth.types";

export const roleLabels: Record<UserRole, string> = {
  admin: "ادمین",
  operator: "اپراتور",
  user: "کاربر",
  device: "دستگاه",
};
