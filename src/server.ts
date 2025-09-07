import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { createPrometheusMetrics } from './utils/metrics';

import Database from './config/database';
import KafkaConsumerService from './services/kafkaConsumer';
import apiRoutes from './routes';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Initialize database and Kafka consumer
const database = Database.getInstance();
const kafkaConsumer = new KafkaConsumerService();

// Initialize Prometheus metrics
const metricsRegister = createPrometheusMetrics();

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.API_RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutes
  max: parseInt(process.env.API_RATE_LIMIT_MAX_REQUESTS || '100'), // limit each IP to 100 requests per windowMs
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Middleware
app.use(helmet()); // Security headers
app.use(compression()); // Compress responses
app.use(limiter); // Rate limiting
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
if (NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path} - IP: ${req.ip}`);
  next();
});

// Health check endpoint (before API routes)
app.get('/health', (req, res) => {
  const dbInfo = database.getConnectionInfo();
  const kafkaStatus = kafkaConsumer.getStatus();
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    database: {
      connected: dbInfo.isConnected,
      readyState: dbInfo.readyState
    },
    kafka: {
      connected: kafkaStatus.kafkaConnected,
      consumerRunning: kafkaStatus.isRunning
    }
  });
});

// Metrics endpoint
app.get('/metrics', (req, res) => {
  res.set('Content-Type', metricsRegister.contentType);
  res.end(metricsRegister.metrics());
});

// API routes
app.use('/api', apiRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'MongoDB API Server',
    version: '1.0.0',
    status: 'running',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/health',
      api: '/api',
      users: '/api/users',
      products: '/api/products',
      orders: '/api/orders'
    }
  });
});

// Error handling middleware
app.use(notFoundHandler);
app.use(errorHandler);

// Graceful shutdown
const gracefulShutdown = async (signal: string) => {
  console.log(`\n🛑 Received ${signal}. Starting graceful shutdown...`);
  
  try {
    // Stop Kafka consumer
    await kafkaConsumer.stop();
    console.log('✅ Kafka consumer stopped');
    
    // Close database connection
    await database.disconnect();
    console.log('✅ Database connection closed');
    
    // Close server
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during shutdown:', error);
    process.exit(1);
  }
};

// Handle shutdown signals
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('❌ Uncaught Exception:', error);
  gracefulShutdown('uncaughtException');
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
  gracefulShutdown('unhandledRejection');
});

// Start server
const startServer = async () => {
  try {
    // Connect to database
    await database.connect();
    
    // Start Kafka consumer
    await kafkaConsumer.start();
    
    // Start HTTP server
    app.listen(PORT, () => {
      console.log('\n🚀 MongoDB API Server with Kafka Consumer started successfully!');
      console.log(`📡 Server running on port ${PORT}`);
      console.log(`🌍 Environment: ${NODE_ENV}`);
      console.log(`🔗 Health check: http://localhost:${PORT}/health`);
      console.log(`📚 API documentation: http://localhost:${PORT}/api`);
      console.log(`📊 Database: ${database.getConnectionInfo().name || 'api_db'}`);
      console.log(`📨 Kafka: ${kafkaConsumer.getStatus().kafkaConnected ? 'Connected' : 'Disconnected'}`);
      console.log('\n📋 Available endpoints:');
      console.log('  GET  /health - Health check');
      console.log('  GET  /api - API documentation');
      console.log('  GET  /api/users - Users CRUD');
      console.log('  GET  /api/products - Products CRUD');
      console.log('  GET  /api/orders - Orders CRUD');
      console.log('  GET  /api/health - Detailed health check');
      console.log('\n📨 Kafka Topics:');
      console.log('  user-events - User lifecycle events');
      console.log('  product-events - Product lifecycle events');
      console.log('  order-events - Order lifecycle events');
      console.log('  api-events - API request/response events');
      console.log('  audit-logs - System audit logs');
      console.log('\n✨ Server is ready to accept requests and consume Kafka messages!\n');
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

// Start the server
startServer();

export default app;
