'use client';

import { useState, useEffect } from 'react';
import { useAuthStore } from '@/stores/auth';
import { restaurantApi, uploadApi, authApi, getErrorMessage, UpdateProfileRequest, UpdateLocationRequest } from '@/lib/api';
import { toast } from 'sonner';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Separator } from '@/components/ui/separator';
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
import {
  Store,
  MapPin,
  Phone,
  Mail,
  Star,
  ShoppingBag,
  Upload,
  Loader2,
  Camera,
  Check,
  AlertCircle,
  Clock,
  XCircle,
  Eye,
  EyeOff,
  Lock,
  Save,
} from 'lucide-react';
import { RESTAURANT_STATUSES } from '@/config/constants';
import api from '@/lib/api';

interface PasswordChangeData {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}

const initialPasswordData: PasswordChangeData = {
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
};

const CUISINE_TYPES = [
  { value: 'egyptian', label: 'مصري' },
  { value: 'syrian', label: 'سوري' },
  { value: 'lebanese', label: 'لبناني' },
  { value: 'gulf', label: 'خليجي' },
  { value: 'indian', label: 'هندي' },
  { value: 'chinese', label: 'صيني' },
  { value: 'italian', label: 'إيطالي' },
  { value: 'american', label: 'أمريكي' },
  { value: 'fast_food', label: 'وجبات سريعة' },
  { value: 'grills', label: 'مشويات' },
  { value: 'seafood', label: 'مأكولات بحرية' },
  { value: 'pizza', label: 'بيتزا' },
  { value: 'burgers', label: 'برجر' },
  { value: 'sandwiches', label: 'سندويتشات' },
  { value: 'desserts', label: 'حلويات' },
  { value: 'beverages', label: 'مشروبات' },
  { value: 'healthy', label: 'أكل صحي' },
  { value: 'vegetarian', label: 'نباتي' },
];

export default function ProfilePage() {
  const { restaurant, user, updateRestaurant, checkAuth } = useAuthStore();
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isUploading, setIsUploading] = useState<'logo' | 'cover' | null>(null);
  const [showPasswordDialog, setShowPasswordDialog] = useState(false);
  const [passwordData, setPasswordData] = useState<PasswordChangeData>(initialPasswordData);
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [isChangingPassword, setIsChangingPassword] = useState(false);

  // Profile form state
  const [profileForm, setProfileForm] = useState({
    name: '',
    nameAr: '',
    description: '',
    descriptionAr: '',
    phone: '',
    whatsapp: '',
    address: '',
    area: '',
    priceRange: '2',
    cuisineTypes: [] as string[],
  });

  useEffect(() => {
    const loadProfile = async () => {
      try {
        await checkAuth();
      } catch {
        // Error handled in store
      } finally {
        setIsLoading(false);
      }
    };
    loadProfile();
  }, [checkAuth]);

  useEffect(() => {
    if (restaurant) {
      setProfileForm({
        name: restaurant.name || '',
        nameAr: restaurant.name || '',
        description: '',
        descriptionAr: '',
        phone: restaurant.phone || '',
        whatsapp: '',
        address: restaurant.address?.street || '',
        area: restaurant.address?.area || '',
        priceRange: '2',
        cuisineTypes: restaurant.cuisineTypes || [],
      });
    }
  }, [restaurant]);

  const handleImageUpload = async (
    e: React.ChangeEvent<HTMLInputElement>,
    type: 'logo' | 'cover'
  ) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      toast.error('حجم الملف يجب أن يكون أقل من 5 ميجابايت');
      return;
    }

    // Validate file type
    if (!file.type.startsWith('image/')) {
      toast.error('يرجى اختيار ملف صورة صحيح');
      return;
    }

    try {
      setIsUploading(type);
      const response = await uploadApi.uploadImage(file, type);
      if (response.success && response.data) {
        if (type === 'logo') {
          updateRestaurant({ logo: response.data.url });
        } else {
          updateRestaurant({ coverImage: response.data.url });
        }
        toast.success(`تم رفع ${type === 'logo' ? 'الشعار' : 'صورة الغلاف'} بنجاح`);
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsUploading(null);
      e.target.value = '';
    }
  };

  const handleSaveProfile = async () => {
    try {
      setIsSaving(true);
      const data: UpdateProfileRequest = {
        name: profileForm.name,
        nameAr: profileForm.nameAr,
        description: profileForm.description,
        descriptionAr: profileForm.descriptionAr,
        phone: profileForm.phone,
        whatsapp: profileForm.whatsapp,
        address: profileForm.address,
        area: profileForm.area,
        priceRange: parseInt(profileForm.priceRange),
      };

      const response = await restaurantApi.updateProfile(data);
      if (response.success && response.data) {
        updateRestaurant(response.data.restaurant);
        toast.success('تم حفظ البيانات بنجاح');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsSaving(false);
    }
  };

  const handleToggleCuisineType = (type: string) => {
    setProfileForm((prev) => {
      const types = prev.cuisineTypes.includes(type)
        ? prev.cuisineTypes.filter((t) => t !== type)
        : [...prev.cuisineTypes, type];
      return { ...prev, cuisineTypes: types };
    });
  };

  const handleChangePassword = async () => {
    if (passwordData.newPassword !== passwordData.confirmPassword) {
      toast.error('كلمة المرور الجديدة غير متطابقة');
      return;
    }

    if (passwordData.newPassword.length < 8) {
      toast.error('كلمة المرور يجب أن تكون 8 أحرف على الأقل');
      return;
    }

    try {
      setIsChangingPassword(true);
      const response = await api.put('/auth/change-password', {
        currentPassword: passwordData.currentPassword,
        newPassword: passwordData.newPassword,
      });

      if (response.data.success) {
        toast.success('تم تغيير كلمة المرور بنجاح');
        setShowPasswordDialog(false);
        setPasswordData(initialPasswordData);
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsChangingPassword(false);
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'approved':
        return <Check className="h-4 w-4" />;
      case 'pending':
        return <Clock className="h-4 w-4" />;
      case 'rejected':
      case 'suspended':
        return <XCircle className="h-4 w-4" />;
      default:
        return <AlertCircle className="h-4 w-4" />;
    }
  };

  const getStatusBadgeVariant = (status: string): 'default' | 'secondary' | 'destructive' => {
    switch (status) {
      case 'approved':
        return 'default';
      case 'pending':
        return 'secondary';
      case 'rejected':
      case 'suspended':
        return 'destructive';
      default:
        return 'secondary';
    }
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-10 w-48" />
        <div className="grid gap-6 md:grid-cols-3">
          <div className="md:col-span-2 space-y-6">
            <Skeleton className="h-64" />
            <Skeleton className="h-96" />
          </div>
          <div className="space-y-6">
            <Skeleton className="h-48" />
            <Skeleton className="h-32" />
          </div>
        </div>
      </div>
    );
  }

  if (!restaurant || !user) {
    return (
      <Card>
        <CardContent className="flex flex-col items-center justify-center py-12">
          <AlertCircle className="h-12 w-12 text-muted-foreground mb-4" />
          <h3 className="text-lg font-semibold mb-2">حدث خطأ</h3>
          <p className="text-muted-foreground">لم يتم تحميل بيانات المطعم</p>
        </CardContent>
      </Card>
    );
  }

  const statusInfo = RESTAURANT_STATUSES[restaurant.status];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">الملف الشخصي</h1>
          <p className="text-muted-foreground">إدارة بيانات المطعم والحساب</p>
        </div>
        <Badge variant={getStatusBadgeVariant(restaurant.status)} className="text-sm px-3 py-1">
          {getStatusIcon(restaurant.status)}
          <span className="mr-2">{statusInfo?.label || restaurant.status}</span>
        </Badge>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        {/* Main Content */}
        <div className="md:col-span-2 space-y-6">
          {/* Cover & Logo Section */}
          <Card>
            <CardHeader>
              <CardTitle>صور المطعم</CardTitle>
              <CardDescription>الشعار وصورة الغلاف الخاصة بالمطعم</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              {/* Cover Image */}
              <div className="space-y-2">
                <Label>صورة الغلاف</Label>
                <div className="relative h-48 w-full rounded-lg border-2 border-dashed overflow-hidden bg-muted">
                  {restaurant.coverImage ? (
                    <img
                      src={restaurant.coverImage}
                      alt="صورة الغلاف"
                      className="h-full w-full object-cover"
                    />
                  ) : (
                    <div className="flex h-full w-full items-center justify-center">
                      <div className="text-center">
                        <Camera className="h-12 w-12 text-muted-foreground mx-auto mb-2" />
                        <p className="text-sm text-muted-foreground">اضغط لرفع صورة الغلاف</p>
                      </div>
                    </div>
                  )}
                  <label className="absolute inset-0 flex items-center justify-center bg-black/50 opacity-0 hover:opacity-100 transition-opacity cursor-pointer">
                    <input
                      type="file"
                      accept="image/*"
                      className="hidden"
                      onChange={(e) => handleImageUpload(e, 'cover')}
                      disabled={isUploading !== null}
                    />
                    {isUploading === 'cover' ? (
                      <Loader2 className="h-8 w-8 text-white animate-spin" />
                    ) : (
                      <div className="text-center text-white">
                        <Upload className="h-8 w-8 mx-auto mb-2" />
                        <span>تغيير صورة الغلاف</span>
                      </div>
                    )}
                  </label>
                </div>
                <p className="text-xs text-muted-foreground">
                  يفضل صورة بحجم 1200x400 بكسل، الحد الأقصى 5 ميجابايت
                </p>
              </div>

              {/* Logo */}
              <div className="space-y-2">
                <Label>الشعار</Label>
                <div className="flex items-center gap-4">
                  <div className="relative h-24 w-24 rounded-lg border-2 border-dashed overflow-hidden bg-muted">
                    {restaurant.logo ? (
                      <img
                        src={restaurant.logo}
                        alt="شعار المطعم"
                        className="h-full w-full object-cover"
                      />
                    ) : (
                      <div className="flex h-full w-full items-center justify-center">
                        <Store className="h-8 w-8 text-muted-foreground" />
                      </div>
                    )}
                  </div>
                  <div className="space-y-2">
                    <label className="cursor-pointer">
                      <input
                        type="file"
                        accept="image/*"
                        className="hidden"
                        onChange={(e) => handleImageUpload(e, 'logo')}
                        disabled={isUploading !== null}
                      />
                      <Button variant="outline" asChild disabled={isUploading === 'logo'}>
                        <span>
                          {isUploading === 'logo' ? (
                            <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                          ) : (
                            <Upload className="h-4 w-4 ml-2" />
                          )}
                          تغيير الشعار
                        </span>
                      </Button>
                    </label>
                    <p className="text-xs text-muted-foreground">
                      يفضل صورة مربعة 200x200 بكسل
                    </p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Basic Info */}
          <Card>
            <CardHeader>
              <CardTitle>المعلومات الأساسية</CardTitle>
              <CardDescription>بيانات المطعم الأساسية</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="name">اسم المطعم بالعربية</Label>
                  <Input
                    id="name"
                    value={profileForm.name}
                    onChange={(e) =>
                      setProfileForm((prev) => ({ ...prev, name: e.target.value }))
                    }
                    placeholder="اسم المطعم"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="nameAr">اسم المطعم بالإنجليزية</Label>
                  <Input
                    id="nameAr"
                    value={profileForm.nameAr}
                    onChange={(e) =>
                      setProfileForm((prev) => ({ ...prev, nameAr: e.target.value }))
                    }
                    placeholder="Restaurant Name"
                    dir="ltr"
                  />
                </div>
              </div>

              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="phone">رقم الهاتف</Label>
                  <Input
                    id="phone"
                    value={profileForm.phone}
                    onChange={(e) =>
                      setProfileForm((prev) => ({ ...prev, phone: e.target.value }))
                    }
                    placeholder="01xxxxxxxxx"
                    dir="ltr"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="whatsapp">رقم واتساب (اختياري)</Label>
                  <Input
                    id="whatsapp"
                    value={profileForm.whatsapp}
                    onChange={(e) =>
                      setProfileForm((prev) => ({ ...prev, whatsapp: e.target.value }))
                    }
                    placeholder="01xxxxxxxxx"
                    dir="ltr"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="description">وصف المطعم بالعربية</Label>
                <Textarea
                  id="description"
                  value={profileForm.description}
                  onChange={(e) =>
                    setProfileForm((prev) => ({ ...prev, description: e.target.value }))
                  }
                  placeholder="وصف مختصر عن المطعم وما يميزه..."
                  rows={3}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="descriptionAr">وصف المطعم بالإنجليزية</Label>
                <Textarea
                  id="descriptionAr"
                  value={profileForm.descriptionAr}
                  onChange={(e) =>
                    setProfileForm((prev) => ({ ...prev, descriptionAr: e.target.value }))
                  }
                  placeholder="Brief description about the restaurant..."
                  rows={3}
                  dir="ltr"
                />
              </div>

              <Separator />

              {/* Address */}
              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="address">العنوان</Label>
                  <Input
                    id="address"
                    value={profileForm.address}
                    onChange={(e) =>
                      setProfileForm((prev) => ({ ...prev, address: e.target.value }))
                    }
                    placeholder="العنوان التفصيلي"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="area">المنطقة</Label>
                  <Input
                    id="area"
                    value={profileForm.area}
                    onChange={(e) =>
                      setProfileForm((prev) => ({ ...prev, area: e.target.value }))
                    }
                    placeholder="مثال: وسط البلد"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="priceRange">نطاق الأسعار</Label>
                <Select
                  value={profileForm.priceRange}
                  onValueChange={(value) =>
                    setProfileForm((prev) => ({ ...prev, priceRange: value }))
                  }
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="1">$ - اقتصادي</SelectItem>
                    <SelectItem value="2">$$ - متوسط</SelectItem>
                    <SelectItem value="3">$$$ - فاخر</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <Separator />

              {/* Cuisine Types */}
              <div className="space-y-2">
                <Label>أنواع المأكولات</Label>
                <p className="text-sm text-muted-foreground mb-2">
                  اختر الأنواع التي تقدمها في مطعمك
                </p>
                <div className="flex flex-wrap gap-2">
                  {CUISINE_TYPES.map((type) => (
                    <Badge
                      key={type.value}
                      variant={profileForm.cuisineTypes.includes(type.value) ? 'default' : 'outline'}
                      className="cursor-pointer"
                      onClick={() => handleToggleCuisineType(type.value)}
                    >
                      {type.label}
                    </Badge>
                  ))}
                </div>
              </div>

              <Button onClick={handleSaveProfile} disabled={isSaving} className="w-full md:w-auto">
                {isSaving ? (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                ) : (
                  <Save className="h-4 w-4 ml-2" />
                )}
                حفظ التغييرات
              </Button>
            </CardContent>
          </Card>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Account Info */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Mail className="h-5 w-5" />
                بيانات الحساب
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-1">
                <Label className="text-muted-foreground">البريد الإلكتروني</Label>
                <p className="font-medium" dir="ltr">{user.email}</p>
              </div>
              <div className="space-y-1">
                <Label className="text-muted-foreground">الاسم</Label>
                <p className="font-medium">{user.name}</p>
              </div>
              <div className="space-y-1">
                <Label className="text-muted-foreground">رقم الهاتف</Label>
                <p className="font-medium" dir="ltr">{user.phone}</p>
              </div>
              <div className="space-y-1">
                <Label className="text-muted-foreground">حالة التحقق</Label>
                <Badge variant={user.isVerified ? 'default' : 'secondary'}>
                  {user.isVerified ? 'تم التحقق' : 'لم يتم التحقق'}
                </Badge>
              </div>
              <Separator />
              <Button
                variant="outline"
                className="w-full"
                onClick={() => setShowPasswordDialog(true)}
              >
                <Lock className="h-4 w-4 ml-2" />
                تغيير كلمة المرور
              </Button>
            </CardContent>
          </Card>

          {/* Restaurant Stats */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Store className="h-5 w-5" />
                إحصائيات المطعم
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Star className="h-4 w-4 text-yellow-500" />
                  <span className="text-muted-foreground">التقييم</span>
                </div>
                <span className="font-semibold">{restaurant.rating?.toFixed(1) || '0.0'}</span>
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <ShoppingBag className="h-4 w-4 text-primary" />
                  <span className="text-muted-foreground">إجمالي الطلبات</span>
                </div>
                <span className="font-semibold">{restaurant.totalOrders || 0}</span>
              </div>
              {restaurant.deliveryFee !== undefined && (
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">رسوم التوصيل</span>
                  <span className="font-semibold">{restaurant.deliveryFee} ج.م</span>
                </div>
              )}
              {restaurant.minimumOrder !== undefined && (
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">الحد الأدنى للطلب</span>
                  <span className="font-semibold">{restaurant.minimumOrder} ج.م</span>
                </div>
              )}
              {restaurant.averageDeliveryTime !== undefined && (
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">متوسط وقت التوصيل</span>
                  <span className="font-semibold">{restaurant.averageDeliveryTime} دقيقة</span>
                </div>
              )}
            </CardContent>
          </Card>

          {/* Location */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <MapPin className="h-5 w-5" />
                الموقع
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              <p className="text-muted-foreground">
                {restaurant.address?.street || 'لم يتم تحديد العنوان'}
              </p>
              <p className="text-muted-foreground">
                {restaurant.address?.area && `${restaurant.address.area}، `}
                {restaurant.address?.city || 'باجور'}
              </p>
              {restaurant.address?.coordinates && (
                <a
                  href={`https://www.google.com/maps?q=${restaurant.address.coordinates.lat},${restaurant.address.coordinates.lng}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-primary hover:underline text-sm"
                >
                  عرض على خرائط جوجل
                </a>
              )}
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Change Password Dialog */}
      <Dialog open={showPasswordDialog} onOpenChange={setShowPasswordDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>تغيير كلمة المرور</DialogTitle>
            <DialogDescription>
              أدخل كلمة المرور الحالية والجديدة
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="currentPassword">كلمة المرور الحالية</Label>
              <div className="relative">
                <Input
                  id="currentPassword"
                  type={showCurrentPassword ? 'text' : 'password'}
                  value={passwordData.currentPassword}
                  onChange={(e) =>
                    setPasswordData((prev) => ({ ...prev, currentPassword: e.target.value }))
                  }
                  placeholder="أدخل كلمة المرور الحالية"
                  dir="ltr"
                />
                <button
                  type="button"
                  className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground"
                  onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                >
                  {showCurrentPassword ? (
                    <EyeOff className="h-4 w-4" />
                  ) : (
                    <Eye className="h-4 w-4" />
                  )}
                </button>
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="newPassword">كلمة المرور الجديدة</Label>
              <div className="relative">
                <Input
                  id="newPassword"
                  type={showNewPassword ? 'text' : 'password'}
                  value={passwordData.newPassword}
                  onChange={(e) =>
                    setPasswordData((prev) => ({ ...prev, newPassword: e.target.value }))
                  }
                  placeholder="أدخل كلمة المرور الجديدة"
                  dir="ltr"
                />
                <button
                  type="button"
                  className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground"
                  onClick={() => setShowNewPassword(!showNewPassword)}
                >
                  {showNewPassword ? (
                    <EyeOff className="h-4 w-4" />
                  ) : (
                    <Eye className="h-4 w-4" />
                  )}
                </button>
              </div>
              <p className="text-xs text-muted-foreground">
                يجب أن تكون 8 أحرف على الأقل
              </p>
            </div>
            <div className="space-y-2">
              <Label htmlFor="confirmPassword">تأكيد كلمة المرور الجديدة</Label>
              <Input
                id="confirmPassword"
                type="password"
                value={passwordData.confirmPassword}
                onChange={(e) =>
                  setPasswordData((prev) => ({ ...prev, confirmPassword: e.target.value }))
                }
                placeholder="أعد إدخال كلمة المرور الجديدة"
                dir="ltr"
              />
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setShowPasswordDialog(false);
                setPasswordData(initialPasswordData);
              }}
            >
              إلغاء
            </Button>
            <Button
              onClick={handleChangePassword}
              disabled={
                isChangingPassword ||
                !passwordData.currentPassword ||
                !passwordData.newPassword ||
                !passwordData.confirmPassword
              }
            >
              {isChangingPassword ? (
                <Loader2 className="h-4 w-4 ml-2 animate-spin" />
              ) : (
                <Lock className="h-4 w-4 ml-2" />
              )}
              تغيير كلمة المرور
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
