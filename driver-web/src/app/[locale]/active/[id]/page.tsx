import { setRequestLocale } from "next-intl/server";

import { OrderDetailClient } from "@/components/orders/order-detail-client";

export default async function OrderDetailPage({
  params,
}: {
  params: Promise<{ locale: string; id: string }>;
}) {
  const { locale, id } = await params;
  setRequestLocale(locale);

  return <OrderDetailClient params={Promise.resolve({ id })} />;
}
