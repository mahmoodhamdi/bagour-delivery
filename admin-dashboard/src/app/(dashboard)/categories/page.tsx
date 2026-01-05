'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui/skeleton';
import { Switch } from '@/components/ui/switch';
import { Textarea } from '@/components/ui/textarea';
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
  RefreshCw,
  Plus,
  Edit,
  Trash2,
  MoreVertical,
  FolderOpen,
  Search,
  ArrowUpDown,
  Image,
  GripVertical,
} from 'lucide-react';
import api, { getErrorMessage, ApiResponse, PaginatedResponse } from '@/services/api';

interface Category {
  _id: string;
  name: string;
  nameAr: string;
  description?: string;
  descriptionAr?: string;
  image?: string;
  sortOrder: number;
  isActive: boolean;
  itemCount?: number;
  createdAt: string;
}

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [editDialog, setEditDialog] = useState<{
    open: boolean;
    category: Partial<Category> | null;
    isNew: boolean;
  }>({ open: false, category: null, isNew: false });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [deleteDialog, setDeleteDialog] = useState<{
    open: boolean;
    category: Category | null;
  }>({ open: false, category: null });

  const fetchCategories = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const res = await api.get<ApiResponse<Category[]>>('/admin/categories', {
        params: { search: search || undefined },
      });

      if (res.data.success && res.data.data) {
        setCategories(res.data.data);
      }
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchCategories();
  }, []);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    fetchCategories();
  };

  const handleSave = async () => {
    if (!editDialog.category) return;

    setIsSubmitting(true);
    try {
      if (editDialog.isNew) {
        await api.post('/admin/categories', {
          name: editDialog.category.name,
          nameAr: editDialog.category.nameAr,
          description: editDialog.category.description,
          descriptionAr: editDialog.category.descriptionAr,
          image: editDialog.category.image,
          sortOrder: editDialog.category.sortOrder || 0,
          isActive: editDialog.category.isActive ?? true,
        });
      } else if (editDialog.category._id) {
        await api.put(`/admin/categories/${editDialog.category._id}`, {
          name: editDialog.category.name,
          nameAr: editDialog.category.nameAr,
          description: editDialog.category.description,
          descriptionAr: editDialog.category.descriptionAr,
          image: editDialog.category.image,
          sortOrder: editDialog.category.sortOrder,
          isActive: editDialog.category.isActive,
        });
      }
      setEditDialog({ open: false, category: null, isNew: false });
      fetchCategories();
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async () => {
    if (!deleteDialog.category) return;

    try {
      await api.delete(`/admin/categories/${deleteDialog.category._id}`);
      setDeleteDialog({ open: false, category: null });
      fetchCategories();
    } catch (err) {
      setError(getErrorMessage(err));
    }
  };

  const handleToggleActive = async (category: Category) => {
    try {
      await api.put(`/admin/categories/${category._id}`, {
        isActive: !category.isActive,
      });
      fetchCategories();
    } catch (err) {
      setError(getErrorMessage(err));
    }
  };

  if (isLoading && categories.length === 0) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-48" />
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

  const activeCategories = categories.filter(c => c.isActive).length;
  const inactiveCategories = categories.filter(c => !c.isActive).length;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">إدارة التصنيفات</h1>
          <p className="text-muted-foreground">إنشاء وإدارة تصنيفات الطعام العامة</p>
        </div>
        <div className="flex gap-2">
          <Button onClick={fetchCategories} variant="outline" size="icon">
            <RefreshCw className="h-4 w-4" />
          </Button>
          <Button onClick={() => setEditDialog({
            open: true,
            category: {
              name: '',
              nameAr: '',
              sortOrder: categories.length,
              isActive: true,
            },
            isNew: true,
          })}>
            <Plus className="h-4 w-4 ml-2" />
            إضافة تصنيف
          </Button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              إجمالي التصنيفات
            </CardTitle>
            <FolderOpen className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{categories.length}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              تصنيفات نشطة
            </CardTitle>
            <FolderOpen className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{activeCategories}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              تصنيفات غير نشطة
            </CardTitle>
            <FolderOpen className="h-4 w-4 text-gray-400" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-gray-400">{inactiveCategories}</div>
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
              placeholder="البحث عن تصنيف..."
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
                <TableHead className="w-12">
                  <ArrowUpDown className="h-4 w-4" />
                </TableHead>
                <TableHead>الصورة</TableHead>
                <TableHead>الاسم</TableHead>
                <TableHead>الاسم (عربي)</TableHead>
                <TableHead>الوصف</TableHead>
                <TableHead>الحالة</TableHead>
                <TableHead></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {categories.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-8 text-muted-foreground">
                    <div className="flex flex-col items-center gap-2">
                      <FolderOpen className="h-12 w-12 text-muted-foreground/50" />
                      <p>لا توجد تصنيفات</p>
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setEditDialog({
                          open: true,
                          category: {
                            name: '',
                            nameAr: '',
                            sortOrder: 0,
                            isActive: true,
                          },
                          isNew: true,
                        })}
                      >
                        <Plus className="h-4 w-4 ml-2" />
                        إضافة تصنيف جديد
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ) : (
                categories.map((category) => (
                  <TableRow key={category._id}>
                    <TableCell>
                      <div className="flex items-center gap-1 text-muted-foreground">
                        <GripVertical className="h-4 w-4 cursor-grab" />
                        <span className="text-xs">{category.sortOrder}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="h-10 w-10 rounded-lg bg-muted flex items-center justify-center overflow-hidden">
                        {category.image ? (
                          <img src={category.image} alt="" className="h-10 w-10 object-cover" />
                        ) : (
                          <Image className="h-5 w-5 text-muted-foreground" />
                        )}
                      </div>
                    </TableCell>
                    <TableCell className="font-medium">{category.name}</TableCell>
                    <TableCell>{category.nameAr}</TableCell>
                    <TableCell>
                      <span className="text-sm text-muted-foreground line-clamp-1">
                        {category.descriptionAr || category.description || '-'}
                      </span>
                    </TableCell>
                    <TableCell>
                      <Switch
                        checked={category.isActive}
                        onCheckedChange={() => handleToggleActive(category)}
                      />
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreVertical className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem
                            onClick={() => setEditDialog({ open: true, category, isNew: false })}
                          >
                            <Edit className="h-4 w-4 ml-2" />
                            تعديل
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            onClick={() => setDeleteDialog({ open: true, category })}
                            className="text-destructive"
                          >
                            <Trash2 className="h-4 w-4 ml-2" />
                            حذف
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Edit Dialog */}
      <Dialog open={editDialog.open} onOpenChange={(open) => !open && setEditDialog({ open: false, category: null, isNew: false })}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>{editDialog.isNew ? 'إضافة تصنيف جديد' : 'تعديل التصنيف'}</DialogTitle>
          </DialogHeader>

          <div className="space-y-4 py-4">
            <div className="grid gap-4 grid-cols-2">
              <div>
                <label className="text-sm font-medium">الاسم (English)</label>
                <Input
                  value={editDialog.category?.name || ''}
                  onChange={(e) => setEditDialog({
                    ...editDialog,
                    category: { ...editDialog.category, name: e.target.value },
                  })}
                  placeholder="Category Name"
                  className="mt-2"
                  dir="ltr"
                />
              </div>
              <div>
                <label className="text-sm font-medium">الاسم (عربي)</label>
                <Input
                  value={editDialog.category?.nameAr || ''}
                  onChange={(e) => setEditDialog({
                    ...editDialog,
                    category: { ...editDialog.category, nameAr: e.target.value },
                  })}
                  placeholder="اسم التصنيف"
                  className="mt-2"
                />
              </div>
            </div>

            <div>
              <label className="text-sm font-medium">الوصف (English)</label>
              <Textarea
                value={editDialog.category?.description || ''}
                onChange={(e) => setEditDialog({
                  ...editDialog,
                  category: { ...editDialog.category, description: e.target.value },
                })}
                placeholder="Category description"
                className="mt-2"
                dir="ltr"
                rows={2}
              />
            </div>

            <div>
              <label className="text-sm font-medium">الوصف (عربي)</label>
              <Textarea
                value={editDialog.category?.descriptionAr || ''}
                onChange={(e) => setEditDialog({
                  ...editDialog,
                  category: { ...editDialog.category, descriptionAr: e.target.value },
                })}
                placeholder="وصف التصنيف"
                className="mt-2"
                rows={2}
              />
            </div>

            <div>
              <label className="text-sm font-medium">رابط الصورة</label>
              <Input
                value={editDialog.category?.image || ''}
                onChange={(e) => setEditDialog({
                  ...editDialog,
                  category: { ...editDialog.category, image: e.target.value },
                })}
                placeholder="https://example.com/image.jpg"
                className="mt-2"
                dir="ltr"
              />
              {editDialog.category?.image && (
                <div className="mt-2 h-20 w-20 rounded-lg bg-muted overflow-hidden">
                  <img
                    src={editDialog.category.image}
                    alt="معاينة"
                    className="h-20 w-20 object-cover"
                    onError={(e) => {
                      (e.target as HTMLImageElement).style.display = 'none';
                    }}
                  />
                </div>
              )}
            </div>

            <div>
              <label className="text-sm font-medium">ترتيب العرض</label>
              <Input
                type="number"
                value={editDialog.category?.sortOrder || 0}
                onChange={(e) => setEditDialog({
                  ...editDialog,
                  category: { ...editDialog.category, sortOrder: parseInt(e.target.value) || 0 },
                })}
                className="mt-2"
                min={0}
              />
            </div>

            <div className="flex items-center justify-between">
              <label className="text-sm font-medium">نشط</label>
              <Switch
                checked={editDialog.category?.isActive ?? true}
                onCheckedChange={(checked) => setEditDialog({
                  ...editDialog,
                  category: { ...editDialog.category, isActive: checked },
                })}
              />
            </div>
          </div>

          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setEditDialog({ open: false, category: null, isNew: false })}
            >
              إلغاء
            </Button>
            <Button
              onClick={handleSave}
              disabled={isSubmitting || !editDialog.category?.name || !editDialog.category?.nameAr}
            >
              {isSubmitting ? 'جاري الحفظ...' : 'حفظ'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={deleteDialog.open} onOpenChange={(open) => !open && setDeleteDialog({ open: false, category: null })}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>تأكيد الحذف</DialogTitle>
          </DialogHeader>
          <p className="py-4">
            هل أنت متأكد من حذف التصنيف &quot;{deleteDialog.category?.nameAr}&quot;؟
            <br />
            <span className="text-sm text-muted-foreground">
              هذا الإجراء لا يمكن التراجع عنه.
            </span>
          </p>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setDeleteDialog({ open: false, category: null })}
            >
              إلغاء
            </Button>
            <Button
              variant="destructive"
              onClick={handleDelete}
            >
              حذف
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
