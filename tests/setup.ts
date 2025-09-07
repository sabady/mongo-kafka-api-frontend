import { MongoMemoryServer } from 'mongodb-memory-server';
import mongoose from 'mongoose';

// Global test setup
beforeAll(async () => {
  // Set test environment variables
  process.env.NODE_ENV = 'test';
  process.env.MONGODB_URI = 'mongodb://localhost:27017/test';
  process.env.KAFKA_BROKERS = 'localhost:9092';
  process.env.PORT = '3001';
});

afterAll(async () => {
  // Cleanup after all tests
  if (mongoose.connection.readyState !== 0) {
    await mongoose.disconnect();
  }
});

// Global test utilities
global.testUtils = {
  generateRandomString: (length: number = 10) => {
    return Math.random().toString(36).substring(2, length + 2);
  },
  
  generateRandomEmail: () => {
    return `test-${Date.now()}@example.com`;
  },
  
  generateRandomProduct: () => ({
    name: `Test Product ${Date.now()}`,
    description: 'Test product description',
    price: Math.floor(Math.random() * 1000) + 10,
    category: 'electronics',
    quantity: Math.floor(Math.random() * 100) + 1
  }),
  
  generateRandomUser: () => ({
    name: `Test User ${Date.now()}`,
    email: `test-${Date.now()}@example.com`,
    age: Math.floor(Math.random() * 50) + 18
  }),
  
  generateRandomOrder: (userId: string) => ({
    userId,
    products: [{
      productId: new mongoose.Types.ObjectId().toString(),
      quantity: Math.floor(Math.random() * 5) + 1,
      price: Math.floor(Math.random() * 100) + 10
    }],
    totalAmount: Math.floor(Math.random() * 500) + 50,
    status: 'pending',
    shippingAddress: {
      street: '123 Test St',
      city: 'Test City',
      state: 'TS',
      zipCode: '12345',
      country: 'USA'
    }
  })
};

// Extend Jest matchers
expect.extend({
  toBeValidObjectId(received) {
    const pass = mongoose.Types.ObjectId.isValid(received);
    return {
      message: () => `expected ${received} ${pass ? 'not ' : ''}to be a valid ObjectId`,
      pass,
    };
  },
  
  toBeValidDate(received) {
    const pass = received instanceof Date && !isNaN(received.getTime());
    return {
      message: () => `expected ${received} ${pass ? 'not ' : ''}to be a valid Date`,
      pass,
    };
  }
});

declare global {
  namespace jest {
    interface Matchers<R> {
      toBeValidObjectId(): R;
      toBeValidDate(): R;
    }
  }
  
  var testUtils: {
    generateRandomString: (length?: number) => string;
    generateRandomEmail: () => string;
    generateRandomProduct: () => any;
    generateRandomUser: () => any;
    generateRandomOrder: (userId: string) => any;
  };
}
