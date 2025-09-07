import { Document } from 'mongoose';

// Base interface for all documents
export interface BaseDocument extends Document {
  createdAt: Date;
  updatedAt: Date;
}

// User interface
export interface IUser extends BaseDocument {
  name: string;
  email: string;
  age?: number;
  isActive: boolean;
}

// Product interface
export interface IProduct extends BaseDocument {
  name: string;
  description: string;
  price: number;
  category: string;
  inStock: boolean;
  quantity: number;
}

// Order interface
export interface IOrder extends BaseDocument {
  userId: string;
  products: Array<{
    productId: string;
    quantity: number;
    price: number;
  }>;
  totalAmount: number;
  status: 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  shippingAddress: {
    street: string;
    city: string;
    state: string;
    zipCode: string;
    country: string;
  };
}

// API Response types
export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  error?: string;
  pagination?: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

// Query parameters for pagination
export interface QueryParams {
  page?: number;
  limit?: number;
  sort?: string;
  order?: 'asc' | 'desc';
  search?: string;
}

// MongoDB connection info
export interface ConnectionInfo {
  isConnected: boolean;
  readyState: number;
  host?: string;
  port?: number;
  name?: string;
}
