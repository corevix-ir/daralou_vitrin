import { RequireAuth } from "@/features/auth/components/require-auth";
import { AppShell } from "@/shared/components/app-shell/app-shell";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <RequireAuth>
      <AppShell>{children}</AppShell>
    </RequireAuth>
  );
}
