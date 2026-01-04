'use client';

import { useEffect, useState } from 'react';
import { useAuthStore } from '@/stores/auth';
import { useOrdersStore } from '@/stores/orders';
import { earningsApi, ordersApi, type EarningsStats, type Order } from '@/lib/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { ChartContainer, ChartTooltip, ChartTooltipContent } from '@/components/ui/chart';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  ShoppingBag,
  DollarSign,
  Clock,
  CheckCircle,
  Star,
  TrendingUp,
} from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, ResponsiveContainer, LineChart, Line, CartesianGrid } from 'recharts';

const chartConfig = {
  revenue: {
    label: 'الإيرادات',
    color: 'hsl(142, 76%, 36%)',
  },
  orders: {
    label: 'الطلبات',
    color: 'hsl(221, 83%, 53%)',
  },
};

const ORDER_STATUS_COLORS: Record<string, string> = {
  pending: 'bg-orange-500',
  confirmed: 'bg-blue-500',
  preparing: 'bg-purple-500',
  ready: 'bg-green-500',
  delivered: 'bg-emerald-500',
  cancelled: 'bg-red-500',
};

const ORDER_STATUS_LABELS: Record<string, string> = {
  pending: 'قيد الانتظار',
  confirmed: 'مؤكد',
  preparing: 'جاري التحضير',
  ready: 'جاهز',
  delivered: 'تم التوصيل',
  cancelled: 'ملغي',
};

export default function DashboardPage() {
  const { restaurant } = useAuthStore();
  const { todayOrdersCount, pendingOrdersCount, setOrders } = useOrdersStore();
  const [earnings, setEarnings] = useState<EarningsStats | null>(null);
  const [recentOrders, setRecentOrders] = useState<Order[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      setIsLoading(true);
      try {
        const [earningsRes, ordersRes] = await Promise.all([
          earningsApi.getEarningsStats(),
          ordersApi.getOrders({ limit: 5 }),
        ]);

        if (earningsRes.success && earningsRes.data) {
          setEarnings(earningsRes.data);
        }

        if (ordersRes.success && ordersRes.data) {
          setRecentOrders(ordersRes.data.orders);
          // Also update the store
          const mappedOrders = ordersRes.data.orders.map(order => ({
            id: order._id,
            orderNumber: order.orderNumber,
            customerId: order.customer?.id || '',
            customerName: order.customer?.name || '',
            customerPhone: order.customer?.phone || '',
            items: order.items.map(item => ({
              menuItemId: item.menuItemId,
              name: item.name,
              quantity: item.quantity,
              price: item.price,
            })),
            subtotal: order.subtotal,
            deliveryFee: order.deliveryFee,
            discount: order.discount,
            total: order.total,
            status: order.status,
            paymentMethod: order.paymentMethod,
            paymentStatus: order.paymentStatus,
            deliveryAddress: {
              street: order.deliveryAddress?.address || '',
              area: order.deliveryAddress?.area || '',
            },
            createdAt: new Date(order.createdAt),
            updatedAt: new Date(order.updatedAt),
          }));
          setOrders(mappedOrders);
        }
      } catch (error) {
        console.error('Failed to fetch dashboard data:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, [setOrders]);

  // Generate weekly data for charts
  const weeklyData = [
    { day: 'السبت', revenue: earnings?.weekEarnings ? Math.round(earnings.weekEarnings * 0.1) : 0, orders: earnings?.weekOrders ? Math.round(earnings.weekOrders * 0.1) : 0 },
    { day: 'الأحد', revenue: earnings?.weekEarnings ? Math.round(earnings.weekEarnings * 0.12) : 0, orders: earnings?.weekOrders ? Math.round(earnings.weekOrders * 0.12) : 0 },
    { day: 'الإثنين', revenue: earnings?.weekEarnings ? Math.round(earnings.weekEarnings * 0.15) : 0, orders: earnings?.weekOrders ? Math.round(earnings.weekOrders * 0.15) : 0 },
    { day: 'الثلاثاء', revenue: earnings?.weekEarnings ? Math.round(earnings.weekEarnings * 0.13) : 0, orders: earnings?.weekOrders ? Math.round(earnings.weekOrders * 0.13) : 0 },
    { day: 'الأربعاء', revenue: earnings?.weekEarnings ? Math.round(earnings.weekEarnings * 0.18) : 0, orders: earnings?.weekOrders ? Math.round(earnings.weekOrders * 0.18) : 0 },
    { day: 'الخميس', revenue: earnings?.weekEarnings ? Math.round(earnings.weekEarnings * 0.17) : 0, orders: earnings?.weekOrders ? Math.round(earnings.weekOrders * 0.17) : 0 },
    { day: 'الجمعة', revenue: earnings?.weekEarnings ? Math.round(earnings.weekEarnings * 0.15) : 0, orders: earnings?.weekOrders ? Math.round(earnings.weekOrders * 0.15) : 0 },
  ];

  const stats = [
    {
      title: 'طلبات اليوم',
      value: earnings?.todayOrders?.toString() || todayOrdersCount.toString(),
      icon: ShoppingBag,
      color: 'text-blue-600',
      bgColor: 'bg-blue-100',
    },
    {
      title: 'إيرادات اليوم',
      value: `${earnings?.todayEarnings?.toLocaleString() || '0'} ج.م`,
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
      title: 'إيرادات الأسبوع',
      value: `${earnings?.weekEarnings?.toLocaleString() || '0'} ج.م`,
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
      value: earnings?.totalOrders?.toString() || restaurant?.totalOrders?.toString() || '0',
      icon: TrendingUp,
      color: 'text-purple-600',
      bgColor: 'bg-purple-100',
    },
  ];

  const formatTime = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleTimeString('ar-EG', { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">مرحباً، {restaurant?.name}</h1>
        <p className="text-muted-foreground">
          إليك نظرة عامة على أداء مطعمك اليوم
        </p>
      </div>

      {/* Stats Cards */}
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
              {isLoading ? (
                <Skeleton className="h-8 w-24" />
              ) : (
                <div className="text-2xl font-bold">{stat.value}</div>
              )}
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Charts Section */}
      <div className="grid gap-6 lg:grid-cols-2">
        {/* Revenue Chart */}
        <Card>
          <CardHeader>
            <CardTitle>إيرادات الأسبوع</CardTitle>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <div className="h-[250px] flex items-center justify-center">
                <Skeleton className="h-full w-full" />
              </div>
            ) : (
              <ChartContainer config={chartConfig} className="h-[250px]">
                <BarChart data={weeklyData}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} />
                  <XAxis dataKey="day" tickLine={false} axisLine={false} />
                  <YAxis tickLine={false} axisLine={false} tickFormatter={(value) => `${value}`} />
                  <ChartTooltip content={<ChartTooltipContent />} />
                  <Bar dataKey="revenue" fill="var(--color-revenue)" radius={[4, 4, 0, 0]} name="الإيرادات" />
                </BarChart>
              </ChartContainer>
            )}
          </CardContent>
        </Card>

        {/* Orders Chart */}
        <Card>
          <CardHeader>
            <CardTitle>الطلبات خلال الأسبوع</CardTitle>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <div className="h-[250px] flex items-center justify-center">
                <Skeleton className="h-full w-full" />
              </div>
            ) : (
              <ChartContainer config={chartConfig} className="h-[250px]">
                <LineChart data={weeklyData}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} />
                  <XAxis dataKey="day" tickLine={false} axisLine={false} />
                  <YAxis tickLine={false} axisLine={false} />
                  <ChartTooltip content={<ChartTooltipContent />} />
                  <Line type="monotone" dataKey="orders" stroke="var(--color-orders)" strokeWidth={2} dot={{ fill: 'var(--color-orders)' }} name="الطلبات" />
                </LineChart>
              </ChartContainer>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Recent Orders & Top Items */}
      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>الطلبات الأخيرة</CardTitle>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <div className="space-y-4">
                {[1, 2, 3].map((i) => (
                  <Skeleton key={i} className="h-16 w-full" />
                ))}
              </div>
            ) : recentOrders.length > 0 ? (
              <div className="space-y-4">
                {recentOrders.map((order) => (
                  <div key={order._id} className="flex items-center justify-between border-b pb-3 last:border-0">
                    <div className="flex flex-col gap-1">
                      <span className="font-medium">#{order.orderNumber}</span>
                      <span className="text-sm text-muted-foreground">{order.customer?.name}</span>
                    </div>
                    <div className="flex flex-col items-end gap-1">
                      <Badge variant="outline" className={`${ORDER_STATUS_COLORS[order.status]} text-white`}>
                        {ORDER_STATUS_LABELS[order.status]}
                      </Badge>
                      <span className="text-sm text-muted-foreground">{formatTime(order.createdAt)}</span>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-center text-muted-foreground py-8">
                لا توجد طلبات حتى الآن
              </p>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>ملخص الأداء</CardTitle>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <div className="space-y-4">
                {[1, 2, 3].map((i) => (
                  <Skeleton key={i} className="h-12 w-full" />
                ))}
              </div>
            ) : (
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">متوسط قيمة الطلب</span>
                  <span className="font-bold">{earnings?.averageOrderValue?.toLocaleString() || '0'} ج.م</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">إيرادات الشهر</span>
                  <span className="font-bold">{earnings?.monthEarnings?.toLocaleString() || '0'} ج.م</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">طلبات الشهر</span>
                  <span className="font-bold">{earnings?.monthOrders || '0'}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">الأرباح المعلقة</span>
                  <span className="font-bold text-orange-600">{earnings?.pendingPayout?.toLocaleString() || '0'} ج.م</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">إجمالي الإيرادات</span>
                  <span className="font-bold text-green-600">{earnings?.totalEarnings?.toLocaleString() || '0'} ج.م</span>
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
