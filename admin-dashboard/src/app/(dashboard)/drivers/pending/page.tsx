'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui/skeleton';
import { Badge } from '@/components/ui/badge';
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
  Search,
  CheckCircle,
  XCircle,
  Eye,
  RefreshCw,
  Truck,
  Bike,
  Car,
  Clock,
  FileText,
  Phone,
  Mail,
  User,
  Calendar,
} from 'lucide-react';
import { driversApi, Driver, getErrorMessage } from '@/services/api';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';

export default function PendingDriversPage() {
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalPending, setTotalPending] = useState(0);
  const [selectedDriver, setSelectedDriver] = useState<Driver | null>(null);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [actionDialog, setActionDialog] = useState<{
    open: boolean;
    type: 'approve' | 'reject' | null;
    driver: Driver | null;
  }>({ open: false, type: null, driver: null });
  const [reason, setReason] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchPendingDrivers = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const res = await driversApi.getDrivers({
        page: currentPage,
        limit: 20,
        search: search || undefined,
        status: 'pending',
      });

      if (res.success && res.data) {
        setDrivers(res.data.data || []);
        setTotalPages(res.data.pagination?.pages || 1);
        setTotalPending(res.data.pagination?.total || 0);
      }
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchPendingDrivers();
  }, [currentPage]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setCurrentPage(1);
    fetchPendingDrivers();
  };

  const handleAction = async () => {
    if (!actionDialog.driver || !actionDialog.type) return;

    setIsSubmitting(true);
    try {
      const id = actionDialog.driver._id;
      if (actionDialog.type === 'approve') {
        await driversApi.approveDriver(id);
      } else {
        await driversApi.rejectDriver(id, reason);
      }
      setActionDialog({ open: false, type: null, driver: null });
      setReason('');
      fetchPendingDrivers();
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
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

  const getVehicleLabel = (type: string) => {
    const labels: Record<string, string> = {
      motorcycle: 'دراجة نارية',
      car: 'سيارة',
      bicycle: 'دراجة هوائية',
    };
    return labels[type] || type;
  };

  const viewDriverDetails = (driver: Driver) => {
    setSelectedDriver(driver);
    setDetailsOpen(true);
  };

  if (isLoading && drivers.length === 0) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-64" />
        <div className="grid gap-4 md:grid-cols-3">
          {[...Array(3)].map((_, i) => (
            <Skeleton key={i} className="h-24" />
          ))}
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
          <h1 className="text-2xl font-bold">طلبات انضمام السائقين</h1>
          <p className="text-muted-foreground">مراجعة والموافقة على طلبات السائقين الجدد</p>
        </div>
        <Button onClick={fetchPendingDrivers} variant="outline" size="icon">
          <RefreshCw className="h-4 w-4" />
        </Button>
      </div>

      {/* Stats Cards */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              إجمالي الطلبات المعلقة
            </CardTitle>
            <Clock className="h-4 w-4 text-orange-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-600">{totalPending}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              بانتظار المراجعة
            </CardTitle>
            <FileText className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-600">{drivers.length}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              الصفحة الحالية
            </CardTitle>
            <User className="h-4 w-4 text-purple-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-purple-600">
              {currentPage} / {totalPages}
            </div>
          </CardContent>
        </Card>
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
              placeholder="البحث عن سائق بالاسم أو الهاتف..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pr-10"
            />
          </div>
          <Button type="submit">بحث</Button>
        </form>
      </div>

      <Card>
        <CardContent className="pt-6">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>السائق</TableHead>
                <TableHead>الهاتف</TableHead>
                <TableHead>نوع المركبة</TableHead>
                <TableHead>رقم اللوحة</TableHead>
                <TableHead>تاريخ التقديم</TableHead>
                <TableHead>الإجراءات</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {drivers.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-8 text-muted-foreground">
                    <div className="flex flex-col items-center gap-2">
                      <CheckCircle className="h-12 w-12 text-green-500" />
                      <p>لا توجد طلبات معلقة حالياً</p>
                    </div>
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
                        <div>
                          <span className="font-medium block">{driver.userId?.name || driver.name || '-'}</span>
                          <span className="text-sm text-muted-foreground">{driver.userId?.email || '-'}</span>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell dir="ltr" className="text-right">
                      {driver.userId?.phone || driver.phone || '-'}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        {getVehicleIcon(driver.vehicleType)}
                        <span>{getVehicleLabel(driver.vehicleType)}</span>
                      </div>
                    </TableCell>
                    <TableCell className="font-mono">
                      {driver.vehiclePlate || '-'}
                    </TableCell>
                    <TableCell className="text-muted-foreground text-sm">
                      {format(new Date(driver.createdAt), 'dd MMM yyyy', { locale: ar })}
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-2">
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => viewDriverDetails(driver)}
                          title="عرض التفاصيل"
                        >
                          <Eye className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => setActionDialog({ open: true, type: 'approve', driver })}
                          className="text-green-600 hover:text-green-700 hover:bg-green-50"
                          title="موافقة"
                        >
                          <CheckCircle className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => setActionDialog({ open: true, type: 'reject', driver })}
                          className="text-red-600 hover:text-red-700 hover:bg-red-50"
                          title="رفض"
                        >
                          <XCircle className="h-4 w-4" />
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

      {/* Driver Details Dialog */}
      <Dialog open={detailsOpen} onOpenChange={setDetailsOpen}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>تفاصيل السائق</DialogTitle>
          </DialogHeader>
          {selectedDriver && (
            <div className="space-y-6">
              <div className="flex items-center gap-4">
                <div className="h-20 w-20 rounded-full bg-muted flex items-center justify-center">
                  {selectedDriver.avatar ? (
                    <img src={selectedDriver.avatar} alt="" className="h-20 w-20 rounded-full object-cover" />
                  ) : (
                    <User className="h-10 w-10 text-muted-foreground" />
                  )}
                </div>
                <div>
                  <h3 className="text-xl font-bold">{selectedDriver.userId?.name || selectedDriver.name}</h3>
                  <Badge variant="outline" className="mt-1">قيد المراجعة</Badge>
                </div>
              </div>

              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-3">
                  <h4 className="font-semibold text-sm text-muted-foreground">معلومات الاتصال</h4>
                  <div className="flex items-center gap-2">
                    <Phone className="h-4 w-4 text-muted-foreground" />
                    <span dir="ltr">{selectedDriver.userId?.phone || selectedDriver.phone || '-'}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Mail className="h-4 w-4 text-muted-foreground" />
                    <span>{selectedDriver.userId?.email || '-'}</span>
                  </div>
                </div>

                <div className="space-y-3">
                  <h4 className="font-semibold text-sm text-muted-foreground">معلومات المركبة</h4>
                  <div className="flex items-center gap-2">
                    {getVehicleIcon(selectedDriver.vehicleType)}
                    <span>{getVehicleLabel(selectedDriver.vehicleType)}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <FileText className="h-4 w-4 text-muted-foreground" />
                    <span className="font-mono">{selectedDriver.vehiclePlate || 'غير محدد'}</span>
                  </div>
                </div>
              </div>

              <div className="space-y-3">
                <h4 className="font-semibold text-sm text-muted-foreground">معلومات التقديم</h4>
                <div className="flex items-center gap-2">
                  <Calendar className="h-4 w-4 text-muted-foreground" />
                  <span>تاريخ التقديم: {format(new Date(selectedDriver.createdAt), 'dd MMMM yyyy - HH:mm', { locale: ar })}</span>
                </div>
              </div>

              <div className="flex gap-2 pt-4 border-t">
                <Button
                  className="flex-1"
                  onClick={() => {
                    setDetailsOpen(false);
                    setActionDialog({ open: true, type: 'approve', driver: selectedDriver });
                  }}
                >
                  <CheckCircle className="h-4 w-4 ml-2" />
                  موافقة
                </Button>
                <Button
                  variant="destructive"
                  className="flex-1"
                  onClick={() => {
                    setDetailsOpen(false);
                    setActionDialog({ open: true, type: 'reject', driver: selectedDriver });
                  }}
                >
                  <XCircle className="h-4 w-4 ml-2" />
                  رفض
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>

      {/* Action Dialog */}
      <Dialog open={actionDialog.open} onOpenChange={(open) => !open && setActionDialog({ open: false, type: null, driver: null })}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {actionDialog.type === 'approve' ? 'تأكيد الموافقة' : 'تأكيد الرفض'}
            </DialogTitle>
            <DialogDescription>
              {actionDialog.type === 'approve'
                ? `هل تريد الموافقة على السائق "${actionDialog.driver?.userId?.name || actionDialog.driver?.name}"؟ سيتمكن السائق من استلام الطلبات فوراً.`
                : `هل تريد رفض طلب السائق "${actionDialog.driver?.userId?.name || actionDialog.driver?.name}"؟`}
            </DialogDescription>
          </DialogHeader>

          {actionDialog.type === 'reject' && (
            <div className="py-4">
              <label className="text-sm font-medium">سبب الرفض</label>
              <Input
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                placeholder="أدخل سبب رفض الطلب..."
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
              disabled={isSubmitting || (actionDialog.type === 'reject' && !reason)}
              variant={actionDialog.type === 'reject' ? 'destructive' : 'default'}
            >
              {isSubmitting ? 'جاري...' : 'تأكيد'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
