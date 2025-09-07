import mongoose, { Schema } from 'mongoose';
import { IProduct } from '../types';

const productSchema = new Schema<IProduct>({
  name: {
    type: String,
    required: [true, 'Product name is required'],
    trim: true,
    minlength: [2, 'Product name must be at least 2 characters long'],
    maxlength: [100, 'Product name cannot exceed 100 characters']
  },
  description: {
    type: String,
    required: [true, 'Product description is required'],
    trim: true,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },
  price: {
    type: Number,
    required: [true, 'Price is required'],
    min: [0, 'Price cannot be negative']
  },
  category: {
    type: String,
    required: [true, 'Category is required'],
    trim: true,
    enum: {
      values: ['electronics', 'clothing', 'books', 'home', 'sports', 'beauty', 'food', 'other'],
      message: 'Category must be one of: electronics, clothing, books, home, sports, beauty, food, other'
    }
  },
  inStock: {
    type: Boolean,
    default: true
  },
  quantity: {
    type: Number,
    required: [true, 'Quantity is required'],
    min: [0, 'Quantity cannot be negative'],
    default: 0
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for better query performance
productSchema.index({ name: 1 });
productSchema.index({ category: 1 });
productSchema.index({ price: 1 });
productSchema.index({ inStock: 1 });
productSchema.index({ name: 'text', description: 'text' }); // Text search index

// Virtual for product availability
productSchema.virtual('isAvailable').get(function() {
  return this.inStock && this.quantity > 0;
});

// Virtual for formatted price
productSchema.virtual('formattedPrice').get(function() {
  return `$${this.price.toFixed(2)}`;
});

// Pre-save middleware
productSchema.pre('save', function(next) {
  // Update inStock based on quantity
  this.inStock = this.quantity > 0;
  
  if (this.isNew) {
    console.log(`Creating new product: ${this.name}`);
  }
  next();
});

// Static method to find products by category
productSchema.statics.findByCategory = function(category: string) {
  return this.find({ category, inStock: true });
};

// Static method to find available products
productSchema.statics.findAvailable = function() {
  return this.find({ inStock: true, quantity: { $gt: 0 } });
};

// Static method to search products by text
productSchema.statics.searchProducts = function(searchTerm: string) {
  return this.find({ $text: { $search: searchTerm } });
};

// Instance method to update stock
productSchema.methods.updateStock = function(quantity: number) {
  this.quantity = Math.max(0, quantity);
  this.inStock = this.quantity > 0;
  return this.save();
};

export const Product = mongoose.model<IProduct>('Product', productSchema);
