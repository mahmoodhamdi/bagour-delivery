'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Skeleton } from '@/components/ui/skeleton';
import {
  DollarSign,
  TrendingUp,
  Package,
  Clock,
  ArrowUpRight,
  ArrowDownRight,
  CalendarDays,
  RefreshCw
} from 'lucide-react';
import { earningsApi, Transaction, PayoutSummary, getErrorMessage } from '@/lib/api';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';

interface EarningsStats {
  todayEarnings: number;
  weekEarnings: number;
  monthEarnings: number;
  totalEarnings: number;
  todayOrders: number;
  weekOrders: number;
  monthOrders: number;
  totalOrders: number;
  pendingPayout: number;
  averageOrderValue: number;
}

export default function EarningsPage() {
  const [stats, setStats] = useState<EarningsStats | null>(null);
  const [payoutSummary, setPayoutSummary] = useState<PayoutSummary | null>(null);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedPeriod, setSelectedPeriod] = useState('month');
  const [transactionFilter, setTransactionFilter] = useState('all');

  const fetchData = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const [statsRes, payoutRes, transactionsRes] = await Promise.all([
        earningsApi.getEarningsStats(),
        earningsApi.getPayoutSummary(),
        earningsApi.getTransactions({ limit: 10 }),
      ]);

      if (statsRes.success && statsRes.data) {
        setStats(statsRes.data);
      }
      if (payoutRes.success && payoutRes.data) {
        setPayoutSummary(payoutRes.data);
      }
      if (transactionsRes.success && transactionsRes.data) {
        setTransactions(transactionsRes.data.data);
      }
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const formatCurrency = (amount: number) => {
    return `${amount.toLocaleString('ar-EG')} ج.م`;
  };

  const getTransactionStatusBadge = (status: Transaction['status']) => {
    const statusConfig = {
      pending: { label: 'قيد الانتظار', variant: 'secondary' as const },
      processing: { label: 'جاري المعالجة', variant: 'default' as const },
      completed: { label: 'مكتمل', variant: 'default' as const },
      failed: { label: 'فشل', variant: 'destructive' as const },
    };
    const config = statusConfig[status];
    return <Badge variant={config.variant}>{config.label}</Badge>;
  };

  const getTransactionTypeBadge = (type: Transaction['type']) => {
    const typeConfig = {
      order_payment: { label: 'دفعة طلب', color: 'bg-green-100 text-green-800' },
      restaurant_payout: { label: 'تحويل للمطعم', color: 'bg-blue-100 text-blue-800' },
      refund: { label: 'استرداد', color: 'bg-red-100 text-red-800' },
    };
    const config = typeConfig[type];
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${config.color}`}>
        {config.label}
      </span>
    );
  };

  const getEarningsForPeriod = () => {
    if (!stats) return { earnings: 0, orders: 0 };
    switch (selectedPeriod) {
      case 'today':
        return { earnings: stats.todayEarnings, orders: stats.todayOrders };
      case 'week':
        return { earnings: stats.weekEarnings, orders: stats.weekOrders };
      case 'month':
        return { earnings: stats.monthEarnings, orders: stats.monthOrders };
      case 'total':
        return { earnings: stats.totalEarnings, orders: stats.totalOrders };
      default:
        return { earnings: stats.monthEarnings, orders: stats.monthOrders };
    }
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <Skeleton className="h-8 w-32" />
          <Skeleton className="h-10 w-40" />
        </div>
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {[...Array(4)].map((_, i) => (
            <Card key={i}>
              <CardHeader className="pb-2">
                <Skeleton className="h-4 w-24" />
              </CardHeader>
              <CardContent>
                <Skeleton className="h-8 w-32" />
              </CardContent>
            </Card>
          ))}
        </div>
        <Card>
          <CardHeader>
            <Skeleton className="h-6 w-40" />
          </CardHeader>
          <CardContent>
            <Skeleton className="h-64 w-full" />
          </CardContent>
        </Card>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-12">
        <p className="text-destructive mb-4">{error}</p>
        <Button onClick={fetchData} variant="outline">
          <RefreshCw className="h-4 w-4 ml-2" />
          إعادة المحاولة
        </Button>
      </div>
    );
  }

  const periodData = getEarningsForPeriod();

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">الأرباح</h1>
          <p className="text-muted-foreground">تتبع أرباحك ومعاملاتك المالية</p>
        </div>
        <div className="flex items-center gap-2">
          <Select value={selectedPeriod} onValueChange={setSelectedPeriod}>
            <SelectTrigger className="w-[140px]">
              <CalendarDays className="h-4 w-4 ml-2" />
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="today">اليوم</SelectItem>
              <SelectItem value="week">هذا الأسبوع</SelectItem>
              <SelectItem value="month">هذا الشهر</SelectItem>
              <SelectItem value="total">الإجمالي</SelectItem>
            </SelectContent>
          </Select>
          <Button onClick={fetchData} variant="outline" size="icon">
            <RefreshCw className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">الأرباح</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(periodData.earnings)}</div>
            <p className="text-xs text-muted-foreground flex items-center mt-1">
              <ArrowUpRight className="h-3 w-3 text-green-500 ml-1" />
              {selectedPeriod === 'today' ? 'اليوم' :
               selectedPeriod === 'week' ? 'هذا الأسبوع' :
               selectedPeriod === 'month' ? 'هذا الشهر' : 'الإجمالي'}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">الطلبات</CardTitle>
            <Package className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{periodData.orders}</div>
            <p className="text-xs text-muted-foreground">طلب مكتمل</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">متوسط قيمة الطلب</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {formatCurrency(stats?.averageOrderValue || 0)}
            </div>
            <p className="text-xs text-muted-foreground">لكل طلب</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">في انتظار التحويل</CardTitle>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {formatCurrency(payoutSummary?.pendingAmount || 0)}
            </div>
            <p className="text-xs text-muted-foreground">
              {payoutSummary?.totalTransactions || 0} معاملة
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Payout Summary */}
      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>ملخص التحويلات</CardTitle>
            <CardDescription>إجمالي التحويلات المالية</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between p-4 bg-green-50 rounded-lg">
              <div>
                <p className="text-sm text-muted-foreground">تم تحويله</p>
                <p className="text-xl font-bold text-green-600">
                  {formatCurrency(payoutSummary?.processedAmount || 0)}
                </p>
              </div>
              <ArrowUpRight className="h-8 w-8 text-green-500" />
            </div>
            <div className="flex items-center justify-between p-4 bg-yellow-50 rounded-lg">
              <div>
                <p className="text-sm text-muted-foreground">قيد الانتظار</p>
                <p className="text-xl font-bold text-yellow-600">
                  {formatCurrency(payoutSummary?.pendingAmount || 0)}
                </p>
              </div>
              <Clock className="h-8 w-8 text-yellow-500" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>إحصائيات سريعة</CardTitle>
            <CardDescription>نظرة عامة على الأداء</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">أرباح اليوم</span>
              <span className="font-semibold">{formatCurrency(stats?.todayEarnings || 0)}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">أرباح الأسبوع</span>
              <span className="font-semibold">{formatCurrency(stats?.weekEarnings || 0)}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">أرباح الشهر</span>
              <span className="font-semibold">{formatCurrency(stats?.monthEarnings || 0)}</span>
            </div>
            <div className="flex items-center justify-between border-t pt-4">
              <span className="text-muted-foreground">إجمالي الأرباح</span>
              <span className="font-bold text-lg">{formatCurrency(stats?.totalEarnings || 0)}</span>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Transactions Table */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>آخر المعاملات</CardTitle>
              <CardDescription>سجل المعاملات المالية الأخيرة</CardDescription>
            </div>
            <Select value={transactionFilter} onValueChange={setTransactionFilter}>
              <SelectTrigger className="w-[160px]">
                <SelectValue placeholder="تصفية حسب النوع" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">جميع المعاملات</SelectItem>
                <SelectItem value="order_payment">دفعات الطلبات</SelectItem>
                <SelectItem value="restaurant_payout">التحويلات</SelectItem>
                <SelectItem value="refund">الاستردادات</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>رقم المعاملة</TableHead>
                <TableHead>النوع</TableHead>
                <TableHead>الطلب</TableHead>
                <TableHead>المبلغ</TableHead>
                <TableHead>الرسوم</TableHead>
                <TableHead>الصافي</TableHead>
                <TableHead>الحالة</TableHead>
                <TableHead>التاريخ</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {transactions.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} className="text-center py-8 text-muted-foreground">
                    لا توجد معاملات حتى الآن
                  </TableCell>
                </TableRow>
              ) : (
                transactions
                  .filter(t => transactionFilter === 'all' || t.type === transactionFilter)
                  .map((transaction) => (
                    <TableRow key={transaction._id}>
                      <TableCell className="font-mono text-sm">
                        {transaction.transactionNumber}
                      </TableCell>
                      <TableCell>{getTransactionTypeBadge(transaction.type)}</TableCell>
                      <TableCell>
                        {transaction.orderId?.orderNumber || '-'}
                      </TableCell>
                      <TableCell>{formatCurrency(transaction.amount)}</TableCell>
                      <TableCell className="text-destructive">
                        {transaction.fee > 0 ? `-${formatCurrency(transaction.fee)}` : '-'}
                      </TableCell>
                      <TableCell className="font-semibold">
                        {formatCurrency(transaction.netAmount)}
                      </TableCell>
                      <TableCell>{getTransactionStatusBadge(transaction.status)}</TableCell>
                      <TableCell className="text-muted-foreground text-sm">
                        {format(new Date(transaction.createdAt), 'dd MMM yyyy', { locale: ar })}
                      </TableCell>
                    </TableRow>
                  ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
