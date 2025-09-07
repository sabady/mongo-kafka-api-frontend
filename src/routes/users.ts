import { Router, Request, Response } from 'express';
import { User } from '../models';
import { asyncHandler, AppError } from '../middleware/errorHandler';
import { validateObjectId, validateRequiredFields, validatePagination } from '../middleware/validation';
import { ApiResponse, QueryParams } from '../types';

const router = Router();

// GET /api/users - Get all users with pagination
router.get('/', validatePagination, asyncHandler(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string);
  const limit = parseInt(req.query.limit as string);
  const sort = req.query.sort as string;
  const order = req.query.order as string;
  const search = req.query.search as string;

  const skip = (page - 1) * limit;
  const sortOrder = order === 'asc' ? 1 : -1;

  // Build query
  let query: any = {};
  if (search) {
    query = {
      $or: [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ]
    };
  }

  // Execute query
  const [users, total] = await Promise.all([
    User.find(query)
      .sort({ [sort]: sortOrder })
      .skip(skip)
      .limit(limit)
      .lean(),
    User.countDocuments(query)
  ]);

  const totalPages = Math.ceil(total / limit);

  const response: ApiResponse = {
    success: true,
    message: 'Users retrieved successfully',
    data: users,
    pagination: {
      page,
      limit,
      total,
      totalPages
    }
  };

  res.json(response);
}));

// GET /api/users/:id - Get user by ID
router.get('/:id', validateObjectId, asyncHandler(async (req: Request, res: Response) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    throw new AppError('User not found', 404);
  }

  const response: ApiResponse = {
    success: true,
    message: 'User retrieved successfully',
    data: user
  };

  res.json(response);
}));

// POST /api/users - Create new user
router.post('/', validateRequiredFields(['name', 'email']), asyncHandler(async (req: Request, res: Response) => {
  const { name, email, age, isActive } = req.body;

  // Check if user already exists
  const existingUser = await User.findOne({ email });
  if (existingUser) {
    throw new AppError('User with this email already exists', 409);
  }

  const user = new User({
    name,
    email,
    age,
    isActive: isActive !== undefined ? isActive : true
  });

  await user.save();

  const response: ApiResponse = {
    success: true,
    message: 'User created successfully',
    data: user
  };

  res.status(201).json(response);
}));

// PUT /api/users/:id - Update user
router.put('/:id', validateObjectId, asyncHandler(async (req: Request, res: Response) => {
  const { name, email, age, isActive } = req.body;

  const user = await User.findById(req.params.id);
  if (!user) {
    throw new AppError('User not found', 404);
  }

  // Check if email is being changed and if it already exists
  if (email && email !== user.email) {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      throw new AppError('User with this email already exists', 409);
    }
  }

  // Update fields
  if (name !== undefined) user.name = name;
  if (email !== undefined) user.email = email;
  if (age !== undefined) user.age = age;
  if (isActive !== undefined) user.isActive = isActive;

  await user.save();

  const response: ApiResponse = {
    success: true,
    message: 'User updated successfully',
    data: user
  };

  res.json(response);
}));

// DELETE /api/users/:id - Delete user
router.delete('/:id', validateObjectId, asyncHandler(async (req: Request, res: Response) => {
  const user = await User.findByIdAndDelete(req.params.id);

  if (!user) {
    throw new AppError('User not found', 404);
  }

  const response: ApiResponse = {
    success: true,
    message: 'User deleted successfully'
  };

  res.json(response);
}));

// PATCH /api/users/:id/deactivate - Deactivate user
router.patch('/:id/deactivate', validateObjectId, asyncHandler(async (req: Request, res: Response) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    throw new AppError('User not found', 404);
  }

  await user.deactivate();

  const response: ApiResponse = {
    success: true,
    message: 'User deactivated successfully',
    data: user
  };

  res.json(response);
}));

// GET /api/users/active - Get active users only
router.get('/active', asyncHandler(async (req: Request, res: Response) => {
  const activeUsers = await User.findActiveUsers();

  const response: ApiResponse = {
    success: true,
    message: 'Active users retrieved successfully',
    data: activeUsers
  };

  res.json(response);
}));

export default router;
