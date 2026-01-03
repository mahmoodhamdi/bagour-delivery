'use client';

import { useAuthStore } from '@/stores/auth';
import { useDashboardStore } from '@/stores/dashboard';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
  Users,
  Store,
  Truck,
  ShoppingBag,
  DollarSign,
  TrendingUp,
  Clock,
  AlertCircle,
} from 'lucide-react';

export default function DashboardPage() {
  const { admin } = useAuthStore();
  const { stats } = useDashboardStore();

  const statCards = [
    {
      title: 'إجمالي المستخدمين',
      value: stats?.totalUsers?.toString() || '0',
      icon: Users,
      color: 'text-blue-600',
      bgColor: 'bg-blue-100',
    },
    {
      title: 'إجمالي المطاعم',
      value: stats?.totalRestaurants?.toString() || '0',
      icon: Store,
      color: 'text-orange-600',
      bgColor: 'bg-orange-100',
    },
    {
      title: 'إجمالي السائقين',
      value: stats?.totalDrivers?.toString() || '0',
      icon: Truck,
      color: 'text-green-600',
      bgColor: 'bg-green-100',
    },
    {
      title: 'إجمالي الطلبات',
      value: stats?.totalOrders?.toString() || '0',
      icon: ShoppingBag,
      color: 'text-purple-600',
      bgColor: 'bg-purple-100',
    },
    {
      title: 'طلبات اليوم',
      value: stats?.todayOrders?.toString() || '0',
      icon: Clock,
      color: 'text-teal-600',
      bgColor: 'bg-teal-100',
    },
    {
      title: 'إيرادات اليوم',
      value: `${stats?.todayRevenue || 0} ج.م`,
      icon: DollarSign,
      color: 'text-emerald-600',
      bgColor: 'bg-emerald-100',
    },
    {
      title: 'مطاعم قيد المراجعة',
      value: stats?.pendingRestaurants?.toString() || '0',
      icon: AlertCircle,
      color: 'text-yellow-600',
      bgColor: 'bg-yellow-100',
    },
    {
      title: 'الإيرادات الشهرية',
      value: `${stats?.monthlyRevenue || 0} ج.م`,
      icon: TrendingUp,
      color: 'text-indigo-600',
      bgColor: 'bg-indigo-100',
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">مرحباً، {admin?.name}</h1>
        <p className="text-muted-foreground">
          إليك نظرة عامة على أداء المنصة
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {statCards.map((stat) => (
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
            <CardTitle>أفضل المطاعم</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-center text-muted-foreground py-8">
              لا توجد بيانات كافية
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>طلبات المراجعة</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex items-center justify-between p-3 bg-muted rounded-lg">
                <span className="text-sm">مطاعم جديدة</span>
                <span className="font-bold text-orange-600">
                  {stats?.pendingRestaurants || 0}
                </span>
              </div>
              <div className="flex items-center justify-between p-3 bg-muted rounded-lg">
                <span className="text-sm">سائقين جدد</span>
                <span className="font-bold text-blue-600">
                  {stats?.pendingDrivers || 0}
                </span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>الطلبات النشطة</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-center py-8">
              <div className="text-center">
                <div className="text-4xl font-bold text-primary">
                  {stats?.activeOrders || 0}
                </div>
                <p className="text-sm text-muted-foreground mt-2">
                  طلب نشط الآن
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
