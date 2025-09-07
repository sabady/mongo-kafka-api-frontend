import { Request, Response, NextFunction } from 'express';
import { ApiResponse } from '../types';

export const validatePagination = (req: Request, res: Response, next: NextFunction): void => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 10;
  const sort = req.query.sort as string || 'createdAt';
  const order = (req.query.order as string) || 'desc';

  // Validate page
  if (page < 1) {
    const response: ApiResponse = {
      success: false,
      message: 'Page number must be greater than 0'
    };
    res.status(400).json(response);
    return;
  }

  // Validate limit
  if (limit < 1 || limit > 100) {
    const response: ApiResponse = {
      success: false,
      message: 'Limit must be between 1 and 100'
    };
    res.status(400).json(response);
    return;
  }

  // Validate order
  if (!['asc', 'desc'].includes(order)) {
    const response: ApiResponse = {
      success: false,
      message: 'Order must be either "asc" or "desc"'
    };
    res.status(400).json(response);
    return;
  }

  // Add validated values to request
  req.query.page = page.toString();
  req.query.limit = limit.toString();
  req.query.sort = sort;
  req.query.order = order;

  next();
};

export const validateObjectId = (req: Request, res: Response, next: NextFunction): void => {
  const { id } = req.params;

  if (!id || !/^[0-9a-fA-F]{24}$/.test(id)) {
    const response: ApiResponse = {
      success: false,
      message: 'Invalid ID format'
    };
    res.status(400).json(response);
    return;
  }

  next();
};

export const validateRequiredFields = (fields: string[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const missingFields: string[] = [];

    fields.forEach(field => {
      if (!req.body[field]) {
        missingFields.push(field);
      }
    });

    if (missingFields.length > 0) {
      const response: ApiResponse = {
        success: false,
        message: `Missing required fields: ${missingFields.join(', ')}`
      };
      res.status(400).json(response);
      return;
    }

    next();
  };
};
