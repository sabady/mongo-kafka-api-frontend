import mongoose from 'mongoose';
import { Product } from '../../../src/models/Product';

describe('Product Model', () => {
  beforeAll(async () => {
    await mongoose.connect(process.env.MONGODB_URI!);
  });

  afterAll(async () => {
    await mongoose.disconnect();
  });

  beforeEach(async () => {
    await Product.deleteMany({});
  });

  describe('Product Creation', () => {
    it('should create a product with valid data', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        category: 'electronics',
        quantity: 10
      };

      const product = new Product(productData);
      const savedProduct = await product.save();

      expect(savedProduct._id).toBeDefined();
      expect(savedProduct.name).toBe(productData.name);
      expect(savedProduct.description).toBe(productData.description);
      expect(savedProduct.price).toBe(productData.price);
      expect(savedProduct.category).toBe(productData.category);
      expect(savedProduct.quantity).toBe(productData.quantity);
      expect(savedProduct.inStock).toBe(true);
      expect(savedProduct.createdAt).toBeValidDate();
      expect(savedProduct.updatedAt).toBeValidDate();
    });

    it('should not create a product without required fields', async () => {
      const product = new Product({});

      await expect(product.save()).rejects.toThrow();
    });

    it('should not create a product with invalid category', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        category: 'invalid-category',
        quantity: 10
      };

      const product = new Product(productData);
      await expect(product.save()).rejects.toThrow();
    });

    it('should not create a product with negative price', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: -10,
        category: 'electronics',
        quantity: 10
      };

      const product = new Product(productData);
      await expect(product.save()).rejects.toThrow();
    });
  });

  describe('Product Virtuals', () => {
    it('should return isAvailable virtual correctly', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        category: 'electronics',
        quantity: 5
      };

      const product = new Product(productData);
      await product.save();

      expect(product.isAvailable).toBe(true);

      product.quantity = 0;
      await product.save();
      expect(product.isAvailable).toBe(false);
    });

    it('should return formatted price virtual', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        category: 'electronics',
        quantity: 10
      };

      const product = new Product(productData);
      await product.save();

      expect(product.formattedPrice).toBe('$99.99');
    });
  });

  describe('Product Methods', () => {
    it('should update stock correctly', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        category: 'electronics',
        quantity: 10
      };

      const product = new Product(productData);
      await product.save();

      await product.updateStock(5);
      expect(product.quantity).toBe(5);
      expect(product.inStock).toBe(true);

      await product.updateStock(0);
      expect(product.quantity).toBe(0);
      expect(product.inStock).toBe(false);
    });
  });

  describe('Product Statics', () => {
    beforeEach(async () => {
      const products = [
        { name: 'Laptop', description: 'Gaming laptop', price: 999, category: 'electronics', quantity: 5 },
        { name: 'T-Shirt', description: 'Cotton t-shirt', price: 25, category: 'clothing', quantity: 20 },
        { name: 'Book', description: 'Programming book', price: 50, category: 'books', quantity: 0 }
      ];

      for (const productData of products) {
        const product = new Product(productData);
        await product.save();
      }
    });

    it('should find products by category', async () => {
      const electronics = await Product.findByCategory('electronics');
      expect(electronics).toHaveLength(1);
      expect(electronics[0].name).toBe('Laptop');
    });

    it('should find available products', async () => {
      const available = await Product.findAvailable();
      expect(available).toHaveLength(2);
      expect(available.every(p => p.inStock && p.quantity > 0)).toBe(true);
    });
  });

  describe('Product Pre-save Middleware', () => {
    it('should update inStock based on quantity', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        category: 'electronics',
        quantity: 0
      };

      const product = new Product(productData);
      await product.save();

      expect(product.inStock).toBe(false);
    });
  });
});
