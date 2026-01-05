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
  Store,
  Clock,
  FileText,
  Phone,
  Mail,
  User,
  Calendar,
  MapPin,
  ExternalLink,
} from 'lucide-react';
import { restaurantsApi, Restaurant, getErrorMessage } from '@/services/api';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';

export default function PendingRestaurantsPage() {
  const [restaurants, setRestaurants] = useState<Restaurant[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalPending, setTotalPending] = useState(0);
  const [selectedRestaurant, setSelectedRestaurant] = useState<Restaurant | null>(null);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [actionDialog, setActionDialog] = useState<{
    open: boolean;
    type: 'approve' | 'reject' | null;
    restaurant: Restaurant | null;
  }>({ open: false, type: null, restaurant: null });
  const [reason, setReason] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchPendingRestaurants = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const res = await restaurantsApi.getRestaurants({
        page: currentPage,
        limit: 20,
        search: search || undefined,
        status: 'pending',
      });

      if (res.success && res.data) {
        setRestaurants(res.data.data || []);
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
    fetchPendingRestaurants();
  }, [currentPage]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setCurrentPage(1);
    fetchPendingRestaurants();
  };

  const handleAction = async () => {
    if (!actionDialog.restaurant || !actionDialog.type) return;

    setIsSubmitting(true);
    try {
      const id = actionDialog.restaurant._id;
      if (actionDialog.type === 'approve') {
        await restaurantsApi.approveRestaurant(id);
      } else {
        await restaurantsApi.rejectRestaurant(id, reason);
      }
      setActionDialog({ open: false, type: null, restaurant: null });
      setReason('');
      fetchPendingRestaurants();
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  const viewRestaurantDetails = (restaurant: Restaurant) => {
    setSelectedRestaurant(restaurant);
    setDetailsOpen(true);
  };

  if (isLoading && restaurants.length === 0) {
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
          <h1 className="text-2xl font-bold">طلبات انضمام المطاعم</h1>
          <p className="text-muted-foreground">مراجعة والموافقة على طلبات المطاعم الجديدة</p>
        </div>
        <Button onClick={fetchPendingRestaurants} variant="outline" size="icon">
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
            <div className="text-2xl font-bold text-blue-600">{restaurants.length}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              الصفحة الحالية
            </CardTitle>
            <Store className="h-4 w-4 text-purple-600" />
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
              placeholder="البحث عن مطعم بالاسم أو الهاتف..."
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
                <TableHead>المطعم</TableHead>
                <TableHead>المالك</TableHead>
                <TableHead>الهاتف</TableHead>
                <TableHead>العنوان</TableHead>
                <TableHead>تاريخ التقديم</TableHead>
                <TableHead>الإجراءات</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {restaurants.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-8 text-muted-foreground">
                    <div className="flex flex-col items-center gap-2">
                      <CheckCircle className="h-12 w-12 text-green-500" />
                      <p>لا توجد طلبات معلقة حالياً</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : (
                restaurants.map((restaurant) => (
                  <TableRow key={restaurant._id}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-lg bg-muted flex items-center justify-center overflow-hidden">
                          {restaurant.logo ? (
                            <img src={restaurant.logo} alt="" className="h-10 w-10 object-cover" />
                          ) : (
                            <Store className="h-5 w-5 text-muted-foreground" />
                          )}
                        </div>
                        <div>
                          <span className="font-medium block">{restaurant.name}</span>
                          {restaurant.description && (
                            <span className="text-sm text-muted-foreground line-clamp-1">
                              {restaurant.description}
                            </span>
                          )}
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div>
                        <span className="block">{restaurant.ownerId?.name || '-'}</span>
                        <span className="text-sm text-muted-foreground">
                          {restaurant.ownerId?.email || '-'}
                        </span>
                      </div>
                    </TableCell>
                    <TableCell dir="ltr" className="text-right">
                      {restaurant.phone}
                    </TableCell>
                    <TableCell>
                      <span className="text-sm">{restaurant.address?.area || '-'}</span>
                    </TableCell>
                    <TableCell className="text-muted-foreground text-sm">
                      {format(new Date(restaurant.createdAt), 'dd MMM yyyy', { locale: ar })}
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-2">
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => viewRestaurantDetails(restaurant)}
                          title="عرض التفاصيل"
                        >
                          <Eye className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => setActionDialog({ open: true, type: 'approve', restaurant })}
                          className="text-green-600 hover:text-green-700 hover:bg-green-50"
                          title="موافقة"
                        >
                          <CheckCircle className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => setActionDialog({ open: true, type: 'reject', restaurant })}
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

      {/* Restaurant Details Dialog */}
      <Dialog open={detailsOpen} onOpenChange={setDetailsOpen}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>تفاصيل المطعم</DialogTitle>
          </DialogHeader>
          {selectedRestaurant && (
            <div className="space-y-6">
              <div className="flex items-start gap-4">
                <div className="h-24 w-24 rounded-lg bg-muted flex items-center justify-center overflow-hidden">
                  {selectedRestaurant.logo ? (
                    <img src={selectedRestaurant.logo} alt="" className="h-24 w-24 object-cover" />
                  ) : (
                    <Store className="h-12 w-12 text-muted-foreground" />
                  )}
                </div>
                <div className="flex-1">
                  <h3 className="text-xl font-bold">{selectedRestaurant.name}</h3>
                  <Badge variant="outline" className="mt-1">قيد المراجعة</Badge>
                  {selectedRestaurant.description && (
                    <p className="text-sm text-muted-foreground mt-2">
                      {selectedRestaurant.description}
                    </p>
                  )}
                </div>
              </div>

              {selectedRestaurant.coverImage && (
                <div className="rounded-lg overflow-hidden h-40">
                  <img
                    src={selectedRestaurant.coverImage}
                    alt="صورة الغلاف"
                    className="w-full h-full object-cover"
                  />
                </div>
              )}

              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-3">
                  <h4 className="font-semibold text-sm text-muted-foreground">معلومات المالك</h4>
                  <div className="flex items-center gap-2">
                    <User className="h-4 w-4 text-muted-foreground" />
                    <span>{selectedRestaurant.ownerId?.name || '-'}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Mail className="h-4 w-4 text-muted-foreground" />
                    <span>{selectedRestaurant.ownerId?.email || '-'}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Phone className="h-4 w-4 text-muted-foreground" />
                    <span dir="ltr">{selectedRestaurant.ownerId?.phone || '-'}</span>
                  </div>
                </div>

                <div className="space-y-3">
                  <h4 className="font-semibold text-sm text-muted-foreground">معلومات المطعم</h4>
                  <div className="flex items-center gap-2">
                    <Phone className="h-4 w-4 text-muted-foreground" />
                    <span dir="ltr">{selectedRestaurant.phone}</span>
                  </div>
                  {selectedRestaurant.email && (
                    <div className="flex items-center gap-2">
                      <Mail className="h-4 w-4 text-muted-foreground" />
                      <span>{selectedRestaurant.email}</span>
                    </div>
                  )}
                </div>
              </div>

              <div className="space-y-3">
                <h4 className="font-semibold text-sm text-muted-foreground">العنوان</h4>
                <div className="flex items-start gap-2">
                  <MapPin className="h-4 w-4 text-muted-foreground mt-0.5" />
                  <div>
                    <span className="block">{selectedRestaurant.address?.street || ''}</span>
                    <span className="text-sm text-muted-foreground">
                      {selectedRestaurant.address?.area}, {selectedRestaurant.address?.city}
                    </span>
                  </div>
                </div>
                {selectedRestaurant.address?.coordinates && (
                  <Button variant="outline" size="sm" asChild>
                    <a
                      href={`https://www.google.com/maps?q=${selectedRestaurant.address.coordinates.lat},${selectedRestaurant.address.coordinates.lng}`}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      <ExternalLink className="h-4 w-4 ml-2" />
                      عرض على الخريطة
                    </a>
                  </Button>
                )}
              </div>

              <div className="space-y-3">
                <h4 className="font-semibold text-sm text-muted-foreground">معلومات التقديم</h4>
                <div className="flex items-center gap-2">
                  <Calendar className="h-4 w-4 text-muted-foreground" />
                  <span>تاريخ التقديم: {format(new Date(selectedRestaurant.createdAt), 'dd MMMM yyyy - HH:mm', { locale: ar })}</span>
                </div>
              </div>

              <div className="flex gap-2 pt-4 border-t">
                <Button
                  className="flex-1"
                  onClick={() => {
                    setDetailsOpen(false);
                    setActionDialog({ open: true, type: 'approve', restaurant: selectedRestaurant });
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
                    setActionDialog({ open: true, type: 'reject', restaurant: selectedRestaurant });
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
      <Dialog open={actionDialog.open} onOpenChange={(open) => !open && setActionDialog({ open: false, type: null, restaurant: null })}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {actionDialog.type === 'approve' ? 'تأكيد الموافقة' : 'تأكيد الرفض'}
            </DialogTitle>
            <DialogDescription>
              {actionDialog.type === 'approve'
                ? `هل تريد الموافقة على مطعم "${actionDialog.restaurant?.name}"؟ سيتمكن المطعم من استقبال الطلبات فوراً.`
                : `هل تريد رفض طلب مطعم "${actionDialog.restaurant?.name}"؟`}
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
              onClick={() => setActionDialog({ open: false, type: null, restaurant: null })}
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
