'use client';

import { useEffect, useState, useCallback } from 'react';
import { useMenuStore, MenuCategory } from '@/stores/menu';
import { menuApi, getErrorMessage, uploadApi } from '@/lib/api';
import { toast } from 'sonner';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';
import { Switch } from '@/components/ui/switch';
import { Skeleton } from '@/components/ui/skeleton';
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
  DropdownMenuSeparator,
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
  Plus,
  FolderOpen,
  MoreVertical,
  Pencil,
  Trash2,
  GripVertical,
  UtensilsCrossed,
  Loader2,
  Search,
  Upload,
  Image as ImageIcon,
  RefreshCw,
  ArrowUp,
  ArrowDown,
  Eye,
  EyeOff,
} from 'lucide-react';
import { format } from 'date-fns';
import { ar } from 'date-fns/locale';

interface CategoryFormData {
  name: string;
  nameAr: string;
  description: string;
  descriptionAr: string;
  image: string;
  isActive: boolean;
  sortOrder: number;
}

const initialCategoryForm: CategoryFormData = {
  name: '',
  nameAr: '',
  description: '',
  descriptionAr: '',
  image: '',
  isActive: true,
  sortOrder: 0,
};

export default function CategoriesPage() {
  const {
    categories,
    isLoading,
    isSaving,
    setCategories,
    addCategory,
    updateCategory,
    removeCategory,
    setLoading,
    setSaving,
    reorderCategories,
  } = useMenuStore();

  const [searchQuery, setSearchQuery] = useState('');
  const [showCategoryDialog, setShowCategoryDialog] = useState(false);
  const [editingCategory, setEditingCategory] = useState<string | null>(null);
  const [categoryForm, setCategoryForm] = useState<CategoryFormData>(initialCategoryForm);
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);
  const [isUploading, setIsUploading] = useState(false);

  // Fetch categories
  const fetchCategories = useCallback(async () => {
    try {
      setLoading(true);
      const response = await menuApi.getCategories();
      if (response.success && response.data) {
        setCategories(response.data.categories);
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  }, [setCategories, setLoading]);

  useEffect(() => {
    fetchCategories();
  }, [fetchCategories]);

  // Filter categories based on search
  const filteredCategories = categories.filter(
    (cat) =>
      cat.nameAr.toLowerCase().includes(searchQuery.toLowerCase()) ||
      cat.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  // Category dialog handlers
  const handleOpenCategoryDialog = (categoryId?: string) => {
    if (categoryId) {
      const category = categories.find((c) => c._id === categoryId);
      if (category) {
        setCategoryForm({
          name: category.name,
          nameAr: category.nameAr,
          description: category.description || '',
          descriptionAr: category.descriptionAr || '',
          image: category.image || '',
          isActive: category.isActive,
          sortOrder: category.sortOrder,
        });
        setEditingCategory(categoryId);
      }
    } else {
      setCategoryForm({
        ...initialCategoryForm,
        sortOrder: categories.length > 0 ? Math.max(...categories.map(c => c.sortOrder)) + 1 : 0,
      });
      setEditingCategory(null);
    }
    setShowCategoryDialog(true);
  };

  const handleSaveCategory = async () => {
    if (!categoryForm.name.trim() || !categoryForm.nameAr.trim()) {
      toast.error('يرجى إدخال اسم القسم بالعربية والإنجليزية');
      return;
    }

    try {
      setSaving(true);

      if (editingCategory) {
        const response = await menuApi.updateCategory(editingCategory, {
          name: categoryForm.name,
          nameAr: categoryForm.nameAr,
          description: categoryForm.description,
          descriptionAr: categoryForm.descriptionAr,
          isActive: categoryForm.isActive,
        });
        if (response.success && response.data) {
          updateCategory(editingCategory, response.data.category);
          toast.success('تم تحديث القسم بنجاح');
        }
      } else {
        const response = await menuApi.createCategory({
          name: categoryForm.name,
          nameAr: categoryForm.nameAr,
          description: categoryForm.description,
          descriptionAr: categoryForm.descriptionAr,
          isActive: categoryForm.isActive,
          sortOrder: categoryForm.sortOrder,
        });
        if (response.success && response.data) {
          addCategory(response.data.category);
          toast.success('تم إنشاء القسم بنجاح');
        }
      }

      setShowCategoryDialog(false);
      setCategoryForm(initialCategoryForm);
      setEditingCategory(null);
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteCategory = async () => {
    if (!deleteConfirm) return;

    try {
      setSaving(true);
      const response = await menuApi.deleteCategory(deleteConfirm);
      if (response.success) {
        removeCategory(deleteConfirm);
        toast.success('تم حذف القسم بنجاح');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setSaving(false);
      setDeleteConfirm(null);
    }
  };

  const handleToggleActive = async (category: MenuCategory) => {
    try {
      const response = await menuApi.updateCategory(category._id, {
        isActive: !category.isActive,
      });
      if (response.success && response.data) {
        updateCategory(category._id, { isActive: !category.isActive });
        toast.success(category.isActive ? 'تم إخفاء القسم' : 'تم تفعيل القسم');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    }
  };

  const handleMoveCategory = async (categoryId: string, direction: 'up' | 'down') => {
    const sortedCategories = [...categories].sort((a, b) => a.sortOrder - b.sortOrder);
    const currentIndex = sortedCategories.findIndex((c) => c._id === categoryId);

    if (
      (direction === 'up' && currentIndex === 0) ||
      (direction === 'down' && currentIndex === sortedCategories.length - 1)
    ) {
      return;
    }

    const targetIndex = direction === 'up' ? currentIndex - 1 : currentIndex + 1;
    const currentCategory = sortedCategories[currentIndex];
    const targetCategory = sortedCategories[targetIndex];

    // Swap sort orders
    const newOrder = [
      { id: currentCategory._id, sortOrder: targetCategory.sortOrder },
      { id: targetCategory._id, sortOrder: currentCategory.sortOrder },
    ];

    try {
      const response = await menuApi.reorderCategories(newOrder);
      if (response.success) {
        reorderCategories(newOrder);
        toast.success('تم تحديث ترتيب الأقسام');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    }
  };

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file size (max 2MB)
    if (file.size > 2 * 1024 * 1024) {
      toast.error('حجم الملف يجب أن يكون أقل من 2 ميجابايت');
      return;
    }

    // Validate file type
    if (!file.type.startsWith('image/')) {
      toast.error('يرجى اختيار ملف صورة صحيح');
      return;
    }

    try {
      setIsUploading(true);
      const response = await uploadApi.uploadImage(file, 'category');
      if (response.success && response.data) {
        setCategoryForm((prev) => ({ ...prev, image: response.data!.url }));
        toast.success('تم رفع الصورة بنجاح');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsUploading(false);
      e.target.value = '';
    }
  };

  // Stats
  const activeCategories = categories.filter((c) => c.isActive).length;
  const totalItems = categories.reduce((sum, c) => sum + (c.itemCount || 0), 0);

  if (isLoading && categories.length === 0) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <Skeleton className="h-8 w-48" />
          <Skeleton className="h-10 w-32" />
        </div>
        <div className="grid gap-4 md:grid-cols-3">
          {[1, 2, 3].map((i) => (
            <Skeleton key={i} className="h-24" />
          ))}
        </div>
        <Skeleton className="h-96" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold">إدارة الأقسام</h1>
          <p className="text-muted-foreground">
            تنظيم أقسام قائمة الطعام الخاصة بمطعمك
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={fetchCategories}>
            <RefreshCw className="h-4 w-4 ml-2" />
            تحديث
          </Button>
          <Button onClick={() => handleOpenCategoryDialog()}>
            <Plus className="h-4 w-4 ml-2" />
            قسم جديد
          </Button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">إجمالي الأقسام</CardTitle>
            <FolderOpen className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{categories.length}</div>
            <p className="text-xs text-muted-foreground">
              {activeCategories} قسم نشط
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">إجمالي الأصناف</CardTitle>
            <UtensilsCrossed className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{totalItems}</div>
            <p className="text-xs text-muted-foreground">
              صنف في جميع الأقسام
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">الأقسام المخفية</CardTitle>
            <EyeOff className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{categories.length - activeCategories}</div>
            <p className="text-xs text-muted-foreground">
              قسم غير نشط
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Search */}
      <div className="flex items-center gap-4">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="البحث في الأقسام..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pr-10"
          />
        </div>
      </div>

      {/* Categories Table */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <FolderOpen className="h-5 w-5" />
            قائمة الأقسام ({filteredCategories.length})
          </CardTitle>
          <CardDescription>
            اسحب الأقسام لإعادة ترتيبها أو استخدم أزرار السهم
          </CardDescription>
        </CardHeader>
        <CardContent>
          {filteredCategories.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <FolderOpen className="h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="font-semibold text-lg">
                {searchQuery ? 'لا توجد نتائج' : 'لا توجد أقسام'}
              </h3>
              <p className="text-muted-foreground mb-4">
                {searchQuery
                  ? 'جرب البحث بكلمات مختلفة'
                  : 'ابدأ بإنشاء أقسام لتنظيم قائمة طعامك'}
              </p>
              {!searchQuery && (
                <Button onClick={() => handleOpenCategoryDialog()}>
                  <Plus className="h-4 w-4 ml-2" />
                  إضافة قسم
                </Button>
              )}
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-12">الترتيب</TableHead>
                  <TableHead>القسم</TableHead>
                  <TableHead>الوصف</TableHead>
                  <TableHead className="text-center">عدد الأصناف</TableHead>
                  <TableHead className="text-center">الحالة</TableHead>
                  <TableHead className="text-center">تاريخ الإنشاء</TableHead>
                  <TableHead className="w-12"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredCategories
                  .sort((a, b) => a.sortOrder - b.sortOrder)
                  .map((category, index) => (
                    <TableRow key={category._id}>
                      <TableCell>
                        <div className="flex items-center gap-1">
                          <GripVertical className="h-4 w-4 cursor-grab text-muted-foreground" />
                          <div className="flex flex-col gap-1">
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-6 w-6"
                              onClick={() => handleMoveCategory(category._id, 'up')}
                              disabled={index === 0}
                            >
                              <ArrowUp className="h-3 w-3" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-6 w-6"
                              onClick={() => handleMoveCategory(category._id, 'down')}
                              disabled={index === filteredCategories.length - 1}
                            >
                              <ArrowDown className="h-3 w-3" />
                            </Button>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-3">
                          {category.image ? (
                            <img
                              src={category.image}
                              alt={category.nameAr}
                              className="h-10 w-10 rounded-md object-cover"
                            />
                          ) : (
                            <div className="flex h-10 w-10 items-center justify-center rounded-md bg-muted">
                              <FolderOpen className="h-5 w-5 text-muted-foreground" />
                            </div>
                          )}
                          <div>
                            <div className="font-medium">{category.nameAr}</div>
                            <div className="text-xs text-muted-foreground">{category.name}</div>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <p className="text-sm text-muted-foreground line-clamp-2 max-w-xs">
                          {category.descriptionAr || category.description || '-'}
                        </p>
                      </TableCell>
                      <TableCell className="text-center">
                        <Badge variant="secondary">{category.itemCount || 0}</Badge>
                      </TableCell>
                      <TableCell className="text-center">
                        <Switch
                          checked={category.isActive}
                          onCheckedChange={() => handleToggleActive(category)}
                        />
                      </TableCell>
                      <TableCell className="text-center text-sm text-muted-foreground">
                        {format(new Date(category.createdAt), 'd MMM yyyy', { locale: ar })}
                      </TableCell>
                      <TableCell>
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" size="icon">
                              <MoreVertical className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuItem onClick={() => handleOpenCategoryDialog(category._id)}>
                              <Pencil className="h-4 w-4 ml-2" />
                              تعديل
                            </DropdownMenuItem>
                            <DropdownMenuItem onClick={() => handleToggleActive(category)}>
                              {category.isActive ? (
                                <>
                                  <EyeOff className="h-4 w-4 ml-2" />
                                  إخفاء
                                </>
                              ) : (
                                <>
                                  <Eye className="h-4 w-4 ml-2" />
                                  تفعيل
                                </>
                              )}
                            </DropdownMenuItem>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem
                              className="text-destructive"
                              onClick={() => setDeleteConfirm(category._id)}
                            >
                              <Trash2 className="h-4 w-4 ml-2" />
                              حذف
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </TableCell>
                    </TableRow>
                  ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      {/* Category Dialog */}
      <Dialog open={showCategoryDialog} onOpenChange={setShowCategoryDialog}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>
              {editingCategory ? 'تعديل القسم' : 'إضافة قسم جديد'}
            </DialogTitle>
            <DialogDescription>
              {editingCategory
                ? 'قم بتعديل بيانات القسم'
                : 'أضف قسم جديد لتنظيم أصناف قائمة الطعام'}
            </DialogDescription>
          </DialogHeader>

          <div className="grid gap-4 py-4">
            {/* Image Upload */}
            <div className="space-y-2">
              <Label>صورة القسم (اختياري)</Label>
              <div className="flex items-center gap-4">
                <div className="relative h-20 w-20 rounded-lg border-2 border-dashed overflow-hidden bg-muted">
                  {categoryForm.image ? (
                    <img
                      src={categoryForm.image}
                      alt="صورة القسم"
                      className="h-full w-full object-cover"
                    />
                  ) : (
                    <div className="flex h-full w-full items-center justify-center">
                      <ImageIcon className="h-6 w-6 text-muted-foreground" />
                    </div>
                  )}
                </div>
                <div className="space-y-2">
                  <label className="cursor-pointer">
                    <input
                      type="file"
                      accept="image/*"
                      className="hidden"
                      onChange={handleImageUpload}
                      disabled={isUploading}
                    />
                    <Button variant="outline" size="sm" asChild disabled={isUploading}>
                      <span>
                        {isUploading ? (
                          <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                        ) : (
                          <Upload className="h-4 w-4 ml-2" />
                        )}
                        رفع صورة
                      </span>
                    </Button>
                  </label>
                  {categoryForm.image && (
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setCategoryForm((prev) => ({ ...prev, image: '' }))}
                    >
                      <Trash2 className="h-4 w-4 ml-2" />
                      إزالة
                    </Button>
                  )}
                </div>
              </div>
            </div>

            {/* Name Fields */}
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="nameAr">الاسم بالعربية *</Label>
                <Input
                  id="nameAr"
                  value={categoryForm.nameAr}
                  onChange={(e) =>
                    setCategoryForm((prev) => ({ ...prev, nameAr: e.target.value }))
                  }
                  placeholder="مثال: المقبلات"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="name">الاسم بالإنجليزية *</Label>
                <Input
                  id="name"
                  value={categoryForm.name}
                  onChange={(e) =>
                    setCategoryForm((prev) => ({ ...prev, name: e.target.value }))
                  }
                  placeholder="e.g., Appetizers"
                  dir="ltr"
                />
              </div>
            </div>

            {/* Description Fields */}
            <div className="space-y-2">
              <Label htmlFor="descriptionAr">الوصف بالعربية (اختياري)</Label>
              <Textarea
                id="descriptionAr"
                value={categoryForm.descriptionAr}
                onChange={(e) =>
                  setCategoryForm((prev) => ({ ...prev, descriptionAr: e.target.value }))
                }
                placeholder="وصف مختصر للقسم..."
                rows={2}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="description">الوصف بالإنجليزية (اختياري)</Label>
              <Textarea
                id="description"
                value={categoryForm.description}
                onChange={(e) =>
                  setCategoryForm((prev) => ({ ...prev, description: e.target.value }))
                }
                placeholder="Brief description..."
                rows={2}
                dir="ltr"
              />
            </div>

            {/* Active Toggle */}
            <div className="flex items-center justify-between p-4 border rounded-lg">
              <div>
                <Label htmlFor="isActive">حالة القسم</Label>
                <p className="text-sm text-muted-foreground">
                  القسم النشط يظهر للعملاء في التطبيق
                </p>
              </div>
              <Switch
                id="isActive"
                checked={categoryForm.isActive}
                onCheckedChange={(checked) =>
                  setCategoryForm((prev) => ({ ...prev, isActive: checked }))
                }
              />
            </div>
          </div>

          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setShowCategoryDialog(false);
                setCategoryForm(initialCategoryForm);
                setEditingCategory(null);
              }}
              disabled={isSaving}
            >
              إلغاء
            </Button>
            <Button
              onClick={handleSaveCategory}
              disabled={isSaving || !categoryForm.name.trim() || !categoryForm.nameAr.trim()}
            >
              {isSaving ? (
                <Loader2 className="h-4 w-4 ml-2 animate-spin" />
              ) : null}
              {isSaving ? 'جاري الحفظ...' : editingCategory ? 'حفظ التعديلات' : 'إنشاء القسم'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <AlertDialog open={!!deleteConfirm} onOpenChange={() => setDeleteConfirm(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>تأكيد الحذف</AlertDialogTitle>
            <AlertDialogDescription>
              هل أنت متأكد من حذف هذا القسم؟ سيتم أيضاً إلغاء تخصيص جميع الأصناف المرتبطة به.
              لا يمكن التراجع عن هذا الإجراء.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isSaving}>إلغاء</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleDeleteCategory}
              disabled={isSaving}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              {isSaving ? (
                <Loader2 className="h-4 w-4 ml-2 animate-spin" />
              ) : (
                <Trash2 className="h-4 w-4 ml-2" />
              )}
              {isSaving ? 'جاري الحذف...' : 'حذف'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
