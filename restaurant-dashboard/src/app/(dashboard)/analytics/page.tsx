'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Skeleton } from '@/components/ui/skeleton';
import {
  TrendingUp,
  TrendingDown,
  DollarSign,
  Package,
  Users,
  Star,
  Clock,
  CalendarDays,
  RefreshCw,
  ArrowUpRight,
  ArrowDownRight,
  BarChart3,
} from 'lucide-react';
import { earningsApi, ordersApi, type Order, getErrorMessage } from '@/lib/api';
import { ChartContainer, ChartTooltip, ChartTooltipContent } from '@/components/ui/chart';
import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, ResponsiveContainer, Legend } from 'recharts';
import { format, subDays, startOfDay, endOfDay } from 'date-fns';
import { ar } from 'date-fns/locale';

interface AnalyticsData {
  totalOrders: number;
  totalRevenue: number;
  averageOrderValue: number;
  popularItems: { name: string; count: number; revenue: number }[];
  ordersByStatus: { status: string; count: number }[];
  hourlyOrders: { hour: string; count: number }[];
  dailyTrends: { date: string; orders: number; revenue: number }[];
}

const chartConfig = {
  revenue: {
    label: 'الإيرادات',
    color: 'hsl(142, 76%, 36%)',
  },
  orders: {
    label: 'الطلبات',
    color: 'hsl(221, 83%, 53%)',
  },
  count: {
    label: 'العدد',
    color: 'hsl(262, 83%, 58%)',
  },
};

const STATUS_COLORS: Record<string, string> = {
  pending: '#f97316',
  confirmed: '#3b82f6',
  preparing: '#8b5cf6',
  ready: '#22c55e',
  delivered: '#10b981',
  cancelled: '#ef4444',
};

const STATUS_LABELS: Record<string, string> = {
  pending: 'قيد الانتظار',
  confirmed: 'مؤكد',
  preparing: 'جاري التحضير',
  ready: 'جاهز',
  delivered: 'تم التوصيل',
  cancelled: 'ملغي',
};

export default function AnalyticsPage() {
  const [analyticsData, setAnalyticsData] = useState<AnalyticsData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedPeriod, setSelectedPeriod] = useState<'week' | 'month' | 'all'>('week');

  const fetchAnalytics = async () => {
    setIsLoading(true);
    setError(null);

    try {
      // Fetch a larger set of orders for analysis
      const limit = selectedPeriod === 'week' ? 100 : selectedPeriod === 'month' ? 500 : 1000;
      const ordersRes = await ordersApi.getOrders({ limit, status: 'all' });

      if (ordersRes.success && ordersRes.data) {
        const orders = ordersRes.data.orders;

        // Calculate analytics
        const analytics = calculateAnalytics(orders);
        setAnalyticsData(analytics);
      }
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  const calculateAnalytics = (orders: Order[]): AnalyticsData => {
    // Filter by period
    const now = new Date();
    const filteredOrders = orders.filter(order => {
      const orderDate = new Date(order.createdAt);
      if (selectedPeriod === 'week') {
        return orderDate >= subDays(now, 7);
      } else if (selectedPeriod === 'month') {
        return orderDate >= subDays(now, 30);
      }
      return true;
    });

    // Total orders and revenue
    const totalOrders = filteredOrders.length;
    const totalRevenue = filteredOrders.reduce((sum, order) => sum + order.total, 0);
    const averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    // Popular items
    const itemsMap = new Map<string, { count: number; revenue: number }>();
    filteredOrders.forEach(order => {
      order.items.forEach(item => {
        const existing = itemsMap.get(item.name) || { count: 0, revenue: 0 };
        itemsMap.set(item.name, {
          count: existing.count + item.quantity,
          revenue: existing.revenue + (item.price * item.quantity),
        });
      });
    });
    const popularItems = Array.from(itemsMap.entries())
      .map(([name, data]) => ({ name, ...data }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 10);

    // Orders by status
    const statusMap = new Map<string, number>();
    filteredOrders.forEach(order => {
      const count = statusMap.get(order.status) || 0;
      statusMap.set(order.status, count + 1);
    });
    const ordersByStatus = Array.from(statusMap.entries())
      .map(([status, count]) => ({ status, count }))
      .sort((a, b) => b.count - a.count);

    // Hourly distribution
    const hourlyMap = new Map<number, number>();
    for (let i = 0; i < 24; i++) hourlyMap.set(i, 0);
    filteredOrders.forEach(order => {
      const hour = new Date(order.createdAt).getHours();
      hourlyMap.set(hour, (hourlyMap.get(hour) || 0) + 1);
    });
    const hourlyOrders = Array.from(hourlyMap.entries())
      .map(([hour, count]) => ({
        hour: `${hour.toString().padStart(2, '0')}:00`,
        count,
      }));

    // Daily trends
    const dailyMap = new Map<string, { orders: number; revenue: number }>();
    const days = selectedPeriod === 'week' ? 7 : selectedPeriod === 'month' ? 30 : 60;
    for (let i = 0; i < days; i++) {
      const date = format(subDays(now, days - i - 1), 'yyyy-MM-dd');
      dailyMap.set(date, { orders: 0, revenue: 0 });
    }
    filteredOrders.forEach(order => {
      const date = format(new Date(order.createdAt), 'yyyy-MM-dd');
      if (dailyMap.has(date)) {
        const existing = dailyMap.get(date)!;
        dailyMap.set(date, {
          orders: existing.orders + 1,
          revenue: existing.revenue + order.total,
        });
      }
    });
    const dailyTrends = Array.from(dailyMap.entries())
      .map(([date, data]) => ({
        date: format(new Date(date), 'd MMM', { locale: ar }),
        ...data,
      }));

    return {
      totalOrders,
      totalRevenue,
      averageOrderValue,
      popularItems,
      ordersByStatus,
      hourlyOrders,
      dailyTrends,
    };
  };

  useEffect(() => {
    fetchAnalytics();
  }, [selectedPeriod]);

  const formatCurrency = (amount: number) => {
    return `${Math.round(amount).toLocaleString('ar-EG')} ج.م`;
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <Skeleton className="h-8 w-48" />
          <Skeleton className="h-10 w-32" />
        </div>
        <div className="grid gap-4 md:grid-cols-4">
          {[1, 2, 3, 4].map((i) => (
            <Skeleton key={i} className="h-32" />
          ))}
        </div>
        <div className="grid gap-6 md:grid-cols-2">
          {[1, 2].map((i) => (
            <Skeleton key={i} className="h-96" />
          ))}
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-red-600">حدث خطأ</CardTitle>
          <CardDescription>{error}</CardDescription>
        </CardHeader>
        <CardContent>
          <Button onClick={fetchAnalytics} variant="outline">
            <RefreshCw className="ml-2 h-4 w-4" />
            إعادة المحاولة
          </Button>
        </CardContent>
      </Card>
    );
  }

  if (!analyticsData) return null;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">التحليلات</h1>
          <p className="text-muted-foreground">تقارير وإحصائيات شاملة عن أداء مطعمك</p>
        </div>
        <div className="flex items-center gap-4">
          <Select value={selectedPeriod} onValueChange={(value) => setSelectedPeriod(value as any)}>
            <SelectTrigger className="w-36">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="week">آخر أسبوع</SelectItem>
              <SelectItem value="month">آخر شهر</SelectItem>
              <SelectItem value="all">الكل</SelectItem>
            </SelectContent>
          </Select>
          <Button onClick={fetchAnalytics} variant="outline" size="icon">
            <RefreshCw className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">إجمالي الطلبات</CardTitle>
            <Package className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{analyticsData.totalOrders}</div>
            <p className="text-xs text-muted-foreground">
              خلال {selectedPeriod === 'week' ? 'آخر أسبوع' : selectedPeriod === 'month' ? 'آخر شهر' : 'كل الفترة'}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">إجمالي الإيرادات</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(analyticsData.totalRevenue)}</div>
            <p className="text-xs text-muted-foreground">
              {selectedPeriod === 'week' ? 'آخر 7 أيام' : selectedPeriod === 'month' ? 'آخر 30 يوم' : 'إجمالي'}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">متوسط قيمة الطلب</CardTitle>
            <BarChart3 className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(analyticsData.averageOrderValue)}</div>
            <p className="text-xs text-muted-foreground">
              لكل طلب
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">أصناف مباعة</CardTitle>
            <Package className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {analyticsData.popularItems.reduce((sum, item) => sum + item.count, 0)}
            </div>
            <p className="text-xs text-muted-foreground">
              إجمالي الوحدات
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Charts */}
      <div className="grid gap-6 md:grid-cols-2">
        {/* Daily Trends */}
        <Card>
          <CardHeader>
            <CardTitle>اتجاهات الطلبات والإيرادات</CardTitle>
            <CardDescription>الطلبات والإيرادات اليومية</CardDescription>
          </CardHeader>
          <CardContent>
            <ChartContainer config={chartConfig} className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={analyticsData.dailyTrends}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis yAxisId="left" />
                  <YAxis yAxisId="right" orientation="left" />
                  <ChartTooltip content={<ChartTooltipContent />} />
                  <Legend />
                  <Line yAxisId="left" type="monotone" dataKey="orders" stroke={chartConfig.orders.color} strokeWidth={2} name="الطلبات" />
                  <Line yAxisId="right" type="monotone" dataKey="revenue" stroke={chartConfig.revenue.color} strokeWidth={2} name="الإيرادات" />
                </LineChart>
              </ResponsiveContainer>
            </ChartContainer>
          </CardContent>
        </Card>

        {/* Hourly Distribution */}
        <Card>
          <CardHeader>
            <CardTitle>توزيع الطلبات حسب الساعة</CardTitle>
            <CardDescription>أوقات الذروة خلال اليوم</CardDescription>
          </CardHeader>
          <CardContent>
            <ChartContainer config={chartConfig} className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={analyticsData.hourlyOrders}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="hour" />
                  <YAxis />
                  <ChartTooltip content={<ChartTooltipContent />} />
                  <Bar dataKey="count" fill={chartConfig.count.color} name="الطلبات" />
                </BarChart>
              </ResponsiveContainer>
            </ChartContainer>
          </CardContent>
        </Card>

        {/* Popular Items */}
        <Card>
          <CardHeader>
            <CardTitle>الأصناف الأكثر طلباً</CardTitle>
            <CardDescription>أفضل 10 أصناف حسب العدد</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {analyticsData.popularItems.slice(0, 10).map((item, index) => (
                <div key={item.name} className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/10 text-sm font-bold text-primary">
                      {index + 1}
                    </div>
                    <div>
                      <p className="font-medium">{item.name}</p>
                      <p className="text-sm text-muted-foreground">
                        {item.count} وحدة • {formatCurrency(item.revenue)}
                      </p>
                    </div>
                  </div>
                  <div className="text-left">
                    <Badge variant="secondary">{item.count}</Badge>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Orders by Status */}
        <Card>
          <CardHeader>
            <CardTitle>الطلبات حسب الحالة</CardTitle>
            <CardDescription>توزيع حالات الطلبات</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {analyticsData.ordersByStatus.map((item) => {
                const percentage = (item.count / analyticsData.totalOrders) * 100;
                return (
                  <div key={item.status} className="space-y-2">
                    <div className="flex items-center justify-between text-sm">
                      <span className="font-medium">{STATUS_LABELS[item.status]}</span>
                      <span className="text-muted-foreground">
                        {item.count} ({percentage.toFixed(1)}%)
                      </span>
                    </div>
                    <div className="h-2 w-full rounded-full bg-muted">
                      <div
                        className="h-2 rounded-full transition-all"
                        style={{
                          width: `${percentage}%`,
                          backgroundColor: STATUS_COLORS[item.status],
                        }}
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
