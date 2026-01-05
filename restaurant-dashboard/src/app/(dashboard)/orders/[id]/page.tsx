'use client';

import { useEffect, useState, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { ordersApi, Order, getErrorMessage } from '@/lib/api';
import { ORDER_STATUSES } from '@/config/constants';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Separator } from '@/components/ui/separator';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  ArrowRight,
  Clock,
  MapPin,
  Phone,
  User,
  ShoppingBag,
  CreditCard,
  Check,
  X,
  ChefHat,
  Package,
  Truck,
  CheckCircle,
  XCircle,
  MessageSquare,
  RefreshCw,
  Copy,
  Printer,
} from 'lucide-react';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';
import { getSocket, emitOrderStatusUpdate } from '@/lib/socket';

type OrderStatus = Order['status'];

export default function OrderDetailsPage() {
  const params = useParams();
  const router = useRouter();
  const orderId = params.id as string;

  const [order, setOrder] = useState<Order | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isUpdating, setIsUpdating] = useState(false);
  const [showAcceptDialog, setShowAcceptDialog] = useState(false);
  const [showRejectDialog, setShowRejectDialog] = useState(false);
  const [estimatedTime, setEstimatedTime] = useState('30');
  const [rejectReason, setRejectReason] = useState('');

  const fetchOrder = useCallback(async () => {
    try {
      setIsLoading(true);
      const response = await ordersApi.getOrder(orderId);
      if (response.success && response.data) {
        setOrder(response.data.order);
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
      router.push('/orders');
    } finally {
      setIsLoading(false);
    }
  }, [orderId, router]);

  useEffect(() => {
    fetchOrder();
  }, [fetchOrder]);

  // Listen for real-time order updates
  useEffect(() => {
    const socket = getSocket();
    if (socket && order) {
      const handleStatusUpdate = (data: { orderId: string; status: OrderStatus }) => {
        if (data.orderId === order._id) {
          setOrder((prev) => prev ? { ...prev, status: data.status } : null);
          toast.info('تم تحديث حالة الطلب');
        }
      };

      socket.on('order:status', handleStatusUpdate);
      return () => {
        socket.off('order:status', handleStatusUpdate);
      };
    }
  }, [order]);

  const handleAcceptOrder = async () => {
    if (!order) return;

    setIsUpdating(true);
    try {
      const response = await ordersApi.acceptOrder(order._id, parseInt(estimatedTime));
      if (response.success && response.data) {
        setOrder(response.data.order);
        toast.success('تم قبول الطلب بنجاح');
        setShowAcceptDialog(false);
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsUpdating(false);
    }
  };

  const handleRejectOrder = async () => {
    if (!order || !rejectReason.trim()) return;

    setIsUpdating(true);
    try {
      const response = await ordersApi.rejectOrder(order._id, rejectReason);
      if (response.success && response.data) {
        setOrder(response.data.order);
        toast.success('تم رفض الطلب');
        setShowRejectDialog(false);
        setRejectReason('');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsUpdating(false);
    }
  };

  const handleUpdateStatus = async (newStatus: OrderStatus) => {
    if (!order) return;

    setIsUpdating(true);
    try {
      const response = await ordersApi.updateOrderStatus(order._id, newStatus);
      if (response.success && response.data) {
        setOrder(response.data.order);
        emitOrderStatusUpdate(order._id, newStatus);
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

  const getStatusBadgeVariant = (status: OrderStatus): 'default' | 'secondary' | 'destructive' => {
    switch (status) {
      case 'pending':
        return 'secondary';
      case 'cancelled':
        return 'destructive';
      default:
        return 'default';
    }
  };

  const getStatusIcon = (status: OrderStatus) => {
    switch (status) {
      case 'pending':
        return <Clock className="h-5 w-5" />;
      case 'confirmed':
        return <Check className="h-5 w-5" />;
      case 'preparing':
        return <ChefHat className="h-5 w-5" />;
      case 'ready':
        return <Package className="h-5 w-5" />;
      case 'picked_up':
      case 'on_the_way':
        return <Truck className="h-5 w-5" />;
      case 'delivered':
        return <CheckCircle className="h-5 w-5" />;
      case 'cancelled':
        return <XCircle className="h-5 w-5" />;
      default:
        return <Clock className="h-5 w-5" />;
    }
  };

  const getPaymentMethodLabel = (method: string) => {
    const methods: Record<string, string> = {
      cash: 'نقداً عند الاستلام',
      card: 'بطاقة ائتمان',
      wallet: 'محفظة إلكترونية',
    };
    return methods[method] || method;
  };

  const getPaymentStatusLabel = (status: string) => {
    const statuses: Record<string, { label: string; color: string }> = {
      pending: { label: 'في انتظار الدفع', color: 'text-yellow-600' },
      paid: { label: 'مدفوع', color: 'text-green-600' },
      failed: { label: 'فشل الدفع', color: 'text-red-600' },
      refunded: { label: 'تم الاسترداد', color: 'text-blue-600' },
    };
    return statuses[status] || { label: status, color: 'text-gray-600' };
  };

  const copyOrderNumber = () => {
    if (order) {
      navigator.clipboard.writeText(order.orderNumber);
      toast.success('تم نسخ رقم الطلب');
    }
  };

  const handlePrint = () => {
    window.print();
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <Skeleton className="h-10 w-10" />
          <Skeleton className="h-8 w-48" />
        </div>
        <div className="grid gap-6 md:grid-cols-3">
          <div className="md:col-span-2 space-y-6">
            <Skeleton className="h-64" />
            <Skeleton className="h-48" />
          </div>
          <div className="space-y-6">
            <Skeleton className="h-48" />
            <Skeleton className="h-32" />
          </div>
        </div>
      </div>
    );
  }

  if (!order) {
    return (
      <Card>
        <CardContent className="flex flex-col items-center justify-center py-12">
          <ShoppingBag className="h-12 w-12 text-muted-foreground mb-4" />
          <h3 className="text-lg font-semibold mb-2">الطلب غير موجود</h3>
          <p className="text-muted-foreground mb-4">لم يتم العثور على الطلب المطلوب</p>
          <Button onClick={() => router.push('/orders')}>
            <ArrowRight className="h-4 w-4 ml-2" />
            العودة للطلبات
          </Button>
        </CardContent>
      </Card>
    );
  }

  const statusInfo = ORDER_STATUSES[order.status];
  const nextStatus = getNextStatus(order.status);
  const paymentStatus = getPaymentStatusLabel(order.paymentStatus);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button variant="ghost" size="icon" onClick={() => router.push('/orders')}>
            <ArrowRight className="h-5 w-5" />
          </Button>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-bold">طلب #{order.orderNumber}</h1>
              <Button variant="ghost" size="icon" onClick={copyOrderNumber}>
                <Copy className="h-4 w-4" />
              </Button>
            </div>
            <p className="text-muted-foreground">
              {format(new Date(order.createdAt), 'EEEE، d MMMM yyyy - hh:mm a', { locale: ar })}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" onClick={fetchOrder}>
            <RefreshCw className="h-4 w-4 ml-2" />
            تحديث
          </Button>
          <Button variant="outline" size="sm" onClick={handlePrint}>
            <Printer className="h-4 w-4 ml-2" />
            طباعة
          </Button>
          <Badge variant={getStatusBadgeVariant(order.status)} className="text-sm px-3 py-1">
            {getStatusIcon(order.status)}
            <span className="mr-2">{statusInfo.label}</span>
          </Badge>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        {/* Main Content */}
        <div className="md:col-span-2 space-y-6">
          {/* Order Items */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <ShoppingBag className="h-5 w-5" />
                تفاصيل الطلب
              </CardTitle>
              <CardDescription>
                {order.items.reduce((sum, item) => sum + item.quantity, 0)} عناصر
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {order.items.map((item, index) => (
                  <div key={index} className="flex gap-4">
                    {item.image ? (
                      <img
                        src={item.image}
                        alt={item.nameAr || item.name}
                        className="h-16 w-16 rounded-lg object-cover"
                      />
                    ) : (
                      <div className="h-16 w-16 rounded-lg bg-muted flex items-center justify-center">
                        <ShoppingBag className="h-6 w-6 text-muted-foreground" />
                      </div>
                    )}
                    <div className="flex-1">
                      <div className="flex items-start justify-between">
                        <div>
                          <h4 className="font-medium">{item.nameAr || item.name}</h4>
                          <p className="text-sm text-muted-foreground">
                            {item.quantity} x {item.price.toFixed(2)} ج.م
                          </p>
                        </div>
                        <span className="font-semibold">
                          {(item.quantity * item.price).toFixed(2)} ج.م
                        </span>
                      </div>

                      {/* Variations */}
                      {item.variations && item.variations.length > 0 && (
                        <div className="mt-1 text-sm text-muted-foreground">
                          {item.variations.map((v, i) => (
                            <span key={i}>
                              {v.nameAr || v.name}: {v.optionAr || v.option}
                              {v.price > 0 && ` (+${v.price.toFixed(2)} ج.م)`}
                              {i < item.variations!.length - 1 && ' | '}
                            </span>
                          ))}
                        </div>
                      )}

                      {/* Addons */}
                      {item.addons && item.addons.length > 0 && (
                        <div className="mt-1 text-sm text-muted-foreground">
                          الإضافات: {item.addons.map((a, i) => (
                            <span key={i}>
                              {a.nameAr || a.name}
                              {a.quantity > 1 && ` x${a.quantity}`}
                              {` (+${(a.price * a.quantity).toFixed(2)} ج.م)`}
                              {i < item.addons!.length - 1 && ', '}
                            </span>
                          ))}
                        </div>
                      )}

                      {/* Special Instructions */}
                      {item.specialInstructions && (
                        <div className="mt-2 text-sm bg-muted/50 p-2 rounded flex items-start gap-2">
                          <MessageSquare className="h-4 w-4 mt-0.5 text-muted-foreground" />
                          <span>{item.specialInstructions}</span>
                        </div>
                      )}
                    </div>
                  </div>
                ))}

                <Separator />

                {/* Order Summary */}
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">المجموع الفرعي</span>
                    <span>{order.subtotal.toFixed(2)} ج.م</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">رسوم التوصيل</span>
                    <span>{order.deliveryFee.toFixed(2)} ج.م</span>
                  </div>
                  {order.discount > 0 && (
                    <div className="flex justify-between text-sm text-green-600">
                      <span>الخصم</span>
                      <span>-{order.discount.toFixed(2)} ج.م</span>
                    </div>
                  )}
                  <Separator />
                  <div className="flex justify-between text-lg font-bold">
                    <span>الإجمالي</span>
                    <span className="text-primary">{order.total.toFixed(2)} ج.م</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Order Notes */}
          {order.notes && (
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <MessageSquare className="h-5 w-5" />
                  ملاحظات العميل
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-muted-foreground">{order.notes}</p>
              </CardContent>
            </Card>
          )}

          {/* Cancellation Reason */}
          {order.status === 'cancelled' && order.cancellationReason && (
            <Card className="border-destructive">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-destructive">
                  <XCircle className="h-5 w-5" />
                  سبب الإلغاء
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-muted-foreground">{order.cancellationReason}</p>
              </CardContent>
            </Card>
          )}
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Customer Info */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <User className="h-5 w-5" />
                بيانات العميل
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center">
                  <User className="h-5 w-5 text-primary" />
                </div>
                <div>
                  <p className="font-medium">{order.customer.name}</p>
                  <a
                    href={`tel:${order.customer.phone}`}
                    className="text-sm text-primary hover:underline flex items-center gap-1"
                  >
                    <Phone className="h-3 w-3" />
                    {order.customer.phone}
                  </a>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Delivery Address */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <MapPin className="h-5 w-5" />
                عنوان التوصيل
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              {order.deliveryAddress.name && (
                <p className="font-medium">{order.deliveryAddress.name}</p>
              )}
              <p className="text-muted-foreground">
                {order.deliveryAddress.address}
              </p>
              <p className="text-muted-foreground">
                {order.deliveryAddress.area}، {order.deliveryAddress.city}
              </p>
              {(order.deliveryAddress.building || order.deliveryAddress.floor || order.deliveryAddress.apartment) && (
                <p className="text-sm text-muted-foreground">
                  {order.deliveryAddress.building && `مبنى: ${order.deliveryAddress.building}`}
                  {order.deliveryAddress.floor && ` | دور: ${order.deliveryAddress.floor}`}
                  {order.deliveryAddress.apartment && ` | شقة: ${order.deliveryAddress.apartment}`}
                </p>
              )}
              {order.deliveryAddress.landmark && (
                <p className="text-sm text-muted-foreground">
                  علامة مميزة: {order.deliveryAddress.landmark}
                </p>
              )}
            </CardContent>
          </Card>

          {/* Payment Info */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <CreditCard className="h-5 w-5" />
                بيانات الدفع
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div className="flex justify-between">
                <span className="text-muted-foreground">طريقة الدفع</span>
                <span className="font-medium">{getPaymentMethodLabel(order.paymentMethod)}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">حالة الدفع</span>
                <span className={`font-medium ${paymentStatus.color}`}>
                  {paymentStatus.label}
                </span>
              </div>
            </CardContent>
          </Card>

          {/* Driver Info */}
          {order.driver && (
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Truck className="h-5 w-5" />
                  بيانات السائق
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex items-center gap-3">
                  {order.driver.avatar ? (
                    <img
                      src={order.driver.avatar}
                      alt={order.driver.name}
                      className="h-10 w-10 rounded-full object-cover"
                    />
                  ) : (
                    <div className="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center">
                      <User className="h-5 w-5 text-primary" />
                    </div>
                  )}
                  <div>
                    <p className="font-medium">{order.driver.name}</p>
                    {order.driver.phone && (
                      <a
                        href={`tel:${order.driver.phone}`}
                        className="text-sm text-primary hover:underline flex items-center gap-1"
                      >
                        <Phone className="h-3 w-3" />
                        {order.driver.phone}
                      </a>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Actions */}
          <Card>
            <CardHeader>
              <CardTitle>الإجراءات</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              {order.status === 'pending' && (
                <>
                  <Button
                    className="w-full"
                    onClick={() => setShowAcceptDialog(true)}
                    disabled={isUpdating}
                  >
                    <Check className="h-4 w-4 ml-2" />
                    قبول الطلب
                  </Button>
                  <Button
                    variant="destructive"
                    className="w-full"
                    onClick={() => setShowRejectDialog(true)}
                    disabled={isUpdating}
                  >
                    <X className="h-4 w-4 ml-2" />
                    رفض الطلب
                  </Button>
                </>
              )}

              {order.status === 'confirmed' && (
                <Button
                  className="w-full"
                  onClick={() => handleUpdateStatus('preparing')}
                  disabled={isUpdating}
                >
                  <ChefHat className="h-4 w-4 ml-2" />
                  بدء التحضير
                </Button>
              )}

              {order.status === 'preparing' && (
                <Button
                  className="w-full"
                  onClick={() => handleUpdateStatus('ready')}
                  disabled={isUpdating}
                >
                  <Package className="h-4 w-4 ml-2" />
                  جاهز للاستلام
                </Button>
              )}

              {['delivered', 'cancelled'].includes(order.status) && (
                <p className="text-center text-muted-foreground text-sm">
                  لا توجد إجراءات متاحة لهذا الطلب
                </p>
              )}

              {order.status === 'ready' && (
                <p className="text-center text-muted-foreground text-sm">
                  في انتظار استلام السائق للطلب
                </p>
              )}
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Accept Dialog */}
      <Dialog open={showAcceptDialog} onOpenChange={setShowAcceptDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>قبول الطلب #{order.orderNumber}</DialogTitle>
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
                  <SelectItem value="90">ساعة ونصف</SelectItem>
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
            <DialogTitle>رفض الطلب #{order.orderNumber}</DialogTitle>
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
