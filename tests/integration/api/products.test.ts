import request from 'supertest';
import mongoose from 'mongoose';
import app from '../../../src/server';
import { Product } from '../../../src/models/Product';

describe('Products API Integration Tests', () => {
  beforeAll(async () => {
    await mongoose.connect(process.env.MONGODB_URI!);
  });

  afterAll(async () => {
    await mongoose.disconnect();
  });

  beforeEach(async () => {
    await Product.deleteMany({});
  });

  describe('GET /api/products', () => {
    it('should get all products with pagination', async () => {
      const products = [
        { name: 'Laptop', description: 'Gaming laptop', price: 999, category: 'electronics', quantity: 5 },
        { name: 'T-Shirt', description: 'Cotton t-shirt', price: 25, category: 'clothing', quantity: 20 },
        { name: 'Book', description: 'Programming book', price: 50, category: 'books', quantity: 10 }
      ];

      for (const productData of products) {
        const product = new Product(productData);
        await product.save();
      }

      const response = await request(app)
        .get('/api/products')
        .query({ page: 1, limit: 2 })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(2);
      expect(response.body.pagination).toBeDefined();
    });

    it('should filter products by category', async () => {
      const products = [
        { name: 'Laptop', description: 'Gaming laptop', price: 999, category: 'electronics', quantity: 5 },
        { name: 'T-Shirt', description: 'Cotton t-shirt', price: 25, category: 'clothing', quantity: 20 }
      ];

      for (const productData of products) {
        const product = new Product(productData);
        await product.save();
      }

      const response = await request(app)
        .get('/api/products')
        .query({ category: 'electronics' })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].category).toBe('electronics');
    });

    it('should filter products by stock status', async () => {
      const products = [
        { name: 'Laptop', description: 'Gaming laptop', price: 999, category: 'electronics', quantity: 5 },
        { name: 'T-Shirt', description: 'Cotton t-shirt', price: 25, category: 'clothing', quantity: 0 }
      ];

      for (const productData of products) {
        const product = new Product(productData);
        await product.save();
      }

      const response = await request(app)
        .get('/api/products')
        .query({ inStock: 'true' })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].inStock).toBe(true);
    });

    it('should get available products only', async () => {
      const products = [
        { name: 'Laptop', description: 'Gaming laptop', price: 999, category: 'electronics', quantity: 5 },
        { name: 'T-Shirt', description: 'Cotton t-shirt', price: 25, category: 'clothing', quantity: 0 }
      ];

      for (const productData of products) {
        const product = new Product(productData);
        await product.save();
      }

      const response = await request(app)
        .get('/api/products/available')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].inStock).toBe(true);
    });
  });

  describe('GET /api/products/:id', () => {
    it('should get product by ID', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        category: 'electronics',
        quantity: 10
      };

      const product = new Product(productData);
      await product.save();

      const response = await request(app)
        .get(`/api/products/${product._id}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toBe(productData.name);
      expect(response.body.data.price).toBe(productData.price);
    });

    it('should return 404 for non-existent product', async () => {
      const fakeId = new mongoose.Types.ObjectId();
      
      const response = await request(app)
        .get(`/api/products/${fakeId}`)
        .expect(404);

      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /api/products', () => {
    it('should create a new product', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        category: 'electronics',
        quantity: 10
      };

      const response = await request(app)
        .post('/api/products')
        .send(productData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toBe(productData.name);
      expect(response.body.data.price).toBe(productData.price);
      expect(response.body.data.category).toBe(productData.category);
      expect(response.body.data.quantity).toBe(productData.quantity);
      expect(response.body.data.inStock).toBe(true);
    });

    it('should not create product without required fields', async () => {
      const response = await request(app)
        .post('/api/products')
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Missing required fields');
    });

    it('should not create product with invalid category', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        category: 'invalid-category',
        quantity: 10
      };

      const response = await request(app)
        .post('/api/products')
        .send(productData)
        .expect(400);

      expect(response.body.success).toBe(false);
    });
  });

  describe('PUT /api/products/:id', () => {
    it('should update product', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        category: 'electronics',
        quantity: 10
      };

      const product = new Product(productData);
      await product.save();

      const updateData = { name: 'Updated Product', price: 149.99 };

      const response = await request(app)
        .put(`/api/products/${product._id}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toBe(updateData.name);
      expect(response.body.data.price).toBe(updateData.price);
    });
  });

  describe('PATCH /api/products/:id/stock', () => {
    it('should update product stock', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        category: 'electronics',
        quantity: 10
      };

      const product = new Product(productData);
      await product.save();

      const response = await request(app)
        .patch(`/api/products/${product._id}/stock`)
        .send({ quantity: 5 })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.quantity).toBe(5);
      expect(response.body.data.inStock).toBe(true);
    });

    it('should set inStock to false when quantity is 0', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        category: 'electronics',
        quantity: 10
      };

      const product = new Product(productData);
      await product.save();

      const response = await request(app)
        .patch(`/api/products/${product._id}/stock`)
        .send({ quantity: 0 })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.quantity).toBe(0);
      expect(response.body.data.inStock).toBe(false);
    });
  });

  describe('DELETE /api/products/:id', () => {
    it('should delete product', async () => {
      const productData = {
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        category: 'electronics',
        quantity: 10
      };

      const product = new Product(productData);
      await product.save();

      const response = await request(app)
        .delete(`/api/products/${product._id}`)
        .expect(200);

      expect(response.body.success).toBe(true);

      // Verify product is deleted
      const deletedProduct = await Product.findById(product._id);
      expect(deletedProduct).toBeNull();
    });
  });
});
