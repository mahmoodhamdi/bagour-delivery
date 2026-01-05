'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Skeleton } from '@/components/ui/skeleton';
import { Separator } from '@/components/ui/separator';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Star,
  Eye,
  EyeOff,
  Trash2,
  AlertCircle,
  CheckCircle,
  RefreshCw,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';
import { toast } from 'sonner';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';

// API types
interface Review {
  _id: string;
  orderId: string;
  customer: {
    name: string;
    avatar?: string;
  };
  restaurant: {
    _id: string;
    name: string;
    logo?: string;
  };
  driver?: {
    _id: string;
    name: string;
  };
  restaurantRating: number;
  foodRating: number;
  driverRating?: number;
  comment?: string;
  images: string[];
  restaurantReply?: string;
  repliedAt?: string;
  isHidden: boolean;
  isReported: boolean;
  reportReason?: string;
  reportedAt?: string;
  reportedBy?: string;
  reportResolved: boolean;
  resolvedAt?: string;
  resolvedBy?: string;
  createdAt: string;
}

interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
}

// API functions
async function getReviews(params: {
  page?: number;
  limit?: number;
  isReported?: boolean;
  isHidden?: boolean;
  rating?: number;
}): Promise<ApiResponse<{ reviews: Review[]; total: number; pages: number }>> {
  const queryParams = new URLSearchParams();
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== '') {
      queryParams.append(key, String(value));
    }
  });

  const response = await fetch(`/api/admin/reviews?${queryParams}`, {
    credentials: 'include',
  });
  return response.json();
}

async function toggleVisibility(id: string, isHidden: boolean): Promise<ApiResponse<Review>> {
  const response = await fetch(`/api/admin/reviews/${id}/visibility`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify({ isHidden }),
  });
  return response.json();
}

async function resolveReport(id: string, action: 'dismiss' | 'hide'): Promise<ApiResponse<Review>> {
  const response = await fetch(`/api/admin/reviews/${id}/resolve`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify({ action }),
  });
  return response.json();
}

async function deleteReview(id: string): Promise<ApiResponse<void>> {
  const response = await fetch(`/api/admin/reviews/${id}`, {
    method: 'DELETE',
    credentials: 'include',
  });
  return response.json();
}

export default function ReviewsPage() {
  const [reviews, setReviews] = useState<Review[]>([]);
  const [total, setTotal] = useState(0);
  const [pages, setPages] = useState(0);
  const [page, setPage] = useState(1);
  const [limit] = useState(20);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Filters
  const [reportedFilter, setReportedFilter] = useState<string>('all');
  const [visibilityFilter, setVisibilityFilter] = useState<string>('all');
  const [ratingFilter, setRatingFilter] = useState<string>('all');

  // Dialog states
  const [deleteDialog, setDeleteDialog] = useState<{ open: boolean; review: Review | null }>({
    open: false,
    review: null,
  });
  const [resolveDialog, setResolveDialog] = useState<{ open: boolean; review: Review | null }>({
    open: false,
    review: null,
  });

  const fetchReviews = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const params: any = { page, limit };

      if (reportedFilter === 'reported') params.isReported = true;
      else if (reportedFilter === 'not-reported') params.isReported = false;

      if (visibilityFilter === 'visible') params.isHidden = false;
      else if (visibilityFilter === 'hidden') params.isHidden = true;

      if (ratingFilter !== 'all') params.rating = parseInt(ratingFilter);

      const response = await getReviews(params);

      if (response.success && response.data) {
        setReviews(response.data.reviews);
        setTotal(response.data.total);
        setPages(response.data.pages);
      } else {
        setError(response.message || 'فشل جلب التقييمات');
      }
    } catch (err) {
      setError('حدث خطأ أثناء جلب التقييمات');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchReviews();
  }, [page, reportedFilter, visibilityFilter, ratingFilter]);

  const handleToggleVisibility = async (review: Review) => {
    try {
      const response = await toggleVisibility(review._id, !review.isHidden);
      if (response.success) {
        toast.success(review.isHidden ? 'تم إظهار التقييم' : 'تم إخفاء التقييم');
        fetchReviews();
      } else {
        toast.error(response.message || 'فشل تحديث التقييم');
      }
    } catch (err) {
      toast.error('حدث خطأ أثناء تحديث التقييم');
    }
  };

  const handleResolveReport = async (action: 'dismiss' | 'hide') => {
    if (!resolveDialog.review) return;

    try {
      const response = await resolveReport(resolveDialog.review._id, action);
      if (response.success) {
        toast.success(action === 'dismiss' ? 'تم رفض البلاغ' : 'تم قبول البلاغ وإخفاء التقييم');
        setResolveDialog({ open: false, review: null });
        fetchReviews();
      } else {
        toast.error(response.message || 'فشل معالجة البلاغ');
      }
    } catch (err) {
      toast.error('حدث خطأ أثناء معالجة البلاغ');
    }
  };

  const handleDelete = async () => {
    if (!deleteDialog.review) return;

    try {
      const response = await deleteReview(deleteDialog.review._id);
      if (response.success) {
        toast.success('تم حذف التقييم بنجاح');
        setDeleteDialog({ open: false, review: null });
        fetchReviews();
      } else {
        toast.error(response.message || 'فشل حذف التقييم');
      }
    } catch (err) {
      toast.error('حدث خطأ أثناء حذف التقييم');
    }
  };

  const renderStars = (rating: number) => {
    return (
      <div className="flex gap-0.5">
        {[1, 2, 3, 4, 5].map((star) => (
          <Star
            key={star}
            className={`h-4 w-4 ${
              star <= rating ? 'fill-yellow-400 text-yellow-400' : 'text-gray-300'
            }`}
          />
        ))}
      </div>
    );
  };

  if (isLoading && reviews.length === 0) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-10 w-48" />
        <div className="space-y-4">
          {[1, 2, 3].map((i) => (
            <Skeleton key={i} className="h-48" />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">إدارة التقييمات</h1>
          <p className="text-muted-foreground">
            عرض ومراجعة تقييمات المطاعم والسائقين ({total} تقييم)
          </p>
        </div>
        <Button onClick={fetchReviews} variant="outline">
          <RefreshCw className="ml-2 h-4 w-4" />
          تحديث
        </Button>
      </div>

      {/* Filters */}
      <Card>
        <CardContent className="pt-6">
          <div className="grid gap-4 md:grid-cols-3">
            <div className="space-y-2">
              <label className="text-sm font-medium">حالة البلاغ</label>
              <Select value={reportedFilter} onValueChange={setReportedFilter}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">الكل</SelectItem>
                  <SelectItem value="reported">تم الإبلاغ عنه</SelectItem>
                  <SelectItem value="not-reported">لم يتم الإبلاغ</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">الرؤية</label>
              <Select value={visibilityFilter} onValueChange={setVisibilityFilter}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">الكل</SelectItem>
                  <SelectItem value="visible">ظاهر</SelectItem>
                  <SelectItem value="hidden">مخفي</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">التقييم</label>
              <Select value={ratingFilter} onValueChange={setRatingFilter}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">الكل</SelectItem>
                  <SelectItem value="5">5 نجوم</SelectItem>
                  <SelectItem value="4">4 نجوم</SelectItem>
                  <SelectItem value="3">3 نجوم</SelectItem>
                  <SelectItem value="2">2 نجوم</SelectItem>
                  <SelectItem value="1">1 نجمة</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Reviews List */}
      {error ? (
        <Card>
          <CardContent className="pt-6 text-center text-red-600">{error}</CardContent>
        </Card>
      ) : reviews.length === 0 ? (
        <Card>
          <CardContent className="pt-6 text-center text-muted-foreground">
            لا توجد تقييمات
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          {reviews.map((review) => (
            <Card key={review._id} className={review.isHidden ? 'opacity-60' : ''}>
              <CardHeader>
                <div className="flex items-start justify-between">
                  <div className="flex items-start gap-4">
                    <Avatar>
                      <AvatarFallback>{review.customer.name.charAt(0)}</AvatarFallback>
                    </Avatar>
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <p className="font-semibold">{review.customer.name}</p>
                        {review.isHidden && (
                          <Badge variant="secondary">
                            <EyeOff className="ml-1 h-3 w-3" />
                            مخفي
                          </Badge>
                        )}
                        {review.isReported && !review.reportResolved && (
                          <Badge variant="destructive">
                            <AlertCircle className="ml-1 h-3 w-3" />
                            تم الإبلاغ
                          </Badge>
                        )}
                      </div>
                      <p className="text-sm text-muted-foreground">
                        {format(new Date(review.createdAt), 'd MMMM yyyy - hh:mm a', { locale: ar })}
                      </p>
                    </div>
                  </div>

                  <div className="flex gap-2">
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => handleToggleVisibility(review)}
                    >
                      {review.isHidden ? <Eye className="h-4 w-4" /> : <EyeOff className="h-4 w-4" />}
                    </Button>
                    {review.isReported && !review.reportResolved && (
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => setResolveDialog({ open: true, review })}
                      >
                        <CheckCircle className="h-4 w-4" />
                      </Button>
                    )}
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => setDeleteDialog({ open: true, review })}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                {/* Restaurant Info */}
                <div>
                  <p className="text-sm font-medium">المطعم: {review.restaurant.name}</p>
                  <div className="mt-1 flex items-center gap-4">
                    <div className="flex items-center gap-2">
                      <span className="text-sm text-muted-foreground">تقييم المطعم:</span>
                      {renderStars(review.restaurantRating)}
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-sm text-muted-foreground">تقييم الطعام:</span>
                      {renderStars(review.foodRating)}
                    </div>
                    {review.driverRating && (
                      <div className="flex items-center gap-2">
                        <span className="text-sm text-muted-foreground">تقييم السائق:</span>
                        {renderStars(review.driverRating)}
                      </div>
                    )}
                  </div>
                </div>

                {/* Comment */}
                {review.comment && (
                  <>
                    <Separator />
                    <div>
                      <p className="text-sm font-medium">التعليق:</p>
                      <p className="mt-1 text-sm">{review.comment}</p>
                    </div>
                  </>
                )}

                {/* Images */}
                {review.images && review.images.length > 0 && (
                  <>
                    <Separator />
                    <div>
                      <p className="text-sm font-medium">الصور ({review.images.length}):</p>
                      <div className="mt-2 flex gap-2">
                        {review.images.map((image, idx) => (
                          <img
                            key={idx}
                            src={image}
                            alt={`صورة ${idx + 1}`}
                            className="h-20 w-20 rounded object-cover"
                          />
                        ))}
                      </div>
                    </div>
                  </>
                )}

                {/* Restaurant Reply */}
                {review.restaurantReply && (
                  <>
                    <Separator />
                    <div className="rounded-lg bg-muted p-3">
                      <p className="text-sm font-medium">رد المطعم:</p>
                      <p className="mt-1 text-sm">{review.restaurantReply}</p>
                      {review.repliedAt && (
                        <p className="mt-1 text-xs text-muted-foreground">
                          {format(new Date(review.repliedAt), 'd MMMM yyyy', { locale: ar })}
                        </p>
                      )}
                    </div>
                  </>
                )}

                {/* Report Info */}
                {review.isReported && (
                  <>
                    <Separator />
                    <div className="rounded-lg bg-red-50 p-3 dark:bg-red-950">
                      <div className="flex items-start gap-2">
                        <AlertCircle className="h-5 w-5 text-red-600" />
                        <div className="flex-1">
                          <p className="text-sm font-medium text-red-900 dark:text-red-100">
                            تم الإبلاغ عن هذا التقييم
                          </p>
                          {review.reportReason && (
                            <p className="mt-1 text-sm text-red-800 dark:text-red-200">
                              السبب: {review.reportReason}
                            </p>
                          )}
                          {review.reportedAt && (
                            <p className="mt-1 text-xs text-red-700 dark:text-red-300">
                              {format(new Date(review.reportedAt), 'd MMMM yyyy - hh:mm a', {
                                locale: ar,
                              })}
                            </p>
                          )}
                          {review.reportResolved && (
                            <Badge variant="outline" className="mt-2">
                              <CheckCircle className="ml-1 h-3 w-3" />
                              تمت المعالجة
                            </Badge>
                          )}
                        </div>
                      </div>
                    </div>
                  </>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {/* Pagination */}
      {pages > 1 && (
        <div className="flex items-center justify-between">
          <p className="text-sm text-muted-foreground">
            صفحة {page} من {pages}
          </p>
          <div className="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(p => Math.max(1, p - 1))}
              disabled={page === 1}
            >
              <ChevronRight className="h-4 w-4" />
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(p => Math.min(pages, p + 1))}
              disabled={page === pages}
            >
              <ChevronLeft className="h-4 w-4" />
            </Button>
          </div>
        </div>
      )}

      {/* Delete Dialog */}
      <Dialog open={deleteDialog.open} onOpenChange={(open) => setDeleteDialog({ ...deleteDialog, open })}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>حذف التقييم</DialogTitle>
            <DialogDescription>
              هل أنت متأكد من حذف هذا التقييم؟ لا يمكن التراجع عن هذا الإجراء.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setDeleteDialog({ open: false, review: null })}
            >
              إلغاء
            </Button>
            <Button variant="destructive" onClick={handleDelete}>
              حذف
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Resolve Report Dialog */}
      <Dialog open={resolveDialog.open} onOpenChange={(open) => setResolveDialog({ ...resolveDialog, open })}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>معالجة البلاغ</DialogTitle>
            <DialogDescription>
              اختر الإجراء المناسب للبلاغ
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <Button
              variant="outline"
              className="w-full"
              onClick={() => handleResolveReport('dismiss')}
            >
              رفض البلاغ (إبقاء التقييم ظاهراً)
            </Button>
            <Button
              variant="destructive"
              className="w-full"
              onClick={() => handleResolveReport('hide')}
            >
              قبول البلاغ (إخفاء التقييم)
            </Button>
          </div>
          <DialogFooter>
            <Button
              variant="ghost"
              onClick={() => setResolveDialog({ open: false, review: null })}
            >
              إلغاء
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
