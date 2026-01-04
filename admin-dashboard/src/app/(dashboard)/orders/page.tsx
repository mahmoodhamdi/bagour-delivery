'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
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
import { RefreshCw, Eye, ShoppingBag, Download, FileSpreadsheet, FileText } from 'lucide-react';
import { ordersApi, Order, getErrorMessage } from '@/services/api';
import { ORDER_STATUSES } from '@/config/constants';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';
import { exportOrdersReport } from '@/lib/export';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

export default function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  const fetchOrders = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const res = await ordersApi.getOrders({
        page: currentPage,
        limit: 20,
        status: statusFilter !== 'all' ? statusFilter : undefined,
      });

      if (res.success && res.data) {
        setOrders(res.data.data || []);
        setTotalPages(res.data.pagination?.pages || 1);
      }
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, [currentPage, statusFilter]);

  const formatCurrency = (amount: number) => {
    return `${amount.toLocaleString('ar-EG')} ج.م`;
  };

  const getStatusBadge = (status: string) => {
    const config = ORDER_STATUSES[status as keyof typeof ORDER_STATUSES];
    if (!config) return <span className="px-2 py-1 rounded-full text-xs bg-gray-100">{status}</span>;

    const colorMap: Record<string, string> = {
      orange: 'bg-orange-100 text-orange-800',
      blue: 'bg-blue-100 text-blue-800',
      purple: 'bg-purple-100 text-purple-800',
      green: 'bg-green-100 text-green-800',
      teal: 'bg-teal-100 text-teal-800',
      indigo: 'bg-indigo-100 text-indigo-800',
      red: 'bg-red-100 text-red-800',
    };

    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${colorMap[config.color]}`}>
        {config.label}
      </span>
    );
  };

  const getPaymentBadge = (method: string, status: string) => {
    const methodLabels: Record<string, string> = {
      cash: 'نقدي',
      card: 'بطاقة',
      wallet: 'محفظة',
    };
    const statusLabels: Record<string, string> = {
      pending: 'قيد الانتظار',
      paid: 'مدفوع',
      failed: 'فشل',
      refunded: 'مسترد',
    };

    return (
      <div className="text-sm">
        <span>{methodLabels[method] || method}</span>
        <span className={`block text-xs ${status === 'paid' ? 'text-green-600' : 'text-muted-foreground'}`}>
          {statusLabels[status] || status}
        </span>
      </div>
    );
  };

  if (isLoading && orders.length === 0) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-48" />
        <Skeleton className="h-10 w-40" />
        <Card>
          <CardContent className="pt-6">
            {[...Array(5)].map((_, i) => (
              <Skeleton key={i} className="h-16 w-full mb-2" />
            ))}
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">إدارة الطلبات</h1>
          <p className="text-muted-foreground">عرض جميع الطلبات</p>
        </div>
        <div className="flex gap-2">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline">
                <Download className="h-4 w-4 ml-2" />
                تصدير
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem
                onClick={() => exportOrdersReport({
                  orders: orders.map(order => ({
                    orderNumber: order.orderNumber,
                    customerName: order.customerId?.name || '-',
                    restaurantName: order.restaurantId?.name || '-',
                    total: order.totalAmount,
                    status: ORDER_STATUSES[order.status as keyof typeof ORDER_STATUSES]?.label || order.status,
                    createdAt: format(new Date(order.createdAt), 'dd/MM/yyyy HH:mm'),
                  })),
                  summary: {
                    totalOrders: orders.length,
                    totalRevenue: orders.reduce((sum, o) => sum + o.totalAmount, 0),
                  },
                }, 'csv')}
              >
                <FileSpreadsheet className="h-4 w-4 ml-2" />
                تصدير Excel (CSV)
              </DropdownMenuItem>
              <DropdownMenuItem
                onClick={() => exportOrdersReport({
                  orders: orders.map(order => ({
                    orderNumber: order.orderNumber,
                    customerName: order.customerId?.name || '-',
                    restaurantName: order.restaurantId?.name || '-',
                    total: order.totalAmount,
                    status: ORDER_STATUSES[order.status as keyof typeof ORDER_STATUSES]?.label || order.status,
                    createdAt: format(new Date(order.createdAt), 'dd/MM/yyyy HH:mm'),
                  })),
                  summary: {
                    totalOrders: orders.length,
                    totalRevenue: orders.reduce((sum, o) => sum + o.totalAmount, 0),
                  },
                }, 'pdf')}
              >
                <FileText className="h-4 w-4 ml-2" />
                تصدير PDF
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
          <Button onClick={fetchOrders} variant="outline" size="icon">
            <RefreshCw className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {error && (
        <div className="bg-destructive/10 text-destructive p-4 rounded-lg">
          {error}
        </div>
      )}

      <div className="flex gap-4">
        <Select value={statusFilter} onValueChange={setStatusFilter}>
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="حالة الطلب" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">جميع الحالات</SelectItem>
            <SelectItem value="pending">قيد الانتظار</SelectItem>
            <SelectItem value="confirmed">مؤكد</SelectItem>
            <SelectItem value="preparing">جاري التحضير</SelectItem>
            <SelectItem value="ready">جاهز</SelectItem>
            <SelectItem value="picked_up">تم الاستلام</SelectItem>
            <SelectItem value="on_the_way">في الطريق</SelectItem>
            <SelectItem value="delivered">تم التوصيل</SelectItem>
            <SelectItem value="cancelled">ملغي</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <Card>
        <CardContent className="pt-6">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>رقم الطلب</TableHead>
                <TableHead>العميل</TableHead>
                <TableHead>المطعم</TableHead>
                <TableHead>السائق</TableHead>
                <TableHead>المبلغ</TableHead>
                <TableHead>الدفع</TableHead>
                <TableHead>الحالة</TableHead>
                <TableHead>التاريخ</TableHead>
                <TableHead></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {orders.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={9} className="text-center py-8 text-muted-foreground">
                    لا توجد طلبات
                  </TableCell>
                </TableRow>
              ) : (
                orders.map((order) => (
                  <TableRow key={order._id}>
                    <TableCell className="font-mono text-sm">
                      {order.orderNumber}
                    </TableCell>
                    <TableCell>
                      <div>
                        <span className="font-medium">{order.customerId?.name || '-'}</span>
                        <span className="block text-xs text-muted-foreground" dir="ltr">
                          {order.customerId?.phone}
                        </span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        {order.restaurantId?.logo ? (
                          <img src={order.restaurantId.logo} alt="" className="h-6 w-6 rounded object-cover" />
                        ) : (
                          <ShoppingBag className="h-4 w-4 text-muted-foreground" />
                        )}
                        <span>{order.restaurantId?.name || '-'}</span>
                      </div>
                    </TableCell>
                    <TableCell>{order.driverId?.name || '-'}</TableCell>
                    <TableCell className="font-semibold">
                      {formatCurrency(order.totalAmount)}
                    </TableCell>
                    <TableCell>
                      {getPaymentBadge(order.paymentMethod, order.paymentStatus)}
                    </TableCell>
                    <TableCell>{getStatusBadge(order.status)}</TableCell>
                    <TableCell className="text-muted-foreground text-sm">
                      {format(new Date(order.createdAt), 'dd MMM yyyy HH:mm', { locale: ar })}
                    </TableCell>
                    <TableCell>
                      <Button variant="ghost" size="icon">
                        <Eye className="h-4 w-4" />
                      </Button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>

          {totalPages > 1 && (
            <div className="flex items-center justify-center gap-2 mt-4">
              <Button
                variant="outline"
                size="sm"
                disabled={currentPage === 1}
                onClick={() => setCurrentPage((p) => p - 1)}
              >
                السابق
              </Button>
              <span className="text-sm text-muted-foreground">
                صفحة {currentPage} من {totalPages}
              </span>
              <Button
                variant="outline"
                size="sm"
                disabled={currentPage === totalPages}
                onClick={() => setCurrentPage((p) => p + 1)}
              >
                التالي
              </Button>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
