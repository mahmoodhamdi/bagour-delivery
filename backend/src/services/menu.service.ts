import { Types } from 'mongoose';
import { MenuCategory, IMenuCategory } from '../models/MenuCategory';
import { MenuItem, IMenuItem } from '../models/MenuItem';
import { Restaurant } from '../models/Restaurant';
import { AppError } from '../utils/errors';
import { StatusCodes } from 'http-status-codes';

// Types
interface CreateCategoryData {
  restaurantId: string;
  name: string;
  nameAr: string;
  description?: string;
  descriptionAr?: string;
  image?: string;
  sortOrder?: number;
  isActive?: boolean;
}

interface UpdateCategoryData {
  name?: string;
  nameAr?: string;
  description?: string;
  descriptionAr?: string;
  image?: string;
  sortOrder?: number;
  isActive?: boolean;
}

interface CreateItemData {
  restaurantId: string;
  categoryId: string;
  name: string;
  nameAr: string;
  description?: string;
  descriptionAr?: string;
  image?: string;
  price: number;
  discountPrice?: number;
  discountEndsAt?: Date;
  preparationTime?: number;
  calories?: number;
  servingSize?: string;
  addons?: Array<{
    name: string;
    nameAr: string;
    price: number;
    isAvailable?: boolean;
    maxQuantity?: number;
  }>;
  variations?: Array<{
    name: string;
    nameAr: string;
    isRequired?: boolean;
    options: Array<{
      name: string;
      nameAr: string;
      price: number;
    }>;
  }>;
  isAvailable?: boolean;
  isPopular?: boolean;
  isNew?: boolean;
  tags?: string[];
  sortOrder?: number;
}

interface UpdateItemData {
  categoryId?: string;
  name?: string;
  nameAr?: string;
  description?: string;
  descriptionAr?: string;
  image?: string;
  price?: number;
  discountPrice?: number;
  discountEndsAt?: Date;
  preparationTime?: number;
  calories?: number;
  servingSize?: string;
  addons?: Array<{
    name: string;
    nameAr: string;
    price: number;
    isAvailable?: boolean;
    maxQuantity?: number;
  }>;
  variations?: Array<{
    name: string;
    nameAr: string;
    isRequired?: boolean;
    options: Array<{
      name: string;
      nameAr: string;
      price: number;
    }>;
  }>;
  isAvailable?: boolean;
  isPopular?: boolean;
  isNew?: boolean;
  tags?: string[];
  sortOrder?: number;
}

interface PaginatedResult<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

class MenuService {
  // ==================== Categories ====================

  /**
   * Get restaurant ID from user ID
   */
  private async getRestaurantId(userId: string): Promise<Types.ObjectId> {
    const restaurant = await Restaurant.findOne({ userId }).select('_id');
    if (!restaurant) {
      throw new AppError('المطعم غير موجود', StatusCodes.NOT_FOUND);
    }
    return restaurant._id;
  }

  /**
   * Get all categories for a restaurant
   */
  async getCategories(userId: string): Promise<IMenuCategory[]> {
    const restaurantId = await this.getRestaurantId(userId);
    return MenuCategory.find({ restaurantId }).sort('sortOrder');
  }

  /**
   * Get category by ID
   */
  async getCategoryById(userId: string, categoryId: string): Promise<IMenuCategory | null> {
    const restaurantId = await this.getRestaurantId(userId);
    return MenuCategory.findOne({ _id: categoryId, restaurantId });
  }

  /**
   * Create a new category
   */
  async createCategory(userId: string, data: Omit<CreateCategoryData, 'restaurantId'>): Promise<IMenuCategory> {
    const restaurantId = await this.getRestaurantId(userId);

    // Check for duplicate name
    const existing = await MenuCategory.findOne({
      restaurantId,
      $or: [{ name: data.name }, { nameAr: data.nameAr }],
    });

    if (existing) {
      throw new AppError('قسم بهذا الاسم موجود بالفعل', StatusCodes.CONFLICT);
    }

    // Get max sort order if not provided
    let sortOrder = data.sortOrder;
    if (sortOrder === undefined) {
      const maxCategory = await MenuCategory.findOne({ restaurantId })
        .sort('-sortOrder')
        .select('sortOrder');
      sortOrder = (maxCategory?.sortOrder ?? -1) + 1;
    }

    return MenuCategory.create({
      ...data,
      restaurantId,
      sortOrder,
      isActive: data.isActive ?? true,
    });
  }

  /**
   * Update a category
   */
  async updateCategory(
    userId: string,
    categoryId: string,
    updates: UpdateCategoryData
  ): Promise<IMenuCategory> {
    const restaurantId = await this.getRestaurantId(userId);

    // Check for duplicate name if updating name
    if (updates.name || updates.nameAr) {
      const existing = await MenuCategory.findOne({
        restaurantId,
        _id: { $ne: categoryId },
        $or: [
          ...(updates.name ? [{ name: updates.name }] : []),
          ...(updates.nameAr ? [{ nameAr: updates.nameAr }] : []),
        ],
      });

      if (existing) {
        throw new AppError('قسم بهذا الاسم موجود بالفعل', StatusCodes.CONFLICT);
      }
    }

    const category = await MenuCategory.findOneAndUpdate(
      { _id: categoryId, restaurantId },
      { $set: updates },
      { new: true, runValidators: true }
    );

    if (!category) {
      throw new AppError('القسم غير موجود', StatusCodes.NOT_FOUND);
    }

    return category;
  }

  /**
   * Delete a category
   */
  async deleteCategory(userId: string, categoryId: string): Promise<void> {
    const restaurantId = await this.getRestaurantId(userId);

    // Check if category has items
    const itemsCount = await MenuItem.countDocuments({ categoryId });
    if (itemsCount > 0) {
      throw new AppError(
        `لا يمكن حذف القسم لأنه يحتوي على ${itemsCount} صنف. قم بنقل أو حذف الأصناف أولاً`,
        StatusCodes.BAD_REQUEST
      );
    }

    const result = await MenuCategory.findOneAndDelete({
      _id: categoryId,
      restaurantId,
    });

    if (!result) {
      throw new AppError('القسم غير موجود', StatusCodes.NOT_FOUND);
    }
  }

  /**
   * Reorder categories
   */
  async reorderCategories(
    userId: string,
    categories: Array<{ id: string; sortOrder: number }>
  ): Promise<IMenuCategory[]> {
    const restaurantId = await this.getRestaurantId(userId);

    const bulkOps = categories.map((cat) => ({
      updateOne: {
        filter: { _id: cat.id, restaurantId },
        update: { $set: { sortOrder: cat.sortOrder } },
      },
    }));

    await MenuCategory.bulkWrite(bulkOps);

    return MenuCategory.find({ restaurantId }).sort('sortOrder');
  }

  // ==================== Menu Items ====================

  /**
   * Get all items for a restaurant
   */
  async getItems(
    userId: string,
    options: {
      categoryId?: string;
      isAvailable?: boolean;
      search?: string;
      page?: number;
      limit?: number;
    } = {}
  ): Promise<PaginatedResult<IMenuItem>> {
    const restaurantId = await this.getRestaurantId(userId);
    const { categoryId, isAvailable, search, page = 1, limit = 50 } = options;

    const filter: Record<string, unknown> = { restaurantId };

    if (categoryId) {
      filter.categoryId = categoryId;
    }

    if (isAvailable !== undefined) {
      filter.isAvailable = isAvailable;
    }

    if (search) {
      filter.$text = { $search: search };
    }

    const skip = (page - 1) * limit;

    const [items, total] = await Promise.all([
      MenuItem.find(filter)
        .populate('categoryId', 'name nameAr')
        .sort('categoryId sortOrder')
        .skip(skip)
        .limit(limit),
      MenuItem.countDocuments(filter),
    ]);

    return {
      data: items,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get item by ID
   */
  async getItemById(userId: string, itemId: string): Promise<IMenuItem | null> {
    const restaurantId = await this.getRestaurantId(userId);
    return MenuItem.findOne({ _id: itemId, restaurantId })
      .populate('categoryId', 'name nameAr');
  }

  /**
   * Create a new item
   */
  async createItem(userId: string, data: Omit<CreateItemData, 'restaurantId'>): Promise<IMenuItem> {
    const restaurantId = await this.getRestaurantId(userId);

    // Verify category belongs to this restaurant
    const category = await MenuCategory.findOne({
      _id: data.categoryId,
      restaurantId,
    });

    if (!category) {
      throw new AppError('القسم غير موجود', StatusCodes.NOT_FOUND);
    }

    // Get max sort order if not provided
    let sortOrder = data.sortOrder;
    if (sortOrder === undefined) {
      const maxItem = await MenuItem.findOne({
        restaurantId,
        categoryId: data.categoryId,
      })
        .sort('-sortOrder')
        .select('sortOrder');
      sortOrder = (maxItem?.sortOrder ?? -1) + 1;
    }

    const item = await MenuItem.create({
      ...data,
      restaurantId,
      sortOrder,
      isAvailable: data.isAvailable ?? true,
    });

    return item.populate('categoryId', 'name nameAr');
  }

  /**
   * Update an item
   */
  async updateItem(userId: string, itemId: string, updates: UpdateItemData): Promise<IMenuItem> {
    const restaurantId = await this.getRestaurantId(userId);

    // If changing category, verify it belongs to this restaurant
    if (updates.categoryId) {
      const category = await MenuCategory.findOne({
        _id: updates.categoryId,
        restaurantId,
      });

      if (!category) {
        throw new AppError('القسم غير موجود', StatusCodes.NOT_FOUND);
      }
    }

    const item = await MenuItem.findOneAndUpdate(
      { _id: itemId, restaurantId },
      { $set: updates },
      { new: true, runValidators: true }
    ).populate('categoryId', 'name nameAr');

    if (!item) {
      throw new AppError('الصنف غير موجود', StatusCodes.NOT_FOUND);
    }

    return item;
  }

  /**
   * Delete an item
   */
  async deleteItem(userId: string, itemId: string): Promise<void> {
    const restaurantId = await this.getRestaurantId(userId);

    const result = await MenuItem.findOneAndDelete({
      _id: itemId,
      restaurantId,
    });

    if (!result) {
      throw new AppError('الصنف غير موجود', StatusCodes.NOT_FOUND);
    }
  }

  /**
   * Toggle item availability
   */
  async toggleItemAvailability(
    userId: string,
    itemId: string,
    isAvailable: boolean
  ): Promise<IMenuItem> {
    const restaurantId = await this.getRestaurantId(userId);

    const item = await MenuItem.findOneAndUpdate(
      { _id: itemId, restaurantId },
      { $set: { isAvailable } },
      { new: true }
    );

    if (!item) {
      throw new AppError('الصنف غير موجود', StatusCodes.NOT_FOUND);
    }

    return item;
  }

  /**
   * Bulk update items
   */
  async bulkUpdateItems(
    userId: string,
    items: Array<{ id: string; isAvailable?: boolean; sortOrder?: number }>
  ): Promise<void> {
    const restaurantId = await this.getRestaurantId(userId);

    const bulkOps = items.map((item) => {
      const update: Record<string, unknown> = {};
      if (item.isAvailable !== undefined) update.isAvailable = item.isAvailable;
      if (item.sortOrder !== undefined) update.sortOrder = item.sortOrder;

      return {
        updateOne: {
          filter: { _id: item.id, restaurantId },
          update: { $set: update },
        },
      };
    });

    await MenuItem.bulkWrite(bulkOps);
  }

  /**
   * Duplicate an item
   */
  async duplicateItem(userId: string, itemId: string): Promise<IMenuItem> {
    const restaurantId = await this.getRestaurantId(userId);

    const originalItem = await MenuItem.findOne({
      _id: itemId,
      restaurantId,
    });

    if (!originalItem) {
      throw new AppError('الصنف غير موجود', StatusCodes.NOT_FOUND);
    }

    // Create a copy
    const { _id, ...itemData } = originalItem.toObject();
    itemData.name = `${itemData.name} (نسخة)`;
    itemData.nameAr = `${itemData.nameAr} (نسخة)`;
    itemData.isAvailable = false;
    itemData.isPopular = false;
    itemData.totalOrders = 0;

    // Get next sort order
    const maxItem = await MenuItem.findOne({
      restaurantId,
      categoryId: originalItem.categoryId,
    })
      .sort('-sortOrder')
      .select('sortOrder');
    itemData.sortOrder = (maxItem?.sortOrder ?? -1) + 1;

    const newItem = await MenuItem.create(itemData);
    return newItem.populate('categoryId', 'name nameAr');
  }

  // ==================== Public Menu APIs ====================

  /**
   * Get public menu for a restaurant
   */
  async getPublicMenu(
    restaurantId: string,
    options: {
      categoryId?: string;
      search?: string;
    } = {}
  ): Promise<Array<{
    category: IMenuCategory;
    items: IMenuItem[];
  }>> {
    const { categoryId, search } = options;

    const categoriesFilter: Record<string, unknown> = {
      restaurantId,
      isActive: true,
    };

    if (categoryId) {
      categoriesFilter._id = categoryId;
    }

    const categories = await MenuCategory.find(categoriesFilter).sort('sortOrder');

    const itemsFilter: Record<string, unknown> = {
      restaurantId,
      isAvailable: true,
    };

    if (categoryId) {
      itemsFilter.categoryId = categoryId;
    }

    if (search) {
      itemsFilter.$text = { $search: search };
    }

    const items = await MenuItem.find(itemsFilter)
      .select('name nameAr description descriptionAr image price discountPrice discountEndsAt preparationTime addons variations tags isPopular categoryId')
      .sort('sortOrder');

    return categories.map((category) => ({
      category,
      items: items.filter(
        (item) => item.categoryId.toString() === category._id.toString()
      ),
    }));
  }
}

export const menuService = new MenuService();
