import { Router, Request, Response } from 'express';
import { Product } from '../models';
import { asyncHandler, AppError } from '../middleware/errorHandler';
import { validateObjectId, validateRequiredFields, validatePagination } from '../middleware/validation';
import { ApiResponse } from '../types';

const router = Router();

// GET /api/products - Get all products with pagination and filtering
router.get('/', validatePagination, asyncHandler(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string);
  const limit = parseInt(req.query.limit as string);
  const sort = req.query.sort as string;
  const order = req.query.order as string;
  const search = req.query.search as string;
  const category = req.query.category as string;
  const inStock = req.query.inStock as string;

  const skip = (page - 1) * limit;
  const sortOrder = order === 'asc' ? 1 : -1;

  // Build query
  let query: any = {};
  
  if (search) {
    query.$text = { $search: search };
  }
  
  if (category) {
    query.category = category;
  }
  
  if (inStock !== undefined) {
    query.inStock = inStock === 'true';
  }

  // Execute query
  const [products, total] = await Promise.all([
    Product.find(query)
      .sort({ [sort]: sortOrder })
      .skip(skip)
      .limit(limit)
      .lean(),
    Product.countDocuments(query)
  ]);

  const totalPages = Math.ceil(total / limit);

  const response: ApiResponse = {
    success: true,
    message: 'Products retrieved successfully',
    data: products,
    pagination: {
      page,
      limit,
      total,
      totalPages
    }
  };

  res.json(response);
}));

// GET /api/products/:id - Get product by ID
router.get('/:id', validateObjectId, asyncHandler(async (req: Request, res: Response) => {
  const product = await Product.findById(req.params.id);

  if (!product) {
    throw new AppError('Product not found', 404);
  }

  const response: ApiResponse = {
    success: true,
    message: 'Product retrieved successfully',
    data: product
  };

  res.json(response);
}));

// POST /api/products - Create new product
router.post('/', validateRequiredFields(['name', 'description', 'price', 'category', 'quantity']), asyncHandler(async (req: Request, res: Response) => {
  const { name, description, price, category, quantity } = req.body;

  const product = new Product({
    name,
    description,
    price,
    category,
    quantity
  });

  await product.save();

  const response: ApiResponse = {
    success: true,
    message: 'Product created successfully',
    data: product
  };

  res.status(201).json(response);
}));

// PUT /api/products/:id - Update product
router.put('/:id', validateObjectId, asyncHandler(async (req: Request, res: Response) => {
  const { name, description, price, category, quantity } = req.body;

  const product = await Product.findById(req.params.id);
  if (!product) {
    throw new AppError('Product not found', 404);
  }

  // Update fields
  if (name !== undefined) product.name = name;
  if (description !== undefined) product.description = description;
  if (price !== undefined) product.price = price;
  if (category !== undefined) product.category = category;
  if (quantity !== undefined) product.quantity = quantity;

  await product.save();

  const response: ApiResponse = {
    success: true,
    message: 'Product updated successfully',
    data: product
  };

  res.json(response);
}));

// DELETE /api/products/:id - Delete product
router.delete('/:id', validateObjectId, asyncHandler(async (req: Request, res: Response) => {
  const product = await Product.findByIdAndDelete(req.params.id);

  if (!product) {
    throw new AppError('Product not found', 404);
  }

  const response: ApiResponse = {
    success: true,
    message: 'Product deleted successfully'
  };

  res.json(response);
}));

// PATCH /api/products/:id/stock - Update product stock
router.patch('/:id/stock', validateObjectId, validateRequiredFields(['quantity']), asyncHandler(async (req: Request, res: Response) => {
  const { quantity } = req.body;

  const product = await Product.findById(req.params.id);
  if (!product) {
    throw new AppError('Product not found', 404);
  }

  await product.updateStock(quantity);

  const response: ApiResponse = {
    success: true,
    message: 'Product stock updated successfully',
    data: product
  };

  res.json(response);
}));

// GET /api/products/category/:category - Get products by category
router.get('/category/:category', asyncHandler(async (req: Request, res: Response) => {
  const { category } = req.params;
  const products = await Product.findByCategory(category);

  const response: ApiResponse = {
    success: true,
    message: `Products in category '${category}' retrieved successfully`,
    data: products
  };

  res.json(response);
}));

// GET /api/products/available - Get available products only
router.get('/available', asyncHandler(async (req: Request, res: Response) => {
  const availableProducts = await Product.findAvailable();

  const response: ApiResponse = {
    success: true,
    message: 'Available products retrieved successfully',
    data: availableProducts
  };

  res.json(response);
}));

// GET /api/products/search/:term - Search products by text
router.get('/search/:term', asyncHandler(async (req: Request, res: Response) => {
  const { term } = req.params;
  const products = await Product.searchProducts(term);

  const response: ApiResponse = {
    success: true,
    message: `Search results for '${term}'`,
    data: products
  };

  res.json(response);
}));

export default router;
