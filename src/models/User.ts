import mongoose, { Schema } from 'mongoose';
import { IUser } from '../types';

const userSchema = new Schema<IUser>({
  name: {
    type: String,
    required: [true, 'Name is required'],
    trim: true,
    minlength: [2, 'Name must be at least 2 characters long'],
    maxlength: [50, 'Name cannot exceed 50 characters']
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
  },
  age: {
    type: Number,
    min: [0, 'Age cannot be negative'],
    max: [150, 'Age cannot exceed 150']
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Index for better query performance
userSchema.index({ email: 1 });
userSchema.index({ name: 1 });
userSchema.index({ isActive: 1 });

// Virtual for user's full info
userSchema.virtual('fullInfo').get(function() {
  return `${this.name} (${this.email}) - ${this.isActive ? 'Active' : 'Inactive'}`;
});

// Pre-save middleware
userSchema.pre('save', function(next) {
  if (this.isNew) {
    console.log(`Creating new user: ${this.email}`);
  }
  next();
});

// Static method to find active users
userSchema.statics.findActiveUsers = function() {
  return this.find({ isActive: true });
};

// Instance method to deactivate user
userSchema.methods.deactivate = function() {
  this.isActive = false;
  return this.save();
};

export const User = mongoose.model<IUser>('User', userSchema);
