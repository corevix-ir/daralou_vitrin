"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "../context/auth-context";
import { FullscreenLoader } from "@/shared/components/spinner";

/** Root-route gate: sends the visitor to the dashboard or the login screen. */
export function AuthGate() {
  const { status } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (status === "authenticated") router.replace("/devices");
    if (status === "unauthenticated") router.replace("/login");
  }, [status, router]);

  return <FullscreenLoader />;
}
