"use client";

import { LogOut, User as UserIcon } from "lucide-react";
import { useTranslations } from "next-intl";
import { useTransition } from "react";
import { toast } from "sonner";

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Link, useRouter } from "@/i18n/navigation";
import { useApi } from "@/lib/api-context";
import { useAuthStore } from "@/stores/auth-store";

function initialsFromName(name: string): string {
  const parts = name.trim().split(/\s+/).slice(0, 2);
  return (
    parts
      .map((p) => p[0])
      .join("")
      .toUpperCase() || "ك"
  );
}

/**
 * Header right-side widget. Hidden until the auth store hydrates so the
 * header never flashes anonymous → signed-in on cold reload.
 */
export function AuthSlot() {
  const t = useTranslations();
  const router = useRouter();
  const api = useApi();
  const user = useAuthStore((s) => s.user);
  const hydrated = useAuthStore((s) => s.hydrated);
  const clear = useAuthStore((s) => s.clear);
  const [, startTransition] = useTransition();

  if (!hydrated) {
    return <div className="h-10 w-24 animate-pulse rounded-full bg-muted" aria-hidden />;
  }

  if (!user) {
    return (
      <Button asChild size="sm" data-testid="auth-sign-in">
        <Link href="/login">{t("Auth.actions.signIn")}</Link>
      </Button>
    );
  }

  const handleSignOut = async () => {
    try {
      await api.auth.logout();
    } catch {
      // Server may return 401 if our token already expired — clear locally regardless.
    }
    clear();
    toast.success(t("Auth.toasts.signedOut"));
    startTransition(() => {
      router.push("/login");
    });
  };

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button
          type="button"
          aria-label={t("Auth.actions.openAccountMenu")}
          className="rounded-full focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
          data-testid="auth-avatar"
        >
          <Avatar>
            {user.avatar ? <AvatarImage src={user.avatar} alt="" /> : null}
            <AvatarFallback>{initialsFromName(user.name)}</AvatarFallback>
          </Avatar>
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="min-w-56">
        <DropdownMenuLabel className="flex flex-col">
          <span className="font-semibold">{user.name}</span>
          <span className="text-xs font-normal text-muted-foreground">{user.email}</span>
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        <DropdownMenuItem asChild>
          <Link href="/profile">
            <UserIcon aria-hidden />
            {t("Nav.profile")}
          </Link>
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem
          onClick={() => void handleSignOut()}
          data-testid="auth-sign-out"
          className="text-destructive focus:text-destructive"
        >
          <LogOut aria-hidden />
          {t("Auth.actions.signOut")}
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
