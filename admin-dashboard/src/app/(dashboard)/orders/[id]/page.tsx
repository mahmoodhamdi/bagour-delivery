'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Skeleton } from '@/components/ui/skeleton';
import { Separator } from '@/components/ui/separator';
import {
  ArrowLeft,
  Phone,
  MapPin,
  Calendar,
  Package,
  DollarSign,
  User,
  Store,
  Bike,
  Clock,
  CheckCircle,
  XCircle,
} from 'lucide-react';
import { ordersApi, getErrorMessage } from '@/services/api';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';
import { toast } from 'sonner';
import { ORDER_STATUSES } from '@/config/constants';

export default function OrderDetailsPage() {
  const router = useRouter();
  const params = useParams();
  const orderId = params.id as string;

  const [order, setOrder] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchOrder = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await ordersApi.getOrder(orderId);
      if (response.success && response.data) {
        setOrder(response.data.order);
      }
    } catch (err) {
      setError(getErrorMessage(err));
      toast.error(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchOrder();
  }, [orderId]);

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-10 w-48" />
        <div className="grid gap-6 md:grid-cols-3">
          <div className="md:col-span-2">
            <Skeleton className="h-96" />
          </div>
          <Skeleton className="h-96" />
        </div>
      </div>
    );
  }

  if (error || !order) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-red-600">حدث خطأ</CardTitle>
          <CardDescription>{error || 'لم يتم العثور على الطلب'}</CardDescription>
        </CardHeader>
        <CardContent>
          <Button onClick={() => router.back()} variant="outline">
            <ArrowLeft className="ml-2 h-4 w-4" />
            العودة
          </Button>
        </CardContent>
      </Card>
    );
  }

  const statusInfo = ORDER_STATUSES[order.status as keyof typeof ORDER_STATUSES];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <Button variant="ghost" onClick={() => router.back()}>
          <ArrowLeft className="ml-2 h-4 w-4" />
          العودة للطلبات
        </Button>
        <div className="flex items-center gap-4">
          <div className="text-left">
            <p className="text-sm text-muted-foreground">رقم الطلب</p>
            <p className="text-lg font-bold">#{order.orderNumber}</p>
          </div>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        {/* Main Info */}
        <div className="md:col-span-2 space-y-6">
          {/* Order Status */}
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>حالة الطلب</CardTitle>
                <Badge
                  variant={
                    order.status === 'delivered' ? 'default' :
                    order.status === 'cancelled' ? 'destructive' : 'secondary'
                  }
                  className="text-base"
                >
                  {statusInfo.label}
                </Badge>
              </div>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {order.statusHistory && order.statusHistory.length > 0 && (
                  <div className="relative space-y-4">
                    {order.statusHistory.map((history: any, index: number) => {
                      const historyStatusInfo = ORDER_STATUSES[history.status as keyof typeof ORDER_STATUSES];
                      return (
                        <div key={index} className="flex gap-4">
                          <div className="relative flex flex-col items-center">
                            <div className={`flex h-8 w-8 items-center justify-center rounded-full ${
                              index === order.statusHistory.length - 1 ? 'bg-primary' : 'bg-muted'
                            }`}>
                              {index === order.statusHistory.length - 1 ? (
                                <CheckCircle className="h-4 w-4 text-primary-foreground" />
                              ) : (
                                <div className="h-2 w-2 rounded-full bg-muted-foreground" />
                              )}
                            </div>
                            {index < order.statusHistory.length - 1 && (
                              <div className="h-full w-0.5 bg-muted" />
                            )}
                          </div>
                          <div className="flex-1 pb-4">
                            <p className="font-medium">{historyStatusInfo.label}</p>
                            <p className="text-sm text-muted-foreground">
                              {format(new Date(history.timestamp), 'd MMMM yyyy - hh:mm a', { locale: ar })}
                            </p>
                            {history.note && (
                              <p className="text-sm text-muted-foreground mt-1">{history.note}</p>
                            )}
                          </div>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            </CardContent>
          </Card>

          {/* Order Items */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Package className="h-5 w-5" />
                الأصناف ({order.items?.length || 0})
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {order.items?.map((item: any, index: number) => (
                  <div key={index}>
                    {index > 0 && <Separator className="my-4" />}
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <p className="font-medium">{item.name}</p>
                        {item.nameEn && (
                          <p className="text-sm text-muted-foreground">{item.nameEn}</p>
                        )}
                        {item.selectedAddons && item.selectedAddons.length > 0 && (
                          <div className="mt-1 text-sm text-muted-foreground">
                            إضافات: {item.selectedAddons.map((a: any) => a.name).join(', ')}
                          </div>
                        )}
                        {item.selectedVariation && (
                          <div className="text-sm text-muted-foreground">
                            {item.selectedVariation.name}: {item.selectedVariation.option}
                          </div>
                        )}
                        {item.specialInstructions && (
                          <div className="mt-1 text-sm text-muted-foreground">
                            ملاحظات: {item.specialInstructions}
                          </div>
                        )}
                      </div>
                      <div className="text-left">
                        <p className="font-semibold">
                          {item.price.toLocaleString('ar-EG')} ج.م
                        </p>
                        <p className="text-sm text-muted-foreground">
                          الكمية: {item.quantity}
                        </p>
                        <p className="text-sm font-medium">
                          {(item.price * item.quantity).toLocaleString('ar-EG')} ج.م
                        </p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              {/* Order Totals */}
              <div className="mt-6 space-y-2 rounded-lg bg-muted p-4">
                <div className="flex items-center justify-between text-sm">
                  <span>المجموع الفرعي</span>
                  <span>{order.subtotal?.toLocaleString('ar-EG')} ج.م</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span>رسوم التوصيل</span>
                  <span>{order.deliveryFee?.toLocaleString('ar-EG')} ج.م</span>
                </div>
                {order.discount > 0 && (
                  <div className="flex items-center justify-between text-sm text-green-600">
                    <span>الخصم</span>
                    <span>-{order.discount?.toLocaleString('ar-EG')} ج.م</span>
                  </div>
                )}
                <Separator />
                <div className="flex items-center justify-between text-lg font-bold">
                  <span>الإجمالي</span>
                  <span>{order.total?.toLocaleString('ar-EG')} ج.م</span>
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
            <CardContent>
              <div className="space-y-2">
                <p className="font-medium">{order.deliveryAddress?.address}</p>
                <p className="text-sm text-muted-foreground">
                  {order.deliveryAddress?.area} - {order.deliveryAddress?.city}
                </p>
                {order.deliveryAddress?.building && (
                  <p className="text-sm text-muted-foreground">
                    مبنى: {order.deliveryAddress.building}
                  </p>
                )}
                {order.deliveryAddress?.floor && (
                  <p className="text-sm text-muted-foreground">
                    طابق: {order.deliveryAddress.floor}
                  </p>
                )}
                {order.deliveryAddress?.apartment && (
                  <p className="text-sm text-muted-foreground">
                    شقة: {order.deliveryAddress.apartment}
                  </p>
                )}
                {order.deliveryNotes && (
                  <div className="mt-3 rounded-lg bg-muted p-3">
                    <p className="text-sm font-medium">ملاحظات التوصيل:</p>
                    <p className="text-sm text-muted-foreground">{order.deliveryNotes}</p>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Customer Info */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base flex items-center gap-2">
                <User className="h-4 w-4" />
                معلومات العميل
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div className="flex items-center gap-3">
                <Avatar>
                  <AvatarFallback>
                    {order.customer?.name?.charAt(0) || 'ع'}
                  </AvatarFallback>
                </Avatar>
                <div>
                  <p className="font-medium">{order.customer?.name}</p>
                  <div className="flex items-center gap-1 text-sm text-muted-foreground">
                    <Phone className="h-3 w-3" />
                    <span>{order.customer?.phone}</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Restaurant Info */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base flex items-center gap-2">
                <Store className="h-4 w-4" />
                معلومات المطعم
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div>
                <p className="font-medium">{order.restaurant?.name}</p>
                <div className="flex items-center gap-1 text-sm text-muted-foreground">
                  <Phone className="h-3 w-3" />
                  <span>{order.restaurant?.phone}</span>
                </div>
                <div className="flex items-center gap-1 text-sm text-muted-foreground mt-1">
                  <MapPin className="h-3 w-3" />
                  <span>{order.restaurant?.address}</span>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Driver Info */}
          {order.driver && (
            <Card>
              <CardHeader>
                <CardTitle className="text-base flex items-center gap-2">
                  <Bike className="h-4 w-4" />
                  معلومات السائق
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex items-center gap-3">
                  <Avatar>
                    <AvatarFallback>
                      {order.driver?.name?.charAt(0) || 'س'}
                    </AvatarFallback>
                  </Avatar>
                  <div>
                    <p className="font-medium">{order.driver?.name}</p>
                    <div className="flex items-center gap-1 text-sm text-muted-foreground">
                      <Phone className="h-3 w-3" />
                      <span>{order.driver?.phone}</span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Payment Info */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base flex items-center gap-2">
                <DollarSign className="h-4 w-4" />
                معلومات الدفع
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3 text-sm">
              <div className="flex items-center justify-between">
                <span className="text-muted-foreground">طريقة الدفع</span>
                <Badge variant="outline">
                  {order.paymentMethod === 'cash' ? 'نقدي' :
                   order.paymentMethod === 'online' ? 'إلكتروني' :
                   order.paymentMethod === 'wallet' ? 'محفظة' : order.paymentMethod}
                </Badge>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-muted-foreground">حالة الدفع</span>
                <Badge variant={order.paymentStatus === 'paid' ? 'default' : 'secondary'}>
                  {order.paymentStatus === 'paid' ? 'مدفوع' :
                   order.paymentStatus === 'pending' ? 'معلق' :
                   order.paymentStatus === 'failed' ? 'فشل' : order.paymentStatus}
                </Badge>
              </div>
              {order.couponCode && (
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">كوبون الخصم</span>
                  <Badge variant="outline">{order.couponCode}</Badge>
                </div>
              )}
            </CardContent>
          </Card>

          {/* Timing Info */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base flex items-center gap-2">
                <Clock className="h-4 w-4" />
                الأوقات
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3 text-sm">
              <div>
                <p className="text-muted-foreground">تاريخ الطلب</p>
                <p className="font-medium">
                  {format(new Date(order.createdAt), 'd MMMM yyyy', { locale: ar })}
                </p>
                <p className="text-xs text-muted-foreground">
                  {format(new Date(order.createdAt), 'hh:mm a', { locale: ar })}
                </p>
              </div>
              {order.estimatedDeliveryTime && (
                <>
                  <Separator />
                  <div>
                    <p className="text-muted-foreground">وقت التوصيل المتوقع</p>
                    <p className="font-medium">{order.estimatedDeliveryTime} دقيقة</p>
                  </div>
                </>
              )}
              {order.deliveredAt && (
                <>
                  <Separator />
                  <div>
                    <p className="text-muted-foreground">تم التوصيل</p>
                    <p className="font-medium">
                      {format(new Date(order.deliveredAt), 'd MMMM yyyy - hh:mm a', { locale: ar })}
                    </p>
                  </div>
                </>
              )}
            </CardContent>
          </Card>

          {/* Order ID */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">معلومات النظام</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2 text-sm">
              <div>
                <p className="text-muted-foreground">معرف الطلب</p>
                <p className="font-mono text-xs">{order._id}</p>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
