'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui/skeleton';
import { Switch } from '@/components/ui/switch';
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
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { RefreshCw, Plus, Edit, Trash2, MapPin } from 'lucide-react';
import { zonesApi, Zone, getErrorMessage } from '@/services/api';

export default function ZonesPage() {
  const [zones, setZones] = useState<Zone[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [editDialog, setEditDialog] = useState<{
    open: boolean;
    zone: Partial<Zone> | null;
    isNew: boolean;
  }>({ open: false, zone: null, isNew: false });
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchZones = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const res = await zonesApi.getZones();
      if (res.success && res.data) {
        setZones(res.data);
      }
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchZones();
  }, []);

  const handleSave = async () => {
    if (!editDialog.zone) return;

    setIsSubmitting(true);
    try {
      if (editDialog.isNew) {
        await zonesApi.createZone({
          name: editDialog.zone.name || '',
          nameAr: editDialog.zone.nameAr || '',
          deliveryFee: editDialog.zone.deliveryFee || 0,
          minOrderAmount: editDialog.zone.minOrderAmount || 0,
          isActive: editDialog.zone.isActive ?? true,
        });
      } else if (editDialog.zone._id) {
        await zonesApi.updateZone(editDialog.zone._id, editDialog.zone);
      }
      setEditDialog({ open: false, zone: null, isNew: false });
      fetchZones();
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('هل تريد حذف هذه المنطقة؟')) return;

    try {
      await zonesApi.deleteZone(id);
      fetchZones();
    } catch (err) {
      setError(getErrorMessage(err));
    }
  };

  const formatCurrency = (amount: number) => {
    return `${amount.toLocaleString('ar-EG')} ج.م`;
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-48" />
        <Card>
          <CardContent className="pt-6">
            {[...Array(5)].map((_, i) => (
              <Skeleton key={i} className="h-16 w-full mb-2" />
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
          <h1 className="text-2xl font-bold">مناطق التوصيل</h1>
          <p className="text-muted-foreground">إدارة مناطق ورسوم التوصيل</p>
        </div>
        <div className="flex gap-2">
          <Button onClick={fetchZones} variant="outline" size="icon">
            <RefreshCw className="h-4 w-4" />
          </Button>
          <Button onClick={() => setEditDialog({
            open: true,
            zone: { name: '', nameAr: '', deliveryFee: 0, minOrderAmount: 0, isActive: true },
            isNew: true,
          })}>
            <Plus className="h-4 w-4 ml-2" />
            إضافة منطقة
          </Button>
        </div>
      </div>

      {error && (
        <div className="bg-destructive/10 text-destructive p-4 rounded-lg">
          {error}
        </div>
      )}

      <Card>
        <CardContent className="pt-6">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>المنطقة</TableHead>
                <TableHead>الاسم بالعربية</TableHead>
                <TableHead>رسوم التوصيل</TableHead>
                <TableHead>الحد الأدنى للطلب</TableHead>
                <TableHead>الحالة</TableHead>
                <TableHead></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {zones.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-8 text-muted-foreground">
                    لا توجد مناطق
                  </TableCell>
                </TableRow>
              ) : (
                zones.map((zone) => (
                  <TableRow key={zone._id}>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <MapPin className="h-4 w-4 text-muted-foreground" />
                        <span className="font-medium">{zone.name}</span>
                      </div>
                    </TableCell>
                    <TableCell>{zone.nameAr}</TableCell>
                    <TableCell>{formatCurrency(zone.deliveryFee)}</TableCell>
                    <TableCell>{formatCurrency(zone.minOrderAmount)}</TableCell>
                    <TableCell>
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        zone.isActive
                          ? 'bg-green-100 text-green-800'
                          : 'bg-gray-100 text-gray-800'
                      }`}>
                        {zone.isActive ? 'نشط' : 'غير نشط'}
                      </span>
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-2">
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => setEditDialog({ open: true, zone, isNew: false })}
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => handleDelete(zone._id)}
                        >
                          <Trash2 className="h-4 w-4 text-destructive" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Edit Dialog */}
      <Dialog open={editDialog.open} onOpenChange={(open) => !open && setEditDialog({ open: false, zone: null, isNew: false })}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{editDialog.isNew ? 'إضافة منطقة جديدة' : 'تعديل المنطقة'}</DialogTitle>
          </DialogHeader>

          <div className="space-y-4 py-4">
            <div>
              <label className="text-sm font-medium">الاسم (English)</label>
              <Input
                value={editDialog.zone?.name || ''}
                onChange={(e) => setEditDialog({
                  ...editDialog,
                  zone: { ...editDialog.zone, name: e.target.value },
                })}
                placeholder="Zone name in English"
                className="mt-2"
              />
            </div>
            <div>
              <label className="text-sm font-medium">الاسم بالعربية</label>
              <Input
                value={editDialog.zone?.nameAr || ''}
                onChange={(e) => setEditDialog({
                  ...editDialog,
                  zone: { ...editDialog.zone, nameAr: e.target.value },
                })}
                placeholder="اسم المنطقة بالعربية"
                className="mt-2"
              />
            </div>
            <div>
              <label className="text-sm font-medium">رسوم التوصيل (ج.م)</label>
              <Input
                type="number"
                value={editDialog.zone?.deliveryFee || 0}
                onChange={(e) => setEditDialog({
                  ...editDialog,
                  zone: { ...editDialog.zone, deliveryFee: parseFloat(e.target.value) || 0 },
                })}
                className="mt-2"
              />
            </div>
            <div>
              <label className="text-sm font-medium">الحد الأدنى للطلب (ج.م)</label>
              <Input
                type="number"
                value={editDialog.zone?.minOrderAmount || 0}
                onChange={(e) => setEditDialog({
                  ...editDialog,
                  zone: { ...editDialog.zone, minOrderAmount: parseFloat(e.target.value) || 0 },
                })}
                className="mt-2"
              />
            </div>
            <div className="flex items-center justify-between">
              <label className="text-sm font-medium">نشط</label>
              <Switch
                checked={editDialog.zone?.isActive ?? true}
                onCheckedChange={(checked) => setEditDialog({
                  ...editDialog,
                  zone: { ...editDialog.zone, isActive: checked },
                })}
              />
            </div>
          </div>

          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setEditDialog({ open: false, zone: null, isNew: false })}
            >
              إلغاء
            </Button>
            <Button onClick={handleSave} disabled={isSubmitting}>
              {isSubmitting ? 'جاري الحفظ...' : 'حفظ'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
