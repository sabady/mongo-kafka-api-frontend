import { Router, Request, Response } from 'express';
import Database from '../config/database';
import { asyncHandler } from '../middleware/errorHandler';
import { ApiResponse } from '../types';

const router = Router();

// GET /api/health - Health check endpoint
router.get('/', asyncHandler(async (req: Request, res: Response) => {
  const db = Database.getInstance();
  const dbInfo = db.getConnectionInfo();

  const healthStatus = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    database: {
      connected: dbInfo.isConnected,
      readyState: dbInfo.readyState,
      host: dbInfo.host,
      port: dbInfo.port,
      name: dbInfo.name
    },
    environment: process.env.NODE_ENV || 'development',
    version: process.env.npm_package_version || '1.0.0'
  };

  const response: ApiResponse = {
    success: true,
    message: 'Health check successful',
    data: healthStatus
  };

  res.json(response);
}));

// GET /api/health/detailed - Detailed health check
router.get('/detailed', asyncHandler(async (req: Request, res: Response) => {
  const db = Database.getInstance();
  const dbInfo = db.getConnectionInfo();

  // Test database operations
  let dbTest = { status: 'unknown', error: null };
  try {
    const { User } = await import('../models');
    await User.findOne().limit(1);
    dbTest = { status: 'healthy', error: null };
  } catch (error) {
    dbTest = { status: 'unhealthy', error: (error as Error).message };
  }

  const detailedHealth = {
    status: dbTest.status === 'healthy' ? 'healthy' : 'unhealthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    cpu: process.cpuUsage(),
    database: {
      ...dbInfo,
      test: dbTest
    },
    environment: process.env.NODE_ENV || 'development',
    version: process.env.npm_package_version || '1.0.0',
    nodeVersion: process.version,
    platform: process.platform,
    arch: process.arch
  };

  const response: ApiResponse = {
    success: dbTest.status === 'healthy',
    message: dbTest.status === 'healthy' ? 'Detailed health check successful' : 'Health check failed',
    data: detailedHealth
  };

  const statusCode = dbTest.status === 'healthy' ? 200 : 503;
  res.status(statusCode).json(response);
}));

export default router;
