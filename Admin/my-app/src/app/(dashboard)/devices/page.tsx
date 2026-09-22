import { RequireRole } from "@/features/auth/components/require-role";
import { DevicesScreen } from "@/features/devices/screens/devices-screen";

export default function DevicesPage() {
  return (
    <RequireRole roles={["admin", "operator"]}>
      <DevicesScreen />
    </RequireRole>
  );
}
