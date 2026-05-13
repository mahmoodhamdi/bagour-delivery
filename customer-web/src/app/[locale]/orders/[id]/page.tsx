"use client";

import { use } from "react";
import { useTranslations } from "next-intl";

import { OrderDetailClient } from "@/components/orders/order-detail-client";
import { ProtectedRoute } from "@/components/protected-route";
import { Link } from "@/i18n/navigation";

export default function OrderDetailPage({
  params,
}: {
  params: Promise<{ id: string; locale: string }>;
}) {
  const { id } = use(params);
  const t = useTranslations();

  return (
    <ProtectedRoute>
      <main
        id="main"
        className="container mx-auto max-w-5xl px-4 py-8 md:py-12"
        data-testid="order-detail-page"
      >
        <nav aria-label="breadcrumb" className="mb-4 text-sm text-muted-foreground">
          <Link href="/orders" className="hover:underline">
            {t("Orders.title")}
          </Link>
          <span aria-hidden> / </span>
          <span aria-current="page">{t("Orders.tracking")}</span>
        </nav>
        <OrderDetailClient orderId={id} />
      </main>
    </ProtectedRoute>
  );
}
