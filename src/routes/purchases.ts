import { Router, Request, Response } from 'express';
import { Order, Product, User } from '../models';
import { asyncHandler, AppError } from '../middleware/errorHandler';
import { validateObjectId, validateRequiredFields } from '../middleware/validation';
import { ApiResponse } from '../types';

const router = Router();

// POST /api/purchases/buy - Buy a product for a user
router.post('/buy', validateRequiredFields(['userId', 'productId', 'quantity']), asyncHandler(async (req: Request, res: Response) => {
  const { userId, productId, quantity, shippingAddress } = req.body;

  // Validate user exists
  const user = await User.findById(userId);
  if (!user) {
    throw new AppError('User not found', 404);
  }

  // Validate product exists and check stock
  const product = await Product.findById(productId);
  if (!product) {
    throw new AppError('Product not found', 404);
  }

  if (!product.inStock || product.quantity < quantity) {
    throw new AppError(`Insufficient stock for product ${product.name}. Available: ${product.quantity}`, 400);
  }

  // Create order
  const orderData = {
    userId,
    products: [{
      productId,
      quantity,
      price: product.price
    }],
    totalAmount: product.price * quantity,
    status: 'pending',
    shippingAddress: shippingAddress || {
      street: 'Default Street',
      city: 'Default City',
      state: 'Default State',
      zipCode: '00000',
      country: 'USA'
    }
  };

  const order = new Order(orderData);
  await order.save();

  // Update product stock
  product.quantity -= quantity;
  product.inStock = product.quantity > 0;
  await product.save();

  // Populate the order with user and product details
  await order.populate('userId', 'name email');
  await order.populate('products.productId', 'name price description');

  const response: ApiResponse = {
    success: true,
    message: 'Product purchased successfully',
    data: {
      order: order,
      product: {
        _id: product._id,
        name: product.name,
        price: product.price,
        remainingStock: product.quantity,
        inStock: product.inStock
      },
      user: {
        _id: user._id,
        name: user.name,
        email: user.email
      }
    }
  };

  res.status(201).json(response);
}));

// GET /api/purchases/user/:userId - Get all purchases made by a user
router.get('/user/:userId', validateObjectId, asyncHandler(async (req: Request, res: Response) => {
  const { userId } = req.params;
  const { page = 1, limit = 10, status } = req.query;

  // Validate user exists
  const user = await User.findById(userId);
  if (!user) {
    throw new AppError('User not found', 404);
  }

  // Build query
  let query: any = { userId };
  if (status) {
    query.status = status;
  }

  const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

  // Get orders with pagination
  const [orders, total] = await Promise.all([
    Order.find(query)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit as string))
      .populate('userId', 'name email')
      .populate('products.productId', 'name price description category')
      .lean(),
    Order.countDocuments(query)
  ]);

  const totalPages = Math.ceil(total / parseInt(limit as string));

  // Calculate purchase statistics
  const stats = await Order.aggregate([
    { $match: { userId: userId } },
    {
      $group: {
        _id: null,
        totalOrders: { $sum: 1 },
        totalSpent: { $sum: '$totalAmount' },
        averageOrderValue: { $avg: '$totalAmount' },
        statusBreakdown: {
          $push: '$status'
        }
      }
    }
  ]);

  const statusCounts = stats[0]?.statusBreakdown?.reduce((acc: any, status: string) => {
    acc[status] = (acc[status] || 0) + 1;
    return acc;
  }, {}) || {};

  const response: ApiResponse = {
    success: true,
    message: 'User purchases retrieved successfully',
    data: {
      user: {
        _id: user._id,
        name: user.name,
        email: user.email
      },
      orders: orders,
      statistics: {
        totalOrders: stats[0]?.totalOrders || 0,
        totalSpent: stats[0]?.totalSpent || 0,
        averageOrderValue: stats[0]?.averageOrderValue || 0,
        statusBreakdown: statusCounts
      },
      pagination: {
        page: parseInt(page as string),
        limit: parseInt(limit as string),
        total,
        totalPages
      }
    }
  };

  res.json(response);
}));

// GET /api/purchases/user/:userId/products - Get all products purchased by a user
router.get('/user/:userId/products', validateObjectId, asyncHandler(async (req: Request, res: Response) => {
  const { userId } = req.params;

  // Validate user exists
  const user = await User.findById(userId);
  if (!user) {
    throw new AppError('User not found', 404);
  }

  // Get all orders for the user
  const orders = await Order.find({ userId })
    .populate('products.productId', 'name price description category')
    .lean();

  // Extract and aggregate products
  const productMap = new Map();
  
  orders.forEach(order => {
    order.products.forEach((item: any) => {
      const productId = item.productId._id.toString();
      if (productMap.has(productId)) {
        const existing = productMap.get(productId);
        existing.totalQuantity += item.quantity;
        existing.totalSpent += item.price * item.quantity;
        existing.orderCount += 1;
        existing.lastPurchased = new Date(Math.max(new Date(existing.lastPurchased).getTime(), new Date(order.createdAt).getTime()));
      } else {
        productMap.set(productId, {
          product: item.productId,
          totalQuantity: item.quantity,
          totalSpent: item.price * item.quantity,
          orderCount: 1,
          firstPurchased: order.createdAt,
          lastPurchased: order.createdAt
        });
      }
    });
  });

  const purchasedProducts = Array.from(productMap.values());

  const response: ApiResponse = {
    success: true,
    message: 'User purchased products retrieved successfully',
    data: {
      user: {
        _id: user._id,
        name: user.name,
        email: user.email
      },
      purchasedProducts: purchasedProducts,
      summary: {
        totalUniqueProducts: purchasedProducts.length,
        totalQuantityPurchased: purchasedProducts.reduce((sum, item) => sum + item.totalQuantity, 0),
        totalSpent: purchasedProducts.reduce((sum, item) => sum + item.totalSpent, 0)
      }
    }
  };

  res.json(response);
}));

export default router;
