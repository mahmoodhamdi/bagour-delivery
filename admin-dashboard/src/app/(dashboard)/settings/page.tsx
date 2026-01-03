'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui/skeleton';
import { Switch } from '@/components/ui/switch';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { RefreshCw, Save } from 'lucide-react';
import { settingsApi, AppSettings, getErrorMessage } from '@/services/api';

export default function SettingsPage() {
  const [settings, setSettings] = useState<AppSettings | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const fetchSettings = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const res = await settingsApi.getSettings();
      if (res.success && res.data) {
        setSettings(res.data);
      }
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchSettings();
  }, []);

  const handleSave = async () => {
    if (!settings) return;

    setIsSaving(true);
    setError(null);
    setSuccess(null);

    try {
      await settingsApi.updateSettings(settings);
      setSuccess('تم حفظ الإعدادات بنجاح');
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsSaving(false);
    }
  };

  const updateSettings = (key: string, value: unknown) => {
    setSettings((prev) => prev ? { ...prev, [key]: value } : null);
  };

  const updateNestedSettings = (parent: string, key: string, value: unknown) => {
    setSettings((prev) => {
      if (!prev) return null;
      const parentObj = (prev[parent as keyof AppSettings] as Record<string, unknown>) || {};
      return {
        ...prev,
        [parent]: { ...parentObj, [key]: value },
      };
    });
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-48" />
        <Card>
          <CardContent className="pt-6 space-y-4">
            {[...Array(6)].map((_, i) => (
              <Skeleton key={i} className="h-12 w-full" />
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
          <h1 className="text-2xl font-bold">الإعدادات</h1>
          <p className="text-muted-foreground">إدارة إعدادات التطبيق</p>
        </div>
        <div className="flex gap-2">
          <Button onClick={fetchSettings} variant="outline" size="icon">
            <RefreshCw className="h-4 w-4" />
          </Button>
          <Button onClick={handleSave} disabled={isSaving}>
            <Save className="h-4 w-4 ml-2" />
            {isSaving ? 'جاري الحفظ...' : 'حفظ الإعدادات'}
          </Button>
        </div>
      </div>

      {error && (
        <div className="bg-destructive/10 text-destructive p-4 rounded-lg">
          {error}
        </div>
      )}

      {success && (
        <div className="bg-green-100 text-green-800 p-4 rounded-lg">
          {success}
        </div>
      )}

      <Tabs defaultValue="general" className="space-y-6">
        <TabsList>
          <TabsTrigger value="general">عام</TabsTrigger>
          <TabsTrigger value="fees">الرسوم</TabsTrigger>
          <TabsTrigger value="payment">الدفع</TabsTrigger>
          <TabsTrigger value="notifications">الإشعارات</TabsTrigger>
          <TabsTrigger value="maintenance">الصيانة</TabsTrigger>
        </TabsList>

        <TabsContent value="general">
          <Card>
            <CardHeader>
              <CardTitle>الإعدادات العامة</CardTitle>
              <CardDescription>معلومات التطبيق الأساسية</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid gap-4 md:grid-cols-2">
                <div>
                  <label className="text-sm font-medium">اسم التطبيق (English)</label>
                  <Input
                    value={settings?.appName || ''}
                    onChange={(e) => updateSettings('appName', e.target.value)}
                    placeholder="Bagour Delivery"
                    className="mt-2"
                  />
                </div>
                <div>
                  <label className="text-sm font-medium">اسم التطبيق (عربي)</label>
                  <Input
                    value={settings?.appNameAr || ''}
                    onChange={(e) => updateSettings('appNameAr', e.target.value)}
                    placeholder="باجور ديليفري"
                    className="mt-2"
                  />
                </div>
              </div>
              <div className="grid gap-4 md:grid-cols-2">
                <div>
                  <label className="text-sm font-medium">بريد الدعم</label>
                  <Input
                    type="email"
                    value={settings?.supportEmail || ''}
                    onChange={(e) => updateSettings('supportEmail', e.target.value)}
                    placeholder="support@bagour.com"
                    className="mt-2"
                  />
                </div>
                <div>
                  <label className="text-sm font-medium">هاتف الدعم</label>
                  <Input
                    value={settings?.supportPhone || ''}
                    onChange={(e) => updateSettings('supportPhone', e.target.value)}
                    placeholder="+201234567890"
                    className="mt-2"
                    dir="ltr"
                  />
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="fees">
          <Card>
            <CardHeader>
              <CardTitle>الرسوم والعمولات</CardTitle>
              <CardDescription>إعدادات الرسوم والعمولات</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid gap-4 md:grid-cols-2">
                <div>
                  <label className="text-sm font-medium">رسوم التوصيل الافتراضية (ج.م)</label>
                  <Input
                    type="number"
                    value={settings?.defaultDeliveryFee || 0}
                    onChange={(e) => updateSettings('defaultDeliveryFee', parseFloat(e.target.value) || 0)}
                    className="mt-2"
                  />
                </div>
                <div>
                  <label className="text-sm font-medium">الحد الأدنى للطلب (ج.م)</label>
                  <Input
                    type="number"
                    value={settings?.minOrderAmount || 0}
                    onChange={(e) => updateSettings('minOrderAmount', parseFloat(e.target.value) || 0)}
                    className="mt-2"
                  />
                </div>
              </div>
              <div className="grid gap-4 md:grid-cols-2">
                <div>
                  <label className="text-sm font-medium">نسبة عمولة المنصة (%)</label>
                  <Input
                    type="number"
                    value={settings?.platformFeePercentage || 0}
                    onChange={(e) => updateSettings('platformFeePercentage', parseFloat(e.target.value) || 0)}
                    className="mt-2"
                    min="0"
                    max="100"
                  />
                </div>
                <div>
                  <label className="text-sm font-medium">نسبة عمولة السائق (%)</label>
                  <Input
                    type="number"
                    value={settings?.driverCommissionPercentage || 0}
                    onChange={(e) => updateSettings('driverCommissionPercentage', parseFloat(e.target.value) || 0)}
                    className="mt-2"
                    min="0"
                    max="100"
                  />
                </div>
              </div>
              <div className="grid gap-4 md:grid-cols-2">
                <div>
                  <label className="text-sm font-medium">أقصى نطاق توصيل (كم)</label>
                  <Input
                    type="number"
                    value={settings?.maxDeliveryRadius || 0}
                    onChange={(e) => updateSettings('maxDeliveryRadius', parseFloat(e.target.value) || 0)}
                    className="mt-2"
                  />
                </div>
                <div>
                  <label className="text-sm font-medium">مهلة إلغاء الطلب (دقيقة)</label>
                  <Input
                    type="number"
                    value={settings?.orderCancellationTimeout || 0}
                    onChange={(e) => updateSettings('orderCancellationTimeout', parseInt(e.target.value) || 0)}
                    className="mt-2"
                  />
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="payment">
          <Card>
            <CardHeader>
              <CardTitle>إعدادات الدفع</CardTitle>
              <CardDescription>طرق الدفع المتاحة</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between p-4 bg-muted rounded-lg">
                <div>
                  <p className="font-medium">الدفع عند الاستلام</p>
                  <p className="text-sm text-muted-foreground">السماح بالدفع نقدياً</p>
                </div>
                <Switch
                  checked={settings?.paymentSettings?.cashOnDelivery ?? true}
                  onCheckedChange={(checked) => updateNestedSettings('paymentSettings', 'cashOnDelivery', checked)}
                />
              </div>
              <div className="flex items-center justify-between p-4 bg-muted rounded-lg">
                <div>
                  <p className="font-medium">الدفع الإلكتروني</p>
                  <p className="text-sm text-muted-foreground">البطاقات البنكية</p>
                </div>
                <Switch
                  checked={settings?.paymentSettings?.onlinePayment ?? true}
                  onCheckedChange={(checked) => updateNestedSettings('paymentSettings', 'onlinePayment', checked)}
                />
              </div>
              <div className="flex items-center justify-between p-4 bg-muted rounded-lg">
                <div>
                  <p className="font-medium">المحفظة الإلكترونية</p>
                  <p className="text-sm text-muted-foreground">فودافون كاش، اتصالات كاش، إلخ</p>
                </div>
                <Switch
                  checked={settings?.paymentSettings?.walletPayment ?? true}
                  onCheckedChange={(checked) => updateNestedSettings('paymentSettings', 'walletPayment', checked)}
                />
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="notifications">
          <Card>
            <CardHeader>
              <CardTitle>إعدادات الإشعارات</CardTitle>
              <CardDescription>أنواع الإشعارات المفعلة</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between p-4 bg-muted rounded-lg">
                <div>
                  <p className="font-medium">إشعارات البريد الإلكتروني</p>
                  <p className="text-sm text-muted-foreground">إرسال رسائل بالبريد</p>
                </div>
                <Switch
                  checked={settings?.notificationSettings?.emailNotifications ?? true}
                  onCheckedChange={(checked) => updateNestedSettings('notificationSettings', 'emailNotifications', checked)}
                />
              </div>
              <div className="flex items-center justify-between p-4 bg-muted rounded-lg">
                <div>
                  <p className="font-medium">الإشعارات الفورية</p>
                  <p className="text-sm text-muted-foreground">Push Notifications</p>
                </div>
                <Switch
                  checked={settings?.notificationSettings?.pushNotifications ?? true}
                  onCheckedChange={(checked) => updateNestedSettings('notificationSettings', 'pushNotifications', checked)}
                />
              </div>
              <div className="flex items-center justify-between p-4 bg-muted rounded-lg">
                <div>
                  <p className="font-medium">رسائل SMS</p>
                  <p className="text-sm text-muted-foreground">إرسال رسائل نصية</p>
                </div>
                <Switch
                  checked={settings?.notificationSettings?.smsNotifications ?? false}
                  onCheckedChange={(checked) => updateNestedSettings('notificationSettings', 'smsNotifications', checked)}
                />
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="maintenance">
          <Card>
            <CardHeader>
              <CardTitle>وضع الصيانة</CardTitle>
              <CardDescription>تعطيل التطبيق مؤقتاً</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between p-4 bg-muted rounded-lg">
                <div>
                  <p className="font-medium">تفعيل وضع الصيانة</p>
                  <p className="text-sm text-muted-foreground">سيتم عرض رسالة الصيانة للمستخدمين</p>
                </div>
                <Switch
                  checked={settings?.maintenanceMode ?? false}
                  onCheckedChange={(checked) => updateSettings('maintenanceMode', checked)}
                />
              </div>
              <div>
                <label className="text-sm font-medium">رسالة الصيانة</label>
                <Input
                  value={settings?.maintenanceMessage || ''}
                  onChange={(e) => updateSettings('maintenanceMessage', e.target.value)}
                  placeholder="التطبيق تحت الصيانة حالياً، يرجى المحاولة لاحقاً"
                  className="mt-2"
                />
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
