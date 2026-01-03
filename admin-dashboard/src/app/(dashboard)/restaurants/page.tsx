'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
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
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Search,
  MoreVertical,
  CheckCircle,
  XCircle,
  Pause,
  Play,
  Eye,
  RefreshCw,
  Store,
} from 'lucide-react';
import { restaurantsApi, Restaurant, getErrorMessage } from '@/services/api';
import { RESTAURANT_STATUSES } from '@/config/constants';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';

export default function RestaurantsPage() {
  const [restaurants, setRestaurants] = useState<Restaurant[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [actionDialog, setActionDialog] = useState<{
    open: boolean;
    type: 'approve' | 'reject' | 'suspend' | 'activate' | null;
    restaurant: Restaurant | null;
  }>({ open: false, type: null, restaurant: null });
  const [reason, setReason] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchRestaurants = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const res = await restaurantsApi.getRestaurants({
        page: currentPage,
        limit: 20,
        search: search || undefined,
        status: statusFilter !== 'all' ? statusFilter as Restaurant['status'] : undefined,
      });

      if (res.success && res.data) {
        setRestaurants(res.data.data || []);
        setTotalPages(res.data.pagination?.pages || 1);
      }
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchRestaurants();
  }, [currentPage, statusFilter]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setCurrentPage(1);
    fetchRestaurants();
  };

  const handleAction = async () => {
    if (!actionDialog.restaurant || !actionDialog.type) return;

    setIsSubmitting(true);
    try {
      const id = actionDialog.restaurant._id;
      switch (actionDialog.type) {
        case 'approve':
          await restaurantsApi.approveRestaurant(id);
          break;
        case 'reject':
          await restaurantsApi.rejectRestaurant(id, reason);
          break;
        case 'suspend':
          await restaurantsApi.suspendRestaurant(id, reason);
          break;
        case 'activate':
          await restaurantsApi.activateRestaurant(id);
          break;
      }
      setActionDialog({ open: false, type: null, restaurant: null });
      setReason('');
      fetchRestaurants();
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  const getStatusBadge = (status: Restaurant['status']) => {
    const config = RESTAURANT_STATUSES[status];
    const colorMap: Record<string, string> = {
      orange: 'bg-orange-100 text-orange-800',
      green: 'bg-green-100 text-green-800',
      red: 'bg-red-100 text-red-800',
      gray: 'bg-gray-100 text-gray-800',
    };

    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${colorMap[config.color]}`}>
        {config.label}
      </span>
    );
  };

  if (isLoading && restaurants.length === 0) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-48" />
        <div className="flex gap-4">
          <Skeleton className="h-10 flex-1" />
          <Skeleton className="h-10 w-40" />
        </div>
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
          <h1 className="text-2xl font-bold">إدارة المطاعم</h1>
          <p className="text-muted-foreground">عرض وإدارة جميع المطاعم</p>
        </div>
        <Button onClick={fetchRestaurants} variant="outline" size="icon">
          <RefreshCw className="h-4 w-4" />
        </Button>
      </div>

      {error && (
        <div className="bg-destructive/10 text-destructive p-4 rounded-lg">
          {error}
        </div>
      )}

      <div className="flex gap-4">
        <form onSubmit={handleSearch} className="flex-1 flex gap-2">
          <div className="relative flex-1">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="البحث عن مطعم..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pr-10"
            />
          </div>
          <Button type="submit">بحث</Button>
        </form>
        <Select value={statusFilter} onValueChange={setStatusFilter}>
          <SelectTrigger className="w-[160px]">
            <SelectValue placeholder="الحالة" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">جميع الحالات</SelectItem>
            <SelectItem value="pending">قيد المراجعة</SelectItem>
            <SelectItem value="approved">موافق عليه</SelectItem>
            <SelectItem value="rejected">مرفوض</SelectItem>
            <SelectItem value="suspended">موقوف</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <Card>
        <CardContent className="pt-6">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>المطعم</TableHead>
                <TableHead>المالك</TableHead>
                <TableHead>الهاتف</TableHead>
                <TableHead>التقييم</TableHead>
                <TableHead>الحالة</TableHead>
                <TableHead>تاريخ التسجيل</TableHead>
                <TableHead></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {restaurants.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-8 text-muted-foreground">
                    لا توجد مطاعم
                  </TableCell>
                </TableRow>
              ) : (
                restaurants.map((restaurant) => (
                  <TableRow key={restaurant._id}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-full bg-muted flex items-center justify-center">
                          {restaurant.logo ? (
                            <img src={restaurant.logo} alt="" className="h-10 w-10 rounded-full object-cover" />
                          ) : (
                            <Store className="h-5 w-5 text-muted-foreground" />
                          )}
                        </div>
                        <div>
                          <p className="font-medium">{restaurant.name}</p>
                          <p className="text-sm text-muted-foreground">{restaurant.address?.area}</p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>{restaurant.ownerId?.name || '-'}</TableCell>
                    <TableCell dir="ltr" className="text-right">{restaurant.phone}</TableCell>
                    <TableCell>
                      {restaurant.rating > 0 ? (
                        <span className="flex items-center gap-1">
                          <span className="text-yellow-500">★</span>
                          {restaurant.rating.toFixed(1)}
                        </span>
                      ) : '-'}
                    </TableCell>
                    <TableCell>{getStatusBadge(restaurant.status)}</TableCell>
                    <TableCell className="text-muted-foreground text-sm">
                      {format(new Date(restaurant.createdAt), 'dd MMM yyyy', { locale: ar })}
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreVertical className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem>
                            <Eye className="h-4 w-4 ml-2" />
                            عرض التفاصيل
                          </DropdownMenuItem>
                          {restaurant.status === 'pending' && (
                            <>
                              <DropdownMenuItem
                                onClick={() => setActionDialog({ open: true, type: 'approve', restaurant })}
                              >
                                <CheckCircle className="h-4 w-4 ml-2 text-green-600" />
                                موافقة
                              </DropdownMenuItem>
                              <DropdownMenuItem
                                onClick={() => setActionDialog({ open: true, type: 'reject', restaurant })}
                              >
                                <XCircle className="h-4 w-4 ml-2 text-red-600" />
                                رفض
                              </DropdownMenuItem>
                            </>
                          )}
                          {restaurant.status === 'approved' && (
                            <DropdownMenuItem
                              onClick={() => setActionDialog({ open: true, type: 'suspend', restaurant })}
                            >
                              <Pause className="h-4 w-4 ml-2 text-yellow-600" />
                              إيقاف
                            </DropdownMenuItem>
                          )}
                          {restaurant.status === 'suspended' && (
                            <DropdownMenuItem
                              onClick={() => setActionDialog({ open: true, type: 'activate', restaurant })}
                            >
                              <Play className="h-4 w-4 ml-2 text-green-600" />
                              تفعيل
                            </DropdownMenuItem>
                          )}
                        </DropdownMenuContent>
                      </DropdownMenu>
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

      {/* Action Dialog */}
      <Dialog open={actionDialog.open} onOpenChange={(open) => !open && setActionDialog({ open: false, type: null, restaurant: null })}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {actionDialog.type === 'approve' && 'تأكيد الموافقة'}
              {actionDialog.type === 'reject' && 'تأكيد الرفض'}
              {actionDialog.type === 'suspend' && 'تأكيد الإيقاف'}
              {actionDialog.type === 'activate' && 'تأكيد التفعيل'}
            </DialogTitle>
            <DialogDescription>
              {actionDialog.type === 'approve' && `هل تريد الموافقة على مطعم "${actionDialog.restaurant?.name}"؟`}
              {actionDialog.type === 'reject' && `هل تريد رفض مطعم "${actionDialog.restaurant?.name}"؟`}
              {actionDialog.type === 'suspend' && `هل تريد إيقاف مطعم "${actionDialog.restaurant?.name}"؟`}
              {actionDialog.type === 'activate' && `هل تريد تفعيل مطعم "${actionDialog.restaurant?.name}"؟`}
            </DialogDescription>
          </DialogHeader>

          {(actionDialog.type === 'reject' || actionDialog.type === 'suspend') && (
            <div className="py-4">
              <label className="text-sm font-medium">السبب</label>
              <Input
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                placeholder="أدخل سبب الرفض أو الإيقاف..."
                className="mt-2"
              />
            </div>
          )}

          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setActionDialog({ open: false, type: null, restaurant: null })}
            >
              إلغاء
            </Button>
            <Button
              onClick={handleAction}
              disabled={isSubmitting || ((actionDialog.type === 'reject' || actionDialog.type === 'suspend') && !reason)}
              variant={actionDialog.type === 'reject' || actionDialog.type === 'suspend' ? 'destructive' : 'default'}
            >
              {isSubmitting ? 'جاري...' : 'تأكيد'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
