import { AuthGate } from "@/features/auth/components/auth-gate";

export default function Home() {
  return <AuthGate />;
}
