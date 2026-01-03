'use client';

import { useState } from 'react';
import { useAuthStore } from '@/stores/auth';
import { restaurantApi, uploadApi, getErrorMessage, UpdateProfileRequest, UpdateDeliverySettingsRequest } from '@/lib/api';
import { toast } from 'sonner';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Store,
  MapPin,
  Clock,
  Truck,
  CreditCard,
  Settings2,
  Upload,
  Loader2,
  X,
} from 'lucide-react';
import { DAYS_OF_WEEK } from '@/config/constants';

interface WorkingHourShift {
  open: string;
  close: string;
}

interface WorkingHourDay {
  day: number;
  isOpen: boolean;
  shifts: WorkingHourShift[];
}

export default function SettingsPage() {
  const { restaurant, updateRestaurant } = useAuthStore();
  const [isSaving, setIsSaving] = useState(false);
  const [isUploading, setIsUploading] = useState<'logo' | 'cover' | null>(null);

  // Profile form state
  const [profileForm, setProfileForm] = useState({
    name: restaurant?.name || '',
    nameAr: restaurant?.name || '',
    description: '',
    descriptionAr: '',
    phone: restaurant?.phone || '',
    whatsapp: '',
    priceRange: 2,
  });

  // Delivery settings form state
  const [deliveryForm, setDeliveryForm] = useState({
    minimumOrder: restaurant?.minimumOrder || 0,
    deliveryFee: restaurant?.deliveryFee || 0,
    freeDeliveryAbove: 0,
    estimatedDeliveryTimeMin: 20,
    estimatedDeliveryTimeMax: 40,
    acceptsCash: true,
    acceptsOnlinePayment: false,
    autoAcceptOrders: false,
  });

  // Working hours state
  const [workingHours, setWorkingHours] = useState<WorkingHourDay[]>(
    DAYS_OF_WEEK.map((_, index) => ({
      day: index,
      isOpen: index !== 5, // Closed on Friday by default
      shifts: [{ open: '09:00', close: '23:00' }],
    }))
  );

  const handleImageUpload = async (
    e: React.ChangeEvent<HTMLInputElement>,
    type: 'logo' | 'cover'
  ) => {
    const file = e.target.files?.[0];
    if (!file) return;

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
    }
  };

  const handleSaveProfile = async () => {
    try {
      setIsSaving(true);
      const data: UpdateProfileRequest = {
        name: profileForm.name,
        phone: profileForm.phone,
        priceRange: profileForm.priceRange,
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

  const handleSaveDeliverySettings = async () => {
    try {
      setIsSaving(true);
      const data: UpdateDeliverySettingsRequest = {
        minimumOrder: deliveryForm.minimumOrder,
        deliveryFee: deliveryForm.deliveryFee,
        freeDeliveryAbove: deliveryForm.freeDeliveryAbove || null,
        estimatedDeliveryTime: {
          min: deliveryForm.estimatedDeliveryTimeMin,
          max: deliveryForm.estimatedDeliveryTimeMax,
        },
        acceptsCash: deliveryForm.acceptsCash,
        acceptsOnlinePayment: deliveryForm.acceptsOnlinePayment,
        autoAcceptOrders: deliveryForm.autoAcceptOrders,
      };

      const response = await restaurantApi.updateDeliverySettings(data);
      if (response.success && response.data) {
        updateRestaurant(response.data.restaurant);
        toast.success('تم حفظ إعدادات التوصيل بنجاح');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsSaving(false);
    }
  };

  const handleSaveWorkingHours = async () => {
    try {
      setIsSaving(true);
      const response = await restaurantApi.updateWorkingHours(workingHours);
      if (response.success && response.data) {
        updateRestaurant(response.data.restaurant);
        toast.success('تم حفظ ساعات العمل بنجاح');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsSaving(false);
    }
  };

  const handleToggleDayOpen = (dayIndex: number) => {
    setWorkingHours((prev) =>
      prev.map((day) =>
        day.day === dayIndex
          ? {
              ...day,
              isOpen: !day.isOpen,
              shifts: !day.isOpen ? [{ open: '09:00', close: '23:00' }] : day.shifts,
            }
          : day
      )
    );
  };

  const handleUpdateShift = (
    dayIndex: number,
    shiftIndex: number,
    field: 'open' | 'close',
    value: string
  ) => {
    setWorkingHours((prev) =>
      prev.map((day) =>
        day.day === dayIndex
          ? {
              ...day,
              shifts: day.shifts.map((shift, i) =>
                i === shiftIndex ? { ...shift, [field]: value } : shift
              ),
            }
          : day
      )
    );
  };

  const handleAddShift = (dayIndex: number) => {
    setWorkingHours((prev) =>
      prev.map((day) =>
        day.day === dayIndex
          ? {
              ...day,
              shifts: [...day.shifts, { open: '14:00', close: '23:00' }],
            }
          : day
      )
    );
  };

  const handleRemoveShift = (dayIndex: number, shiftIndex: number) => {
    setWorkingHours((prev) =>
      prev.map((day) =>
        day.day === dayIndex && day.shifts.length > 1
          ? {
              ...day,
              shifts: day.shifts.filter((_, i) => i !== shiftIndex),
            }
          : day
      )
    );
  };

  if (!restaurant) {
    return null;
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">الإعدادات</h1>
        <p className="text-muted-foreground">إدارة إعدادات المطعم</p>
      </div>

      <Tabs defaultValue="profile" className="space-y-6">
        <TabsList className="grid w-full grid-cols-4 lg:w-[600px]">
          <TabsTrigger value="profile" className="gap-2">
            <Store className="h-4 w-4" />
            <span className="hidden sm:inline">الملف الشخصي</span>
          </TabsTrigger>
          <TabsTrigger value="hours" className="gap-2">
            <Clock className="h-4 w-4" />
            <span className="hidden sm:inline">ساعات العمل</span>
          </TabsTrigger>
          <TabsTrigger value="delivery" className="gap-2">
            <Truck className="h-4 w-4" />
            <span className="hidden sm:inline">التوصيل</span>
          </TabsTrigger>
          <TabsTrigger value="payment" className="gap-2">
            <CreditCard className="h-4 w-4" />
            <span className="hidden sm:inline">الدفع</span>
          </TabsTrigger>
        </TabsList>

        {/* Profile Tab */}
        <TabsContent value="profile" className="space-y-6">
          {/* Images */}
          <Card>
            <CardHeader>
              <CardTitle>صور المطعم</CardTitle>
              <CardDescription>شعار المطعم وصورة الغلاف</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="grid gap-6 md:grid-cols-2">
                {/* Logo */}
                <div className="space-y-2">
                  <Label>الشعار</Label>
                  <div className="flex items-center gap-4">
                    <div className="relative h-24 w-24 rounded-lg border overflow-hidden bg-muted">
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
                  </div>
                </div>

                {/* Cover */}
                <div className="space-y-2">
                  <Label>صورة الغلاف</Label>
                  <div className="relative h-24 w-full rounded-lg border overflow-hidden bg-muted">
                    {restaurant.coverImage ? (
                      <img
                        src={restaurant.coverImage}
                        alt="صورة الغلاف"
                        className="h-full w-full object-cover"
                      />
                    ) : (
                      <div className="flex h-full w-full items-center justify-center">
                        <MapPin className="h-8 w-8 text-muted-foreground" />
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
                        <Loader2 className="h-6 w-6 text-white animate-spin" />
                      ) : (
                        <Upload className="h-6 w-6 text-white" />
                      )}
                    </label>
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
                  <Label htmlFor="name">اسم المطعم</Label>
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
              </div>

              <div className="space-y-2">
                <Label htmlFor="description">الوصف</Label>
                <Textarea
                  id="description"
                  value={profileForm.description}
                  onChange={(e) =>
                    setProfileForm((prev) => ({ ...prev, description: e.target.value }))
                  }
                  placeholder="وصف مختصر عن المطعم..."
                  rows={3}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="priceRange">نطاق الأسعار</Label>
                <Select
                  value={profileForm.priceRange.toString()}
                  onValueChange={(value) =>
                    setProfileForm((prev) => ({ ...prev, priceRange: parseInt(value) }))
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

              <Button onClick={handleSaveProfile} disabled={isSaving}>
                {isSaving && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                حفظ التغييرات
              </Button>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Working Hours Tab */}
        <TabsContent value="hours">
          <Card>
            <CardHeader>
              <CardTitle>ساعات العمل</CardTitle>
              <CardDescription>حدد أوقات العمل لكل يوم</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              {DAYS_OF_WEEK.map((day, index) => {
                const dayHours = workingHours.find((wh) => wh.day === index);
                return (
                  <div
                    key={day.key}
                    className="flex flex-col gap-4 p-4 border rounded-lg sm:flex-row sm:items-center"
                  >
                    <div className="flex items-center gap-3 w-32">
                      <Switch
                        checked={dayHours?.isOpen || false}
                        onCheckedChange={() => handleToggleDayOpen(index)}
                      />
                      <span className="font-medium">{day.label}</span>
                    </div>

                    {dayHours?.isOpen && (
                      <div className="flex-1 space-y-2">
                        {dayHours.shifts.map((shift, shiftIndex) => (
                          <div key={shiftIndex} className="flex items-center gap-2">
                            <Input
                              type="time"
                              value={shift.open}
                              onChange={(e) =>
                                handleUpdateShift(index, shiftIndex, 'open', e.target.value)
                              }
                              className="w-32"
                            />
                            <span>-</span>
                            <Input
                              type="time"
                              value={shift.close}
                              onChange={(e) =>
                                handleUpdateShift(index, shiftIndex, 'close', e.target.value)
                              }
                              className="w-32"
                            />
                            {dayHours.shifts.length > 1 && (
                              <Button
                                variant="ghost"
                                size="icon"
                                onClick={() => handleRemoveShift(index, shiftIndex)}
                              >
                                <X className="h-4 w-4" />
                              </Button>
                            )}
                          </div>
                        ))}
                        {dayHours.shifts.length < 3 && (
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleAddShift(index)}
                          >
                            + إضافة فترة
                          </Button>
                        )}
                      </div>
                    )}

                    {!dayHours?.isOpen && (
                      <span className="text-muted-foreground">مغلق</span>
                    )}
                  </div>
                );
              })}

              <Button onClick={handleSaveWorkingHours} disabled={isSaving}>
                {isSaving && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                حفظ ساعات العمل
              </Button>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Delivery Tab */}
        <TabsContent value="delivery">
          <Card>
            <CardHeader>
              <CardTitle>إعدادات التوصيل</CardTitle>
              <CardDescription>حدد رسوم ووقت التوصيل</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="minimumOrder">الحد الأدنى للطلب (ج.م)</Label>
                  <Input
                    id="minimumOrder"
                    type="number"
                    min="0"
                    value={deliveryForm.minimumOrder}
                    onChange={(e) =>
                      setDeliveryForm((prev) => ({
                        ...prev,
                        minimumOrder: parseFloat(e.target.value) || 0,
                      }))
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="deliveryFee">رسوم التوصيل (ج.م)</Label>
                  <Input
                    id="deliveryFee"
                    type="number"
                    min="0"
                    value={deliveryForm.deliveryFee}
                    onChange={(e) =>
                      setDeliveryForm((prev) => ({
                        ...prev,
                        deliveryFee: parseFloat(e.target.value) || 0,
                      }))
                    }
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="freeDeliveryAbove">
                  التوصيل مجاني للطلبات أكثر من (ج.م)
                </Label>
                <Input
                  id="freeDeliveryAbove"
                  type="number"
                  min="0"
                  value={deliveryForm.freeDeliveryAbove || ''}
                  onChange={(e) =>
                    setDeliveryForm((prev) => ({
                      ...prev,
                      freeDeliveryAbove: e.target.value ? parseFloat(e.target.value) : 0,
                    }))
                  }
                  placeholder="اتركه فارغاً لتعطيل هذه الميزة"
                />
              </div>

              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="estimatedTimeMin">وقت التوصيل الأدنى (دقيقة)</Label>
                  <Input
                    id="estimatedTimeMin"
                    type="number"
                    min="5"
                    max="120"
                    value={deliveryForm.estimatedDeliveryTimeMin}
                    onChange={(e) =>
                      setDeliveryForm((prev) => ({
                        ...prev,
                        estimatedDeliveryTimeMin: parseInt(e.target.value) || 20,
                      }))
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="estimatedTimeMax">وقت التوصيل الأقصى (دقيقة)</Label>
                  <Input
                    id="estimatedTimeMax"
                    type="number"
                    min="10"
                    max="180"
                    value={deliveryForm.estimatedDeliveryTimeMax}
                    onChange={(e) =>
                      setDeliveryForm((prev) => ({
                        ...prev,
                        estimatedDeliveryTimeMax: parseInt(e.target.value) || 40,
                      }))
                    }
                  />
                </div>
              </div>

              <div className="flex items-center justify-between">
                <div>
                  <Label htmlFor="autoAccept">قبول الطلبات تلقائياً</Label>
                  <p className="text-sm text-muted-foreground">
                    قبول الطلبات الجديدة تلقائياً بدون تأكيد
                  </p>
                </div>
                <Switch
                  id="autoAccept"
                  checked={deliveryForm.autoAcceptOrders}
                  onCheckedChange={(checked) =>
                    setDeliveryForm((prev) => ({ ...prev, autoAcceptOrders: checked }))
                  }
                />
              </div>

              <Button onClick={handleSaveDeliverySettings} disabled={isSaving}>
                {isSaving && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                حفظ إعدادات التوصيل
              </Button>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Payment Tab */}
        <TabsContent value="payment">
          <Card>
            <CardHeader>
              <CardTitle>طرق الدفع</CardTitle>
              <CardDescription>حدد طرق الدفع المتاحة</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="flex items-center justify-between p-4 border rounded-lg">
                <div className="flex items-center gap-3">
                  <div className="p-2 bg-green-100 rounded-lg">
                    <CreditCard className="h-5 w-5 text-green-600" />
                  </div>
                  <div>
                    <Label>الدفع نقداً عند الاستلام</Label>
                    <p className="text-sm text-muted-foreground">
                      قبول الدفع نقداً من العميل
                    </p>
                  </div>
                </div>
                <Switch
                  checked={deliveryForm.acceptsCash}
                  onCheckedChange={(checked) =>
                    setDeliveryForm((prev) => ({ ...prev, acceptsCash: checked }))
                  }
                />
              </div>

              <div className="flex items-center justify-between p-4 border rounded-lg">
                <div className="flex items-center gap-3">
                  <div className="p-2 bg-blue-100 rounded-lg">
                    <CreditCard className="h-5 w-5 text-blue-600" />
                  </div>
                  <div>
                    <Label>الدفع الإلكتروني</Label>
                    <p className="text-sm text-muted-foreground">
                      قبول الدفع ببطاقات الائتمان والمحافظ الإلكترونية
                    </p>
                  </div>
                </div>
                <Switch
                  checked={deliveryForm.acceptsOnlinePayment}
                  onCheckedChange={(checked) =>
                    setDeliveryForm((prev) => ({ ...prev, acceptsOnlinePayment: checked }))
                  }
                />
              </div>

              <Button onClick={handleSaveDeliverySettings} disabled={isSaving}>
                {isSaving && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                حفظ إعدادات الدفع
              </Button>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
