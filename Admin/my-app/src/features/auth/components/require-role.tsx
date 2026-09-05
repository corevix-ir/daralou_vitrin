"use client";

import { useAuth } from "../context/auth-context";
import type { UserRole } from "../model/auth.types";
import { EmptyState } from "@/shared/components/empty-state";

export function RequireRole({
  roles,
  children,
  deniedMessage = "این بخش برای نقش شما در دسترس نیست.",
}: {
  roles: UserRole[];
  children: React.ReactNode;
  deniedMessage?: string;
}) {
  const { user } = useAuth();

  if (!user || !roles.includes(user.role)) {
    return (
      <div className="p-6">
        <EmptyState title="دسترسی محدود" description={deniedMessage} />
      </div>
    );
  }

  return <>{children}</>;
}
