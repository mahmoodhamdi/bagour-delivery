'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
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
  Truck,
  Bike,
  Car,
} from 'lucide-react';
import { driversApi, Driver, getErrorMessage } from '@/services/api';
import { DRIVER_STATUSES } from '@/config/constants';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';

export default function DriversPage() {
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [onlineFilter, setOnlineFilter] = useState<string>('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [actionDialog, setActionDialog] = useState<{
    open: boolean;
    type: 'approve' | 'reject' | 'suspend' | 'activate' | null;
    driver: Driver | null;
  }>({ open: false, type: null, driver: null });
  const [reason, setReason] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchDrivers = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const res = await driversApi.getDrivers({
        page: currentPage,
        limit: 20,
        search: search || undefined,
        status: statusFilter !== 'all' ? statusFilter as Driver['status'] : undefined,
        isOnline: onlineFilter !== 'all' ? onlineFilter : undefined,
      });

      if (res.success && res.data) {
        setDrivers(res.data.data || []);
        setTotalPages(res.data.pagination?.pages || 1);
      }
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchDrivers();
  }, [currentPage, statusFilter, onlineFilter]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setCurrentPage(1);
    fetchDrivers();
  };

  const handleAction = async () => {
    if (!actionDialog.driver || !actionDialog.type) return;

    setIsSubmitting(true);
    try {
      const id = actionDialog.driver._id;
      switch (actionDialog.type) {
        case 'approve':
          await driversApi.approveDriver(id);
          break;
        case 'reject':
          await driversApi.rejectDriver(id, reason);
          break;
        case 'suspend':
          await driversApi.suspendDriver(id, reason);
          break;
        case 'activate':
          await driversApi.activateDriver(id);
          break;
      }
      setActionDialog({ open: false, type: null, driver: null });
      setReason('');
      fetchDrivers();
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  const getStatusBadge = (status: Driver['status']) => {
    const config = DRIVER_STATUSES[status];
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

  const getVehicleIcon = (type: string) => {
    switch (type) {
      case 'motorcycle':
        return <Bike className="h-4 w-4" />;
      case 'car':
        return <Car className="h-4 w-4" />;
      case 'bicycle':
        return <Bike className="h-4 w-4" />;
      default:
        return <Truck className="h-4 w-4" />;
    }
  };

  const formatCurrency = (amount: number) => {
    return `${amount.toLocaleString('ar-EG')} ج.م`;
  };

  if (isLoading && drivers.length === 0) {
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
          <h1 className="text-2xl font-bold">إدارة السائقين</h1>
          <p className="text-muted-foreground">عرض وإدارة جميع السائقين</p>
        </div>
        <Button onClick={fetchDrivers} variant="outline" size="icon">
          <RefreshCw className="h-4 w-4" />
        </Button>
      </div>

      {error && (
        <div className="bg-destructive/10 text-destructive p-4 rounded-lg">
          {error}
        </div>
      )}

      <div className="flex gap-4 flex-wrap">
        <form onSubmit={handleSearch} className="flex-1 flex gap-2 min-w-[300px]">
          <div className="relative flex-1">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="البحث عن سائق..."
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
        <Select value={onlineFilter} onValueChange={setOnlineFilter}>
          <SelectTrigger className="w-[140px]">
            <SelectValue placeholder="الاتصال" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">الكل</SelectItem>
            <SelectItem value="true">متصل</SelectItem>
            <SelectItem value="false">غير متصل</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <Card>
        <CardContent className="pt-6">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>السائق</TableHead>
                <TableHead>الهاتف</TableHead>
                <TableHead>المركبة</TableHead>
                <TableHead>التوصيلات</TableHead>
                <TableHead>الأرباح</TableHead>
                <TableHead>التقييم</TableHead>
                <TableHead>الحالة</TableHead>
                <TableHead>متصل</TableHead>
                <TableHead></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {drivers.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={9} className="text-center py-8 text-muted-foreground">
                    لا يوجد سائقين
                  </TableCell>
                </TableRow>
              ) : (
                drivers.map((driver) => (
                  <TableRow key={driver._id}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-full bg-muted flex items-center justify-center">
                          {driver.avatar ? (
                            <img src={driver.avatar} alt="" className="h-10 w-10 rounded-full object-cover" />
                          ) : (
                            <Truck className="h-5 w-5 text-muted-foreground" />
                          )}
                        </div>
                        <span className="font-medium">{driver.userId?.name || driver.name || '-'}</span>
                      </div>
                    </TableCell>
                    <TableCell dir="ltr" className="text-right">
                      {driver.userId?.phone || driver.phone || '-'}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        {getVehicleIcon(driver.vehicleType)}
                        <span className="text-sm">{driver.vehiclePlate || '-'}</span>
                      </div>
                    </TableCell>
                    <TableCell>{driver.totalDeliveries}</TableCell>
                    <TableCell>{formatCurrency(driver.totalEarnings)}</TableCell>
                    <TableCell>
                      {driver.rating > 0 ? (
                        <span className="flex items-center gap-1">
                          <span className="text-yellow-500">★</span>
                          {driver.rating.toFixed(1)}
                        </span>
                      ) : '-'}
                    </TableCell>
                    <TableCell>{getStatusBadge(driver.status)}</TableCell>
                    <TableCell>
                      <span className={`inline-flex h-2 w-2 rounded-full ${driver.isOnline ? 'bg-green-500' : 'bg-gray-300'}`} />
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
                          {driver.status === 'pending' && (
                            <>
                              <DropdownMenuItem
                                onClick={() => setActionDialog({ open: true, type: 'approve', driver })}
                              >
                                <CheckCircle className="h-4 w-4 ml-2 text-green-600" />
                                موافقة
                              </DropdownMenuItem>
                              <DropdownMenuItem
                                onClick={() => setActionDialog({ open: true, type: 'reject', driver })}
                              >
                                <XCircle className="h-4 w-4 ml-2 text-red-600" />
                                رفض
                              </DropdownMenuItem>
                            </>
                          )}
                          {driver.status === 'approved' && (
                            <DropdownMenuItem
                              onClick={() => setActionDialog({ open: true, type: 'suspend', driver })}
                            >
                              <Pause className="h-4 w-4 ml-2 text-yellow-600" />
                              إيقاف
                            </DropdownMenuItem>
                          )}
                          {driver.status === 'suspended' && (
                            <DropdownMenuItem
                              onClick={() => setActionDialog({ open: true, type: 'activate', driver })}
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
      <Dialog open={actionDialog.open} onOpenChange={(open) => !open && setActionDialog({ open: false, type: null, driver: null })}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {actionDialog.type === 'approve' && 'تأكيد الموافقة'}
              {actionDialog.type === 'reject' && 'تأكيد الرفض'}
              {actionDialog.type === 'suspend' && 'تأكيد الإيقاف'}
              {actionDialog.type === 'activate' && 'تأكيد التفعيل'}
            </DialogTitle>
            <DialogDescription>
              {actionDialog.type === 'approve' && `هل تريد الموافقة على السائق "${actionDialog.driver?.userId?.name || actionDialog.driver?.name}"؟`}
              {actionDialog.type === 'reject' && `هل تريد رفض السائق "${actionDialog.driver?.userId?.name || actionDialog.driver?.name}"؟`}
              {actionDialog.type === 'suspend' && `هل تريد إيقاف السائق "${actionDialog.driver?.userId?.name || actionDialog.driver?.name}"؟`}
              {actionDialog.type === 'activate' && `هل تريد تفعيل السائق "${actionDialog.driver?.userId?.name || actionDialog.driver?.name}"؟`}
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
              onClick={() => setActionDialog({ open: false, type: null, driver: null })}
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
