'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Skeleton } from '@/components/ui/skeleton';
import { Separator } from '@/components/ui/separator';
import { Textarea } from '@/components/ui/textarea';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  ArrowLeft,
  Mail,
  Phone,
  MapPin,
  Calendar,
  Star,
  Clock,
  DollarSign,
  CheckCircle,
  XCircle,
  Ban,
  Unlock,
  Package,
  Users,
} from 'lucide-react';
import { restaurantsApi, getErrorMessage } from '@/services/api';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';
import { toast } from 'sonner';
import { RESTAURANT_STATUSES } from '@/config/constants';

export default function RestaurantDetailsPage() {
  const router = useRouter();
  const params = useParams();
  const restaurantId = params.id as string;

  const [restaurant, setRestaurant] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Action dialogs
  const [actionDialog, setActionDialog] = useState<{
    open: boolean;
    type: 'approve' | 'reject' | 'suspend' | 'activate' | null;
    reason: string;
  }>({ open: false, type: null, reason: '' });
  const [isActionLoading, setIsActionLoading] = useState(false);

  const fetchRestaurant = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await restaurantsApi.getRestaurantById(restaurantId);
      if (response.success && response.data) {
        setRestaurant(response.data);
      }
    } catch (err) {
      setError(getErrorMessage(err));
      toast.error(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchRestaurant();
  }, [restaurantId]);

  const handleAction = async () => {
    if (!actionDialog.type) return;

    setIsActionLoading(true);
    try {
      let response;
      switch (actionDialog.type) {
        case 'approve':
          response = await restaurantsApi.approveRestaurant(restaurantId);
          break;
        case 'reject':
          response = await restaurantsApi.rejectRestaurant(restaurantId, actionDialog.reason);
          break;
        case 'suspend':
          response = await restaurantsApi.suspendRestaurant(restaurantId, actionDialog.reason);
          break;
        case 'activate':
          response = await restaurantsApi.activateRestaurant(restaurantId);
          break;
      }

      if (response && response.success) {
        toast.success('تم تنفيذ الإجراء بنجاح');
        setActionDialog({ open: false, type: null, reason: '' });
        fetchRestaurant();
      }
    } catch (err) {
      toast.error(getErrorMessage(err));
    } finally {
      setIsActionLoading(false);
    }
  };

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

  if (error || !restaurant) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-red-600">حدث خطأ</CardTitle>
          <CardDescription>{error || 'لم يتم العثور على المطعم'}</CardDescription>
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

  const statusInfo = RESTAURANT_STATUSES[restaurant.status as keyof typeof RESTAURANT_STATUSES];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <Button variant="ghost" onClick={() => router.back()}>
          <ArrowLeft className="ml-2 h-4 w-4" />
          العودة للمطاعم
        </Button>
        <div className="flex gap-2">
          {restaurant.status === 'pending' && (
            <>
              <Button
                variant="default"
                onClick={() => setActionDialog({ open: true, type: 'approve', reason: '' })}
              >
                <CheckCircle className="ml-2 h-4 w-4" />
                موافقة
              </Button>
              <Button
                variant="destructive"
                onClick={() => setActionDialog({ open: true, type: 'reject', reason: '' })}
              >
                <XCircle className="ml-2 h-4 w-4" />
                رفض
              </Button>
            </>
          )}
          {restaurant.status === 'approved' && (
            <Button
              variant="destructive"
              onClick={() => setActionDialog({ open: true, type: 'suspend', reason: '' })}
            >
              <Ban className="ml-2 h-4 w-4" />
              إيقاف
            </Button>
          )}
          {restaurant.status === 'suspended' && (
            <Button
              variant="default"
              onClick={() => setActionDialog({ open: true, type: 'activate', reason: '' })}
            >
              <Unlock className="ml-2 h-4 w-4" />
              تفعيل
            </Button>
          )}
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        {/* Main Info */}
        <div className="md:col-span-2 space-y-6">
          {/* Restaurant Profile Card */}
          <Card>
            <CardHeader>
              <CardTitle>معلومات المطعم</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-6">
                {/* Cover & Logo */}
                <div className="relative">
                  {restaurant.coverImage && (
                    <div className="h-48 w-full overflow-hidden rounded-lg">
                      <img
                        src={restaurant.coverImage}
                        alt="Cover"
                        className="h-full w-full object-cover"
                      />
                    </div>
                  )}
                  {restaurant.logo && (
                    <Avatar className="absolute -bottom-8 right-6 h-20 w-20 border-4 border-background">
                      <AvatarImage src={restaurant.logo} />
                      <AvatarFallback className="text-2xl">
                        {restaurant.name.charAt(0)}
                      </AvatarFallback>
                    </Avatar>
                  )}
                </div>

                {/* Basic Info */}
                <div className="space-y-4 pt-8">
                  <div>
                    <h2 className="text-2xl font-bold">{restaurant.name}</h2>
                    {restaurant.nameEn && (
                      <p className="text-muted-foreground">{restaurant.nameEn}</p>
                    )}
                    <div className="mt-2 flex flex-wrap gap-2">
                      <Badge
                        variant={statusInfo.color === 'green' ? 'default' : 'destructive'}
                      >
                        {statusInfo.label}
                      </Badge>
                      <Badge variant={restaurant.isOpen ? 'default' : 'secondary'}>
                        {restaurant.isOpen ? 'مفتوح' : 'مغلق'}
                      </Badge>
                      {restaurant.cuisineTypes?.map((cuisine: string) => (
                        <Badge key={cuisine} variant="outline">
                          {cuisine}
                        </Badge>
                      ))}
                    </div>
                  </div>

                  <div className="grid gap-3 sm:grid-cols-2">
                    <div className="flex items-center gap-2 text-sm">
                      <Mail className="h-4 w-4 text-muted-foreground" />
                      <span>{restaurant.email}</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <Phone className="h-4 w-4 text-muted-foreground" />
                      <span>{restaurant.phone}</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <MapPin className="h-4 w-4 text-muted-foreground" />
                      <span>
                        {restaurant.address?.street}, {restaurant.address?.area}
                      </span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <Calendar className="h-4 w-4 text-muted-foreground" />
                      <span>
                        انضم {format(new Date(restaurant.createdAt), 'd MMMM yyyy', { locale: ar })}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Delivery Settings */}
          <Card>
            <CardHeader>
              <CardTitle>إعدادات التوصيل</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid gap-4 sm:grid-cols-3">
                <div className="space-y-1">
                  <p className="text-sm text-muted-foreground">رسوم التوصيل</p>
                  <p className="text-xl font-bold">
                    {restaurant.deliveryFee || 0} ج.م
                  </p>
                </div>
                <div className="space-y-1">
                  <p className="text-sm text-muted-foreground">الحد الأدنى للطلب</p>
                  <p className="text-xl font-bold">
                    {restaurant.minimumOrder || 0} ج.م
                  </p>
                </div>
                <div className="space-y-1">
                  <p className="text-sm text-muted-foreground">وقت التوصيل</p>
                  <p className="text-xl font-bold">
                    {restaurant.averageDeliveryTime || 30} دقيقة
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Working Hours */}
          {restaurant.workingHours && restaurant.workingHours.length > 0 && (
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Clock className="h-5 w-5" />
                  ساعات العمل
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  {restaurant.workingHours.map((day: any) => (
                    <div key={day.day} className="flex items-center justify-between">
                      <span className="font-medium">{day.day}</span>
                      {day.isOpen ? (
                        <span className="text-sm text-muted-foreground">
                          {day.openTime} - {day.closeTime}
                        </span>
                      ) : (
                        <Badge variant="secondary">مغلق</Badge>
                      )}
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          )}
        </div>

        {/* Stats Sidebar */}
        <div className="space-y-6">
          {/* Rating Stats */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">التقييمات</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Star className="h-5 w-5 fill-yellow-400 text-yellow-400" />
                  <span className="text-2xl font-bold">
                    {restaurant.rating?.toFixed(1) || '0.0'}
                  </span>
                </div>
                <span className="text-sm text-muted-foreground">
                  ({restaurant.totalReviews || 0} تقييم)
                </span>
              </div>
            </CardContent>
          </Card>

          {/* Order Stats */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">إحصائيات الطلبات</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Package className="h-4 w-4 text-muted-foreground" />
                  <span className="text-sm">إجمالي الطلبات</span>
                </div>
                <span className="text-lg font-bold">
                  {restaurant.totalOrders || 0}
                </span>
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <DollarSign className="h-4 w-4 text-muted-foreground" />
                  <span className="text-sm">إجمالي الإيرادات</span>
                </div>
                <span className="text-lg font-bold">
                  {restaurant.totalRevenue?.toLocaleString('ar-EG') || 0} ج.م
                </span>
              </div>
            </CardContent>
          </Card>

          {/* Owner Info */}
          {restaurant.owner && (
            <Card>
              <CardHeader>
                <CardTitle className="text-base">صاحب المطعم</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex items-center gap-3">
                  <Users className="h-4 w-4 text-muted-foreground" />
                  <div>
                    <p className="font-medium">{restaurant.owner.name}</p>
                    <p className="text-sm text-muted-foreground">{restaurant.owner.email}</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Account Info */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">معلومات الحساب</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3 text-sm">
              <div>
                <p className="text-muted-foreground">رقم المطعم</p>
                <p className="font-mono text-xs">{restaurant._id}</p>
              </div>
              <Separator />
              <div>
                <p className="text-muted-foreground">تاريخ الإنشاء</p>
                <p>{format(new Date(restaurant.createdAt), 'dd/MM/yyyy', { locale: ar })}</p>
              </div>
              <Separator />
              <div>
                <p className="text-muted-foreground">آخر تحديث</p>
                <p>{format(new Date(restaurant.updatedAt), 'dd/MM/yyyy', { locale: ar })}</p>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Action Dialog */}
      <Dialog open={actionDialog.open} onOpenChange={(open) => setActionDialog({ ...actionDialog, open })}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {actionDialog.type === 'approve' && 'الموافقة على المطعم'}
              {actionDialog.type === 'reject' && 'رفض المطعم'}
              {actionDialog.type === 'suspend' && 'إيقاف المطعم'}
              {actionDialog.type === 'activate' && 'تفعيل المطعم'}
            </DialogTitle>
            <DialogDescription>
              {actionDialog.type === 'approve' && 'هل أنت متأكد من الموافقة على هذا المطعم؟'}
              {actionDialog.type === 'reject' && 'يرجى توضيح سبب الرفض'}
              {actionDialog.type === 'suspend' && 'يرجى توضيح سبب الإيقاف'}
              {actionDialog.type === 'activate' && 'هل أنت متأكد من تفعيل هذا المطعم؟'}
            </DialogDescription>
          </DialogHeader>
          {(actionDialog.type === 'reject' || actionDialog.type === 'suspend') && (
            <Textarea
              placeholder="اكتب السبب هنا..."
              value={actionDialog.reason}
              onChange={(e) => setActionDialog({ ...actionDialog, reason: e.target.value })}
              rows={4}
            />
          )}
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setActionDialog({ open: false, type: null, reason: '' })}
            >
              إلغاء
            </Button>
            <Button
              variant={actionDialog.type === 'approve' || actionDialog.type === 'activate' ? 'default' : 'destructive'}
              onClick={handleAction}
              disabled={isActionLoading || ((actionDialog.type === 'reject' || actionDialog.type === 'suspend') && !actionDialog.reason.trim())}
            >
              {isActionLoading ? 'جاري المعالجة...' : 'تأكيد'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
