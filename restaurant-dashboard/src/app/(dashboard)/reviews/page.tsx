'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Skeleton } from '@/components/ui/skeleton';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import {
  Star,
  MessageSquare,
  RefreshCw,
  ChevronLeft,
  ChevronRight,
  Image as ImageIcon,
  Pencil,
  Trash2,
} from 'lucide-react';
import { reviewsApi, type Review, type ReviewStats, getErrorMessage } from '@/lib/api';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';
import { toast } from 'sonner';

export default function ReviewsPage() {
  const [reviews, setReviews] = useState<Review[]>([]);
  const [stats, setStats] = useState<ReviewStats | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [filterRating, setFilterRating] = useState<string>('all');
  const [filterReply, setFilterReply] = useState<string>('all');

  // Reply dialog state
  const [replyDialogOpen, setReplyDialogOpen] = useState(false);
  const [selectedReview, setSelectedReview] = useState<Review | null>(null);
  const [replyText, setReplyText] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Image viewer dialog
  const [imageViewerOpen, setImageViewerOpen] = useState(false);
  const [selectedImages, setSelectedImages] = useState<string[]>([]);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  const fetchData = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const [reviewsRes, statsRes] = await Promise.all([
        reviewsApi.getReviews({
          page,
          limit: 10,
          rating: filterRating === 'all' ? undefined : Number(filterRating),
          hasReply: filterReply === 'all' ? undefined : filterReply === 'yes',
        }),
        reviewsApi.getStats(),
      ]);

      if (reviewsRes.success && reviewsRes.data) {
        setReviews(reviewsRes.data.reviews);
        setTotalPages(reviewsRes.data.pagination.pages);
      }

      if (statsRes.success && statsRes.data) {
        setStats(statsRes.data);
      }
    } catch (err) {
      setError(getErrorMessage(err));
      toast.error(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [page, filterRating, filterReply]);

  const handleReply = (review: Review) => {
    setSelectedReview(review);
    setReplyText(review.restaurantReply || '');
    setReplyDialogOpen(true);
  };

  const handleSubmitReply = async () => {
    if (!selectedReview || !replyText.trim()) return;

    setIsSubmitting(true);
    try {
      const response = selectedReview.restaurantReply
        ? await reviewsApi.updateReply(selectedReview._id, replyText)
        : await reviewsApi.replyToReview(selectedReview._id, replyText);

      if (response.success) {
        toast.success(selectedReview.restaurantReply ? 'تم تحديث الرد بنجاح' : 'تم إضافة الرد بنجاح');
        setReplyDialogOpen(false);
        setReplyText('');
        setSelectedReview(null);
        fetchData();
      }
    } catch (err) {
      toast.error(getErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDeleteReply = async (reviewId: string) => {
    try {
      const response = await reviewsApi.deleteReply(reviewId);
      if (response.success) {
        toast.success('تم حذف الرد بنجاح');
        fetchData();
      }
    } catch (err) {
      toast.error(getErrorMessage(err));
    }
  };

  const renderStars = (rating: number) => {
    return (
      <div className="flex gap-0.5">
        {[1, 2, 3, 4, 5].map((star) => (
          <Star
            key={star}
            className={`h-4 w-4 ${
              star <= rating
                ? 'fill-yellow-400 text-yellow-400'
                : 'fill-gray-200 text-gray-200'
            }`}
          />
        ))}
      </div>
    );
  };

  const getRatingColor = (rating: number) => {
    if (rating >= 4) return 'text-green-600';
    if (rating >= 3) return 'text-yellow-600';
    return 'text-red-600';
  };

  if (isLoading && !stats) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-10 w-48" />
        <div className="grid gap-4 md:grid-cols-4">
          {[1, 2, 3, 4].map((i) => (
            <Skeleton key={i} className="h-32" />
          ))}
        </div>
        <Skeleton className="h-96" />
      </div>
    );
  }

  if (error && !stats) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-red-600">حدث خطأ</CardTitle>
          <CardDescription>{error}</CardDescription>
        </CardHeader>
        <CardContent>
          <Button onClick={fetchData} variant="outline">
            <RefreshCw className="ml-2 h-4 w-4" />
            إعادة المحاولة
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">التقييمات والمراجعات</h1>
          <p className="text-muted-foreground">إدارة تقييمات العملاء والرد عليها</p>
        </div>
        <Button onClick={fetchData} variant="outline" size="icon">
          <RefreshCw className="h-4 w-4" />
        </Button>
      </div>

      {/* Stats Cards */}
      {stats && (
        <div className="grid gap-4 md:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">إجمالي التقييمات</CardTitle>
              <Star className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.totalReviews}</div>
              <p className="text-xs text-muted-foreground">
                تم الرد على {stats.repliedCount} ({stats.replyRate.toFixed(1)}%)
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">تقييم المطعم</CardTitle>
              <Star className="h-4 w-4 text-yellow-400 fill-yellow-400" />
            </CardHeader>
            <CardContent>
              <div className={`text-2xl font-bold ${getRatingColor(stats.averageRestaurantRating)}`}>
                {stats.averageRestaurantRating.toFixed(1)}
              </div>
              <div className="flex items-center gap-1">
                {renderStars(Math.round(stats.averageRestaurantRating))}
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">تقييم الطعام</CardTitle>
              <Star className="h-4 w-4 text-yellow-400 fill-yellow-400" />
            </CardHeader>
            <CardContent>
              <div className={`text-2xl font-bold ${getRatingColor(stats.averageFoodRating)}`}>
                {stats.averageFoodRating.toFixed(1)}
              </div>
              <div className="flex items-center gap-1">
                {renderStars(Math.round(stats.averageFoodRating))}
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">تقييم التوصيل</CardTitle>
              <Star className="h-4 w-4 text-yellow-400 fill-yellow-400" />
            </CardHeader>
            <CardContent>
              <div className={`text-2xl font-bold ${getRatingColor(stats.averageDriverRating)}`}>
                {stats.averageDriverRating.toFixed(1)}
              </div>
              <div className="flex items-center gap-1">
                {renderStars(Math.round(stats.averageDriverRating))}
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Filters */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle>قائمة التقييمات</CardTitle>
            <div className="flex gap-2">
              <Select value={filterRating} onValueChange={setFilterRating}>
                <SelectTrigger className="w-32">
                  <SelectValue placeholder="التقييم" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">جميع التقييمات</SelectItem>
                  <SelectItem value="5">5 نجوم</SelectItem>
                  <SelectItem value="4">4 نجوم</SelectItem>
                  <SelectItem value="3">3 نجوم</SelectItem>
                  <SelectItem value="2">نجمتان</SelectItem>
                  <SelectItem value="1">نجمة واحدة</SelectItem>
                </SelectContent>
              </Select>
              <Select value={filterReply} onValueChange={setFilterReply}>
                <SelectTrigger className="w-32">
                  <SelectValue placeholder="الردود" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">الكل</SelectItem>
                  <SelectItem value="yes">تم الرد</SelectItem>
                  <SelectItem value="no">لم يتم الرد</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="space-y-4">
              {[1, 2, 3].map((i) => (
                <Skeleton key={i} className="h-48" />
              ))}
            </div>
          ) : reviews.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <Star className="mb-4 h-12 w-12 text-muted-foreground" />
              <h3 className="text-lg font-semibold">لا توجد تقييمات</h3>
              <p className="text-muted-foreground">لم يقم أي عميل بتقييم مطعمك بعد</p>
            </div>
          ) : (
            <div className="space-y-4">
              {reviews.map((review) => (
                <Card key={review._id} className="border-2">
                  <CardContent className="pt-6">
                    <div className="space-y-4">
                      {/* Customer Info & Ratings */}
                      <div className="flex items-start justify-between">
                        <div className="flex items-start gap-4">
                          <Avatar className="h-12 w-12">
                            <AvatarImage src={review.customer?.avatar} />
                            <AvatarFallback>
                              {review.customer?.name?.charAt(0) || 'ع'}
                            </AvatarFallback>
                          </Avatar>
                          <div className="space-y-1">
                            <p className="font-semibold">{review.customer?.name || 'عميل'}</p>
                            <p className="text-sm text-muted-foreground">
                              {format(new Date(review.createdAt), 'd MMMM yyyy', { locale: ar })}
                            </p>
                            <div className="flex gap-4 text-sm">
                              <div className="flex items-center gap-1">
                                <span className="text-muted-foreground">المطعم:</span>
                                {renderStars(review.restaurantRating)}
                              </div>
                              <div className="flex items-center gap-1">
                                <span className="text-muted-foreground">الطعام:</span>
                                {renderStars(review.foodRating)}
                              </div>
                              {review.driverRating && (
                                <div className="flex items-center gap-1">
                                  <span className="text-muted-foreground">التوصيل:</span>
                                  {renderStars(review.driverRating)}
                                </div>
                              )}
                            </div>
                          </div>
                        </div>
                        <div className="flex gap-2">
                          {review.isReported && (
                            <Badge variant="destructive">مبلّغ عنه</Badge>
                          )}
                          {!review.isVisible && (
                            <Badge variant="secondary">مخفي</Badge>
                          )}
                        </div>
                      </div>

                      {/* Comment */}
                      {review.comment && (
                        <div className="rounded-lg bg-muted p-4">
                          <p className="text-sm">{review.comment}</p>
                        </div>
                      )}

                      {/* Images */}
                      {review.images && review.images.length > 0 && (
                        <div className="flex gap-2">
                          {review.images.map((image, index) => (
                            <button
                              key={index}
                              onClick={() => {
                                setSelectedImages(review.images);
                                setCurrentImageIndex(index);
                                setImageViewerOpen(true);
                              }}
                              className="relative h-20 w-20 overflow-hidden rounded-lg border-2 hover:border-primary"
                            >
                              <img
                                src={image}
                                alt={`Review image ${index + 1}`}
                                className="h-full w-full object-cover"
                              />
                            </button>
                          ))}
                        </div>
                      )}

                      {/* Restaurant Reply */}
                      {review.restaurantReply ? (
                        <div className="rounded-lg border-2 border-primary/20 bg-primary/5 p-4">
                          <div className="mb-2 flex items-center justify-between">
                            <div className="flex items-center gap-2">
                              <MessageSquare className="h-4 w-4 text-primary" />
                              <p className="text-sm font-semibold text-primary">ردك على التقييم</p>
                            </div>
                            <div className="flex gap-2">
                              <Button
                                size="sm"
                                variant="ghost"
                                onClick={() => handleReply(review)}
                              >
                                <Pencil className="h-4 w-4" />
                              </Button>
                              <Button
                                size="sm"
                                variant="ghost"
                                onClick={() => handleDeleteReply(review._id)}
                              >
                                <Trash2 className="h-4 w-4" />
                              </Button>
                            </div>
                          </div>
                          <p className="text-sm">{review.restaurantReply}</p>
                          <p className="mt-2 text-xs text-muted-foreground">
                            {format(new Date(review.repliedAt!), 'd MMMM yyyy - hh:mm a', { locale: ar })}
                          </p>
                        </div>
                      ) : (
                        <Button
                          variant="outline"
                          onClick={() => handleReply(review)}
                          className="w-full"
                        >
                          <MessageSquare className="ml-2 h-4 w-4" />
                          الرد على التقييم
                        </Button>
                      )}
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="mt-6 flex items-center justify-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={page === 1}
              >
                <ChevronRight className="h-4 w-4" />
                السابق
              </Button>
              <span className="text-sm text-muted-foreground">
                صفحة {page} من {totalPages}
              </span>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
              >
                التالي
                <ChevronLeft className="ml-2 h-4 w-4" />
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Reply Dialog */}
      <Dialog open={replyDialogOpen} onOpenChange={setReplyDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {selectedReview?.restaurantReply ? 'تعديل الرد' : 'الرد على التقييم'}
            </DialogTitle>
            <DialogDescription>
              اكتب ردك على تقييم العميل (حد أقصى 300 حرف)
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <Textarea
              placeholder="اكتب ردك هنا..."
              value={replyText}
              onChange={(e) => setReplyText(e.target.value)}
              maxLength={300}
              rows={5}
            />
            <p className="text-sm text-muted-foreground">
              {replyText.length}/300 حرف
            </p>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setReplyDialogOpen(false);
                setReplyText('');
                setSelectedReview(null);
              }}
            >
              إلغاء
            </Button>
            <Button
              onClick={handleSubmitReply}
              disabled={!replyText.trim() || isSubmitting}
            >
              {isSubmitting ? 'جاري الحفظ...' : 'حفظ الرد'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Image Viewer Dialog */}
      <Dialog open={imageViewerOpen} onOpenChange={setImageViewerOpen}>
        <DialogContent className="max-w-3xl">
          <DialogHeader>
            <DialogTitle>صور التقييم</DialogTitle>
          </DialogHeader>
          {selectedImages.length > 0 && (
            <div className="space-y-4">
              <div className="relative aspect-video overflow-hidden rounded-lg">
                <img
                  src={selectedImages[currentImageIndex]}
                  alt={`Review image ${currentImageIndex + 1}`}
                  className="h-full w-full object-contain"
                />
              </div>
              {selectedImages.length > 1 && (
                <div className="flex items-center justify-center gap-4">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() =>
                      setCurrentImageIndex((i) =>
                        i === 0 ? selectedImages.length - 1 : i - 1
                      )
                    }
                  >
                    <ChevronRight className="h-4 w-4" />
                  </Button>
                  <span className="text-sm text-muted-foreground">
                    {currentImageIndex + 1} / {selectedImages.length}
                  </span>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() =>
                      setCurrentImageIndex((i) =>
                        i === selectedImages.length - 1 ? 0 : i + 1
                      )
                    }
                  >
                    <ChevronLeft className="h-4 w-4" />
                  </Button>
                </div>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
