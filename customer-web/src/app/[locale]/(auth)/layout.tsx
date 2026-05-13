import type { ReactNode } from "react";

export default function AuthGroupLayout({ children }: { children: ReactNode }) {
  return <div className="min-h-[calc(100vh-4rem)]">{children}</div>;
}
