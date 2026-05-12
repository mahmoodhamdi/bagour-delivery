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
  Bike,
  FileText,
  CheckCircle,
  XCircle,
  Ban,
  Unlock,
  Package,
  DollarSign,
  TrendingUp,
} from 'lucide-react';
import { driversApi, getErrorMessage } from '@/services/api';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';
import { toast } from 'sonner';
import { DRIVER_STATUSES } from '@/config/constants';

export default function DriverDetailsPage() {
  const router = useRouter();
  const params = useParams();
  const driverId = params.id as string;

  const [driver, setDriver] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Action dialogs
  const [actionDialog, setActionDialog] = useState<{
    open: boolean;
    type: 'approve' | 'reject' | 'suspend' | 'activate' | null;
    reason: string;
  }>({ open: false, type: null, reason: '' });
  const [isActionLoading, setIsActionLoading] = useState(false);

  // Document viewer
  const [documentDialog, setDocumentDialog] = useState<{
    open: boolean;
    url: string;
    title: string;
  }>({ open: false, url: '', title: '' });

  const fetchDriver = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await driversApi.getDriverById(driverId);
      if (response.success && response.data) {
        setDriver(response.data);
      }
    } catch (err) {
      setError(getErrorMessage(err));
      toast.error(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchDriver();
  }, [driverId]);

  const handleAction = async () => {
    if (!actionDialog.type) return;

    setIsActionLoading(true);
    try {
      let response;
      switch (actionDialog.type) {
        case 'approve':
          response = await driversApi.approveDriver(driverId);
          break;
        case 'reject':
          response = await driversApi.rejectDriver(driverId, actionDialog.reason);
          break;
        case 'suspend':
          response = await driversApi.suspendDriver(driverId, actionDialog.reason);
          break;
        case 'activate':
          response = await driversApi.activateDriver(driverId);
          break;
      }

      if (response && response.success) {
        toast.success('تم تنفيذ الإجراء بنجاح');
        setActionDialog({ open: false, type: null, reason: '' });
        fetchDriver();
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

  if (error || !driver) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-red-600">حدث خطأ</CardTitle>
          <CardDescription>{error || 'لم يتم العثور على السائق'}</CardDescription>
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

  const statusInfo = DRIVER_STATUSES[driver.status as keyof typeof DRIVER_STATUSES];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <Button variant="ghost" onClick={() => router.back()}>
          <ArrowLeft className="ml-2 h-4 w-4" />
          العودة للسائقين
        </Button>
        <div className="flex gap-2">
          {driver.status === 'pending' && (
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
          {driver.status === 'approved' && (
            <Button
              variant="destructive"
              onClick={() => setActionDialog({ open: true, type: 'suspend', reason: '' })}
            >
              <Ban className="ml-2 h-4 w-4" />
              إيقاف
            </Button>
          )}
          {driver.status === 'suspended' && (
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
          {/* Driver Profile Card */}
          <Card>
            <CardHeader>
              <CardTitle>معلومات السائق</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-start gap-6">
                <Avatar className="h-24 w-24">
                  <AvatarImage src={driver.avatar} />
                  <AvatarFallback className="text-2xl">
                    {driver.name?.charAt(0) || 'س'}
                  </AvatarFallback>
                </Avatar>
                <div className="flex-1 space-y-4">
                  <div>
                    <h2 className="text-2xl font-bold">{driver.name}</h2>
                    <div className="mt-2 flex flex-wrap gap-2">
                      <Badge
                        variant={statusInfo.color === 'green' ? 'default' : 'destructive'}
                      >
                        {statusInfo.label}
                      </Badge>
                      <Badge variant={driver.isOnline ? 'default' : 'secondary'}>
                        {driver.isOnline ? 'متصل' : 'غير متصل'}
                      </Badge>
                      <Badge variant="outline">سائق</Badge>
                    </div>
                  </div>

                  <div className="grid gap-3 sm:grid-cols-2">
                    <div className="flex items-center gap-2 text-sm">
                      <Mail className="h-4 w-4 text-muted-foreground" />
                      <span>{driver.email}</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <Phone className="h-4 w-4 text-muted-foreground" />
                      <span>{driver.phone}</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <Calendar className="h-4 w-4 text-muted-foreground" />
                      <span>
                        انضم {format(new Date(driver.createdAt), 'd MMMM yyyy', { locale: ar })}
                      </span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <Star className="h-4 w-4 fill-yellow-400 text-yellow-400" />
                      <span>التقييم: {driver.rating?.toFixed(1) || '0.0'}</span>
                    </div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Vehicle Info */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Bike className="h-5 w-5" />
                معلومات المركبة
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid gap-4 sm:grid-cols-2">
                <div className="space-y-1">
                  <p className="text-sm text-muted-foreground">نوع المركبة</p>
                  <p className="text-lg font-semibold">
                    {driver.vehicleType === 'motorcycle' ? 'دراجة نارية' :
                     driver.vehicleType === 'bicycle' ? 'دراجة هوائية' :
                     driver.vehicleType === 'car' ? 'سيارة' : driver.vehicleType}
                  </p>
                </div>
                <div className="space-y-1">
                  <p className="text-sm text-muted-foreground">رقم اللوحة</p>
                  <p className="text-lg font-mono font-semibold">
                    {driver.vehiclePlate || 'غير محدد'}
                  </p>
                </div>
                {driver.vehicleModel && (
                  <div className="space-y-1">
                    <p className="text-sm text-muted-foreground">الموديل</p>
                    <p className="text-lg font-semibold">{driver.vehicleModel}</p>
                  </div>
                )}
                {driver.vehicleColor && (
                  <div className="space-y-1">
                    <p className="text-sm text-muted-foreground">اللون</p>
                    <p className="text-lg font-semibold">{driver.vehicleColor}</p>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>

          {/* Documents */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <FileText className="h-5 w-5" />
                المستندات
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {driver.nationalId && (
                  <div className="flex items-center justify-between rounded-lg border p-3">
                    <div className="flex items-center gap-3">
                      <FileText className="h-5 w-5 text-muted-foreground" />
                      <div>
                        <p className="font-medium">البطاقة الشخصية</p>
                        <p className="text-sm text-muted-foreground">
                          {driver.nationalIdExpiry ? `تنتهي: ${format(new Date(driver.nationalIdExpiry), 'd/MM/yyyy')}` : ''}
                        </p>
                      </div>
                    </div>
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => setDocumentDialog({ open: true, url: driver.nationalId, title: 'البطاقة الشخصية' })}
                    >
                      عرض
                    </Button>
                  </div>
                )}
                {driver.drivingLicense && (
                  <div className="flex items-center justify-between rounded-lg border p-3">
                    <div className="flex items-center gap-3">
                      <FileText className="h-5 w-5 text-muted-foreground" />
                      <div>
                        <p className="font-medium">رخصة القيادة</p>
                        <p className="text-sm text-muted-foreground">
                          {driver.licenseExpiry ? `تنتهي: ${format(new Date(driver.licenseExpiry), 'd/MM/yyyy')}` : ''}
                        </p>
                      </div>
                    </div>
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => setDocumentDialog({ open: true, url: driver.drivingLicense, title: 'رخصة القيادة' })}
                    >
                      عرض
                    </Button>
                  </div>
                )}
                {driver.vehicleRegistration && (
                  <div className="flex items-center justify-between rounded-lg border p-3">
                    <div className="flex items-center gap-3">
                      <FileText className="h-5 w-5 text-muted-foreground" />
                      <div>
                        <p className="font-medium">رخصة المركبة</p>
                      </div>
                    </div>
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => setDocumentDialog({ open: true, url: driver.vehicleRegistration, title: 'رخصة المركبة' })}
                    >
                      عرض
                    </Button>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Stats Sidebar */}
        <div className="space-y-6">
          {/* Delivery Stats */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">إحصائيات التوصيل</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Package className="h-4 w-4 text-muted-foreground" />
                  <span className="text-sm">إجمالي التوصيلات</span>
                </div>
                <span className="text-lg font-bold">
                  {driver.totalDeliveries || 0}
                </span>
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Star className="h-4 w-4 text-muted-foreground" />
                  <span className="text-sm">التقييم</span>
                </div>
                <div className="flex items-center gap-1">
                  <span className="text-lg font-bold">
                    {driver.rating?.toFixed(1) || '0.0'}
                  </span>
                  <Star className="h-4 w-4 fill-yellow-400 text-yellow-400" />
                </div>
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <span className="text-sm">معدل الإكمال</span>
                <span className="text-lg font-bold">
                  {driver.totalDeliveries
                    ? Math.round(((driver.completedDeliveries || 0) / driver.totalDeliveries) * 100)
                    : 0}%
                </span>
              </div>
            </CardContent>
          </Card>

          {/* Earnings Stats */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">الأرباح</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <DollarSign className="h-4 w-4 text-muted-foreground" />
                  <span className="text-sm">إجمالي الأرباح</span>
                </div>
                <span className="text-lg font-bold">
                  {driver.totalEarnings?.toLocaleString('ar-EG') || 0} ج.م
                </span>
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <span className="text-sm">الرصيد المتاح</span>
                <span className="text-lg font-bold text-green-600">
                  {driver.balance?.toLocaleString('ar-EG') || 0} ج.م
                </span>
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <span className="text-sm">متوسط الربح لكل طلب</span>
                <span className="text-lg font-bold">
                  {driver.totalDeliveries && driver.totalEarnings
                    ? Math.round(driver.totalEarnings / driver.totalDeliveries).toLocaleString('ar-EG')
                    : 0}{' '}
                  ج.م
                </span>
              </div>
            </CardContent>
          </Card>

          {/* Current Location */}
          {driver.location && (
            <Card>
              <CardHeader>
                <CardTitle className="text-base flex items-center gap-2">
                  <MapPin className="h-4 w-4" />
                  الموقع الحالي
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground">
                  {driver.location.coordinates?.[1]?.toFixed(6)},{' '}
                  {driver.location.coordinates?.[0]?.toFixed(6)}
                </p>
                {driver.lastLocationUpdate && (
                  <p className="text-xs text-muted-foreground mt-2">
                    آخر تحديث: {format(new Date(driver.lastLocationUpdate), 'd MMM yyyy - hh:mm a', { locale: ar })}
                  </p>
                )}
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
                <p className="text-muted-foreground">رقم السائق</p>
                <p className="font-mono text-xs">{driver._id}</p>
              </div>
              <Separator />
              <div>
                <p className="text-muted-foreground">تاريخ الإنشاء</p>
                <p>{format(new Date(driver.createdAt), 'dd/MM/yyyy', { locale: ar })}</p>
              </div>
              <Separator />
              <div>
                <p className="text-muted-foreground">آخر تحديث</p>
                <p>{format(new Date(driver.updatedAt), 'dd/MM/yyyy', { locale: ar })}</p>
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
              {actionDialog.type === 'approve' && 'الموافقة على السائق'}
              {actionDialog.type === 'reject' && 'رفض السائق'}
              {actionDialog.type === 'suspend' && 'إيقاف السائق'}
              {actionDialog.type === 'activate' && 'تفعيل السائق'}
            </DialogTitle>
            <DialogDescription>
              {actionDialog.type === 'approve' && 'هل أنت متأكد من الموافقة على هذا السائق؟'}
              {actionDialog.type === 'reject' && 'يرجى توضيح سبب الرفض'}
              {actionDialog.type === 'suspend' && 'يرجى توضيح سبب الإيقاف'}
              {actionDialog.type === 'activate' && 'هل أنت متأكد من تفعيل هذا السائق؟'}
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

      {/* Document Viewer Dialog */}
      <Dialog open={documentDialog.open} onOpenChange={(open) => setDocumentDialog({ ...documentDialog, open })}>
        <DialogContent className="max-w-4xl">
          <DialogHeader>
            <DialogTitle>{documentDialog.title}</DialogTitle>
          </DialogHeader>
          <div className="relative aspect-video overflow-hidden rounded-lg bg-muted">
            {documentDialog.url && (
              <img
                src={documentDialog.url}
                alt={documentDialog.title}
                className="h-full w-full object-contain"
              />
            )}
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
