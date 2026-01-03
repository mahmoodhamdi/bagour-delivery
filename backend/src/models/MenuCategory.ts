import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IMenuCategory extends Document {
  _id: Types.ObjectId;
  restaurantId: Types.ObjectId;
  name: string;
  nameAr: string;
  description?: string;
  descriptionAr?: string;
  image?: string;
  sortOrder: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const menuCategorySchema = new Schema<IMenuCategory>(
  {
    restaurantId: {
      type: Schema.Types.ObjectId,
      ref: 'Restaurant',
      required: [true, 'Restaurant ID is required'],
      index: true,
    },
    name: {
      type: String,
      required: [true, 'Category name is required'],
      trim: true,
      maxlength: [50, 'Name cannot exceed 50 characters'],
    },
    nameAr: {
      type: String,
      required: [true, 'Arabic name is required'],
      trim: true,
      maxlength: [50, 'Arabic name cannot exceed 50 characters'],
    },
    description: {
      type: String,
      trim: true,
      maxlength: [200, 'Description cannot exceed 200 characters'],
    },
    descriptionAr: {
      type: String,
      trim: true,
      maxlength: [200, 'Arabic description cannot exceed 200 characters'],
    },
    image: {
      type: String,
    },
    sortOrder: {
      type: Number,
      default: 0,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes
menuCategorySchema.index({ restaurantId: 1, sortOrder: 1 });
menuCategorySchema.index({ restaurantId: 1, isActive: 1 });

// Virtual for menu items in this category
menuCategorySchema.virtual('items', {
  ref: 'MenuItem',
  localField: '_id',
  foreignField: 'categoryId',
});

// Virtual for item count
menuCategorySchema.virtual('itemCount', {
  ref: 'MenuItem',
  localField: '_id',
  foreignField: 'categoryId',
  count: true,
});

export const MenuCategory = mongoose.model<IMenuCategory>('MenuCategory', menuCategorySchema);
export default MenuCategory;
