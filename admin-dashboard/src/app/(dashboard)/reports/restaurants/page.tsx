'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { Input } from '@/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from '@/components/ui/chart';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  PieChart,
  Pie,
  Cell,
  Legend,
} from 'recharts';
import {
  RefreshCw,
  Store,
  TrendingUp,
  ShoppingBag,
  Star,
  Download,
  FileSpreadsheet,
  FileText,
  ArrowLeft,
  Search,
  Eye,
} from 'lucide-react';
import Link from 'next/link';
import { dashboardApi, restaurantsApi, getErrorMessage, Restaurant, TopRestaurant } from '@/services/api';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';
import { exportToCSV, exportToPDF } from '@/lib/export';

interface RestaurantPerformance extends Restaurant {
  orderCount?: number;
  totalRevenue?: number;
}

const COLORS = ['#10B981', '#3B82F6', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899', '#06B6D4', '#84CC16'];

export default function RestaurantReportsPage() {
  const [topRestaurants, setTopRestaurants] = useState<TopRestaurant[]>([]);
  const [restaurants, setRestaurants] = useState<RestaurantPerformance[]>([]);
  const [stats, setStats] = useState({
    totalRestaurants: 0,
    activeRestaurants: 0,
    pendingRestaurants: 0,
    averageRating: 0,
  });
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [sortBy, setSortBy] = useState<'orders' | 'revenue' | 'rating'>('orders');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  const fetchData = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const [topRes, restaurantsRes, dashboardRes] = await Promise.all([
        dashboardApi.getTopRestaurants(10),
        restaurantsApi.getRestaurants({
          page: currentPage,
          limit: 20,
          search: search || undefined,
          status: 'approved',
        }),
        dashboardApi.getStats(),
      ]);

      if (topRes.success && topRes.data) {
        setTopRestaurants(topRes.data);
      }

      if (restaurantsRes.success && restaurantsRes.data) {
        setRestaurants(restaurantsRes.data.data || []);
        setTotalPages(restaurantsRes.data.pagination?.pages || 1);
      }

      if (dashboardRes.success && dashboardRes.data) {
        // Calculate average rating
        const ratings = restaurantsRes.data?.data?.filter(r => r.rating > 0).map(r => r.rating) || [];
        const avgRating = ratings.length > 0 ? ratings.reduce((a, b) => a + b, 0) / ratings.length : 0;

        setStats({
          totalRestaurants: dashboardRes.data.totalRestaurants,
          activeRestaurants: restaurantsRes.data?.pagination?.total || 0,
          pendingRestaurants: dashboardRes.data.pendingRestaurants,
          averageRating: avgRating,
        });
      }
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [currentPage]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setCurrentPage(1);
    fetchData();
  };

  const formatCurrency = (amount: number) => {
    return `${amount.toLocaleString('ar-EG')} ج.م`;
  };

  const handleExport = (format: 'csv' | 'pdf') => {
    const today = new Date();
    const dateStr = today.toLocaleDateString('ar-EG', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });

    const exportData = {
      title: 'تقرير أداء المطاعم',
      date: dateStr,
      columns: [
        { header: 'المطعم', key: 'name' },
        { header: 'عدد الطلبات', key: 'orders' },
        { header: 'الإيرادات', key: 'revenue' },
        { header: 'التقييم', key: 'rating' },
        { header: 'الحالة', key: 'status' },
      ],
      rows: topRestaurants.map(restaurant => ({
        name: restaurant.name,
        orders: restaurant.totalOrders,
        revenue: formatCurrency(restaurant.totalRevenue),
        rating: restaurant.totalOrders > 0 ? '4.5' : '-',
        status: 'نشط',
      })),
      summary: {
        'إجمالي المطاعم': stats.totalRestaurants,
        'المطاعم النشطة': stats.activeRestaurants,
        'قيد المراجعة': stats.pendingRestaurants,
        'متوسط التقييم': stats.averageRating.toFixed(1),
      },
    };

    if (format === 'csv') {
      exportToCSV(exportData);
    } else {
      exportToPDF(exportData);
    }
  };

  const chartConfig = {
    orders: {
      label: 'الطلبات',
      color: '#3B82F6',
    },
    revenue: {
      label: 'الإيرادات',
      color: '#10B981',
    },
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-48" />
        <div className="grid gap-4 md:grid-cols-4">
          {[...Array(4)].map((_, i) => (
            <Skeleton key={i} className="h-32" />
          ))}
        </div>
        <Skeleton className="h-96" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link href="/reports">
            <Button variant="ghost" size="icon">
              <ArrowLeft className="h-4 w-4" />
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold">تقرير أداء المطاعم</h1>
            <p className="text-muted-foreground">إحصائيات وتحليلات أداء المطاعم</p>
          </div>
        </div>
        <div className="flex gap-2">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline">
                <Download className="h-4 w-4 ml-2" />
                تصدير
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={() => handleExport('csv')}>
                <FileSpreadsheet className="h-4 w-4 ml-2" />
                تصدير Excel (CSV)
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => handleExport('pdf')}>
                <FileText className="h-4 w-4 ml-2" />
                تصدير PDF
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
          <Button onClick={fetchData} variant="outline" size="icon">
            <RefreshCw className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {error && (
        <div className="bg-destructive/10 text-destructive p-4 rounded-lg">
          {error}
        </div>
      )}

      {/* Stats Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              إجمالي المطاعم
            </CardTitle>
            <Store className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.totalRestaurants}</div>
            <p className="text-xs text-muted-foreground mt-1">
              جميع المطاعم المسجلة
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              المطاعم النشطة
            </CardTitle>
            <TrendingUp className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{stats.activeRestaurants}</div>
            <p className="text-xs text-muted-foreground mt-1">
              تستقبل طلبات حالياً
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              قيد المراجعة
            </CardTitle>
            <Store className="h-4 w-4 text-orange-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-600">{stats.pendingRestaurants}</div>
            <p className="text-xs text-muted-foreground mt-1">
              بانتظار الموافقة
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              متوسط التقييم
            </CardTitle>
            <Star className="h-4 w-4 text-yellow-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold flex items-center gap-1">
              <Star className="h-5 w-5 text-yellow-500 fill-yellow-500" />
              {stats.averageRating.toFixed(1)}
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              من 5 نجوم
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Top Restaurants Chart */}
      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>أفضل المطاعم حسب الطلبات</CardTitle>
          </CardHeader>
          <CardContent>
            <ChartContainer config={chartConfig} className="h-[350px] w-full">
              <BarChart
                data={topRestaurants.slice(0, 8)}
                layout="vertical"
                margin={{ left: 0, right: 20 }}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" />
                <YAxis
                  type="category"
                  dataKey="name"
                  width={100}
                  tick={{ fontSize: 12 }}
                />
                <ChartTooltip content={<ChartTooltipContent />} />
                <Bar
                  dataKey="totalOrders"
                  fill="var(--color-orders)"
                  name="عدد الطلبات"
                  radius={[0, 4, 4, 0]}
                />
              </BarChart>
            </ChartContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>توزيع الإيرادات</CardTitle>
          </CardHeader>
          <CardContent>
            {topRestaurants.length > 0 ? (
              <ChartContainer config={chartConfig} className="h-[350px] w-full">
                <PieChart>
                  <Pie
                    data={topRestaurants.slice(0, 6)}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, percent }) => `${name.slice(0, 10)}... (${(percent * 100).toFixed(0)}%)`}
                    outerRadius={100}
                    fill="#8884d8"
                    dataKey="totalRevenue"
                    nameKey="name"
                  >
                    {topRestaurants.slice(0, 6).map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Legend />
                </PieChart>
              </ChartContainer>
            ) : (
              <div className="h-[350px] flex items-center justify-center text-muted-foreground">
                لا توجد بيانات كافية
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Top 10 Restaurants */}
      <Card>
        <CardHeader>
          <CardTitle>أفضل 10 مطاعم</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-12">#</TableHead>
                <TableHead>المطعم</TableHead>
                <TableHead>عدد الطلبات</TableHead>
                <TableHead>إجمالي الإيرادات</TableHead>
                <TableHead>متوسط الطلب</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {topRestaurants.map((restaurant, index) => (
                <TableRow key={restaurant._id}>
                  <TableCell>
                    <span className={`flex h-8 w-8 items-center justify-center rounded-full text-sm font-bold ${
                      index === 0 ? 'bg-yellow-100 text-yellow-800' :
                      index === 1 ? 'bg-gray-100 text-gray-800' :
                      index === 2 ? 'bg-orange-100 text-orange-800' :
                      'bg-muted text-muted-foreground'
                    }`}>
                      {index + 1}
                    </span>
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center gap-3">
                      <div className="h-10 w-10 rounded-lg bg-muted flex items-center justify-center overflow-hidden">
                        {restaurant.logo ? (
                          <img src={restaurant.logo} alt="" className="h-10 w-10 object-cover" />
                        ) : (
                          <Store className="h-5 w-5 text-muted-foreground" />
                        )}
                      </div>
                      <span className="font-medium">{restaurant.name}</span>
                    </div>
                  </TableCell>
                  <TableCell className="font-semibold">{restaurant.totalOrders}</TableCell>
                  <TableCell>{formatCurrency(restaurant.totalRevenue)}</TableCell>
                  <TableCell>
                    {restaurant.totalOrders > 0
                      ? formatCurrency(restaurant.totalRevenue / restaurant.totalOrders)
                      : '-'}
                  </TableCell>
                </TableRow>
              ))}
              {topRestaurants.length === 0 && (
                <TableRow>
                  <TableCell colSpan={5} className="text-center py-8 text-muted-foreground">
                    لا توجد بيانات
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* All Restaurants */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle>جميع المطاعم النشطة</CardTitle>
            <form onSubmit={handleSearch} className="flex gap-2">
              <div className="relative">
                <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="البحث..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="pr-10 w-[200px]"
                />
              </div>
              <Button type="submit" size="sm">بحث</Button>
            </form>
          </div>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>المطعم</TableHead>
                <TableHead>المنطقة</TableHead>
                <TableHead>التقييم</TableHead>
                <TableHead>تاريخ الانضمام</TableHead>
                <TableHead></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {restaurants.map((restaurant) => (
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
                        <span className="text-sm text-muted-foreground">{restaurant.ownerId?.name || '-'}</span>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>{restaurant.address?.area || '-'}</TableCell>
                  <TableCell>
                    {restaurant.rating > 0 ? (
                      <span className="flex items-center gap-1">
                        <Star className="h-4 w-4 text-yellow-500 fill-yellow-500" />
                        {restaurant.rating.toFixed(1)}
                        <span className="text-xs text-muted-foreground">({restaurant.totalRatings})</span>
                      </span>
                    ) : '-'}
                  </TableCell>
                  <TableCell className="text-muted-foreground text-sm">
                    {format(new Date(restaurant.createdAt), 'dd MMM yyyy', { locale: ar })}
                  </TableCell>
                  <TableCell>
                    <Link href={`/restaurants/${restaurant._id}`}>
                      <Button variant="ghost" size="icon">
                        <Eye className="h-4 w-4" />
                      </Button>
                    </Link>
                  </TableCell>
                </TableRow>
              ))}
              {restaurants.length === 0 && (
                <TableRow>
                  <TableCell colSpan={5} className="text-center py-8 text-muted-foreground">
                    لا توجد مطاعم
                  </TableCell>
                </TableRow>
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
    </div>
  );
}
