'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Switch } from '@/components/ui/switch';
import { Bell, Send, Users, Store, Truck, Megaphone } from 'lucide-react';
import api, { getErrorMessage } from '@/services/api';

export default function NotificationsPage() {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [success, setSuccess] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const [formData, setFormData] = useState({
    title: '',
    titleAr: '',
    body: '',
    bodyAr: '',
    targetRole: 'all',
    image: '',
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setError(null);
    setSuccess(null);

    try {
      const response = await api.post('/admin/notifications/broadcast', formData);

      if (response.data.success) {
        setSuccess(`تم إرسال الإشعار إلى ${response.data.data.sentCount} مستخدم`);
        setFormData({
          title: '',
          titleAr: '',
          body: '',
          bodyAr: '',
          targetRole: 'all',
          image: '',
        });
      }
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  const targetOptions = [
    { value: 'all', label: 'جميع المستخدمين', icon: Users },
    { value: 'customer', label: 'العملاء', icon: Users },
    { value: 'driver', label: 'السائقين', icon: Truck },
    { value: 'restaurant_owner', label: 'أصحاب المطاعم', icon: Store },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">إرسال الإشعارات</h1>
          <p className="text-muted-foreground">إرسال إشعارات للمستخدمين</p>
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

      <div className="grid gap-6 lg:grid-cols-3">
        {/* Broadcast Form */}
        <div className="lg:col-span-2">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Megaphone className="h-5 w-5" />
                إشعار جماعي
              </CardTitle>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor="title">العنوان (English)</Label>
                    <Input
                      id="title"
                      placeholder="Notification Title"
                      value={formData.title}
                      onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="titleAr">العنوان (عربي)</Label>
                    <Input
                      id="titleAr"
                      placeholder="عنوان الإشعار"
                      value={formData.titleAr}
                      onChange={(e) => setFormData({ ...formData, titleAr: e.target.value })}
                      required
                      dir="rtl"
                    />
                  </div>
                </div>

                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor="body">النص (English)</Label>
                    <Textarea
                      id="body"
                      placeholder="Notification body"
                      value={formData.body}
                      onChange={(e) => setFormData({ ...formData, body: e.target.value })}
                      required
                      rows={3}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="bodyAr">النص (عربي)</Label>
                    <Textarea
                      id="bodyAr"
                      placeholder="نص الإشعار"
                      value={formData.bodyAr}
                      onChange={(e) => setFormData({ ...formData, bodyAr: e.target.value })}
                      required
                      rows={3}
                      dir="rtl"
                    />
                  </div>
                </div>

                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor="targetRole">الفئة المستهدفة</Label>
                    <Select
                      value={formData.targetRole}
                      onValueChange={(value) => setFormData({ ...formData, targetRole: value })}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="اختر الفئة" />
                      </SelectTrigger>
                      <SelectContent>
                        {targetOptions.map((option) => (
                          <SelectItem key={option.value} value={option.value}>
                            <div className="flex items-center gap-2">
                              <option.icon className="h-4 w-4" />
                              {option.label}
                            </div>
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="image">رابط الصورة (اختياري)</Label>
                    <Input
                      id="image"
                      type="url"
                      placeholder="https://example.com/image.jpg"
                      value={formData.image}
                      onChange={(e) => setFormData({ ...formData, image: e.target.value })}
                    />
                  </div>
                </div>

                <Button type="submit" className="w-full" disabled={isSubmitting}>
                  {isSubmitting ? (
                    <>جاري الإرسال...</>
                  ) : (
                    <>
                      <Send className="h-4 w-4 ml-2" />
                      إرسال الإشعار
                    </>
                  )}
                </Button>
              </form>
            </CardContent>
          </Card>
        </div>

        {/* Info Card */}
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Bell className="h-5 w-5" />
                معلومات
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="text-sm text-muted-foreground space-y-2">
                <p>• يتم إرسال الإشعارات لجميع المستخدمين النشطين</p>
                <p>• يتم عرض النص العربي للمستخدمين</p>
                <p>• يتم حفظ الإشعارات في قاعدة البيانات</p>
                <p>• الإشعارات تصل عبر Firebase Cloud Messaging</p>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>الفئات المستهدفة</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {targetOptions.map((option) => (
                  <div key={option.value} className="flex items-center gap-3 p-2 bg-muted rounded-lg">
                    <option.icon className="h-5 w-5 text-primary" />
                    <span className="text-sm">{option.label}</span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
