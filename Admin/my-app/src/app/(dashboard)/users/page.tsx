import { RequireRole } from "@/features/auth/components/require-role";
import { UsersScreen } from "@/features/users/screens/users-screen";

export default function UsersPage() {
  return (
    <RequireRole roles={["admin"]} deniedMessage="مدیریت کاربران فقط برای نقش ادمین در دسترس است.">
      <UsersScreen />
    </RequireRole>
  );
}
