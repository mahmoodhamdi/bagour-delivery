"use client";

import {
  Loader2,
  Mail,
  MapPin,
  Phone,
  ShieldCheck,
  Sparkles,
  ChevronRight,
  KeyRound,
} from "lucide-react";
import { useTranslations } from "next-intl";

import { Link } from "@/i18n/navigation";
import { useCustomer } from "@/lib/hooks/use-customer";
import { useAuthStore } from "@/stores/auth-store";

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";

function initials(name: string): string {
  const parts = name.trim().split(/\s+/).slice(0, 2);
  return (
    parts
      .map((p) => p[0])
      .join("")
      .toUpperCase() || "ب"
  );
}

export function ProfileSummary() {
  const t = useTranslations();
  const user = useAuthStore((s) => s.user);
  const { data: customer, isLoading } = useCustomer();

  if (!user) return null;

  return (
    <div className="space-y-6">
      <header className="flex items-center gap-4">
        <Avatar className="size-16">
          {user.avatar ? <AvatarImage src={user.avatar} alt="" /> : null}
          <AvatarFallback className="text-lg">{initials(user.name)}</AvatarFallback>
        </Avatar>
        <div className="flex-1 space-y-1">
          <h2 className="text-2xl font-bold">{user.name}</h2>
          <p className="text-sm text-muted-foreground">{user.email}</p>
        </div>
        <Button asChild variant="outline" size="sm">
          <Link href="/profile/edit">{t("Profile.editProfile")}</Link>
        </Button>
      </header>

      <Separator />

      <dl className="grid grid-cols-1 gap-3 md:grid-cols-2" data-testid="profile-details">
        <DetailRow icon={<Mail aria-hidden className="size-5" />} label={t("Auth.fields.email")}>
          {user.email}
        </DetailRow>
        <DetailRow icon={<Phone aria-hidden className="size-5" />} label={t("Auth.fields.phone")}>
          {user.phone}
        </DetailRow>
        <DetailRow
          icon={<ShieldCheck aria-hidden className="size-5" />}
          label={t("Profile.emailVerified")}
        >
          {user.isEmailVerified ? t("Profile.yes") : t("Profile.no")}
        </DetailRow>
        <DetailRow
          icon={<Sparkles aria-hidden className="size-5" />}
          label={t("Profile.loyaltyPoints")}
        >
          {isLoading ? <Loader2 className="size-4 animate-spin" /> : (customer?.loyaltyPoints ?? 0)}
        </DetailRow>
      </dl>

      <Separator />

      <nav aria-label={t("Profile.actions")} className="grid gap-3">
        <ActionLink
          href="/profile/addresses"
          icon={<MapPin aria-hidden className="size-5" />}
          label={t("Profile.addresses")}
          description={t("Profile.addressesDesc")}
          testId="profile-addresses-link"
        />
        <ActionLink
          href="/profile/change-password"
          icon={<KeyRound aria-hidden className="size-5" />}
          label={t("Profile.changePassword")}
          description={t("Profile.changePasswordDesc")}
          testId="profile-change-password-link"
        />
      </nav>
    </div>
  );
}

function DetailRow({
  icon,
  label,
  children,
}: {
  icon: React.ReactNode;
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex items-center gap-3 rounded-xl border bg-card p-4">
      <div className="text-muted-foreground">{icon}</div>
      <div className="min-w-0 flex-1">
        <dt className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
          {label}
        </dt>
        <dd className="truncate text-sm font-semibold">{children}</dd>
      </div>
    </div>
  );
}

function ActionLink({
  href,
  icon,
  label,
  description,
  testId,
}: {
  href: "/profile/addresses" | "/profile/change-password";
  icon: React.ReactNode;
  label: string;
  description: string;
  testId?: string;
}) {
  return (
    <Link
      href={href}
      data-testid={testId}
      className="group flex items-center gap-4 rounded-2xl border bg-card p-4 transition-colors hover:bg-accent/40 focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2"
    >
      <div className="rounded-xl bg-accent/40 p-3 text-primary">{icon}</div>
      <div className="flex-1">
        <p className="font-semibold">{label}</p>
        <p className="text-sm text-muted-foreground">{description}</p>
      </div>
      <ChevronRight
        aria-hidden
        className="size-5 shrink-0 text-muted-foreground transition-transform group-hover:translate-x-0.5 rtl:rotate-180 rtl:group-hover:-translate-x-0.5"
      />
    </Link>
  );
}
