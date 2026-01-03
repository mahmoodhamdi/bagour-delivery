'use client';

import { useAuthStore } from '@/stores/auth';
import { useOrdersStore } from '@/stores/orders';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
  ShoppingBag,
  DollarSign,
  Clock,
  CheckCircle,
  Star,
  TrendingUp,
} from 'lucide-react';

export default function DashboardPage() {
  const { restaurant } = useAuthStore();
  const { todayOrdersCount, pendingOrdersCount } = useOrdersStore();

  const stats = [
    {
      title: 'طلبات اليوم',
      value: todayOrdersCount.toString(),
      icon: ShoppingBag,
      color: 'text-blue-600',
      bgColor: 'bg-blue-100',
    },
    {
      title: 'الإيرادات اليوم',
      value: '0 ج.م',
      icon: DollarSign,
      color: 'text-green-600',
      bgColor: 'bg-green-100',
    },
    {
      title: 'طلبات معلقة',
      value: pendingOrdersCount.toString(),
      icon: Clock,
      color: 'text-orange-600',
      bgColor: 'bg-orange-100',
    },
    {
      title: 'طلبات مكتملة',
      value: '0',
      icon: CheckCircle,
      color: 'text-emerald-600',
      bgColor: 'bg-emerald-100',
    },
    {
      title: 'التقييم',
      value: restaurant?.rating?.toFixed(1) || '0.0',
      icon: Star,
      color: 'text-yellow-600',
      bgColor: 'bg-yellow-100',
    },
    {
      title: 'إجمالي الطلبات',
      value: restaurant?.totalOrders?.toString() || '0',
      icon: TrendingUp,
      color: 'text-purple-600',
      bgColor: 'bg-purple-100',
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">مرحباً، {restaurant?.name}</h1>
        <p className="text-muted-foreground">
          إليك نظرة عامة على أداء مطعمك اليوم
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {stats.map((stat) => (
          <Card key={stat.title}>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                {stat.title}
              </CardTitle>
              <div className={`rounded-full p-2 ${stat.bgColor}`}>
                <stat.icon className={`h-4 w-4 ${stat.color}`} />
              </div>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stat.value}</div>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>الطلبات الأخيرة</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-center text-muted-foreground py-8">
              لا توجد طلبات حتى الآن
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>الأصناف الأكثر طلباً</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-center text-muted-foreground py-8">
              لا توجد بيانات كافية
            </p>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
