export interface Customer {
  id?: string;
  name: string;
  email?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface Product {
  id?: string;
  name: string;
  description: string;
  price: number;
  category: string;
  inStock: boolean;
  quantity: number;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface Order {
  id?: string;
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
  createdAt?: Date;
  updatedAt?: Date;
}

export interface KafkaEvent {
  id: string;
  type: string;
  timestamp: Date;
  source: string;
  data: any;
  metadata?: {
    correlationId?: string;
    userId?: string;
    sessionId?: string;
    [key: string]: any;
  };
}

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

export interface RandomProduct {
  name: string;
  description: string;
  price: number;
  category: string;
  quantity: number;
}
