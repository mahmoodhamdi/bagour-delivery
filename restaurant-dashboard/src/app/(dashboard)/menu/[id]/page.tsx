'use client';

import { useEffect, useState, useCallback } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { useMenuStore } from '@/stores/menu';
import { menuApi, uploadApi, getErrorMessage, CreateItemRequest, MenuAddon, MenuVariation } from '@/lib/api';
import { toast } from 'sonner';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  ArrowRight,
  X,
  Plus,
  Trash2,
  Loader2,
  ImageIcon,
} from 'lucide-react';

interface ItemFormData {
  categoryId: string;
  name: string;
  nameAr: string;
  description: string;
  descriptionAr: string;
  image: string;
  price: number;
  discountPrice: number | null;
  preparationTime: number;
  calories: number | null;
  servingSize: string;
  tags: string[];
  isAvailable: boolean;
  isPopular: boolean;
  addons: MenuAddon[];
  variations: MenuVariation[];
}

export default function EditItemPage() {
  const router = useRouter();
  const params = useParams();
  const itemId = params.id as string;

  const { categories, setCategories, updateItem, setLoading } = useMenuStore();
  const [formData, setFormData] = useState<ItemFormData | null>(null);
  const [isLoadingItem, setIsLoadingItem] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const [newTag, setNewTag] = useState('');

  // Fetch categories if not loaded
  const fetchCategories = useCallback(async () => {
    if (categories.length === 0) {
      try {
        const response = await menuApi.getCategories();
        if (response.success && response.data) {
          setCategories(response.data.categories);
        }
      } catch (error) {
        toast.error(getErrorMessage(error));
      }
    }
  }, [categories.length, setCategories]);

  // Fetch item
  const fetchItem = useCallback(async () => {
    try {
      setIsLoadingItem(true);
      const response = await menuApi.getItem(itemId);
      if (response.success && response.data) {
        const item = response.data.item;
        const categoryId = typeof item.categoryId === 'object' ? item.categoryId._id : item.categoryId;
        setFormData({
          categoryId,
          name: item.name,
          nameAr: item.nameAr,
          description: item.description || '',
          descriptionAr: item.descriptionAr || '',
          image: item.image || '',
          price: item.price,
          discountPrice: item.discountPrice || null,
          preparationTime: item.preparationTime || 15,
          calories: item.calories || null,
          servingSize: item.servingSize || '',
          tags: item.tags || [],
          isAvailable: item.isAvailable,
          isPopular: item.isPopular,
          addons: item.addons || [],
          variations: item.variations || [],
        });
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
      router.push('/dashboard/menu');
    } finally {
      setIsLoadingItem(false);
    }
  }, [itemId, router]);

  useEffect(() => {
    fetchCategories();
    fetchItem();
  }, [fetchCategories, fetchItem]);

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !formData) return;

    try {
      setIsUploading(true);
      const response = await uploadApi.uploadImage(file, 'menu-item');
      if (response.success && response.data) {
        setFormData((prev) => prev ? { ...prev, image: response.data!.url } : null);
        toast.success('تم رفع الصورة بنجاح');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsUploading(false);
    }
  };

  const handleAddTag = () => {
    if (!formData) return;
    if (newTag.trim() && !formData.tags.includes(newTag.trim())) {
      setFormData((prev) => prev ? {
        ...prev,
        tags: [...prev.tags, newTag.trim()],
      } : null);
      setNewTag('');
    }
  };

  const handleRemoveTag = (tag: string) => {
    setFormData((prev) => prev ? {
      ...prev,
      tags: prev.tags.filter((t) => t !== tag),
    } : null);
  };

  const handleAddAddon = () => {
    setFormData((prev) => prev ? {
      ...prev,
      addons: [
        ...prev.addons,
        { name: '', nameAr: '', price: 0, isAvailable: true, maxQuantity: 5 },
      ],
    } : null);
  };

  const handleUpdateAddon = (index: number, updates: Partial<MenuAddon>) => {
    setFormData((prev) => prev ? {
      ...prev,
      addons: prev.addons.map((addon, i) =>
        i === index ? { ...addon, ...updates } : addon
      ),
    } : null);
  };

  const handleRemoveAddon = (index: number) => {
    setFormData((prev) => prev ? {
      ...prev,
      addons: prev.addons.filter((_, i) => i !== index),
    } : null);
  };

  const handleAddVariation = () => {
    setFormData((prev) => prev ? {
      ...prev,
      variations: [
        ...prev.variations,
        {
          name: '',
          nameAr: '',
          isRequired: false,
          options: [{ name: '', nameAr: '', price: 0 }],
        },
      ],
    } : null);
  };

  const handleUpdateVariation = (index: number, updates: Partial<MenuVariation>) => {
    setFormData((prev) => prev ? {
      ...prev,
      variations: prev.variations.map((variation, i) =>
        i === index ? { ...variation, ...updates } : variation
      ),
    } : null);
  };

  const handleRemoveVariation = (index: number) => {
    setFormData((prev) => prev ? {
      ...prev,
      variations: prev.variations.filter((_, i) => i !== index),
    } : null);
  };

  const handleAddVariationOption = (variationIndex: number) => {
    setFormData((prev) => prev ? {
      ...prev,
      variations: prev.variations.map((variation, i) =>
        i === variationIndex
          ? {
              ...variation,
              options: [...variation.options, { name: '', nameAr: '', price: 0 }],
            }
          : variation
      ),
    } : null);
  };

  const handleUpdateVariationOption = (
    variationIndex: number,
    optionIndex: number,
    updates: Partial<{ name: string; nameAr: string; price: number }>
  ) => {
    setFormData((prev) => prev ? {
      ...prev,
      variations: prev.variations.map((variation, vi) =>
        vi === variationIndex
          ? {
              ...variation,
              options: variation.options.map((option, oi) =>
                oi === optionIndex ? { ...option, ...updates } : option
              ),
            }
          : variation
      ),
    } : null);
  };

  const handleRemoveVariationOption = (variationIndex: number, optionIndex: number) => {
    setFormData((prev) => prev ? {
      ...prev,
      variations: prev.variations.map((variation, vi) =>
        vi === variationIndex
          ? {
              ...variation,
              options: variation.options.filter((_, oi) => oi !== optionIndex),
            }
          : variation
      ),
    } : null);
  };

  const handleSubmit = async () => {
    if (!formData) return;

    // Validation
    if (!formData.categoryId) {
      toast.error('يرجى اختيار القسم');
      return;
    }
    if (!formData.nameAr.trim()) {
      toast.error('يرجى إدخال اسم الصنف بالعربية');
      return;
    }
    if (!formData.name.trim()) {
      toast.error('يرجى إدخال اسم الصنف بالإنجليزية');
      return;
    }
    if (formData.price <= 0) {
      toast.error('يرجى إدخال سعر صحيح');
      return;
    }

    try {
      setIsSaving(true);

      const data: Partial<CreateItemRequest> = {
        categoryId: formData.categoryId,
        name: formData.name,
        nameAr: formData.nameAr,
        description: formData.description || undefined,
        descriptionAr: formData.descriptionAr || undefined,
        image: formData.image || undefined,
        price: formData.price,
        discountPrice: formData.discountPrice || undefined,
        preparationTime: formData.preparationTime || undefined,
        calories: formData.calories || undefined,
        servingSize: formData.servingSize || undefined,
        tags: formData.tags.length > 0 ? formData.tags : undefined,
        isAvailable: formData.isAvailable,
        isPopular: formData.isPopular,
        addons: formData.addons.filter((a) => a.name && a.nameAr),
        variations: formData.variations.filter(
          (v) => v.name && v.nameAr && v.options.length > 0
        ),
      };

      const response = await menuApi.updateItem(itemId, data);
      if (response.success && response.data) {
        updateItem(itemId, response.data.item);
        toast.success('تم تحديث الصنف بنجاح');
        router.push('/dashboard/menu');
      }
    } catch (error) {
      toast.error(getErrorMessage(error));
    } finally {
      setIsSaving(false);
    }
  };

  if (isLoadingItem || !formData) {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <Skeleton className="h-10 w-10 rounded-md" />
          <div>
            <Skeleton className="h-8 w-48" />
            <Skeleton className="h-4 w-64 mt-2" />
          </div>
        </div>
        <div className="grid gap-6 lg:grid-cols-3">
          <div className="lg:col-span-2 space-y-6">
            <Skeleton className="h-80" />
            <Skeleton className="h-40" />
          </div>
          <div className="space-y-6">
            <Skeleton className="h-64" />
            <Skeleton className="h-48" />
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" onClick={() => router.back()}>
          <ArrowRight className="h-5 w-5" />
        </Button>
        <div>
          <h1 className="text-2xl font-bold">تعديل الصنف</h1>
          <p className="text-muted-foreground">تعديل بيانات {formData.nameAr}</p>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        {/* Main Form */}
        <div className="lg:col-span-2 space-y-6">
          {/* Basic Info */}
          <Card>
            <CardHeader>
              <CardTitle>المعلومات الأساسية</CardTitle>
              <CardDescription>أدخل بيانات الصنف الأساسية</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="category">القسم *</Label>
                <Select
                  value={formData.categoryId}
                  onValueChange={(value) =>
                    setFormData((prev) => prev ? { ...prev, categoryId: value } : null)
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="اختر القسم" />
                  </SelectTrigger>
                  <SelectContent>
                    {categories.map((category) => (
                      <SelectItem key={category._id} value={category._id}>
                        {category.nameAr}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="nameAr">الاسم بالعربية *</Label>
                  <Input
                    id="nameAr"
                    value={formData.nameAr}
                    onChange={(e) =>
                      setFormData((prev) => prev ? { ...prev, nameAr: e.target.value } : null)
                    }
                    placeholder="مثال: برجر لحم"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="name">الاسم بالإنجليزية *</Label>
                  <Input
                    id="name"
                    value={formData.name}
                    onChange={(e) =>
                      setFormData((prev) => prev ? { ...prev, name: e.target.value } : null)
                    }
                    placeholder="e.g., Beef Burger"
                    dir="ltr"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="descriptionAr">الوصف بالعربية</Label>
                <Textarea
                  id="descriptionAr"
                  value={formData.descriptionAr}
                  onChange={(e) =>
                    setFormData((prev) => prev ? { ...prev, descriptionAr: e.target.value } : null)
                  }
                  placeholder="وصف مختصر للصنف..."
                  rows={3}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="description">الوصف بالإنجليزية</Label>
                <Textarea
                  id="description"
                  value={formData.description}
                  onChange={(e) =>
                    setFormData((prev) => prev ? { ...prev, description: e.target.value } : null)
                  }
                  placeholder="Brief description..."
                  rows={3}
                  dir="ltr"
                />
              </div>
            </CardContent>
          </Card>

          {/* Pricing */}
          <Card>
            <CardHeader>
              <CardTitle>التسعير</CardTitle>
              <CardDescription>حدد سعر الصنف والخصومات</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="price">السعر (ج.م) *</Label>
                  <Input
                    id="price"
                    type="number"
                    min="0"
                    step="0.5"
                    value={formData.price}
                    onChange={(e) =>
                      setFormData((prev) => prev ? {
                        ...prev,
                        price: parseFloat(e.target.value) || 0,
                      } : null)
                    }
                    placeholder="0.00"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="discountPrice">سعر الخصم (ج.م)</Label>
                  <Input
                    id="discountPrice"
                    type="number"
                    min="0"
                    step="0.5"
                    value={formData.discountPrice || ''}
                    onChange={(e) =>
                      setFormData((prev) => prev ? {
                        ...prev,
                        discountPrice: e.target.value ? parseFloat(e.target.value) : null,
                      } : null)
                    }
                    placeholder="اختياري"
                  />
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Addons */}
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle>الإضافات</CardTitle>
                  <CardDescription>إضافات يمكن للعميل اختيارها</CardDescription>
                </div>
                <Button variant="outline" size="sm" onClick={handleAddAddon}>
                  <Plus className="h-4 w-4 ml-2" />
                  إضافة
                </Button>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              {formData.addons.length === 0 ? (
                <p className="text-center text-muted-foreground py-4">
                  لا توجد إضافات
                </p>
              ) : (
                formData.addons.map((addon, index) => (
                  <div
                    key={index}
                    className="grid gap-4 p-4 border rounded-lg relative"
                  >
                    <Button
                      variant="ghost"
                      size="icon"
                      className="absolute top-2 left-2 h-8 w-8"
                      onClick={() => handleRemoveAddon(index)}
                    >
                      <Trash2 className="h-4 w-4 text-destructive" />
                    </Button>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label>الاسم بالعربية</Label>
                        <Input
                          value={addon.nameAr}
                          onChange={(e) =>
                            handleUpdateAddon(index, { nameAr: e.target.value })
                          }
                        />
                      </div>
                      <div className="space-y-2">
                        <Label>الاسم بالإنجليزية</Label>
                        <Input
                          value={addon.name}
                          onChange={(e) =>
                            handleUpdateAddon(index, { name: e.target.value })
                          }
                          dir="ltr"
                        />
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label>السعر (ج.م)</Label>
                        <Input
                          type="number"
                          min="0"
                          value={addon.price}
                          onChange={(e) =>
                            handleUpdateAddon(index, {
                              price: parseFloat(e.target.value) || 0,
                            })
                          }
                        />
                      </div>
                      <div className="space-y-2">
                        <Label>الحد الأقصى</Label>
                        <Input
                          type="number"
                          min="1"
                          max="10"
                          value={addon.maxQuantity}
                          onChange={(e) =>
                            handleUpdateAddon(index, {
                              maxQuantity: parseInt(e.target.value) || 1,
                            })
                          }
                        />
                      </div>
                    </div>
                  </div>
                ))
              )}
            </CardContent>
          </Card>

          {/* Variations */}
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle>الاختيارات</CardTitle>
                  <CardDescription>اختيارات مثل الحجم أو النوع</CardDescription>
                </div>
                <Button variant="outline" size="sm" onClick={handleAddVariation}>
                  <Plus className="h-4 w-4 ml-2" />
                  إضافة
                </Button>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              {formData.variations.length === 0 ? (
                <p className="text-center text-muted-foreground py-4">
                  لا توجد اختيارات
                </p>
              ) : (
                formData.variations.map((variation, varIndex) => (
                  <div
                    key={varIndex}
                    className="p-4 border rounded-lg relative space-y-4"
                  >
                    <Button
                      variant="ghost"
                      size="icon"
                      className="absolute top-2 left-2 h-8 w-8"
                      onClick={() => handleRemoveVariation(varIndex)}
                    >
                      <Trash2 className="h-4 w-4 text-destructive" />
                    </Button>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label>الاسم بالعربية</Label>
                        <Input
                          value={variation.nameAr}
                          onChange={(e) =>
                            handleUpdateVariation(varIndex, { nameAr: e.target.value })
                          }
                        />
                      </div>
                      <div className="space-y-2">
                        <Label>الاسم بالإنجليزية</Label>
                        <Input
                          value={variation.name}
                          onChange={(e) =>
                            handleUpdateVariation(varIndex, { name: e.target.value })
                          }
                          dir="ltr"
                        />
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Switch
                        checked={variation.isRequired}
                        onCheckedChange={(checked) =>
                          handleUpdateVariation(varIndex, { isRequired: checked })
                        }
                      />
                      <Label>اختيار إجباري</Label>
                    </div>
                    <Separator />
                    <div className="space-y-2">
                      <div className="flex items-center justify-between">
                        <Label>الخيارات</Label>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleAddVariationOption(varIndex)}
                        >
                          <Plus className="h-4 w-4 ml-1" />
                          خيار
                        </Button>
                      </div>
                      {variation.options.map((option, optIndex) => (
                        <div key={optIndex} className="grid grid-cols-5 gap-2 items-end">
                          <div className="col-span-2">
                            <Input
                              value={option.nameAr}
                              onChange={(e) =>
                                handleUpdateVariationOption(varIndex, optIndex, {
                                  nameAr: e.target.value,
                                })
                              }
                            />
                          </div>
                          <div className="col-span-2">
                            <Input
                              value={option.name}
                              onChange={(e) =>
                                handleUpdateVariationOption(varIndex, optIndex, {
                                  name: e.target.value,
                                })
                              }
                              dir="ltr"
                            />
                          </div>
                          <div className="flex gap-1">
                            <Input
                              type="number"
                              min="0"
                              value={option.price}
                              onChange={(e) =>
                                handleUpdateVariationOption(varIndex, optIndex, {
                                  price: parseFloat(e.target.value) || 0,
                                })
                              }
                            />
                            {variation.options.length > 1 && (
                              <Button
                                variant="ghost"
                                size="icon"
                                className="shrink-0"
                                onClick={() =>
                                  handleRemoveVariationOption(varIndex, optIndex)
                                }
                              >
                                <X className="h-4 w-4" />
                              </Button>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                ))
              )}
            </CardContent>
          </Card>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Image */}
          <Card>
            <CardHeader>
              <CardTitle>صورة الصنف</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {formData.image ? (
                  <div className="relative aspect-square rounded-lg overflow-hidden">
                    <img
                      src={formData.image}
                      alt="صورة الصنف"
                      className="w-full h-full object-cover"
                    />
                    <Button
                      variant="destructive"
                      size="icon"
                      className="absolute top-2 right-2"
                      onClick={() => setFormData((prev) => prev ? { ...prev, image: '' } : null)}
                    >
                      <X className="h-4 w-4" />
                    </Button>
                  </div>
                ) : (
                  <label className="flex flex-col items-center justify-center aspect-square border-2 border-dashed rounded-lg cursor-pointer hover:bg-muted/50 transition-colors">
                    <input
                      type="file"
                      accept="image/*"
                      className="hidden"
                      onChange={handleImageUpload}
                      disabled={isUploading}
                    />
                    {isUploading ? (
                      <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
                    ) : (
                      <>
                        <ImageIcon className="h-8 w-8 text-muted-foreground mb-2" />
                        <span className="text-sm text-muted-foreground">
                          اضغط لرفع صورة
                        </span>
                      </>
                    )}
                  </label>
                )}
              </div>
            </CardContent>
          </Card>

          {/* Additional Info */}
          <Card>
            <CardHeader>
              <CardTitle>معلومات إضافية</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="preparationTime">وقت التحضير (دقيقة)</Label>
                <Input
                  id="preparationTime"
                  type="number"
                  min="0"
                  value={formData.preparationTime}
                  onChange={(e) =>
                    setFormData((prev) => prev ? {
                      ...prev,
                      preparationTime: parseInt(e.target.value) || 0,
                    } : null)
                  }
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="calories">السعرات الحرارية</Label>
                <Input
                  id="calories"
                  type="number"
                  min="0"
                  value={formData.calories || ''}
                  onChange={(e) =>
                    setFormData((prev) => prev ? {
                      ...prev,
                      calories: e.target.value ? parseInt(e.target.value) : null,
                    } : null)
                  }
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="servingSize">حجم الوجبة</Label>
                <Input
                  id="servingSize"
                  value={formData.servingSize}
                  onChange={(e) =>
                    setFormData((prev) => prev ? { ...prev, servingSize: e.target.value } : null)
                  }
                />
              </div>
            </CardContent>
          </Card>

          {/* Tags */}
          <Card>
            <CardHeader>
              <CardTitle>الوسوم</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex gap-2">
                <Input
                  value={newTag}
                  onChange={(e) => setNewTag(e.target.value)}
                  placeholder="أضف وسم..."
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault();
                      handleAddTag();
                    }
                  }}
                />
                <Button variant="outline" onClick={handleAddTag}>
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
              {formData.tags.length > 0 && (
                <div className="flex flex-wrap gap-2">
                  {formData.tags.map((tag) => (
                    <Badge key={tag} variant="secondary" className="gap-1">
                      {tag}
                      <button
                        type="button"
                        onClick={() => handleRemoveTag(tag)}
                        className="hover:text-destructive"
                      >
                        <X className="h-3 w-3" />
                      </button>
                    </Badge>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Status */}
          <Card>
            <CardHeader>
              <CardTitle>الحالة</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <Label htmlFor="isAvailable">متاح للطلب</Label>
                <Switch
                  id="isAvailable"
                  checked={formData.isAvailable}
                  onCheckedChange={(checked) =>
                    setFormData((prev) => prev ? { ...prev, isAvailable: checked } : null)
                  }
                />
              </div>
              <div className="flex items-center justify-between">
                <Label htmlFor="isPopular">صنف مميز</Label>
                <Switch
                  id="isPopular"
                  checked={formData.isPopular}
                  onCheckedChange={(checked) =>
                    setFormData((prev) => prev ? { ...prev, isPopular: checked } : null)
                  }
                />
              </div>
            </CardContent>
          </Card>

          {/* Actions */}
          <div className="flex gap-2">
            <Button
              variant="outline"
              className="flex-1"
              onClick={() => router.back()}
              disabled={isSaving}
            >
              إلغاء
            </Button>
            <Button
              className="flex-1"
              onClick={handleSubmit}
              disabled={isSaving}
            >
              {isSaving ? (
                <>
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                  جاري الحفظ...
                </>
              ) : (
                'حفظ التعديلات'
              )}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
