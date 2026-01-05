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
  Truck,
  TrendingUp,
  DollarSign,
  Star,
  Download,
  FileSpreadsheet,
  FileText,
  ArrowLeft,
  Search,
  Eye,
  Bike,
  Car,
  Users,
  CheckCircle,
} from 'lucide-react';
import Link from 'next/link';
import { dashboardApi, driversApi, getErrorMessage, Driver } from '@/services/api';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';
import { exportToCSV, exportToPDF } from '@/lib/export';

interface DriverStats {
  totalDrivers: number;
  onlineDrivers: number;
  pendingDrivers: number;
  deliveredToday: number;
  averageRating: number;
  totalEarnings: number;
}

interface TopDriver {
  driver: Driver;
  deliveries: number;
  earnings: number;
}

const COLORS = ['#10B981', '#3B82F6', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899', '#06B6D4', '#84CC16'];

export default function DriverReportsPage() {
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [stats, setStats] = useState<DriverStats>({
    totalDrivers: 0,
    onlineDrivers: 0,
    pendingDrivers: 0,
    deliveredToday: 0,
    averageRating: 0,
    totalEarnings: 0,
  });
  const [vehicleDistribution, setVehicleDistribution] = useState<{ type: string; label: string; count: number }[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [sortBy, setSortBy] = useState<'deliveries' | 'earnings' | 'rating'>('deliveries');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  const fetchData = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const [driversRes, dashboardRes] = await Promise.all([
        driversApi.getDrivers({
          page: currentPage,
          limit: 20,
          search: search || undefined,
          status: 'approved',
        }),
        dashboardApi.getStats(),
      ]);

      if (driversRes.success && driversRes.data) {
        const driverList = driversRes.data.data || [];
        setDrivers(driverList);
        setTotalPages(driversRes.data.pagination?.pages || 1);

        // Calculate stats
        const ratings = driverList.filter(d => d.rating > 0).map(d => d.rating);
        const avgRating = ratings.length > 0 ? ratings.reduce((a, b) => a + b, 0) / ratings.length : 0;
        const totalEarnings = driverList.reduce((sum, d) => sum + d.totalEarnings, 0);

        // Calculate vehicle distribution
        const vehicleCounts: Record<string, number> = {};
        driverList.forEach(driver => {
          const type = driver.vehicleType || 'other';
          vehicleCounts[type] = (vehicleCounts[type] || 0) + 1;
        });

        const vehicleLabels: Record<string, string> = {
          motorcycle: 'دراجة نارية',
          car: 'سيارة',
          bicycle: 'دراجة هوائية',
          other: 'أخرى',
        };

        setVehicleDistribution(
          Object.entries(vehicleCounts).map(([type, count]) => ({
            type,
            label: vehicleLabels[type] || type,
            count,
          }))
        );

        if (dashboardRes.success && dashboardRes.data) {
          setStats({
            totalDrivers: dashboardRes.data.totalDrivers,
            onlineDrivers: dashboardRes.data.onlineDrivers,
            pendingDrivers: dashboardRes.data.pendingDrivers,
            deliveredToday: dashboardRes.data.deliveredToday,
            averageRating: avgRating,
            totalEarnings: totalEarnings,
          });
        }
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

  const handleExport = (format: 'csv' | 'pdf') => {
    const today = new Date();
    const dateStr = today.toLocaleDateString('ar-EG', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });

    const sortedDrivers = [...drivers].sort((a, b) => {
      if (sortBy === 'deliveries') return b.totalDeliveries - a.totalDeliveries;
      if (sortBy === 'earnings') return b.totalEarnings - a.totalEarnings;
      return b.rating - a.rating;
    });

    const exportData = {
      title: 'تقرير أداء السائقين',
      date: dateStr,
      columns: [
        { header: 'السائق', key: 'name' },
        { header: 'المركبة', key: 'vehicle' },
        { header: 'عدد التوصيلات', key: 'deliveries' },
        { header: 'الأرباح', key: 'earnings' },
        { header: 'التقييم', key: 'rating' },
      ],
      rows: sortedDrivers.map(driver => ({
        name: driver.userId?.name || driver.name || '-',
        vehicle: getVehicleLabel(driver.vehicleType),
        deliveries: driver.totalDeliveries,
        earnings: formatCurrency(driver.totalEarnings),
        rating: driver.rating > 0 ? driver.rating.toFixed(1) : '-',
      })),
      summary: {
        'إجمالي السائقين': stats.totalDrivers,
        'السائقين المتصلين': stats.onlineDrivers,
        'توصيلات اليوم': stats.deliveredToday,
        'متوسط التقييم': stats.averageRating.toFixed(1),
        'إجمالي الأرباح': formatCurrency(stats.totalEarnings),
      },
    };

    if (format === 'csv') {
      exportToCSV(exportData);
    } else {
      exportToPDF(exportData);
    }
  };

  const chartConfig = {
    deliveries: {
      label: 'التوصيلات',
      color: '#3B82F6',
    },
    earnings: {
      label: 'الأرباح',
      color: '#10B981',
    },
  };

  // Sort drivers based on sortBy
  const sortedDrivers = [...drivers].sort((a, b) => {
    if (sortBy === 'deliveries') return b.totalDeliveries - a.totalDeliveries;
    if (sortBy === 'earnings') return b.totalEarnings - a.totalEarnings;
    return b.rating - a.rating;
  });

  const topDrivers = sortedDrivers.slice(0, 10);

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
            <h1 className="text-2xl font-bold">تقرير أداء السائقين</h1>
            <p className="text-muted-foreground">إحصائيات وتحليلات أداء السائقين</p>
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
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-5">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              إجمالي السائقين
            </CardTitle>
            <Users className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.totalDrivers}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              متصلين الآن
            </CardTitle>
            <div className="h-2 w-2 bg-green-500 rounded-full animate-pulse" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{stats.onlineDrivers}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              توصيلات اليوم
            </CardTitle>
            <CheckCircle className="h-4 w-4 text-teal-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-teal-600">{stats.deliveredToday}</div>
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
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              إجمالي الأرباح
            </CardTitle>
            <DollarSign className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(stats.totalEarnings)}</div>
          </CardContent>
        </Card>
      </div>

      {/* Charts */}
      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>أفضل السائقين حسب التوصيلات</CardTitle>
          </CardHeader>
          <CardContent>
            <ChartContainer config={chartConfig} className="h-[350px] w-full">
              <BarChart
                data={topDrivers.map(d => ({
                  name: d.userId?.name || d.name || 'غير معروف',
                  deliveries: d.totalDeliveries,
                }))}
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
                  dataKey="deliveries"
                  fill="var(--color-deliveries)"
                  name="التوصيلات"
                  radius={[0, 4, 4, 0]}
                />
              </BarChart>
            </ChartContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>توزيع أنواع المركبات</CardTitle>
          </CardHeader>
          <CardContent>
            {vehicleDistribution.length > 0 ? (
              <ChartContainer config={chartConfig} className="h-[350px] w-full">
                <PieChart>
                  <Pie
                    data={vehicleDistribution}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ label, percent }) => `${label} (${(percent * 100).toFixed(0)}%)`}
                    outerRadius={100}
                    fill="#8884d8"
                    dataKey="count"
                    nameKey="label"
                  >
                    {vehicleDistribution.map((entry, index) => (
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

      {/* Top 10 Drivers */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle>أفضل 10 سائقين</CardTitle>
            <Select value={sortBy} onValueChange={(v: 'deliveries' | 'earnings' | 'rating') => setSortBy(v)}>
              <SelectTrigger className="w-[160px]">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="deliveries">حسب التوصيلات</SelectItem>
                <SelectItem value="earnings">حسب الأرباح</SelectItem>
                <SelectItem value="rating">حسب التقييم</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-12">#</TableHead>
                <TableHead>السائق</TableHead>
                <TableHead>المركبة</TableHead>
                <TableHead>التوصيلات</TableHead>
                <TableHead>الأرباح</TableHead>
                <TableHead>التقييم</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {topDrivers.map((driver, index) => (
                <TableRow key={driver._id}>
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
                      <div className="h-10 w-10 rounded-full bg-muted flex items-center justify-center overflow-hidden">
                        {driver.avatar ? (
                          <img src={driver.avatar} alt="" className="h-10 w-10 object-cover" />
                        ) : (
                          <Truck className="h-5 w-5 text-muted-foreground" />
                        )}
                      </div>
                      <div>
                        <span className="font-medium block">{driver.userId?.name || driver.name || '-'}</span>
                        <span className="text-sm text-muted-foreground" dir="ltr">
                          {driver.userId?.phone || driver.phone || ''}
                        </span>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      {getVehicleIcon(driver.vehicleType)}
                      <span>{getVehicleLabel(driver.vehicleType)}</span>
                    </div>
                  </TableCell>
                  <TableCell className="font-semibold">{driver.totalDeliveries}</TableCell>
                  <TableCell>{formatCurrency(driver.totalEarnings)}</TableCell>
                  <TableCell>
                    {driver.rating > 0 ? (
                      <span className="flex items-center gap-1">
                        <Star className="h-4 w-4 text-yellow-500 fill-yellow-500" />
                        {driver.rating.toFixed(1)}
                      </span>
                    ) : '-'}
                  </TableCell>
                </TableRow>
              ))}
              {topDrivers.length === 0 && (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-8 text-muted-foreground">
                    لا توجد بيانات
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* All Drivers */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle>جميع السائقين النشطين</CardTitle>
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
                <TableHead>السائق</TableHead>
                <TableHead>المركبة</TableHead>
                <TableHead>التوصيلات</TableHead>
                <TableHead>الأرباح</TableHead>
                <TableHead>التقييم</TableHead>
                <TableHead>الحالة</TableHead>
                <TableHead></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {drivers.map((driver) => (
                <TableRow key={driver._id}>
                  <TableCell>
                    <div className="flex items-center gap-3">
                      <div className="h-10 w-10 rounded-full bg-muted flex items-center justify-center overflow-hidden">
                        {driver.avatar ? (
                          <img src={driver.avatar} alt="" className="h-10 w-10 object-cover" />
                        ) : (
                          <Truck className="h-5 w-5 text-muted-foreground" />
                        )}
                      </div>
                      <div>
                        <span className="font-medium block">{driver.userId?.name || driver.name || '-'}</span>
                        <span className="text-sm text-muted-foreground" dir="ltr">
                          {driver.userId?.phone || driver.phone || ''}
                        </span>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      {getVehicleIcon(driver.vehicleType)}
                      <span>{driver.vehiclePlate || '-'}</span>
                    </div>
                  </TableCell>
                  <TableCell>{driver.totalDeliveries}</TableCell>
                  <TableCell>{formatCurrency(driver.totalEarnings)}</TableCell>
                  <TableCell>
                    {driver.rating > 0 ? (
                      <span className="flex items-center gap-1">
                        <Star className="h-4 w-4 text-yellow-500 fill-yellow-500" />
                        {driver.rating.toFixed(1)}
                      </span>
                    ) : '-'}
                  </TableCell>
                  <TableCell>
                    <span className={`inline-flex h-2 w-2 rounded-full ${driver.isOnline ? 'bg-green-500' : 'bg-gray-300'}`} />
                    <span className="mr-2 text-sm">{driver.isOnline ? 'متصل' : 'غير متصل'}</span>
                  </TableCell>
                  <TableCell>
                    <Link href={`/drivers/${driver._id}`}>
                      <Button variant="ghost" size="icon">
                        <Eye className="h-4 w-4" />
                      </Button>
                    </Link>
                  </TableCell>
                </TableRow>
              ))}
              {drivers.length === 0 && (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-8 text-muted-foreground">
                    لا يوجد سائقين
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
