'use client';

import { useState, useEffect, useCallback } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Skeleton } from '@/components/ui/skeleton';
import { Separator } from '@/components/ui/separator';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
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
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import {
  DollarSign,
  ArrowUpRight,
  ArrowDownRight,
  Clock,
  CheckCircle,
  XCircle,
  RefreshCw,
  Send,
  Calendar,
  Filter,
  ChevronLeft,
  ChevronRight,
  AlertCircle,
  Wallet,
  Building2,
  CreditCard,
  Loader2,
  FileText,
  Download,
  Info,
  ArrowLeft,
} from 'lucide-react';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';
import { toast } from 'sonner';
import api, { getErrorMessage, ApiResponse, Transaction } from '@/lib/api';
import { useRouter } from 'next/navigation';

interface Payout {
  _id: string;
  payoutNumber: string;
  amount: number;
  fee: number;
  netAmount: number;
  status: 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled';
  method: 'bank_transfer' | 'instapay' | 'vodafone_cash' | 'wallet';
  bankDetails?: {
    bankName: string;
    accountNumber: string;
    accountHolderName: string;
  };
  walletDetails?: {
    provider: string;
    phoneNumber: string;
  };
  notes?: string;
  rejectionReason?: string;
  processedAt?: string;
  createdAt: string;
  updatedAt: string;
}

interface PayoutSummary {
  availableBalance: number;
  pendingPayouts: number;
  totalPaidOut: number;
  minimumPayout: number;
}

interface PayoutsResponse {
  payouts: Payout[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

interface PayoutRequest {
  amount: number;
  method: Payout['method'];
  bankDetails?: {
    bankName: string;
    accountNumber: string;
    accountHolderName: string;
  };
  walletDetails?: {
    provider: string;
    phoneNumber: string;
  };
}

type PayoutStatus = 'all' | Payout['status'];

const BANKS = [
  { value: 'cib', label: 'البنك التجاري الدولي (CIB)' },
  { value: 'nbe', label: 'البنك الأهلي المصري' },
  { value: 'banque_misr', label: 'بنك مصر' },
  { value: 'qnb', label: 'بنك قطر الوطني (QNB)' },
  { value: 'hsbc', label: 'HSBC' },
  { value: 'alexbank', label: 'بنك الإسكندرية' },
  { value: 'aaib', label: 'المصرف العربي الدولي' },
  { value: 'other', label: 'بنك آخر' },
];

const WALLET_PROVIDERS = [
  { value: 'vodafone_cash', label: 'فودافون كاش' },
  { value: 'orange_cash', label: 'أورانج كاش' },
  { value: 'etisalat_cash', label: 'اتصالات كاش' },
  { value: 'we_pay', label: 'WE Pay' },
  { value: 'instapay', label: 'إنستا باي' },
];

export default function PayoutsPage() {
  const router = useRouter();
  const [payouts, setPayouts] = useState<Payout[]>([]);
  const [summary, setSummary] = useState<PayoutSummary | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [statusFilter, setStatusFilter] = useState<PayoutStatus>('all');
  const [showRequestDialog, setShowRequestDialog] = useState(false);
  const [showConfirmDialog, setShowConfirmDialog] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [selectedPayout, setSelectedPayout] = useState<Payout | null>(null);

  // Payout request form
  const [payoutForm, setPayoutForm] = useState<PayoutRequest>({
    amount: 0,
    method: 'bank_transfer',
    bankDetails: {
      bankName: '',
      accountNumber: '',
      accountHolderName: '',
    },
  });

  const fetchData = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);

      const params: Record<string, unknown> = { page, limit: 15 };
      if (statusFilter !== 'all') {
        params.status = statusFilter;
      }

      const [payoutsRes, summaryRes] = await Promise.all([
        api.get<ApiResponse<PayoutsResponse>>('/restaurant/payouts', { params }),
        api.get<ApiResponse<PayoutSummary>>('/restaurant/payouts/summary'),
      ]);

      if (payoutsRes.data.success && payoutsRes.data.data) {
        setPayouts(payoutsRes.data.data.payouts);
        setTotalPages(payoutsRes.data.data.pagination.pages);
      }

      if (summaryRes.data.success && summaryRes.data.data) {
        setSummary(summaryRes.data.data);
      }
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  }, [page, statusFilter]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const handleRequestPayout = async () => {
    if (!summary) return;

    if (payoutForm.amount < summary.minimumPayout) {
      toast.error(`الحد الأدنى للسحب هو ${summary.minimumPayout} ج.م`);
      return;
    }

    if (payoutForm.amount > summary.availableBalance) {
      toast.error('المبلغ المطلوب أكبر من الرصيد المتاح');
      return;
    }

    // Validate method-specific fields
    if (payoutForm.method === 'bank_transfer') {
      if (
        !payoutForm.bankDetails?.bankName ||
        !payoutForm.bankDetails?.accountNumber ||
        !payoutForm.bankDetails?.accountHolderName
      ) {
        toast.error('يرجى إكمال بيانات الحساب البنكي');
        return;
      }
    } else {
      if (!payoutForm.walletDetails?.provider || !payoutForm.walletDetails?.phoneNumber) {
        toast.error('يرجى إكمال بيانات المحفظة');
        return;
      }
    }

    setShowConfirmDialog(true);
  };

  const confirmPayoutRequest = async () => {
    try {
      setIsSubmitting(true);

      const requestData: PayoutRequest = {
        amount: payoutForm.amount,
        method: payoutForm.method,
      };

      if (payoutForm.method === 'bank_transfer') {
        requestData.bankDetails = payoutForm.bankDetails;
      } else {
        requestData.walletDetails = payoutForm.walletDetails;
      }

      const response = await api.post<ApiResponse<{ payout: Payout }>>(
        '/restaurant/payouts/request',
        requestData
      );

      if (response.data.success && response.data.data) {
        toast.success('تم إرسال طلب السحب بنجاح');
        setShowConfirmDialog(false);
        setShowRequestDialog(false);
        setPayoutForm({
          amount: 0,
          method: 'bank_transfer',
          bankDetails: {
            bankName: '',
            accountNumber: '',
            accountHolderName: '',
          },
        });
        fetchData();
      }
    } catch (err) {
      toast.error(getErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  const cancelPayoutRequest = async (payoutId: string) => {
    try {
      const response = await api.post<ApiResponse<void>>(
        `/restaurant/payouts/${payoutId}/cancel`
      );

      if (response.data.success) {
        toast.success('تم إلغاء طلب السحب');
        fetchData();
      }
    } catch (err) {
      toast.error(getErrorMessage(err));
    }
  };

  const getStatusBadge = (status: Payout['status']) => {
    const statusConfig: Record<
      Payout['status'],
      { label: string; variant: 'default' | 'secondary' | 'destructive' | 'outline' }
    > = {
      pending: { label: 'قيد الانتظار', variant: 'secondary' },
      processing: { label: 'جاري المعالجة', variant: 'default' },
      completed: { label: 'مكتمل', variant: 'default' },
      failed: { label: 'فشل', variant: 'destructive' },
      cancelled: { label: 'ملغي', variant: 'outline' },
    };
    const config = statusConfig[status];
    return <Badge variant={config.variant}>{config.label}</Badge>;
  };

  const getStatusIcon = (status: Payout['status']) => {
    switch (status) {
      case 'pending':
        return <Clock className="h-4 w-4 text-yellow-500" />;
      case 'processing':
        return <RefreshCw className="h-4 w-4 text-blue-500 animate-spin" />;
      case 'completed':
        return <CheckCircle className="h-4 w-4 text-green-500" />;
      case 'failed':
        return <XCircle className="h-4 w-4 text-red-500" />;
      case 'cancelled':
        return <XCircle className="h-4 w-4 text-gray-500" />;
      default:
        return <Clock className="h-4 w-4" />;
    }
  };

  const getMethodLabel = (method: Payout['method']) => {
    const methods: Record<string, string> = {
      bank_transfer: 'تحويل بنكي',
      instapay: 'إنستا باي',
      vodafone_cash: 'فودافون كاش',
      wallet: 'محفظة إلكترونية',
    };
    return methods[method] || method;
  };

  const formatCurrency = (amount: number) => {
    return `${amount.toLocaleString('ar-EG')} ج.م`;
  };

  if (isLoading && !summary) {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <Skeleton className="h-10 w-10" />
          <Skeleton className="h-8 w-48" />
        </div>
        <div className="grid gap-4 md:grid-cols-4">
          {[1, 2, 3, 4].map((i) => (
            <Skeleton key={i} className="h-32" />
          ))}
        </div>
        <Skeleton className="h-96" />
      </div>
    );
  }

  if (error && !summary) {
    return (
      <Card>
        <CardContent className="flex flex-col items-center justify-center py-12">
          <AlertCircle className="h-12 w-12 text-destructive mb-4" />
          <p className="text-destructive mb-4">{error}</p>
          <Button onClick={fetchData} variant="outline">
            <RefreshCw className="h-4 w-4 ml-2" />
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
        <div className="flex items-center gap-4">
          <Button variant="ghost" size="icon" onClick={() => router.push('/earnings')}>
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div>
            <h1 className="text-2xl font-bold">المدفوعات والسحب</h1>
            <p className="text-muted-foreground">إدارة طلبات السحب والمدفوعات</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" onClick={fetchData}>
            <RefreshCw className="h-4 w-4 ml-2" />
            تحديث
          </Button>
          <Button
            onClick={() => setShowRequestDialog(true)}
            disabled={!summary || summary.availableBalance < summary.minimumPayout}
          >
            <Send className="h-4 w-4 ml-2" />
            طلب سحب
          </Button>
        </div>
      </div>

      {/* Summary Cards */}
      {summary && (
        <div className="grid gap-4 md:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">الرصيد المتاح</CardTitle>
              <Wallet className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-green-600">
                {formatCurrency(summary.availableBalance)}
              </div>
              <p className="text-xs text-muted-foreground">
                الحد الأدنى للسحب: {formatCurrency(summary.minimumPayout)}
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">في انتظار المعالجة</CardTitle>
              <Clock className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-yellow-600">
                {formatCurrency(summary.pendingPayouts)}
              </div>
              <p className="text-xs text-muted-foreground">طلبات قيد الانتظار</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">إجمالي المسحوبات</CardTitle>
              <ArrowUpRight className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{formatCurrency(summary.totalPaidOut)}</div>
              <p className="text-xs text-muted-foreground">تم تحويله بنجاح</p>
            </CardContent>
          </Card>

          <Card className="bg-primary/5 border-primary/20">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">السحب الآن</CardTitle>
              <DollarSign className="h-4 w-4 text-primary" />
            </CardHeader>
            <CardContent>
              <Button
                className="w-full"
                onClick={() => setShowRequestDialog(true)}
                disabled={summary.availableBalance < summary.minimumPayout}
              >
                <Send className="h-4 w-4 ml-2" />
                طلب سحب
              </Button>
              {summary.availableBalance < summary.minimumPayout && (
                <p className="text-xs text-muted-foreground mt-2 text-center">
                  الرصيد أقل من الحد الأدنى
                </p>
              )}
            </CardContent>
          </Card>
        </div>
      )}

      {/* Info Banner */}
      <Card className="bg-blue-50 border-blue-200">
        <CardContent className="flex items-center gap-4 py-4">
          <Info className="h-5 w-5 text-blue-600 flex-shrink-0" />
          <div className="text-sm text-blue-800">
            <p className="font-medium">معلومات السحب</p>
            <p>
              يتم معالجة طلبات السحب خلال 1-3 أيام عمل. التحويل البنكي قد يستغرق وقت أطول
              حسب البنك المستلم.
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Filters */}
      <div className="flex items-center gap-4">
        <Select
          value={statusFilter}
          onValueChange={(v) => {
            setStatusFilter(v as PayoutStatus);
            setPage(1);
          }}
        >
          <SelectTrigger className="w-[180px]">
            <Filter className="h-4 w-4 ml-2" />
            <SelectValue placeholder="جميع الحالات" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">جميع الحالات</SelectItem>
            <SelectItem value="pending">قيد الانتظار</SelectItem>
            <SelectItem value="processing">جاري المعالجة</SelectItem>
            <SelectItem value="completed">مكتملة</SelectItem>
            <SelectItem value="failed">فشلت</SelectItem>
            <SelectItem value="cancelled">ملغية</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Payouts Table */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <DollarSign className="h-5 w-5" />
            سجل المدفوعات
          </CardTitle>
          <CardDescription>جميع طلبات السحب والمدفوعات</CardDescription>
        </CardHeader>
        <CardContent>
          {payouts.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <Wallet className="h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="text-lg font-semibold mb-2">لا توجد مدفوعات</h3>
              <p className="text-muted-foreground mb-4">
                {statusFilter === 'all'
                  ? 'لم تقم بأي طلب سحب بعد'
                  : 'لا توجد مدفوعات بهذه الحالة'}
              </p>
              {summary && summary.availableBalance >= summary.minimumPayout && (
                <Button onClick={() => setShowRequestDialog(true)}>
                  <Send className="h-4 w-4 ml-2" />
                  طلب سحب الآن
                </Button>
              )}
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>رقم الطلب</TableHead>
                  <TableHead>المبلغ</TableHead>
                  <TableHead>الرسوم</TableHead>
                  <TableHead>الصافي</TableHead>
                  <TableHead>الطريقة</TableHead>
                  <TableHead>الحالة</TableHead>
                  <TableHead>التاريخ</TableHead>
                  <TableHead className="w-12"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {payouts.map((payout) => (
                  <TableRow key={payout._id}>
                    <TableCell className="font-mono text-sm">
                      {payout.payoutNumber}
                    </TableCell>
                    <TableCell>{formatCurrency(payout.amount)}</TableCell>
                    <TableCell className="text-destructive">
                      {payout.fee > 0 ? `-${formatCurrency(payout.fee)}` : '-'}
                    </TableCell>
                    <TableCell className="font-semibold">
                      {formatCurrency(payout.netAmount)}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        {payout.method === 'bank_transfer' ? (
                          <Building2 className="h-4 w-4 text-muted-foreground" />
                        ) : (
                          <CreditCard className="h-4 w-4 text-muted-foreground" />
                        )}
                        <span>{getMethodLabel(payout.method)}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        {getStatusIcon(payout.status)}
                        {getStatusBadge(payout.status)}
                      </div>
                    </TableCell>
                    <TableCell className="text-muted-foreground text-sm">
                      {format(new Date(payout.createdAt), 'd MMM yyyy', { locale: ar })}
                    </TableCell>
                    <TableCell>
                      {payout.status === 'pending' && (
                        <Button
                          variant="ghost"
                          size="sm"
                          className="text-destructive hover:text-destructive"
                          onClick={() => cancelPayoutRequest(payout._id)}
                        >
                          إلغاء
                        </Button>
                      )}
                      {payout.status === 'failed' && payout.rejectionReason && (
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => setSelectedPayout(payout)}
                        >
                          التفاصيل
                        </Button>
                      )}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
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

      {/* Request Payout Dialog */}
      <Dialog open={showRequestDialog} onOpenChange={setShowRequestDialog}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>طلب سحب رصيد</DialogTitle>
            <DialogDescription>
              أدخل المبلغ المراد سحبه وطريقة الاستلام
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-6 py-4">
            {/* Available Balance */}
            {summary && (
              <div className="p-4 bg-green-50 rounded-lg">
                <div className="flex items-center justify-between">
                  <span className="text-muted-foreground">الرصيد المتاح</span>
                  <span className="text-xl font-bold text-green-600">
                    {formatCurrency(summary.availableBalance)}
                  </span>
                </div>
              </div>
            )}

            {/* Amount */}
            <div className="space-y-2">
              <Label htmlFor="amount">المبلغ المراد سحبه (ج.م)</Label>
              <Input
                id="amount"
                type="number"
                min={summary?.minimumPayout || 0}
                max={summary?.availableBalance || 0}
                value={payoutForm.amount || ''}
                onChange={(e) =>
                  setPayoutForm((prev) => ({
                    ...prev,
                    amount: parseFloat(e.target.value) || 0,
                  }))
                }
                placeholder={`الحد الأدنى ${summary?.minimumPayout || 0} ج.م`}
                dir="ltr"
              />
              {summary && (
                <div className="flex gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() =>
                      setPayoutForm((prev) => ({
                        ...prev,
                        amount: summary.availableBalance,
                      }))
                    }
                  >
                    سحب الكل
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() =>
                      setPayoutForm((prev) => ({
                        ...prev,
                        amount: Math.min(500, summary.availableBalance),
                      }))
                    }
                  >
                    500 ج.م
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() =>
                      setPayoutForm((prev) => ({
                        ...prev,
                        amount: Math.min(1000, summary.availableBalance),
                      }))
                    }
                  >
                    1000 ج.م
                  </Button>
                </div>
              )}
            </div>

            <Separator />

            {/* Payment Method */}
            <div className="space-y-2">
              <Label>طريقة الاستلام</Label>
              <Tabs
                value={payoutForm.method}
                onValueChange={(v) =>
                  setPayoutForm((prev) => ({
                    ...prev,
                    method: v as Payout['method'],
                  }))
                }
              >
                <TabsList className="grid grid-cols-2">
                  <TabsTrigger value="bank_transfer" className="gap-2">
                    <Building2 className="h-4 w-4" />
                    تحويل بنكي
                  </TabsTrigger>
                  <TabsTrigger value="wallet" className="gap-2">
                    <CreditCard className="h-4 w-4" />
                    محفظة إلكترونية
                  </TabsTrigger>
                </TabsList>

                <TabsContent value="bank_transfer" className="space-y-4 mt-4">
                  <div className="space-y-2">
                    <Label htmlFor="bankName">اسم البنك</Label>
                    <Select
                      value={payoutForm.bankDetails?.bankName || ''}
                      onValueChange={(v) =>
                        setPayoutForm((prev) => ({
                          ...prev,
                          bankDetails: { ...prev.bankDetails!, bankName: v },
                        }))
                      }
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="اختر البنك" />
                      </SelectTrigger>
                      <SelectContent>
                        {BANKS.map((bank) => (
                          <SelectItem key={bank.value} value={bank.value}>
                            {bank.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="accountNumber">رقم الحساب</Label>
                    <Input
                      id="accountNumber"
                      value={payoutForm.bankDetails?.accountNumber || ''}
                      onChange={(e) =>
                        setPayoutForm((prev) => ({
                          ...prev,
                          bankDetails: { ...prev.bankDetails!, accountNumber: e.target.value },
                        }))
                      }
                      placeholder="رقم الحساب أو IBAN"
                      dir="ltr"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="accountHolderName">اسم صاحب الحساب</Label>
                    <Input
                      id="accountHolderName"
                      value={payoutForm.bankDetails?.accountHolderName || ''}
                      onChange={(e) =>
                        setPayoutForm((prev) => ({
                          ...prev,
                          bankDetails: {
                            ...prev.bankDetails!,
                            accountHolderName: e.target.value,
                          },
                        }))
                      }
                      placeholder="الاسم كما هو مسجل في البنك"
                    />
                  </div>
                </TabsContent>

                <TabsContent value="wallet" className="space-y-4 mt-4">
                  <div className="space-y-2">
                    <Label htmlFor="walletProvider">مزود المحفظة</Label>
                    <Select
                      value={payoutForm.walletDetails?.provider || ''}
                      onValueChange={(v) =>
                        setPayoutForm((prev) => ({
                          ...prev,
                          walletDetails: { ...prev.walletDetails!, provider: v },
                        }))
                      }
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="اختر المحفظة" />
                      </SelectTrigger>
                      <SelectContent>
                        {WALLET_PROVIDERS.map((provider) => (
                          <SelectItem key={provider.value} value={provider.value}>
                            {provider.label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="walletPhone">رقم الهاتف</Label>
                    <Input
                      id="walletPhone"
                      value={payoutForm.walletDetails?.phoneNumber || ''}
                      onChange={(e) =>
                        setPayoutForm((prev) => ({
                          ...prev,
                          walletDetails: { ...prev.walletDetails!, phoneNumber: e.target.value },
                        }))
                      }
                      placeholder="01xxxxxxxxx"
                      dir="ltr"
                    />
                  </div>
                </TabsContent>
              </Tabs>
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setShowRequestDialog(false)}>
              إلغاء
            </Button>
            <Button
              onClick={handleRequestPayout}
              disabled={
                !payoutForm.amount ||
                payoutForm.amount < (summary?.minimumPayout || 0) ||
                payoutForm.amount > (summary?.availableBalance || 0)
              }
            >
              <Send className="h-4 w-4 ml-2" />
              إرسال الطلب
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Confirm Payout Dialog */}
      <AlertDialog open={showConfirmDialog} onOpenChange={setShowConfirmDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>تأكيد طلب السحب</AlertDialogTitle>
            <AlertDialogDescription>
              <div className="space-y-2 mt-4">
                <div className="flex justify-between">
                  <span>المبلغ:</span>
                  <span className="font-semibold">{formatCurrency(payoutForm.amount)}</span>
                </div>
                <div className="flex justify-between">
                  <span>الطريقة:</span>
                  <span className="font-semibold">{getMethodLabel(payoutForm.method)}</span>
                </div>
                {payoutForm.method === 'bank_transfer' && payoutForm.bankDetails && (
                  <div className="flex justify-between">
                    <span>الحساب:</span>
                    <span className="font-semibold">{payoutForm.bankDetails.accountNumber}</span>
                  </div>
                )}
                {payoutForm.method === 'wallet' && payoutForm.walletDetails && (
                  <div className="flex justify-between">
                    <span>الهاتف:</span>
                    <span className="font-semibold">{payoutForm.walletDetails.phoneNumber}</span>
                  </div>
                )}
              </div>
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isSubmitting}>إلغاء</AlertDialogCancel>
            <AlertDialogAction onClick={confirmPayoutRequest} disabled={isSubmitting}>
              {isSubmitting ? (
                <>
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                  جاري الإرسال...
                </>
              ) : (
                'تأكيد الطلب'
              )}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Payout Details Dialog */}
      <Dialog open={!!selectedPayout} onOpenChange={() => setSelectedPayout(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>تفاصيل طلب السحب</DialogTitle>
          </DialogHeader>
          {selectedPayout && (
            <div className="space-y-4">
              <div className="flex justify-between">
                <span className="text-muted-foreground">رقم الطلب:</span>
                <span className="font-mono">{selectedPayout.payoutNumber}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">المبلغ:</span>
                <span className="font-semibold">{formatCurrency(selectedPayout.amount)}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">الحالة:</span>
                {getStatusBadge(selectedPayout.status)}
              </div>
              {selectedPayout.rejectionReason && (
                <div className="p-4 bg-red-50 rounded-lg">
                  <p className="text-sm font-medium text-red-800 mb-1">سبب الرفض:</p>
                  <p className="text-sm text-red-700">{selectedPayout.rejectionReason}</p>
                </div>
              )}
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setSelectedPayout(null)}>
              إغلاق
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
