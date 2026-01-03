'use client';

import { useEffect, useState, useCallback } from 'react';
import { useMenuStore } from '@/stores/menu';
import { menuApi, getErrorMessage } from '@/lib/api';
import { toast } from 'sonner';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Switch } from '@/components/ui/switch';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
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
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Plus,
  Search,
  MoreVertical,
  Pencil,
  Trash2,
  Copy,
  FolderOpen,
  UtensilsCrossed,
  GripVertical,
} from 'lucide-react';

interface CategoryFormData {
  name: string;
  nameAr: string;
  description: string;
  descriptionAr: string;
  isActive: boolean;
}

const initialCategoryForm: CategoryFormData = {
  name: '',
  nameAr: '',
  description: '',
  descriptionAr: '',
  isActive: true,
};

export default function MenuPage() {
  const {
    categories,
    items,
    isLoading,
    isSaving,
    filterCategoryId,
    searchQuery,
    setCategories,
    setItems,
    addCategory,
    updateCategory,
    removeCategory,
    addItem,
    updateItem,
    removeItem,
    toggleItemAvailability,
    setFilterCategoryId,
    setSearchQuery,
    setLoading,
    setSaving,
  } = useMenuStore();

  const [showCategoryDialog, setShowCategoryDialog] = useState(false);
  const [editingCategory, setEditingCategory] = useState<string | null>(null);
  const [categoryForm, setCategoryForm] = useState<CategoryFormData>(initialCategoryForm);
  const [deleteConfirm, setDeleteConfirm] = useState<{ type: 'category' | 'item'; id: string } | null>(null);

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

  // Fetch items
  const fetchItems = useCallback(async () => {
    try {
      const params: Record<string, unknown> = {};
      if (filterCategoryId) params.categoryId = filterCategoryId;
      if (searchQuery) params.search = searchQuery;

      const response = await menuApi.getItems(params);
      if (response.success && response.data) {
        setItems(response.data.items, response.data.pagination);
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    }
  }, [filterCategoryId, searchQuery, setItems]);

  useEffect(() => {
    fetchCategories();
  }, [fetchCategories]);

  useEffect(() => {
    fetchItems();
  }, [fetchItems]);

  // Category handlers
  const handleOpenCategoryDialog = (categoryId?: string) => {
    if (categoryId) {
      const category = categories.find((c) => c._id === categoryId);
      if (category) {
        setCategoryForm({
          name: category.name,
          nameAr: category.nameAr,
          description: category.description || '',
          descriptionAr: category.descriptionAr || '',
          isActive: category.isActive,
        });
        setEditingCategory(categoryId);
      }
    } else {
      setCategoryForm(initialCategoryForm);
      setEditingCategory(null);
    }
    setShowCategoryDialog(true);
  };

  const handleSaveCategory = async () => {
    try {
      setSaving(true);

      if (editingCategory) {
        const response = await menuApi.updateCategory(editingCategory, categoryForm);
        if (response.success && response.data) {
          updateCategory(editingCategory, response.data.category);
          toast.success('تم تحديث القسم بنجاح');
        }
      } else {
        const response = await menuApi.createCategory(categoryForm);
        if (response.success && response.data) {
          addCategory(response.data.category);
          toast.success('تم إنشاء القسم بنجاح');
        }
      }

      setShowCategoryDialog(false);
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteCategory = async () => {
    if (!deleteConfirm || deleteConfirm.type !== 'category') return;

    try {
      setSaving(true);
      const response = await menuApi.deleteCategory(deleteConfirm.id);
      if (response.success) {
        removeCategory(deleteConfirm.id);
        toast.success('تم حذف القسم بنجاح');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setSaving(false);
      setDeleteConfirm(null);
    }
  };

  // Item handlers
  const handleToggleAvailability = async (itemId: string, currentValue: boolean) => {
    try {
      const newValue = !currentValue;
      toggleItemAvailability(itemId, newValue);

      const response = await menuApi.toggleItemAvailability(itemId, newValue);
      if (!response.success) {
        toggleItemAvailability(itemId, currentValue);
        toast.error('فشل في تحديث حالة الصنف');
      }
    } catch (error) {
      toggleItemAvailability(itemId, currentValue);
      toast.error(getErrorMessage(error));
    }
  };

  const handleDuplicateItem = async (itemId: string) => {
    try {
      setSaving(true);
      const response = await menuApi.duplicateItem(itemId);
      if (response.success && response.data) {
        addItem(response.data.item);
        toast.success('تم نسخ الصنف بنجاح');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteItem = async () => {
    if (!deleteConfirm || deleteConfirm.type !== 'item') return;

    try {
      setSaving(true);
      const response = await menuApi.deleteItem(deleteConfirm.id);
      if (response.success) {
        removeItem(deleteConfirm.id);
        toast.success('تم حذف الصنف بنجاح');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setSaving(false);
      setDeleteConfirm(null);
    }
  };

  const getCategoryName = (categoryId: string | { _id: string; name: string; nameAr: string }) => {
    if (typeof categoryId === 'object') {
      return categoryId.nameAr;
    }
    const category = categories.find((c) => c._id === categoryId);
    return category?.nameAr || '-';
  };

  if (isLoading && categories.length === 0) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <Skeleton className="h-8 w-48" />
          <Skeleton className="h-10 w-32" />
        </div>
        <div className="grid gap-4 md:grid-cols-4">
          {[...Array(4)].map((_, i) => (
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
          <h1 className="text-2xl font-bold">إدارة القائمة</h1>
          <p className="text-muted-foreground">
            إدارة أقسام وأصناف قائمة الطعام
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => handleOpenCategoryDialog()}>
            <FolderOpen className="h-4 w-4 ml-2" />
            قسم جديد
          </Button>
          <Button onClick={() => window.location.href = '/dashboard/menu/new'}>
            <Plus className="h-4 w-4 ml-2" />
            صنف جديد
          </Button>
        </div>
      </div>

      {/* Categories */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card
          className={`cursor-pointer transition-colors hover:border-primary ${
            !filterCategoryId ? 'border-primary bg-primary/5' : ''
          }`}
          onClick={() => setFilterCategoryId(null)}
        >
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">جميع الأقسام</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{items.length}</div>
            <p className="text-xs text-muted-foreground">صنف</p>
          </CardContent>
        </Card>

        {categories.map((category) => (
          <Card
            key={category._id}
            className={`cursor-pointer transition-colors hover:border-primary ${
              filterCategoryId === category._id ? 'border-primary bg-primary/5' : ''
            }`}
          >
            <CardHeader className="pb-2">
              <div className="flex items-center justify-between">
                <CardTitle className="text-sm font-medium truncate">
                  {category.nameAr}
                </CardTitle>
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="ghost" size="icon" className="h-8 w-8">
                      <MoreVertical className="h-4 w-4" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    <DropdownMenuItem onClick={() => handleOpenCategoryDialog(category._id)}>
                      <Pencil className="h-4 w-4 ml-2" />
                      تعديل
                    </DropdownMenuItem>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem
                      className="text-destructive"
                      onClick={() => setDeleteConfirm({ type: 'category', id: category._id })}
                    >
                      <Trash2 className="h-4 w-4 ml-2" />
                      حذف
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>
            </CardHeader>
            <CardContent onClick={() => setFilterCategoryId(category._id)}>
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-2xl font-bold">{category.itemCount || 0}</div>
                  <p className="text-xs text-muted-foreground">صنف</p>
                </div>
                <Badge variant={category.isActive ? 'default' : 'secondary'}>
                  {category.isActive ? 'نشط' : 'غير نشط'}
                </Badge>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Items Filter & Search */}
      <div className="flex flex-col gap-4 sm:flex-row">
        <div className="relative flex-1">
          <Search className="absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="البحث في الأصناف..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pr-10"
          />
        </div>
        <Select
          value={filterCategoryId || 'all'}
          onValueChange={(value) => setFilterCategoryId(value === 'all' ? null : value)}
        >
          <SelectTrigger className="w-full sm:w-[200px]">
            <SelectValue placeholder="جميع الأقسام" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">جميع الأقسام</SelectItem>
            {categories.map((category) => (
              <SelectItem key={category._id} value={category._id}>
                {category.nameAr}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Items Table */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <UtensilsCrossed className="h-5 w-5" />
            الأصناف ({items.length})
          </CardTitle>
        </CardHeader>
        <CardContent>
          {items.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <UtensilsCrossed className="h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="font-semibold text-lg">لا توجد أصناف</h3>
              <p className="text-muted-foreground mb-4">
                ابدأ بإضافة أصناف جديدة لقائمة طعامك
              </p>
              <Button onClick={() => window.location.href = '/dashboard/menu/new'}>
                <Plus className="h-4 w-4 ml-2" />
                إضافة صنف
              </Button>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-12">
                    <GripVertical className="h-4 w-4" />
                  </TableHead>
                  <TableHead>الصنف</TableHead>
                  <TableHead>القسم</TableHead>
                  <TableHead>السعر</TableHead>
                  <TableHead>متاح</TableHead>
                  <TableHead className="w-12"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {items.map((item) => (
                  <TableRow key={item._id}>
                    <TableCell>
                      <GripVertical className="h-4 w-4 cursor-grab text-muted-foreground" />
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        {item.image ? (
                          <img
                            src={item.image}
                            alt={item.nameAr}
                            className="h-10 w-10 rounded-md object-cover"
                          />
                        ) : (
                          <div className="flex h-10 w-10 items-center justify-center rounded-md bg-muted">
                            <UtensilsCrossed className="h-5 w-5 text-muted-foreground" />
                          </div>
                        )}
                        <div>
                          <div className="font-medium">{item.nameAr}</div>
                          <div className="text-xs text-muted-foreground">{item.name}</div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>{getCategoryName(item.categoryId)}</TableCell>
                    <TableCell>
                      <div className="flex flex-col">
                        <span className={item.discountPrice ? 'line-through text-muted-foreground text-xs' : ''}>
                          {item.price} ج.م
                        </span>
                        {item.discountPrice && (
                          <span className="text-green-600 font-medium">
                            {item.discountPrice} ج.م
                          </span>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <Switch
                        checked={item.isAvailable}
                        onCheckedChange={() => handleToggleAvailability(item._id, item.isAvailable)}
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
                            onClick={() => window.location.href = `/dashboard/menu/${item._id}`}
                          >
                            <Pencil className="h-4 w-4 ml-2" />
                            تعديل
                          </DropdownMenuItem>
                          <DropdownMenuItem onClick={() => handleDuplicateItem(item._id)}>
                            <Copy className="h-4 w-4 ml-2" />
                            نسخ
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem
                            className="text-destructive"
                            onClick={() => setDeleteConfirm({ type: 'item', id: item._id })}
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
        <DialogContent>
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
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="nameAr">الاسم بالعربية</Label>
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
                <Label htmlFor="name">الاسم بالإنجليزية</Label>
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

            <div className="flex items-center gap-2">
              <Switch
                id="isActive"
                checked={categoryForm.isActive}
                onCheckedChange={(checked) =>
                  setCategoryForm((prev) => ({ ...prev, isActive: checked }))
                }
              />
              <Label htmlFor="isActive">القسم نشط</Label>
            </div>
          </div>

          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setShowCategoryDialog(false)}
              disabled={isSaving}
            >
              إلغاء
            </Button>
            <Button onClick={handleSaveCategory} disabled={isSaving || !categoryForm.name || !categoryForm.nameAr}>
              {isSaving ? 'جاري الحفظ...' : editingCategory ? 'حفظ التعديلات' : 'إنشاء القسم'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={!!deleteConfirm} onOpenChange={() => setDeleteConfirm(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>تأكيد الحذف</DialogTitle>
            <DialogDescription>
              {deleteConfirm?.type === 'category'
                ? 'هل أنت متأكد من حذف هذا القسم؟ لا يمكن التراجع عن هذا الإجراء.'
                : 'هل أنت متأكد من حذف هذا الصنف؟ لا يمكن التراجع عن هذا الإجراء.'}
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setDeleteConfirm(null)}
              disabled={isSaving}
            >
              إلغاء
            </Button>
            <Button
              variant="destructive"
              onClick={deleteConfirm?.type === 'category' ? handleDeleteCategory : handleDeleteItem}
              disabled={isSaving}
            >
              {isSaving ? 'جاري الحذف...' : 'حذف'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
