'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Skeleton } from '@/components/ui/skeleton';
import { Separator } from '@/components/ui/separator';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
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
  ShoppingBag,
  Heart,
  Ban,
  Unlock,
  Trash2,
  CheckCircle,
  XCircle,
} from 'lucide-react';
import { usersApi, getErrorMessage } from '@/services/api';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';
import { toast } from 'sonner';

interface UserDetails {
  _id: string;
  name: string;
  email: string;
  phone: string;
  avatar?: string;
  role: string;
  isVerified: boolean;
  isBlocked: boolean;
  addresses?: Array<{
    _id: string;
    street: string;
    area: string;
    city: string;
    isDefault: boolean;
  }>;
  favorites?: Array<{
    restaurantId: string;
    restaurantName: string;
  }>;
  totalOrders?: number;
  totalSpent?: number;
  loyaltyPoints?: number;
  createdAt: string;
  updatedAt: string;
  lastLogin?: string;
}

export default function UserDetailsPage() {
  const router = useRouter();
  const params = useParams();
  const userId = params.id as string;

  const [user, setUser] = useState<UserDetails | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Action dialogs
  const [blockDialogOpen, setBlockDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [isActionLoading, setIsActionLoading] = useState(false);

  const fetchUser = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await usersApi.getUser(userId);
      if (response.success && response.data) {
        setUser(response.data.user);
      }
    } catch (err) {
      setError(getErrorMessage(err));
      toast.error(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchUser();
  }, [userId]);

  const handleBlockUnblock = async () => {
    if (!user) return;

    setIsActionLoading(true);
    try {
      const response = user.isBlocked
        ? await usersApi.unblockUser(userId)
        : await usersApi.blockUser(userId);

      if (response.success) {
        toast.success(user.isBlocked ? 'تم إلغاء حظر المستخدم بنجاح' : 'تم حظر المستخدم بنجاح');
        setBlockDialogOpen(false);
        fetchUser();
      }
    } catch (err) {
      toast.error(getErrorMessage(err));
    } finally {
      setIsActionLoading(false);
    }
  };

  const handleDelete = async () => {
    setIsActionLoading(true);
    try {
      const response = await usersApi.deleteUser(userId);
      if (response.success) {
        toast.success('تم حذف المستخدم بنجاح');
        router.push('/dashboard/users');
      }
    } catch (err) {
      toast.error(getErrorMessage(err));
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

  if (error || !user) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-red-600">حدث خطأ</CardTitle>
          <CardDescription>{error || 'لم يتم العثور على المستخدم'}</CardDescription>
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

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <Button variant="ghost" onClick={() => router.back()}>
          <ArrowLeft className="ml-2 h-4 w-4" />
          العودة للمستخدمين
        </Button>
        <div className="flex gap-2">
          <Button
            variant={user.isBlocked ? 'default' : 'destructive'}
            onClick={() => setBlockDialogOpen(true)}
          >
            {user.isBlocked ? (
              <>
                <Unlock className="ml-2 h-4 w-4" />
                إلغاء الحظر
              </>
            ) : (
              <>
                <Ban className="ml-2 h-4 w-4" />
                حظر المستخدم
              </>
            )}
          </Button>
          <Button
            variant="destructive"
            onClick={() => setDeleteDialogOpen(true)}
          >
            <Trash2 className="ml-2 h-4 w-4" />
            حذف
          </Button>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        {/* Main Info */}
        <div className="md:col-span-2 space-y-6">
          {/* User Profile Card */}
          <Card>
            <CardHeader>
              <CardTitle>معلومات المستخدم</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-start gap-6">
                <Avatar className="h-24 w-24">
                  <AvatarImage src={user.avatar} />
                  <AvatarFallback className="text-2xl">
                    {user.name.charAt(0)}
                  </AvatarFallback>
                </Avatar>
                <div className="flex-1 space-y-4">
                  <div>
                    <h2 className="text-2xl font-bold">{user.name}</h2>
                    <div className="mt-2 flex flex-wrap gap-2">
                      <Badge variant={user.isVerified ? 'default' : 'secondary'}>
                        {user.isVerified ? (
                          <>
                            <CheckCircle className="ml-1 h-3 w-3" />
                            موثق
                          </>
                        ) : (
                          <>
                            <XCircle className="ml-1 h-3 w-3" />
                            غير موثق
                          </>
                        )}
                      </Badge>
                      {user.isBlocked && (
                        <Badge variant="destructive">
                          <Ban className="ml-1 h-3 w-3" />
                          محظور
                        </Badge>
                      )}
                      <Badge variant="outline">{user.role === 'customer' ? 'عميل' : user.role}</Badge>
                    </div>
                  </div>

                  <div className="grid gap-3 sm:grid-cols-2">
                    <div className="flex items-center gap-2 text-sm">
                      <Mail className="h-4 w-4 text-muted-foreground" />
                      <span>{user.email}</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <Phone className="h-4 w-4 text-muted-foreground" />
                      <span>{user.phone}</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <Calendar className="h-4 w-4 text-muted-foreground" />
                      <span>
                        انضم {format(new Date(user.createdAt), 'd MMMM yyyy', { locale: ar })}
                      </span>
                    </div>
                    {user.lastLogin && (
                      <div className="flex items-center gap-2 text-sm">
                        <Calendar className="h-4 w-4 text-muted-foreground" />
                        <span>
                          آخر دخول {format(new Date(user.lastLogin), 'd MMM yyyy', { locale: ar })}
                        </span>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Addresses Card */}
          {user.addresses && user.addresses.length > 0 && (
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <MapPin className="h-5 w-5" />
                  العناوين ({user.addresses.length})
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {user.addresses.map((address, index) => (
                    <div key={address._id}>
                      {index > 0 && <Separator className="my-3" />}
                      <div className="flex items-start justify-between">
                        <div>
                          <p className="font-medium">{address.street}</p>
                          <p className="text-sm text-muted-foreground">
                            {address.area} - {address.city}
                          </p>
                        </div>
                        {address.isDefault && (
                          <Badge variant="secondary">افتراضي</Badge>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          )}

          {/* Favorites Card */}
          {user.favorites && user.favorites.length > 0 && (
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Heart className="h-5 w-5" />
                  المطاعم المفضلة ({user.favorites.length})
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  {user.favorites.map((fav, index) => (
                    <div key={index} className="flex items-center gap-2">
                      <Heart className="h-4 w-4 fill-red-500 text-red-500" />
                      <span className="text-sm">{fav.restaurantName}</span>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          )}
        </div>

        {/* Stats Sidebar */}
        <div className="space-y-6">
          {/* Order Stats */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">إحصائيات الطلبات</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <ShoppingBag className="h-4 w-4 text-muted-foreground" />
                  <span className="text-sm">إجمالي الطلبات</span>
                </div>
                <span className="text-lg font-bold">{user.totalOrders || 0}</span>
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <span className="text-sm">إجمالي الإنفاق</span>
                <span className="text-lg font-bold">
                  {user.totalSpent?.toLocaleString('ar-EG') || 0} ج.م
                </span>
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <span className="text-sm">متوسط قيمة الطلب</span>
                <span className="text-lg font-bold">
                  {user.totalOrders && user.totalSpent
                    ? Math.round(user.totalSpent / user.totalOrders).toLocaleString('ar-EG')
                    : 0}{' '}
                  ج.م
                </span>
              </div>
            </CardContent>
          </Card>

          {/* Loyalty Points */}
          {user.loyaltyPoints !== undefined && (
            <Card>
              <CardHeader>
                <CardTitle className="text-base">نقاط الولاء</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-center">
                  <p className="text-4xl font-bold text-primary">{user.loyaltyPoints}</p>
                  <p className="text-sm text-muted-foreground">نقطة</p>
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
                <p className="text-muted-foreground">رقم المستخدم</p>
                <p className="font-mono">{user._id}</p>
              </div>
              <Separator />
              <div>
                <p className="text-muted-foreground">تاريخ الإنشاء</p>
                <p>{format(new Date(user.createdAt), 'dd/MM/yyyy - hh:mm a', { locale: ar })}</p>
              </div>
              <Separator />
              <div>
                <p className="text-muted-foreground">آخر تحديث</p>
                <p>{format(new Date(user.updatedAt), 'dd/MM/yyyy - hh:mm a', { locale: ar })}</p>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Block/Unblock Dialog */}
      <Dialog open={blockDialogOpen} onOpenChange={setBlockDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {user.isBlocked ? 'إلغاء حظر المستخدم' : 'حظر المستخدم'}
            </DialogTitle>
            <DialogDescription>
              {user.isBlocked
                ? 'هل أنت متأكد من إلغاء حظر هذا المستخدم؟ سيتمكن من استخدام التطبيق مرة أخرى.'
                : 'هل أنت متأكد من حظر هذا المستخدم؟ لن يتمكن من تسجيل الدخول أو تقديم طلبات.'}
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setBlockDialogOpen(false)}>
              إلغاء
            </Button>
            <Button
              variant={user.isBlocked ? 'default' : 'destructive'}
              onClick={handleBlockUnblock}
              disabled={isActionLoading}
            >
              {isActionLoading ? 'جاري المعالجة...' : user.isBlocked ? 'إلغاء الحظر' : 'حظر'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Dialog */}
      <Dialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>حذف المستخدم</DialogTitle>
            <DialogDescription>
              هل أنت متأكد من حذف هذا المستخدم؟ هذا الإجراء لا يمكن التراجع عنه.
              سيتم حذف جميع بيانات المستخدم نهائياً.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteDialogOpen(false)}>
              إلغاء
            </Button>
            <Button
              variant="destructive"
              onClick={handleDelete}
              disabled={isActionLoading}
            >
              {isActionLoading ? 'جاري الحذف...' : 'حذف نهائياً'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
