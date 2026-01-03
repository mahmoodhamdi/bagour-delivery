'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent } from '@/components/ui/card';
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
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { RefreshCw, Plus, Edit, Trash2, Ticket } from 'lucide-react';
import { couponsApi, getErrorMessage } from '@/services/api';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';

interface Coupon {
  _id: string;
  code: string;
  discountType: 'percentage' | 'fixed';
  discountValue: number;
  minOrderAmount?: number;
  maxDiscount?: number;
  usageLimit?: number;
  usedCount: number;
  startDate: string;
  endDate: string;
  isActive: boolean;
  createdAt: string;
}

export default function CouponsPage() {
  const [coupons, setCoupons] = useState<Coupon[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [editDialog, setEditDialog] = useState<{
    open: boolean;
    coupon: Partial<Coupon> | null;
    isNew: boolean;
  }>({ open: false, coupon: null, isNew: false });
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchCoupons = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const res = await couponsApi.getCoupons({
        page: currentPage,
        limit: 20,
      });

      if (res.success && res.data) {
        setCoupons(res.data.data || []);
        setTotalPages(res.data.pagination?.pages || 1);
      }
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchCoupons();
  }, [currentPage]);

  const handleSave = async () => {
    if (!editDialog.coupon) return;

    setIsSubmitting(true);
    try {
      if (editDialog.isNew) {
        await couponsApi.createCoupon({
          code: editDialog.coupon.code || '',
          discountType: editDialog.coupon.discountType || 'percentage',
          discountValue: editDialog.coupon.discountValue || 0,
          minOrderAmount: editDialog.coupon.minOrderAmount,
          maxDiscount: editDialog.coupon.maxDiscount,
          usageLimit: editDialog.coupon.usageLimit,
          startDate: editDialog.coupon.startDate || new Date().toISOString(),
          endDate: editDialog.coupon.endDate || new Date().toISOString(),
        });
      } else if (editDialog.coupon._id) {
        await couponsApi.updateCoupon(editDialog.coupon._id, {
          code: editDialog.coupon.code,
          discountType: editDialog.coupon.discountType,
          discountValue: editDialog.coupon.discountValue,
          minOrderAmount: editDialog.coupon.minOrderAmount,
          maxDiscount: editDialog.coupon.maxDiscount,
          usageLimit: editDialog.coupon.usageLimit,
          isActive: editDialog.coupon.isActive,
        });
      }
      setEditDialog({ open: false, coupon: null, isNew: false });
      fetchCoupons();
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('هل تريد حذف هذا الكوبون؟')) return;

    try {
      await couponsApi.deleteCoupon(id);
      fetchCoupons();
    } catch (err) {
      setError(getErrorMessage(err));
    }
  };

  const formatCurrency = (amount: number) => {
    return `${amount.toLocaleString('ar-EG')} ج.م`;
  };

  if (isLoading && coupons.length === 0) {
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
          <h1 className="text-2xl font-bold">إدارة الكوبونات</h1>
          <p className="text-muted-foreground">إنشاء وإدارة كوبونات الخصم</p>
        </div>
        <div className="flex gap-2">
          <Button onClick={fetchCoupons} variant="outline" size="icon">
            <RefreshCw className="h-4 w-4" />
          </Button>
          <Button onClick={() => setEditDialog({
            open: true,
            coupon: {
              code: '',
              discountType: 'percentage',
              discountValue: 10,
              isActive: true,
              startDate: new Date().toISOString().split('T')[0],
              endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
            },
            isNew: true,
          })}>
            <Plus className="h-4 w-4 ml-2" />
            إضافة كوبون
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
                <TableHead>الكود</TableHead>
                <TableHead>نوع الخصم</TableHead>
                <TableHead>قيمة الخصم</TableHead>
                <TableHead>الحد الأدنى</TableHead>
                <TableHead>الاستخدام</TableHead>
                <TableHead>الصلاحية</TableHead>
                <TableHead>الحالة</TableHead>
                <TableHead></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {coupons.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} className="text-center py-8 text-muted-foreground">
                    لا توجد كوبونات
                  </TableCell>
                </TableRow>
              ) : (
                coupons.map((coupon) => (
                  <TableRow key={coupon._id}>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Ticket className="h-4 w-4 text-primary" />
                        <span className="font-mono font-bold">{coupon.code}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      {coupon.discountType === 'percentage' ? 'نسبة مئوية' : 'مبلغ ثابت'}
                    </TableCell>
                    <TableCell>
                      {coupon.discountType === 'percentage'
                        ? `${coupon.discountValue}%`
                        : formatCurrency(coupon.discountValue)}
                    </TableCell>
                    <TableCell>
                      {coupon.minOrderAmount ? formatCurrency(coupon.minOrderAmount) : '-'}
                    </TableCell>
                    <TableCell>
                      {coupon.usedCount}/{coupon.usageLimit || '∞'}
                    </TableCell>
                    <TableCell className="text-sm">
                      <div>
                        {format(new Date(coupon.startDate), 'dd/MM/yyyy', { locale: ar })}
                      </div>
                      <div className="text-muted-foreground">
                        → {format(new Date(coupon.endDate), 'dd/MM/yyyy', { locale: ar })}
                      </div>
                    </TableCell>
                    <TableCell>
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        coupon.isActive && new Date(coupon.endDate) > new Date()
                          ? 'bg-green-100 text-green-800'
                          : 'bg-gray-100 text-gray-800'
                      }`}>
                        {coupon.isActive && new Date(coupon.endDate) > new Date() ? 'نشط' : 'منتهي'}
                      </span>
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-2">
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => setEditDialog({ open: true, coupon, isNew: false })}
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => handleDelete(coupon._id)}
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

          {totalPages > 1 && (
            <div className="flex items-center justify-center gap-2 mt-4">
              <Button
                variant="outline"
                size="sm"
                disabled={currentPage === 1}
                onClick={() => setCurrentPage((p) => p - 1)}
              >
                السابق
              </Button>
              <span className="text-sm text-muted-foreground">
                صفحة {currentPage} من {totalPages}
              </span>
              <Button
                variant="outline"
                size="sm"
                disabled={currentPage === totalPages}
                onClick={() => setCurrentPage((p) => p + 1)}
              >
                التالي
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Edit Dialog */}
      <Dialog open={editDialog.open} onOpenChange={(open) => !open && setEditDialog({ open: false, coupon: null, isNew: false })}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{editDialog.isNew ? 'إضافة كوبون جديد' : 'تعديل الكوبون'}</DialogTitle>
          </DialogHeader>

          <div className="space-y-4 py-4">
            <div>
              <label className="text-sm font-medium">كود الكوبون</label>
              <Input
                value={editDialog.coupon?.code || ''}
                onChange={(e) => setEditDialog({
                  ...editDialog,
                  coupon: { ...editDialog.coupon, code: e.target.value.toUpperCase() },
                })}
                placeholder="SAVE20"
                className="mt-2 font-mono"
              />
            </div>
            <div className="grid gap-4 grid-cols-2">
              <div>
                <label className="text-sm font-medium">نوع الخصم</label>
                <Select
                  value={editDialog.coupon?.discountType || 'percentage'}
                  onValueChange={(value) => setEditDialog({
                    ...editDialog,
                    coupon: { ...editDialog.coupon, discountType: value as 'percentage' | 'fixed' },
                  })}
                >
                  <SelectTrigger className="mt-2">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="percentage">نسبة مئوية</SelectItem>
                    <SelectItem value="fixed">مبلغ ثابت</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div>
                <label className="text-sm font-medium">
                  قيمة الخصم {editDialog.coupon?.discountType === 'percentage' ? '(%)' : '(ج.م)'}
                </label>
                <Input
                  type="number"
                  value={editDialog.coupon?.discountValue || 0}
                  onChange={(e) => setEditDialog({
                    ...editDialog,
                    coupon: { ...editDialog.coupon, discountValue: parseFloat(e.target.value) || 0 },
                  })}
                  className="mt-2"
                />
              </div>
            </div>
            <div className="grid gap-4 grid-cols-2">
              <div>
                <label className="text-sm font-medium">الحد الأدنى للطلب (ج.م)</label>
                <Input
                  type="number"
                  value={editDialog.coupon?.minOrderAmount || ''}
                  onChange={(e) => setEditDialog({
                    ...editDialog,
                    coupon: { ...editDialog.coupon, minOrderAmount: parseFloat(e.target.value) || undefined },
                  })}
                  placeholder="اختياري"
                  className="mt-2"
                />
              </div>
              <div>
                <label className="text-sm font-medium">أقصى خصم (ج.م)</label>
                <Input
                  type="number"
                  value={editDialog.coupon?.maxDiscount || ''}
                  onChange={(e) => setEditDialog({
                    ...editDialog,
                    coupon: { ...editDialog.coupon, maxDiscount: parseFloat(e.target.value) || undefined },
                  })}
                  placeholder="اختياري"
                  className="mt-2"
                />
              </div>
            </div>
            <div>
              <label className="text-sm font-medium">عدد مرات الاستخدام</label>
              <Input
                type="number"
                value={editDialog.coupon?.usageLimit || ''}
                onChange={(e) => setEditDialog({
                  ...editDialog,
                  coupon: { ...editDialog.coupon, usageLimit: parseInt(e.target.value) || undefined },
                })}
                placeholder="غير محدود"
                className="mt-2"
              />
            </div>
            {!editDialog.isNew && (
              <div className="flex items-center justify-between">
                <label className="text-sm font-medium">نشط</label>
                <Switch
                  checked={editDialog.coupon?.isActive ?? true}
                  onCheckedChange={(checked) => setEditDialog({
                    ...editDialog,
                    coupon: { ...editDialog.coupon, isActive: checked },
                  })}
                />
              </div>
            )}
          </div>

          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setEditDialog({ open: false, coupon: null, isNew: false })}
            >
              إلغاء
            </Button>
            <Button onClick={handleSave} disabled={isSubmitting || !editDialog.coupon?.code}>
              {isSubmitting ? 'جاري الحفظ...' : 'حفظ'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
