import { create } from 'zustand';

export interface MenuAddon {
  name: string;
  nameAr: string;
  price: number;
  isAvailable: boolean;
  maxQuantity: number;
}

export interface VariationOption {
  name: string;
  nameAr: string;
  price: number;
}

export interface MenuVariation {
  name: string;
  nameAr: string;
  isRequired: boolean;
  options: VariationOption[];
}

export interface MenuItem {
  _id: string;
  restaurantId: string;
  categoryId: string | { _id: string; name: string; nameAr: string };
  name: string;
  nameAr: string;
  description?: string;
  descriptionAr?: string;
  image?: string;
  price: number;
  discountPrice?: number;
  discountEndsAt?: string;
  preparationTime?: number;
  calories?: number;
  servingSize?: string;
  addons: MenuAddon[];
  variations: MenuVariation[];
  tags: string[];
  isAvailable: boolean;
  isPopular: boolean;
  isNew: boolean;
  sortOrder: number;
  totalOrders: number;
  createdAt: string;
  updatedAt: string;
}

export interface MenuCategory {
  _id: string;
  restaurantId: string;
  name: string;
  nameAr: string;
  description?: string;
  descriptionAr?: string;
  image?: string;
  sortOrder: number;
  isActive: boolean;
  itemCount?: number;
  createdAt: string;
  updatedAt: string;
}

interface MenuState {
  categories: MenuCategory[];
  items: MenuItem[];
  selectedCategory: MenuCategory | null;
  selectedItem: MenuItem | null;
  isLoading: boolean;
  isSaving: boolean;
  error: string | null;

  // Filters
  filterCategoryId: string | null;
  filterAvailability: boolean | null;
  searchQuery: string;

  // Pagination
  currentPage: number;
  totalPages: number;
  totalItems: number;

  // Actions - Categories
  setCategories: (categories: MenuCategory[]) => void;
  addCategory: (category: MenuCategory) => void;
  updateCategory: (categoryId: string, updates: Partial<MenuCategory>) => void;
  removeCategory: (categoryId: string) => void;
  setSelectedCategory: (category: MenuCategory | null) => void;
  reorderCategories: (categories: { id: string; sortOrder: number }[]) => void;

  // Actions - Items
  setItems: (items: MenuItem[], pagination?: { page: number; pages: number; total: number }) => void;
  addItem: (item: MenuItem) => void;
  updateItem: (itemId: string, updates: Partial<MenuItem>) => void;
  removeItem: (itemId: string) => void;
  setSelectedItem: (item: MenuItem | null) => void;
  toggleItemAvailability: (itemId: string, isAvailable: boolean) => void;

  // Actions - Filters
  setFilterCategoryId: (categoryId: string | null) => void;
  setFilterAvailability: (availability: boolean | null) => void;
  setSearchQuery: (query: string) => void;

  // Actions - State
  setLoading: (isLoading: boolean) => void;
  setSaving: (isSaving: boolean) => void;
  setError: (error: string | null) => void;
  clearMenu: () => void;
}

export const useMenuStore = create<MenuState>((set, get) => ({
  categories: [],
  items: [],
  selectedCategory: null,
  selectedItem: null,
  isLoading: false,
  isSaving: false,
  error: null,
  filterCategoryId: null,
  filterAvailability: null,
  searchQuery: '',
  currentPage: 1,
  totalPages: 1,
  totalItems: 0,

  // Categories
  setCategories: (categories) => set({ categories }),

  addCategory: (category) => {
    const { categories } = get();
    set({ categories: [...categories, category] });
  },

  updateCategory: (categoryId, updates) => {
    const { categories, selectedCategory } = get();
    set({
      categories: categories.map((cat) =>
        cat._id === categoryId ? { ...cat, ...updates } : cat
      ),
      selectedCategory:
        selectedCategory?._id === categoryId
          ? { ...selectedCategory, ...updates }
          : selectedCategory,
    });
  },

  removeCategory: (categoryId) => {
    const { categories, selectedCategory } = get();
    set({
      categories: categories.filter((cat) => cat._id !== categoryId),
      selectedCategory:
        selectedCategory?._id === categoryId ? null : selectedCategory,
    });
  },

  setSelectedCategory: (category) => set({ selectedCategory: category }),

  reorderCategories: (newOrder) => {
    const { categories } = get();
    const updated = categories.map((cat) => {
      const newPosition = newOrder.find((o) => o.id === cat._id);
      return newPosition ? { ...cat, sortOrder: newPosition.sortOrder } : cat;
    });
    set({ categories: updated.sort((a, b) => a.sortOrder - b.sortOrder) });
  },

  // Items
  setItems: (items, pagination) => {
    set({
      items,
      currentPage: pagination?.page ?? 1,
      totalPages: pagination?.pages ?? 1,
      totalItems: pagination?.total ?? items.length,
    });
  },

  addItem: (item) => {
    const { items } = get();
    set({ items: [...items, item] });
  },

  updateItem: (itemId, updates) => {
    const { items, selectedItem } = get();
    set({
      items: items.map((item) =>
        item._id === itemId ? { ...item, ...updates } : item
      ),
      selectedItem:
        selectedItem?._id === itemId
          ? { ...selectedItem, ...updates }
          : selectedItem,
    });
  },

  removeItem: (itemId) => {
    const { items, selectedItem } = get();
    set({
      items: items.filter((item) => item._id !== itemId),
      selectedItem: selectedItem?._id === itemId ? null : selectedItem,
    });
  },

  setSelectedItem: (item) => set({ selectedItem: item }),

  toggleItemAvailability: (itemId, isAvailable) => {
    const { items, selectedItem } = get();
    set({
      items: items.map((item) =>
        item._id === itemId ? { ...item, isAvailable } : item
      ),
      selectedItem:
        selectedItem?._id === itemId
          ? { ...selectedItem, isAvailable }
          : selectedItem,
    });
  },

  // Filters
  setFilterCategoryId: (categoryId) => set({ filterCategoryId: categoryId }),
  setFilterAvailability: (availability) => set({ filterAvailability: availability }),
  setSearchQuery: (query) => set({ searchQuery: query }),

  // State
  setLoading: (isLoading) => set({ isLoading }),
  setSaving: (isSaving) => set({ isSaving }),
  setError: (error) => set({ error }),

  clearMenu: () =>
    set({
      categories: [],
      items: [],
      selectedCategory: null,
      selectedItem: null,
      filterCategoryId: null,
      filterAvailability: null,
      searchQuery: '',
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    }),
}));
