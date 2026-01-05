'use client';

import { useEffect, useState, useCallback } from 'react';
import { toast } from 'sonner';
import { ordersApi, Order, getErrorMessage } from '@/lib/api';
import { ORDER_STATUSES, PAGINATION } from '@/config/constants';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  RefreshCw,
  Clock,
  MapPin,
  Phone,
  User,
  ShoppingBag,
  Check,
  X,
  ChefHat,
  Package,
  AlertCircle,
  Download,
  FileSpreadsheet,
  FileText,
} from 'lucide-react';
import { exportOrdersReport } from '@/lib/export';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { format } from 'date-fns';

type OrderStatus = Order['status'];
type TabValue = 'active' | 'completed' | 'all';

export default function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [activeTab, setActiveTab] = useState<TabValue>('active');
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [showAcceptDialog, setShowAcceptDialog] = useState(false);
  const [showRejectDialog, setShowRejectDialog] = useState(false);
  const [estimatedTime, setEstimatedTime] = useState('30');
  const [rejectReason, setRejectReason] = useState('');
  const [isUpdating, setIsUpdating] = useState(false);

  const fetchOrders = useCallback(async (showRefresh = false) => {
    try {
      if (showRefresh) {
        setIsRefreshing(true);
      }
      const response = await ordersApi.getOrders({
        limit: PAGINATION.ordersPageSize,
      });
      if (response.success && response.data) {
        setOrders(response.data.orders);
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsLoading(false);
      setIsRefreshing(false);
    }
  }, []);

  useEffect(() => {
    fetchOrders();
  }, [fetchOrders]);

  const handleRefresh = () => {
    fetchOrders(true);
  };

  const activeOrders = orders.filter(
    (order) => !['delivered', 'cancelled'].includes(order.status)
  );

  const completedOrders = orders.filter((order) =>
    ['delivered', 'cancelled'].includes(order.status)
  );

  const getDisplayOrders = () => {
    switch (activeTab) {
      case 'active':
        return activeOrders;
      case 'completed':
        return completedOrders;
      default:
        return orders;
    }
  };

  const handleAcceptOrder = async () => {
    if (!selectedOrder) return;

    setIsUpdating(true);
    try {
      const response = await ordersApi.acceptOrder(
        selectedOrder._id,
        parseInt(estimatedTime)
      );
      if (response.success && response.data) {
        setOrders((prev) =>
          prev.map((o) =>
            o._id === selectedOrder._id ? response.data!.order : o
          )
        );
        toast.success('تم قبول الطلب بنجاح');
        setShowAcceptDialog(false);
        setSelectedOrder(null);
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsUpdating(false);
    }
  };

  const handleRejectOrder = async () => {
    if (!selectedOrder || !rejectReason.trim()) return;

    setIsUpdating(true);
    try {
      const response = await ordersApi.rejectOrder(
        selectedOrder._id,
        rejectReason
      );
      if (response.success && response.data) {
        setOrders((prev) =>
          prev.map((o) =>
            o._id === selectedOrder._id ? response.data!.order : o
          )
        );
        toast.success('تم رفض الطلب');
        setShowRejectDialog(false);
        setSelectedOrder(null);
        setRejectReason('');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsUpdating(false);
    }
  };

  const handleUpdateStatus = async (orderId: string, newStatus: OrderStatus) => {
    setIsUpdating(true);
    try {
      const response = await ordersApi.updateOrderStatus(orderId, newStatus);
      if (response.success && response.data) {
        setOrders((prev) =>
          prev.map((o) => (o._id === orderId ? response.data!.order : o))
        );
        toast.success('تم تحديث حالة الطلب');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsUpdating(false);
    }
  };

  const getNextStatus = (currentStatus: OrderStatus): OrderStatus | null => {
    const statusFlow: Record<OrderStatus, OrderStatus | null> = {
      pending: 'confirmed',
      confirmed: 'preparing',
      preparing: 'ready',
      ready: null,
      picked_up: null,
      on_the_way: null,
      delivered: null,
      cancelled: null,
    };
    return statusFlow[currentStatus];
  };

  const getStatusBadgeVariant = (status: OrderStatus) => {
    switch (status) {
      case 'pending':
        return 'secondary';
      case 'confirmed':
      case 'preparing':
        return 'default';
      case 'ready':
      case 'picked_up':
      case 'on_the_way':
        return 'default';
      case 'delivered':
        return 'default';
      case 'cancelled':
        return 'destructive';
      default:
        return 'secondary';
    }
  };

  const formatTime = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleTimeString('ar-EG', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const orderDate = new Date(
      date.getFullYear(),
      date.getMonth(),
      date.getDate()
    );

    if (orderDate.getTime() === today.getTime()) {
      return 'اليوم';
    }

    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    if (orderDate.getTime() === yesterday.getTime()) {
      return 'أمس';
    }

    return date.toLocaleDateString('ar-EG', {
      day: 'numeric',
      month: 'short',
    });
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <Skeleton className="h-8 w-32" />
          <Skeleton className="h-10 w-24" />
        </div>
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <Card key={i}>
              <CardHeader>
                <Skeleton className="h-6 w-24" />
              </CardHeader>
              <CardContent>
                <Skeleton className="h-4 w-full mb-2" />
                <Skeleton className="h-4 w-3/4" />
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">الطلبات</h1>
          <p className="text-muted-foreground">
            إدارة ومتابعة طلبات المطعم
          </p>
        </div>
        <div className="flex gap-2">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm">
                <Download className="h-4 w-4 ml-2" />
                تصدير
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem
                onClick={() => exportOrdersReport({
                  orders: getDisplayOrders().map(order => ({
                    orderNumber: order.orderNumber,
                    customerName: order.customer.name,
                    total: order.total,
                    status: ORDER_STATUSES[order.status]?.label || order.status,
                    createdAt: format(new Date(order.createdAt), 'dd/MM/yyyy HH:mm'),
                  })),
                  summary: {
                    totalOrders: getDisplayOrders().length,
                    totalRevenue: getDisplayOrders().reduce((sum, o) => sum + o.total, 0),
                  },
                }, 'csv')}
              >
                <FileSpreadsheet className="h-4 w-4 ml-2" />
                تصدير Excel (CSV)
              </DropdownMenuItem>
              <DropdownMenuItem
                onClick={() => exportOrdersReport({
                  orders: getDisplayOrders().map(order => ({
                    orderNumber: order.orderNumber,
                    customerName: order.customer.name,
                    total: order.total,
                    status: ORDER_STATUSES[order.status]?.label || order.status,
                    createdAt: format(new Date(order.createdAt), 'dd/MM/yyyy HH:mm'),
                  })),
                  summary: {
                    totalOrders: getDisplayOrders().length,
                    totalRevenue: getDisplayOrders().reduce((sum, o) => sum + o.total, 0),
                  },
                }, 'pdf')}
              >
                <FileText className="h-4 w-4 ml-2" />
                تصدير PDF
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
          <Button
            variant="outline"
            size="sm"
            onClick={handleRefresh}
            disabled={isRefreshing}
          >
            <RefreshCw
              className={`h-4 w-4 ml-2 ${isRefreshing ? 'animate-spin' : ''}`}
            />
            تحديث
          </Button>
        </div>
      </div>

      {/* Tabs */}
      <Tabs
        value={activeTab}
        onValueChange={(v) => setActiveTab(v as TabValue)}
      >
        <TabsList className="grid w-full max-w-md grid-cols-3">
          <TabsTrigger value="active" className="gap-2">
            <Clock className="h-4 w-4" />
            نشطة
            {activeOrders.length > 0 && (
              <Badge variant="secondary" className="mr-1">
                {activeOrders.length}
              </Badge>
            )}
          </TabsTrigger>
          <TabsTrigger value="completed">مكتملة</TabsTrigger>
          <TabsTrigger value="all">الكل</TabsTrigger>
        </TabsList>

        <TabsContent value={activeTab} className="mt-6">
          {getDisplayOrders().length === 0 ? (
            <Card>
              <CardContent className="flex flex-col items-center justify-center py-12">
                <ShoppingBag className="h-12 w-12 text-muted-foreground mb-4" />
                <h3 className="text-lg font-semibold mb-2">لا توجد طلبات</h3>
                <p className="text-muted-foreground text-center">
                  {activeTab === 'active'
                    ? 'لا توجد طلبات نشطة حالياً'
                    : activeTab === 'completed'
                      ? 'لا توجد طلبات مكتملة'
                      : 'لا توجد طلبات'}
                </p>
              </CardContent>
            </Card>
          ) : (
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              {getDisplayOrders().map((order) => (
                <OrderCard
                  key={order._id}
                  order={order}
                  onAccept={() => {
                    setSelectedOrder(order);
                    setShowAcceptDialog(true);
                  }}
                  onReject={() => {
                    setSelectedOrder(order);
                    setShowRejectDialog(true);
                  }}
                  onUpdateStatus={handleUpdateStatus}
                  getNextStatus={getNextStatus}
                  getStatusBadgeVariant={getStatusBadgeVariant}
                  formatTime={formatTime}
                  formatDate={formatDate}
                  isUpdating={isUpdating}
                />
              ))}
            </div>
          )}
        </TabsContent>
      </Tabs>

      {/* Accept Dialog */}
      <Dialog open={showAcceptDialog} onOpenChange={setShowAcceptDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>قبول الطلب #{selectedOrder?.orderNumber}</DialogTitle>
            <DialogDescription>
              حدد الوقت المتوقع لتحضير الطلب
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>وقت التحضير المتوقع (بالدقائق)</Label>
              <Select value={estimatedTime} onValueChange={setEstimatedTime}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="15">15 دقيقة</SelectItem>
                  <SelectItem value="20">20 دقيقة</SelectItem>
                  <SelectItem value="30">30 دقيقة</SelectItem>
                  <SelectItem value="45">45 دقيقة</SelectItem>
                  <SelectItem value="60">ساعة</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setShowAcceptDialog(false)}
            >
              إلغاء
            </Button>
            <Button onClick={handleAcceptOrder} disabled={isUpdating}>
              {isUpdating ? 'جاري القبول...' : 'قبول الطلب'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Reject Dialog */}
      <Dialog open={showRejectDialog} onOpenChange={setShowRejectDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>رفض الطلب #{selectedOrder?.orderNumber}</DialogTitle>
            <DialogDescription>
              يرجى توضيح سبب رفض الطلب للعميل
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>سبب الرفض</Label>
              <Input
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                placeholder="مثال: المطعم مغلق حالياً"
              />
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setShowRejectDialog(false)}
            >
              إلغاء
            </Button>
            <Button
              variant="destructive"
              onClick={handleRejectOrder}
              disabled={isUpdating || !rejectReason.trim()}
            >
              {isUpdating ? 'جاري الرفض...' : 'رفض الطلب'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// Order Card Component
interface OrderCardProps {
  order: Order;
  onAccept: () => void;
  onReject: () => void;
  onUpdateStatus: (orderId: string, status: OrderStatus) => void;
  getNextStatus: (status: OrderStatus) => OrderStatus | null;
  getStatusBadgeVariant: (status: OrderStatus) => 'default' | 'secondary' | 'destructive' | 'outline';
  formatTime: (date: string) => string;
  formatDate: (date: string) => string;
  isUpdating: boolean;
}

function OrderCard({
  order,
  onAccept,
  onReject,
  onUpdateStatus,
  getNextStatus,
  getStatusBadgeVariant,
  formatTime,
  formatDate,
  isUpdating,
}: OrderCardProps) {
  const statusInfo = ORDER_STATUSES[order.status];
  const nextStatus = getNextStatus(order.status);
  const totalItems = order.items.reduce((sum, item) => sum + item.quantity, 0);

  return (
    <Card className="overflow-hidden">
      {/* Status Bar */}
      <div
        className={`h-1 ${
          order.status === 'pending'
            ? 'bg-orange-500'
            : order.status === 'cancelled'
              ? 'bg-red-500'
              : order.status === 'delivered'
                ? 'bg-green-500'
                : 'bg-blue-500'
        }`}
      />

      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <div>
            <CardTitle className="text-lg">#{order.orderNumber}</CardTitle>
            <p className="text-sm text-muted-foreground">
              {formatDate(order.createdAt)} - {formatTime(order.createdAt)}
            </p>
          </div>
          <Badge variant={getStatusBadgeVariant(order.status)}>
            {statusInfo.label}
          </Badge>
        </div>
      </CardHeader>

      <CardContent className="space-y-4">
        {/* Customer Info */}
        <div className="flex items-center gap-2 text-sm">
          <User className="h-4 w-4 text-muted-foreground" />
          <span>{order.customer.name}</span>
          <a
            href={`tel:${order.customer.phone}`}
            className="mr-auto text-primary hover:underline"
          >
            <Phone className="h-4 w-4" />
          </a>
        </div>

        {/* Address */}
        <div className="flex items-start gap-2 text-sm">
          <MapPin className="h-4 w-4 text-muted-foreground mt-0.5" />
          <span className="text-muted-foreground">
            {order.deliveryAddress.address}، {order.deliveryAddress.area}
          </span>
        </div>

        {/* Items Summary */}
        <div className="border-t pt-3">
          <div className="flex items-center gap-2 text-sm font-medium mb-2">
            <ShoppingBag className="h-4 w-4" />
            <span>{totalItems} عناصر</span>
          </div>
          <div className="space-y-1">
            {order.items.slice(0, 3).map((item, index) => (
              <div
                key={index}
                className="flex justify-between text-sm text-muted-foreground"
              >
                <span>
                  {item.quantity}x {item.nameAr || item.name}
                </span>
                <span>{(item.price * item.quantity).toFixed(2)} ج.م</span>
              </div>
            ))}
            {order.items.length > 3 && (
              <p className="text-sm text-muted-foreground">
                + {order.items.length - 3} عناصر أخرى
              </p>
            )}
          </div>
        </div>

        {/* Notes */}
        {order.notes && (
          <div className="flex items-start gap-2 text-sm bg-muted/50 p-2 rounded">
            <AlertCircle className="h-4 w-4 text-muted-foreground mt-0.5" />
            <span className="text-muted-foreground">{order.notes}</span>
          </div>
        )}

        {/* Total */}
        <div className="flex items-center justify-between border-t pt-3">
          <span className="font-medium">الإجمالي</span>
          <span className="text-lg font-bold text-primary">
            {order.total.toFixed(2)} ج.م
          </span>
        </div>

        {/* Actions */}
        {order.status === 'pending' && (
          <div className="flex gap-2 pt-2">
            <Button
              variant="default"
              className="flex-1"
              onClick={onAccept}
              disabled={isUpdating}
            >
              <Check className="h-4 w-4 ml-2" />
              قبول
            </Button>
            <Button
              variant="destructive"
              className="flex-1"
              onClick={onReject}
              disabled={isUpdating}
            >
              <X className="h-4 w-4 ml-2" />
              رفض
            </Button>
          </div>
        )}

        {order.status !== 'pending' &&
          order.status !== 'delivered' &&
          order.status !== 'cancelled' &&
          nextStatus && (
            <Button
              className="w-full"
              onClick={() => onUpdateStatus(order._id, nextStatus)}
              disabled={isUpdating}
            >
              {order.status === 'confirmed' && (
                <>
                  <ChefHat className="h-4 w-4 ml-2" />
                  بدء التحضير
                </>
              )}
              {order.status === 'preparing' && (
                <>
                  <Package className="h-4 w-4 ml-2" />
                  جاهز للاستلام
                </>
              )}
            </Button>
          )}
      </CardContent>
    </Card>
  );
}
