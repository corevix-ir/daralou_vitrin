import type { Metadata } from "next";
import "@fontsource/vazirmatn/400.css";
import "@fontsource/vazirmatn/500.css";
import "@fontsource/vazirmatn/600.css";
import "@fontsource/vazirmatn/700.css";
import "./globals.css";
import { AuthProvider } from "@/features/auth/context/auth-context";
import { ToastProvider } from "@/shared/components/toast/toast-context";
import { config } from "@/core/config/config";

export const metadata: Metadata = {
  title: config.appName,
  description: "پنل ادمین شبکه کیوسک‌های سازمانی",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="fa" dir="rtl" className="h-full antialiased">
      <body className="min-h-full flex flex-col">
        <ToastProvider>
          <AuthProvider>{children}</AuthProvider>
        </ToastProvider>
      </body>
    </html>
  );
}
