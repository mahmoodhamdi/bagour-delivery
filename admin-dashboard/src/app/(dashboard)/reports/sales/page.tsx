'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from '@/components/ui/chart';
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend,
} from 'recharts';
import {
  RefreshCw,
  DollarSign,
  TrendingUp,
  TrendingDown,
  ShoppingBag,
  Calendar,
  Download,
  FileSpreadsheet,
  FileText,
  ArrowLeft,
} from 'lucide-react';
import Link from 'next/link';
import { dashboardApi, analyticsApi, ordersApi, getErrorMessage, RevenueData } from '@/services/api';
import { format, subDays, startOfMonth, endOfMonth, subMonths } from 'date-fns';
import { ar } from 'date-fns/locale';
import { exportToCSV, exportToPDF } from '@/lib/export';

interface SalesStats {
  totalRevenue: number;
  totalOrders: number;
  averageOrderValue: number;
  deliveryFees: number;
  platformFees: number;
  previousPeriodRevenue: number;
}

interface PaymentMethodData {
  method: string;
  label: string;
  count: number;
  total: number;
}

const COLORS = ['#10B981', '#3B82F6', '#F59E0B', '#EF4444', '#8B5CF6'];

export default function SalesReportPage() {
  const [stats, setStats] = useState<SalesStats | null>(null);
  const [revenueData, setRevenueData] = useState<RevenueData[]>([]);
  const [paymentMethods, setPaymentMethods] = useState<PaymentMethodData[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [period, setPeriod] = useState('30');

  const fetchData = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const days = parseInt(period);
      const [revenueRes, financialRes, ordersRes] = await Promise.all([
        dashboardApi.getRevenueChart(days),
        analyticsApi.getFinancialSummary({
          startDate: format(subDays(new Date(), days), 'yyyy-MM-dd'),
          endDate: format(new Date(), 'yyyy-MM-dd'),
        }),
        ordersApi.getOrders({ limit: 100 }),
      ]);

      // Process revenue data
      if (revenueRes.success && revenueRes.data) {
        setRevenueData(revenueRes.data);
      }

      // Calculate stats
      const revenue = financialRes.data?.revenue;
      const orders = ordersRes.data?.data || [];

      // Calculate payment method distribution
      const paymentCounts: Record<string, { count: number; total: number }> = {};
      orders.forEach(order => {
        const method = order.paymentMethod;
        if (!paymentCounts[method]) {
          paymentCounts[method] = { count: 0, total: 0 };
        }
        paymentCounts[method].count++;
        paymentCounts[method].total += order.totalAmount;
      });

      const paymentLabels: Record<string, string> = {
        cash: 'الدفع عند الاستلام',
        card: 'بطاقة ائتمان',
        wallet: 'محفظة إلكترونية',
      };

      setPaymentMethods(
        Object.entries(paymentCounts).map(([method, data]) => ({
          method,
          label: paymentLabels[method] || method,
          count: data.count,
          total: data.total,
        }))
      );

      // Set stats
      setStats({
        totalRevenue: revenue?.totalRevenue || 0,
        totalOrders: revenue?.orderCount || 0,
        averageOrderValue: revenue?.orderCount ? (revenue.totalRevenue / revenue.orderCount) : 0,
        deliveryFees: revenue?.totalDeliveryFees || 0,
        platformFees: revenue?.totalPlatformFees || 0,
        previousPeriodRevenue: 0, // Would need another API call
      });

    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [period]);

  const formatCurrency = (amount: number) => {
    return `${amount.toLocaleString('ar-EG')} ج.م`;
  };

  const handleExport = (format: 'csv' | 'pdf') => {
    const today = new Date();
    const dateStr = today.toLocaleDateString('ar-EG', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });

    const exportData = {
      title: 'تقرير المبيعات',
      date: dateStr,
      columns: [
        { header: 'التاريخ', key: 'date' },
        { header: 'الإيرادات', key: 'revenue' },
        { header: 'عدد الطلبات', key: 'orders' },
        { header: 'العمولة', key: 'commission' },
      ],
      rows: revenueData.map(item => ({
        date: item.date,
        revenue: formatCurrency(item.revenue),
        orders: item.orders,
        commission: formatCurrency(item.commission),
      })),
      summary: {
        'إجمالي الإيرادات': formatCurrency(stats?.totalRevenue || 0),
        'إجمالي الطلبات': stats?.totalOrders || 0,
        'متوسط قيمة الطلب': formatCurrency(stats?.averageOrderValue || 0),
        'رسوم التوصيل': formatCurrency(stats?.deliveryFees || 0),
        'عمولة المنصة': formatCurrency(stats?.platformFees || 0),
      },
    };

    if (format === 'csv') {
      exportToCSV(exportData);
    } else {
      exportToPDF(exportData);
    }
  };

  const chartConfig = {
    revenue: {
      label: 'الإيرادات',
      color: '#10B981',
    },
    orders: {
      label: 'الطلبات',
      color: '#3B82F6',
    },
    commission: {
      label: 'العمولة',
      color: '#F59E0B',
    },
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-48" />
        <div className="grid gap-4 md:grid-cols-4">
          {[...Array(4)].map((_, i) => (
            <Skeleton key={i} className="h-32" />
          ))}
        </div>
        <Skeleton className="h-96" />
      </div>
    );
  }

  const revenueGrowth = stats?.previousPeriodRevenue
    ? ((stats.totalRevenue - stats.previousPeriodRevenue) / stats.previousPeriodRevenue) * 100
    : 0;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link href="/reports">
            <Button variant="ghost" size="icon">
              <ArrowLeft className="h-4 w-4" />
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold">تقرير المبيعات</h1>
            <p className="text-muted-foreground">تحليل الإيرادات والطلبات</p>
          </div>
        </div>
        <div className="flex gap-2">
          <Select value={period} onValueChange={setPeriod}>
            <SelectTrigger className="w-[140px]">
              <Calendar className="h-4 w-4 ml-2" />
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="7">آخر 7 أيام</SelectItem>
              <SelectItem value="30">آخر 30 يوم</SelectItem>
              <SelectItem value="90">آخر 3 أشهر</SelectItem>
              <SelectItem value="365">آخر سنة</SelectItem>
            </SelectContent>
          </Select>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline">
                <Download className="h-4 w-4 ml-2" />
                تصدير
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={() => handleExport('csv')}>
                <FileSpreadsheet className="h-4 w-4 ml-2" />
                تصدير Excel (CSV)
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => handleExport('pdf')}>
                <FileText className="h-4 w-4 ml-2" />
                تصدير PDF
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
          <Button onClick={fetchData} variant="outline" size="icon">
            <RefreshCw className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {error && (
        <div className="bg-destructive/10 text-destructive p-4 rounded-lg">
          {error}
        </div>
      )}

      {/* Stats Cards */}
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
            {revenueGrowth !== 0 && (
              <p className={`text-xs flex items-center gap-1 mt-1 ${revenueGrowth > 0 ? 'text-green-600' : 'text-red-600'}`}>
                {revenueGrowth > 0 ? <TrendingUp className="h-3 w-3" /> : <TrendingDown className="h-3 w-3" />}
                {Math.abs(revenueGrowth).toFixed(1)}% عن الفترة السابقة
              </p>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              عدد الطلبات
            </CardTitle>
            <ShoppingBag className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats?.totalOrders?.toLocaleString() || 0}</div>
            <p className="text-xs text-muted-foreground mt-1">
              خلال الفترة المحددة
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              متوسط قيمة الطلب
            </CardTitle>
            <TrendingUp className="h-4 w-4 text-purple-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(stats?.averageOrderValue || 0)}</div>
            <p className="text-xs text-muted-foreground mt-1">
              لكل طلب
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              عمولة المنصة
            </CardTitle>
            <DollarSign className="h-4 w-4 text-orange-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(stats?.platformFees || 0)}</div>
            <p className="text-xs text-muted-foreground mt-1">
              صافي الأرباح
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Revenue Chart */}
      <Card>
        <CardHeader>
          <CardTitle>مخطط الإيرادات</CardTitle>
        </CardHeader>
        <CardContent>
          <ChartContainer config={chartConfig} className="h-[400px] w-full">
            <LineChart data={revenueData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis
                dataKey="date"
                tickFormatter={(value) => {
                  const date = new Date(value);
                  return format(date, 'dd/MM', { locale: ar });
                }}
              />
              <YAxis tickFormatter={(value) => `${(value / 1000).toFixed(0)}k`} />
              <ChartTooltip
                content={<ChartTooltipContent />}
                formatter={(value: number) => formatCurrency(value)}
              />
              <Line
                type="monotone"
                dataKey="revenue"
                stroke="var(--color-revenue)"
                strokeWidth={2}
                dot={false}
                name="الإيرادات"
              />
              <Line
                type="monotone"
                dataKey="commission"
                stroke="var(--color-commission)"
                strokeWidth={2}
                dot={false}
                name="العمولة"
              />
            </LineChart>
          </ChartContainer>
        </CardContent>
      </Card>

      {/* Orders Chart & Payment Methods */}
      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>عدد الطلبات اليومي</CardTitle>
          </CardHeader>
          <CardContent>
            <ChartContainer config={chartConfig} className="h-[300px] w-full">
              <BarChart data={revenueData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis
                  dataKey="date"
                  tickFormatter={(value) => {
                    const date = new Date(value);
                    return format(date, 'dd/MM', { locale: ar });
                  }}
                />
                <YAxis />
                <ChartTooltip content={<ChartTooltipContent />} />
                <Bar dataKey="orders" fill="var(--color-orders)" name="الطلبات" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ChartContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>توزيع طرق الدفع</CardTitle>
          </CardHeader>
          <CardContent>
            {paymentMethods.length > 0 ? (
              <ChartContainer config={chartConfig} className="h-[300px] w-full">
                <PieChart>
                  <Pie
                    data={paymentMethods}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ label, percent }) => `${label} (${(percent * 100).toFixed(0)}%)`}
                    outerRadius={100}
                    fill="#8884d8"
                    dataKey="count"
                    nameKey="label"
                  >
                    {paymentMethods.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Legend />
                </PieChart>
              </ChartContainer>
            ) : (
              <div className="h-[300px] flex items-center justify-center text-muted-foreground">
                لا توجد بيانات كافية
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Daily Summary Table */}
      <Card>
        <CardHeader>
          <CardTitle>ملخص يومي</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>التاريخ</TableHead>
                <TableHead>الإيرادات</TableHead>
                <TableHead>عدد الطلبات</TableHead>
                <TableHead>العمولة</TableHead>
                <TableHead>متوسط الطلب</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {revenueData.slice(0, 10).map((day) => (
                <TableRow key={day.date}>
                  <TableCell>
                    {format(new Date(day.date), 'dd MMMM yyyy', { locale: ar })}
                  </TableCell>
                  <TableCell className="font-semibold">
                    {formatCurrency(day.revenue)}
                  </TableCell>
                  <TableCell>{day.orders}</TableCell>
                  <TableCell>{formatCurrency(day.commission)}</TableCell>
                  <TableCell>
                    {day.orders > 0 ? formatCurrency(day.revenue / day.orders) : '-'}
                  </TableCell>
                </TableRow>
              ))}
              {revenueData.length === 0 && (
                <TableRow>
                  <TableCell colSpan={5} className="text-center py-8 text-muted-foreground">
                    لا توجد بيانات للفترة المحددة
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
