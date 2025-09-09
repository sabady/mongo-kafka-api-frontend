import { Router } from 'express';
import userRoutes from './users';
import productRoutes from './products';
import orderRoutes from './orders';
import healthRoutes from './health';
import purchaseRoutes from './purchases';

const router = Router();

// Mount routes
router.use('/users', userRoutes);
router.use('/products', productRoutes);
router.use('/orders', orderRoutes);
router.use('/health', healthRoutes);
router.use('/purchases', purchaseRoutes);

// API info endpoint
router.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'MongoDB API Server',
    version: '1.0.0',
    endpoints: {
      users: '/api/users',
      products: '/api/products',
      orders: '/api/orders',
      health: '/api/health',
      purchases: '/api/purchases'
    },
    documentation: {
      users: {
        'GET /api/users': 'Get all users with pagination',
        'GET /api/users/:id': 'Get user by ID',
        'POST /api/users': 'Create new user',
        'PUT /api/users/:id': 'Update user',
        'DELETE /api/users/:id': 'Delete user',
        'PATCH /api/users/:id/deactivate': 'Deactivate user',
        'GET /api/users/active': 'Get active users only'
      },
      products: {
        'GET /api/products': 'Get all products with pagination and filtering',
        'GET /api/products/:id': 'Get product by ID',
        'POST /api/products': 'Create new product',
        'PUT /api/products/:id': 'Update product',
        'DELETE /api/products/:id': 'Delete product',
        'PATCH /api/products/:id/stock': 'Update product stock',
        'GET /api/products/category/:category': 'Get products by category',
        'GET /api/products/available': 'Get available products only',
        'GET /api/products/search/:term': 'Search products by text'
      },
      orders: {
        'GET /api/orders': 'Get all orders with pagination',
        'GET /api/orders/:id': 'Get order by ID',
        'POST /api/orders': 'Create new order',
        'PUT /api/orders/:id': 'Update order',
        'DELETE /api/orders/:id': 'Delete order',
        'PATCH /api/orders/:id/status': 'Update order status',
        'PATCH /api/orders/:id/cancel': 'Cancel order',
        'GET /api/orders/user/:userId': 'Get orders by user',
        'GET /api/orders/status/:status': 'Get orders by status',
        'GET /api/orders/stats': 'Get order statistics'
      },
      health: {
        'GET /api/health': 'Basic health check',
        'GET /api/health/detailed': 'Detailed health check with database test'
      },
      purchases: {
        'POST /api/purchases/buy': 'Buy a product for a user',
        'GET /api/purchases/user/:userId': 'Get all purchases made by a user',
        'GET /api/purchases/user/:userId/products': 'Get all products purchased by a user'
      }
    }
  });
});

export default router;
