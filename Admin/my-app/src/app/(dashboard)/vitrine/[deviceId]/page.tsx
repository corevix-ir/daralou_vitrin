import { RequireRole } from "@/features/auth/components/require-role";
import { VitrineEditorScreen } from "@/features/vitrine/screens/vitrine-editor-screen";

export default async function VitrinePage({
  params,
}: {
  params: Promise<{ deviceId: string }>;
}) {
  const { deviceId } = await params;

  return (
    <RequireRole roles={["admin", "operator"]}>
      <VitrineEditorScreen deviceId={Number(deviceId)} />
    </RequireRole>
  );
}
