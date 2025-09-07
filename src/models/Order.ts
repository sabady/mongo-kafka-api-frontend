import mongoose, { Schema } from 'mongoose';
import { IOrder } from '../types';

const orderSchema = new Schema<IOrder>({
  userId: {
    type: String,
    required: [true, 'User ID is required'],
    ref: 'User'
  },
  products: [{
    productId: {
      type: String,
      required: [true, 'Product ID is required'],
      ref: 'Product'
    },
    quantity: {
      type: Number,
      required: [true, 'Quantity is required'],
      min: [1, 'Quantity must be at least 1']
    },
    price: {
      type: Number,
      required: [true, 'Price is required'],
      min: [0, 'Price cannot be negative']
    }
  }],
  totalAmount: {
    type: Number,
    required: [true, 'Total amount is required'],
    min: [0, 'Total amount cannot be negative']
  },
  status: {
    type: String,
    required: [true, 'Order status is required'],
    enum: {
      values: ['pending', 'processing', 'shipped', 'delivered', 'cancelled'],
      message: 'Status must be one of: pending, processing, shipped, delivered, cancelled'
    },
    default: 'pending'
  },
  shippingAddress: {
    street: {
      type: String,
      required: [true, 'Street address is required'],
      trim: true
    },
    city: {
      type: String,
      required: [true, 'City is required'],
      trim: true
    },
    state: {
      type: String,
      required: [true, 'State is required'],
      trim: true
    },
    zipCode: {
      type: String,
      required: [true, 'ZIP code is required'],
      trim: true
    },
    country: {
      type: String,
      required: [true, 'Country is required'],
      trim: true,
      default: 'USA'
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for better query performance
orderSchema.index({ userId: 1 });
orderSchema.index({ status: 1 });
orderSchema.index({ createdAt: -1 });
orderSchema.index({ totalAmount: 1 });

// Virtual for order summary
orderSchema.virtual('orderSummary').get(function() {
  return `Order #${this._id} - ${this.products.length} items - $${this.totalAmount.toFixed(2)}`;
});

// Virtual for formatted total
orderSchema.virtual('formattedTotal').get(function() {
  return `$${this.totalAmount.toFixed(2)}`;
});

// Pre-save middleware
orderSchema.pre('save', function(next) {
  // Calculate total amount if not set
  if (this.isNew || this.isModified('products')) {
    this.totalAmount = this.products.reduce((total, product) => {
      return total + (product.price * product.quantity);
    }, 0);
  }
  
  if (this.isNew) {
    console.log(`Creating new order for user: ${this.userId}`);
  }
  next();
});

// Static method to find orders by user
orderSchema.statics.findByUser = function(userId: string) {
  return this.find({ userId }).sort({ createdAt: -1 });
};

// Static method to find orders by status
orderSchema.statics.findByStatus = function(status: string) {
  return this.find({ status }).sort({ createdAt: -1 });
};

// Static method to get order statistics
orderSchema.statics.getOrderStats = function() {
  return this.aggregate([
    {
      $group: {
        _id: '$status',
        count: { $sum: 1 },
        totalAmount: { $sum: '$totalAmount' }
      }
    }
  ]);
};

// Instance method to update status
orderSchema.methods.updateStatus = function(newStatus: string) {
  this.status = newStatus;
  return this.save();
};

// Instance method to cancel order
orderSchema.methods.cancel = function() {
  if (this.status === 'delivered') {
    throw new Error('Cannot cancel a delivered order');
  }
  this.status = 'cancelled';
  return this.save();
};

export const Order = mongoose.model<IOrder>('Order', orderSchema);
