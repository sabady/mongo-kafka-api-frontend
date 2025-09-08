import { Router, Request, Response } from 'express';
import { Order, Product } from '../models';
import { asyncHandler, AppError } from '../middleware/errorHandler';
import { validateObjectId, validateRequiredFields, validatePagination } from '../middleware/validation';
import { ApiResponse } from '../types';

const router = Router();

// GET /api/orders - Get all orders with pagination
router.get('/', validatePagination, asyncHandler(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string);
  const limit = parseInt(req.query.limit as string);
  const sort = req.query.sort as string;
  const order = req.query.order as string;
  const status = req.query.status as string;
  const userId = req.query.userId as string;

  const skip = (page - 1) * limit;
  const sortOrder = order === 'asc' ? 1 : -1;

  // Build query
  let query: any = {};
  if (status) {
    query.status = status;
  }
  if (userId) {
    query.userId = userId;
  }

  // Execute query
  const [orders, total] = await Promise.all([
    Order.find(query)
      .sort({ [sort]: sortOrder })
      .skip(skip)
      .limit(limit)
      .populate('userId', 'name email')
      .populate('products.productId', 'name price')
      .lean(),
    Order.countDocuments(query)
  ]);

  const totalPages = Math.ceil(total / limit);

  const response: ApiResponse = {
    success: true,
    message: 'Orders retrieved successfully',
    data: orders,
    pagination: {
      page,
      limit,
      total,
      totalPages
    }
  };

  res.json(response);
}));

// GET /api/orders/:id - Get order by ID
router.get('/:id', validateObjectId, asyncHandler(async (req: Request, res: Response) => {
  const order = await Order.findById(req.params.id)
    .populate('userId', 'name email')
    .populate('products.productId', 'name price description');

  if (!order) {
    throw new AppError('Order not found', 404);
  }

  const response: ApiResponse = {
    success: true,
    message: 'Order retrieved successfully',
    data: order
  };

  res.json(response);
}));

// POST /api/orders - Create new order
router.post('/', validateRequiredFields(['userId', 'products', 'shippingAddress']), asyncHandler(async (req: Request, res: Response) => {
  const { userId, products, shippingAddress } = req.body;

  // Validate products and check stock
  const productIds = products.map((p: any) => p.productId);
  const dbProducts = await Product.find({ _id: { $in: productIds } });

  if (dbProducts.length !== products.length) {
    throw new AppError('One or more products not found', 404);
  }

  // Check stock availability and calculate total
  let totalAmount = 0;
  for (const orderProduct of products) {
    const dbProduct = dbProducts.find(p => (p._id as any).toString() === orderProduct.productId);
    if (!dbProduct) {
      throw new AppError(`Product ${orderProduct.productId} not found`, 404);
    }
    if (!dbProduct.inStock || dbProduct.quantity < orderProduct.quantity) {
      throw new AppError(`Insufficient stock for product ${dbProduct.name}`, 400);
    }
    totalAmount += dbProduct.price * orderProduct.quantity;
  }

  // Create order
  const order = new Order({
    userId,
    products: products.map((p: any) => ({
      productId: p.productId,
      quantity: p.quantity,
      price: dbProducts.find(dp => (dp._id as any).toString() === p.productId)?.price || 0
    })),
    totalAmount,
    shippingAddress
  });

  await order.save();

  // Update product stock
  for (const orderProduct of products) {
    const dbProduct = dbProducts.find(p => (p._id as any).toString() === orderProduct.productId);
    if (dbProduct) {
      await (dbProduct as any).updateStock(dbProduct.quantity - orderProduct.quantity);
    }
  }

  const response: ApiResponse = {
    success: true,
    message: 'Order created successfully',
    data: order
  };

  res.status(201).json(response);
}));

// PUT /api/orders/:id - Update order
router.put('/:id', validateObjectId, asyncHandler(async (req: Request, res: Response) => {
  const { status, shippingAddress } = req.body;

  const order = await Order.findById(req.params.id);
  if (!order) {
    throw new AppError('Order not found', 404);
  }

  // Update fields
  if (status !== undefined) order.status = status;
  if (shippingAddress !== undefined) order.shippingAddress = shippingAddress;

  await order.save();

  const response: ApiResponse = {
    success: true,
    message: 'Order updated successfully',
    data: order
  };

  res.json(response);
}));

// DELETE /api/orders/:id - Delete order
router.delete('/:id', validateObjectId, asyncHandler(async (req: Request, res: Response) => {
  const order = await Order.findByIdAndDelete(req.params.id);

  if (!order) {
    throw new AppError('Order not found', 404);
  }

  const response: ApiResponse = {
    success: true,
    message: 'Order deleted successfully'
  };

  res.json(response);
}));

// PATCH /api/orders/:id/status - Update order status
router.patch('/:id/status', validateObjectId, validateRequiredFields(['status']), asyncHandler(async (req: Request, res: Response) => {
  const { status } = req.body;

  const order = await Order.findById(req.params.id);
  if (!order) {
    throw new AppError('Order not found', 404);
  }

  await (order as any).updateStatus(status);

  const response: ApiResponse = {
    success: true,
    message: 'Order status updated successfully',
    data: order
  };

  res.json(response);
}));

// PATCH /api/orders/:id/cancel - Cancel order
router.patch('/:id/cancel', validateObjectId, asyncHandler(async (req: Request, res: Response) => {
  const order = await Order.findById(req.params.id);
  if (!order) {
    throw new AppError('Order not found', 404);
  }

  await (order as any).cancel();

  // Restore product stock
  for (const orderProduct of order.products) {
    const product = await Product.findById(orderProduct.productId);
    if (product) {
      await (product as any).updateStock(product.quantity + orderProduct.quantity);
    }
  }

  const response: ApiResponse = {
    success: true,
    message: 'Order cancelled successfully',
    data: order
  };

  res.json(response);
}));

// GET /api/orders/user/:userId - Get orders by user
router.get('/user/:userId', asyncHandler(async (req: Request, res: Response) => {
  const { userId } = req.params;
  const orders = await (Order as any).findByUser(userId);

  const response: ApiResponse = {
    success: true,
    message: `Orders for user ${userId} retrieved successfully`,
    data: orders
  };

  res.json(response);
}));

// GET /api/orders/status/:status - Get orders by status
router.get('/status/:status', asyncHandler(async (req: Request, res: Response) => {
  const { status } = req.params;
  const orders = await (Order as any).findByStatus(status);

  const response: ApiResponse = {
    success: true,
    message: `Orders with status '${status}' retrieved successfully`,
    data: orders
  };

  res.json(response);
}));

// GET /api/orders/stats - Get order statistics
router.get('/stats', asyncHandler(async (req: Request, res: Response) => {
  const stats = await (Order as any).getOrderStats();

  const response: ApiResponse = {
    success: true,
    message: 'Order statistics retrieved successfully',
    data: stats
  };

  res.json(response);
}));

export default router;
