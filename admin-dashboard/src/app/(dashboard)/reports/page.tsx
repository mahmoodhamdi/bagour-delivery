'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import {
  RefreshCw,
  TrendingUp,
  DollarSign,
  ShoppingBag,
  Store,
  Truck,
  Users,
  ArrowUpRight,
  BarChart3,
  PieChart,
  FileText,
  Calendar,
} from 'lucide-react';
import { dashboardApi, analyticsApi, getErrorMessage } from '@/services/api';

interface QuickStats {
  totalRevenue: number;
  totalOrders: number;
  totalRestaurants: number;
  totalDrivers: number;
  totalCustomers: number;
  monthlyGrowth: number;
}

export default function ReportsPage() {
  const [stats, setStats] = useState<QuickStats | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchStats = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const [dashboardRes, financialRes, customerRes] = await Promise.all([
        dashboardApi.getStats(),
        analyticsApi.getFinancialSummary(),
        analyticsApi.getCustomerStats(),
      ]);

      const quickStats: QuickStats = {
        totalRevenue: financialRes.data?.revenue?.totalRevenue || 0,
        totalOrders: dashboardRes.data?.totalOrders || 0,
        totalRestaurants: dashboardRes.data?.totalRestaurants || 0,
        totalDrivers: dashboardRes.data?.totalDrivers || 0,
        totalCustomers: customerRes.data?.totalCustomers || 0,
        monthlyGrowth: customerRes.data?.newThisMonth || 0,
      };

      setStats(quickStats);
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, []);

  const formatCurrency = (amount: number) => {
    return `${amount.toLocaleString('ar-EG')} ج.م`;
  };

  const reportCards = [
    {
      title: 'تقارير المبيعات',
      description: 'تحليل الإيرادات والطلبات مع رسوم بيانية تفصيلية',
      icon: DollarSign,
      href: '/reports/sales',
      color: 'text-green-600',
      bgColor: 'bg-green-50',
    },
    {
      title: 'تقارير المطاعم',
      description: 'أداء المطاعم وإحصائيات الطلبات لكل مطعم',
      icon: Store,
      href: '/reports/restaurants',
      color: 'text-orange-600',
      bgColor: 'bg-orange-50',
    },
    {
      title: 'تقارير السائقين',
      description: 'إحصائيات التوصيل وأداء السائقين',
      icon: Truck,
      href: '/reports/drivers',
      color: 'text-blue-600',
      bgColor: 'bg-blue-50',
    },
  ];

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-48" />
        <div className="grid gap-4 md:grid-cols-4">
          {[...Array(4)].map((_, i) => (
            <Skeleton key={i} className="h-32" />
          ))}
        </div>
        <div className="grid gap-4 md:grid-cols-3">
          {[...Array(3)].map((_, i) => (
            <Skeleton key={i} className="h-48" />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">التقارير</h1>
          <p className="text-muted-foreground">نظرة شاملة على أداء المنصة والإحصائيات</p>
        </div>
        <Button onClick={fetchStats} variant="outline" size="icon">
          <RefreshCw className="h-4 w-4" />
        </Button>
      </div>

      {error && (
        <div className="bg-destructive/10 text-destructive p-4 rounded-lg">
          {error}
        </div>
      )}

      {/* Quick Stats */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              إجمالي الإيرادات
            </CardTitle>
            <DollarSign className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(stats?.totalRevenue || 0)}</div>
            <p className="text-xs text-muted-foreground mt-1">
              <TrendingUp className="h-3 w-3 inline ml-1 text-green-600" />
              منذ بداية التشغيل
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              إجمالي الطلبات
            </CardTitle>
            <ShoppingBag className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats?.totalOrders?.toLocaleString() || 0}</div>
            <p className="text-xs text-muted-foreground mt-1">
              طلب تم معالجته
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              المطاعم النشطة
            </CardTitle>
            <Store className="h-4 w-4 text-orange-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats?.totalRestaurants || 0}</div>
            <p className="text-xs text-muted-foreground mt-1">
              مطعم مسجل
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              العملاء
            </CardTitle>
            <Users className="h-4 w-4 text-purple-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats?.totalCustomers?.toLocaleString() || 0}</div>
            <p className="text-xs text-muted-foreground mt-1">
              <span className="text-green-600">+{stats?.monthlyGrowth || 0}</span> هذا الشهر
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Report Cards */}
      <div className="grid gap-4 md:grid-cols-3">
        {reportCards.map((report) => (
          <Link key={report.href} href={report.href}>
            <Card className="hover:shadow-lg transition-shadow cursor-pointer h-full">
              <CardHeader>
                <div className={`w-12 h-12 rounded-lg ${report.bgColor} flex items-center justify-center mb-4`}>
                  <report.icon className={`h-6 w-6 ${report.color}`} />
                </div>
                <CardTitle className="flex items-center justify-between">
                  {report.title}
                  <ArrowUpRight className="h-4 w-4 text-muted-foreground" />
                </CardTitle>
                <CardDescription>{report.description}</CardDescription>
              </CardHeader>
              <CardContent>
                <Button variant="outline" className="w-full">
                  عرض التقرير
                </Button>
              </CardContent>
            </Card>
          </Link>
        ))}
      </div>

      {/* Quick Actions */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <FileText className="h-5 w-5" />
            إجراءات سريعة
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Link href="/reports/sales">
              <Button variant="outline" className="w-full justify-start">
                <BarChart3 className="h-4 w-4 ml-2" />
                تقرير المبيعات الشهري
              </Button>
            </Link>
            <Link href="/reports/restaurants">
              <Button variant="outline" className="w-full justify-start">
                <PieChart className="h-4 w-4 ml-2" />
                أداء المطاعم
              </Button>
            </Link>
            <Link href="/reports/drivers">
              <Button variant="outline" className="w-full justify-start">
                <Truck className="h-4 w-4 ml-2" />
                إحصائيات السائقين
              </Button>
            </Link>
            <Link href="/analytics">
              <Button variant="outline" className="w-full justify-start">
                <TrendingUp className="h-4 w-4 ml-2" />
                التحليلات المتقدمة
              </Button>
            </Link>
          </div>
        </CardContent>
      </Card>

      {/* Information Cards */}
      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Calendar className="h-5 w-5" />
              فترات التقارير
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-muted-foreground">تقرير يومي</span>
              <span className="text-sm">آخر 24 ساعة</span>
            </div>
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-muted-foreground">تقرير أسبوعي</span>
              <span className="text-sm">آخر 7 أيام</span>
            </div>
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-muted-foreground">تقرير شهري</span>
              <span className="text-sm">آخر 30 يوم</span>
            </div>
            <div className="flex justify-between items-center py-2">
              <span className="text-muted-foreground">تقرير سنوي</span>
              <span className="text-sm">آخر 12 شهر</span>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <BarChart3 className="h-5 w-5" />
              أنواع التقارير المتاحة
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-muted-foreground">تقارير المبيعات</span>
              <span className="text-sm text-green-600">متاح</span>
            </div>
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-muted-foreground">تقارير المطاعم</span>
              <span className="text-sm text-green-600">متاح</span>
            </div>
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-muted-foreground">تقارير السائقين</span>
              <span className="text-sm text-green-600">متاح</span>
            </div>
            <div className="flex justify-between items-center py-2">
              <span className="text-muted-foreground">تصدير البيانات</span>
              <span className="text-sm text-green-600">CSV / PDF</span>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
