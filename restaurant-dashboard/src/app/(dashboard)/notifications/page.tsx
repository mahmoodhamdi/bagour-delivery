'use client';

import { useState, useEffect, useCallback } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  Bell,
  BellOff,
  Check,
  CheckCheck,
  ChevronLeft,
  ChevronRight,
  Clock,
  MessageSquare,
  MoreVertical,
  Package,
  RefreshCw,
  Settings,
  ShoppingBag,
  Star,
  Trash2,
  AlertCircle,
  Info,
  DollarSign,
  UserCheck,
  Truck,
  XCircle,
} from 'lucide-react';
import { format, formatDistanceToNow } from 'date-fns';
import { ar } from 'date-fns/locale';
import { toast } from 'sonner';
import api, { getErrorMessage, ApiResponse } from '@/lib/api';
import { API_ENDPOINTS } from '@/config/constants';
import { useAuthStore } from '@/stores/auth';
import { getSocket } from '@/lib/socket';

interface Notification {
  _id: string;
  type: 'order' | 'review' | 'payment' | 'system' | 'promotion' | 'driver';
  title: string;
  titleAr: string;
  message: string;
  messageAr: string;
  data?: {
    orderId?: string;
    orderNumber?: string;
    reviewId?: string;
    payoutId?: string;
    amount?: number;
  };
  isRead: boolean;
  createdAt: string;
}

interface NotificationsResponse {
  notifications: Notification[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
  unreadCount: number;
}

type NotificationType = 'all' | 'order' | 'review' | 'payment' | 'system';

export default function NotificationsPage() {
  const { restaurant } = useAuthStore();
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [unreadCount, setUnreadCount] = useState(0);
  const [activeTab, setActiveTab] = useState<NotificationType>('all');
  const [showClearDialog, setShowClearDialog] = useState(false);
  const [isClearing, setIsClearing] = useState(false);
  const [selectedNotification, setSelectedNotification] = useState<Notification | null>(null);

  const fetchNotifications = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);

      const params: Record<string, unknown> = { page, limit: 20 };
      if (activeTab !== 'all') {
        params.type = activeTab;
      }

      const response = await api.get<ApiResponse<NotificationsResponse>>(
        API_ENDPOINTS.notifications,
        { params }
      );

      if (response.data.success && response.data.data) {
        setNotifications(response.data.data.notifications);
        setTotalPages(response.data.data.pagination.pages);
        setUnreadCount(response.data.data.unreadCount);
      }
    } catch (err) {
      setError(getErrorMessage(err));
      toast.error(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  }, [page, activeTab]);

  useEffect(() => {
    fetchNotifications();
  }, [fetchNotifications]);

  // Listen for real-time notifications
  useEffect(() => {
    const socket = getSocket();
    if (socket) {
      const handleNewNotification = (notification: Notification) => {
        setNotifications((prev) => [notification, ...prev]);
        setUnreadCount((prev) => prev + 1);
        toast.info(notification.titleAr || notification.title, {
          description: notification.messageAr || notification.message,
        });
      };

      socket.on('notification:new', handleNewNotification);
      return () => {
        socket.off('notification:new', handleNewNotification);
      };
    }
  }, []);

  const markAsRead = async (notificationId: string) => {
    try {
      await api.patch(`${API_ENDPOINTS.notifications}/${notificationId}/read`);
      setNotifications((prev) =>
        prev.map((n) =>
          n._id === notificationId ? { ...n, isRead: true } : n
        )
      );
      setUnreadCount((prev) => Math.max(0, prev - 1));
    } catch (err) {
      toast.error(getErrorMessage(err));
    }
  };

  const markAllAsRead = async () => {
    try {
      await api.patch(`${API_ENDPOINTS.notifications}/read-all`);
      setNotifications((prev) => prev.map((n) => ({ ...n, isRead: true })));
      setUnreadCount(0);
      toast.success('تم تحديد جميع الإشعارات كمقروءة');
    } catch (err) {
      toast.error(getErrorMessage(err));
    }
  };

  const deleteNotification = async (notificationId: string) => {
    try {
      await api.delete(`${API_ENDPOINTS.notifications}/${notificationId}`);
      setNotifications((prev) => prev.filter((n) => n._id !== notificationId));
      const notification = notifications.find((n) => n._id === notificationId);
      if (notification && !notification.isRead) {
        setUnreadCount((prev) => Math.max(0, prev - 1));
      }
      toast.success('تم حذف الإشعار');
    } catch (err) {
      toast.error(getErrorMessage(err));
    }
  };

  const clearAllNotifications = async () => {
    try {
      setIsClearing(true);
      await api.delete(API_ENDPOINTS.notifications);
      setNotifications([]);
      setUnreadCount(0);
      toast.success('تم حذف جميع الإشعارات');
      setShowClearDialog(false);
    } catch (err) {
      toast.error(getErrorMessage(err));
    } finally {
      setIsClearing(false);
    }
  };

  const getNotificationIcon = (type: Notification['type']) => {
    switch (type) {
      case 'order':
        return <ShoppingBag className="h-5 w-5" />;
      case 'review':
        return <Star className="h-5 w-5" />;
      case 'payment':
        return <DollarSign className="h-5 w-5" />;
      case 'driver':
        return <Truck className="h-5 w-5" />;
      case 'system':
        return <Settings className="h-5 w-5" />;
      case 'promotion':
        return <Bell className="h-5 w-5" />;
      default:
        return <Info className="h-5 w-5" />;
    }
  };

  const getNotificationColor = (type: Notification['type']) => {
    switch (type) {
      case 'order':
        return 'bg-blue-100 text-blue-600';
      case 'review':
        return 'bg-yellow-100 text-yellow-600';
      case 'payment':
        return 'bg-green-100 text-green-600';
      case 'driver':
        return 'bg-purple-100 text-purple-600';
      case 'system':
        return 'bg-gray-100 text-gray-600';
      case 'promotion':
        return 'bg-pink-100 text-pink-600';
      default:
        return 'bg-gray-100 text-gray-600';
    }
  };

  const getNotificationTypeBadge = (type: Notification['type']) => {
    const labels: Record<string, string> = {
      order: 'طلب',
      review: 'تقييم',
      payment: 'مالي',
      driver: 'سائق',
      system: 'نظام',
      promotion: 'ترويج',
    };
    return labels[type] || type;
  };

  const handleNotificationClick = (notification: Notification) => {
    if (!notification.isRead) {
      markAsRead(notification._id);
    }
    setSelectedNotification(notification);
  };

  const navigateToRelatedPage = (notification: Notification) => {
    if (notification.data?.orderId) {
      window.location.href = `/orders/${notification.data.orderId}`;
    } else if (notification.data?.reviewId) {
      window.location.href = '/reviews';
    } else if (notification.data?.payoutId) {
      window.location.href = '/earnings/payouts';
    }
  };

  if (isLoading && notifications.length === 0) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <Skeleton className="h-8 w-48" />
          <Skeleton className="h-10 w-32" />
        </div>
        <Skeleton className="h-12 w-full max-w-md" />
        <div className="space-y-4">
          {[1, 2, 3, 4, 5].map((i) => (
            <Skeleton key={i} className="h-24" />
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
          <h1 className="text-2xl font-bold">الإشعارات</h1>
          <p className="text-muted-foreground">
            {unreadCount > 0
              ? `لديك ${unreadCount} إشعار غير مقروء`
              : 'لا توجد إشعارات جديدة'}
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" onClick={fetchNotifications}>
            <RefreshCw className="h-4 w-4 ml-2" />
            تحديث
          </Button>
          {unreadCount > 0 && (
            <Button variant="outline" size="sm" onClick={markAllAsRead}>
              <CheckCheck className="h-4 w-4 ml-2" />
              تحديد الكل كمقروء
            </Button>
          )}
          {notifications.length > 0 && (
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowClearDialog(true)}
              className="text-destructive hover:text-destructive"
            >
              <Trash2 className="h-4 w-4 ml-2" />
              مسح الكل
            </Button>
          )}
        </div>
      </div>

      {/* Tabs */}
      <Tabs
        value={activeTab}
        onValueChange={(v) => {
          setActiveTab(v as NotificationType);
          setPage(1);
        }}
      >
        <TabsList className="grid w-full max-w-2xl grid-cols-5">
          <TabsTrigger value="all" className="gap-2">
            <Bell className="h-4 w-4" />
            الكل
          </TabsTrigger>
          <TabsTrigger value="order" className="gap-2">
            <ShoppingBag className="h-4 w-4" />
            الطلبات
          </TabsTrigger>
          <TabsTrigger value="review" className="gap-2">
            <Star className="h-4 w-4" />
            التقييمات
          </TabsTrigger>
          <TabsTrigger value="payment" className="gap-2">
            <DollarSign className="h-4 w-4" />
            المالية
          </TabsTrigger>
          <TabsTrigger value="system" className="gap-2">
            <Settings className="h-4 w-4" />
            النظام
          </TabsTrigger>
        </TabsList>
      </Tabs>

      {/* Error State */}
      {error && (
        <Card className="border-destructive">
          <CardContent className="flex items-center justify-center py-8">
            <div className="text-center">
              <AlertCircle className="h-12 w-12 text-destructive mx-auto mb-4" />
              <p className="text-destructive mb-4">{error}</p>
              <Button onClick={fetchNotifications} variant="outline">
                <RefreshCw className="h-4 w-4 ml-2" />
                إعادة المحاولة
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Notifications List */}
      {!error && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Bell className="h-5 w-5" />
              قائمة الإشعارات
            </CardTitle>
            <CardDescription>
              {notifications.length} إشعار
            </CardDescription>
          </CardHeader>
          <CardContent>
            {notifications.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-12 text-center">
                <BellOff className="h-12 w-12 text-muted-foreground mb-4" />
                <h3 className="text-lg font-semibold mb-2">لا توجد إشعارات</h3>
                <p className="text-muted-foreground">
                  {activeTab === 'all'
                    ? 'سيتم عرض الإشعارات الجديدة هنا'
                    : `لا توجد إشعارات من نوع "${getNotificationTypeBadge(activeTab as Notification['type'])}"`}
                </p>
              </div>
            ) : (
              <ScrollArea className="h-[600px]">
                <div className="space-y-2">
                  {notifications.map((notification) => (
                    <div
                      key={notification._id}
                      className={`flex items-start gap-4 p-4 rounded-lg border cursor-pointer transition-colors hover:bg-muted/50 ${
                        !notification.isRead ? 'bg-primary/5 border-primary/20' : ''
                      }`}
                      onClick={() => handleNotificationClick(notification)}
                    >
                      <div
                        className={`p-2 rounded-full ${getNotificationColor(notification.type)}`}
                      >
                        {getNotificationIcon(notification.type)}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-start justify-between gap-2">
                          <div className="flex-1">
                            <div className="flex items-center gap-2">
                              <h4 className="font-medium">
                                {notification.titleAr || notification.title}
                              </h4>
                              {!notification.isRead && (
                                <Badge variant="default" className="h-2 w-2 p-0 rounded-full" />
                              )}
                            </div>
                            <p className="text-sm text-muted-foreground mt-1 line-clamp-2">
                              {notification.messageAr || notification.message}
                            </p>
                            <div className="flex items-center gap-2 mt-2">
                              <Badge variant="outline" className="text-xs">
                                {getNotificationTypeBadge(notification.type)}
                              </Badge>
                              <span className="text-xs text-muted-foreground flex items-center gap-1">
                                <Clock className="h-3 w-3" />
                                {formatDistanceToNow(new Date(notification.createdAt), {
                                  addSuffix: true,
                                  locale: ar,
                                })}
                              </span>
                            </div>
                          </div>
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button
                                variant="ghost"
                                size="icon"
                                className="h-8 w-8"
                                onClick={(e) => e.stopPropagation()}
                              >
                                <MoreVertical className="h-4 w-4" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              {!notification.isRead && (
                                <DropdownMenuItem
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    markAsRead(notification._id);
                                  }}
                                >
                                  <Check className="h-4 w-4 ml-2" />
                                  تحديد كمقروء
                                </DropdownMenuItem>
                              )}
                              {notification.data?.orderId && (
                                <DropdownMenuItem
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    window.location.href = `/orders/${notification.data!.orderId}`;
                                  }}
                                >
                                  <Package className="h-4 w-4 ml-2" />
                                  عرض الطلب
                                </DropdownMenuItem>
                              )}
                              <DropdownMenuSeparator />
                              <DropdownMenuItem
                                className="text-destructive"
                                onClick={(e) => {
                                  e.stopPropagation();
                                  deleteNotification(notification._id);
                                }}
                              >
                                <Trash2 className="h-4 w-4 ml-2" />
                                حذف
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </ScrollArea>
            )}

            {/* Pagination */}
            {totalPages > 1 && (
              <div className="flex items-center justify-center gap-2 mt-6 pt-6 border-t">
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
                  <ChevronLeft className="h-4 w-4 mr-2" />
                </Button>
              </div>
            )}
          </CardContent>
        </Card>
      )}

      {/* Notification Detail Dialog */}
      <Dialog open={!!selectedNotification} onOpenChange={() => setSelectedNotification(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              {selectedNotification && (
                <div className={`p-2 rounded-full ${getNotificationColor(selectedNotification.type)}`}>
                  {getNotificationIcon(selectedNotification.type)}
                </div>
              )}
              {selectedNotification?.titleAr || selectedNotification?.title}
            </DialogTitle>
            <DialogDescription>
              {selectedNotification && (
                <span className="flex items-center gap-2 mt-2">
                  <Badge variant="outline">
                    {getNotificationTypeBadge(selectedNotification.type)}
                  </Badge>
                  <span className="text-xs">
                    {format(new Date(selectedNotification.createdAt), 'EEEE، d MMMM yyyy - hh:mm a', {
                      locale: ar,
                    })}
                  </span>
                </span>
              )}
            </DialogDescription>
          </DialogHeader>
          <div className="py-4">
            <p className="text-muted-foreground">
              {selectedNotification?.messageAr || selectedNotification?.message}
            </p>
            {selectedNotification?.data && (
              <div className="mt-4 p-4 bg-muted rounded-lg space-y-2">
                {selectedNotification.data.orderNumber && (
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">رقم الطلب:</span>
                    <span className="font-medium">#{selectedNotification.data.orderNumber}</span>
                  </div>
                )}
                {selectedNotification.data.amount && (
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">المبلغ:</span>
                    <span className="font-medium">{selectedNotification.data.amount.toFixed(2)} ج.م</span>
                  </div>
                )}
              </div>
            )}
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setSelectedNotification(null)}>
              إغلاق
            </Button>
            {selectedNotification?.data?.orderId && (
              <Button onClick={() => navigateToRelatedPage(selectedNotification)}>
                <Package className="h-4 w-4 ml-2" />
                عرض الطلب
              </Button>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Clear All Dialog */}
      <Dialog open={showClearDialog} onOpenChange={setShowClearDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>مسح جميع الإشعارات</DialogTitle>
            <DialogDescription>
              هل أنت متأكد من مسح جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowClearDialog(false)}>
              إلغاء
            </Button>
            <Button
              variant="destructive"
              onClick={clearAllNotifications}
              disabled={isClearing}
            >
              {isClearing ? (
                <>
                  <RefreshCw className="h-4 w-4 ml-2 animate-spin" />
                  جاري المسح...
                </>
              ) : (
                <>
                  <Trash2 className="h-4 w-4 ml-2" />
                  مسح الكل
                </>
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
