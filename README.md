# MongoDB API Server

A comprehensive Node.js TypeScript API server that provides CRUD operations for MongoDB with full Kubernetes deployment support.

## 🚀 Features

- **Full CRUD Operations**: Complete REST API for Users, Products, and Orders
- **TypeScript**: Fully typed with comprehensive interfaces and models
- **MongoDB Integration**: Robust connection handling with Mongoose ODM
- **Kafka Integration**: Real-time message consumption with KafkaJS
- **Express.js**: Fast, unopinionated web framework
- **Kubernetes Ready**: Complete K8s manifests for production deployment
- **Docker Support**: Containerized with multi-stage builds
- **Health Checks**: Comprehensive health monitoring endpoints
- **Rate Limiting**: Built-in API rate limiting
- **Error Handling**: Centralized error handling with proper HTTP status codes
- **Validation**: Request validation and sanitization
- **Logging**: Structured logging with Morgan
- **Security**: Helmet.js security headers and CORS support
- **Event-Driven Architecture**: Asynchronous message processing

## 📁 Project Structure

```
├── src/
│   ├── config/          # Database and Kafka configuration
│   ├── models/          # Mongoose models (User, Product, Order)
│   ├── routes/          # Express routes and API endpoints
│   ├── middleware/      # Custom middleware (error handling, validation)
│   ├── services/        # Kafka consumer service
│   ├── utils/           # Kafka producer utilities
│   ├── types/           # TypeScript interfaces and types
│   └── server.ts        # Main application entry point
├── mongodb-*.yaml       # MongoDB Kubernetes manifests
├── kafka-*.yaml         # Kafka Kubernetes manifests
├── api-server-*.yaml    # API server Kubernetes manifests
├── Dockerfile           # Container configuration
├── package.json         # Dependencies and scripts
└── tsconfig.json        # TypeScript configuration
```

## 🛠️ API Endpoints

### Users
- `GET /api/users` - Get all users (with pagination)
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user
- `PATCH /api/users/:id/deactivate` - Deactivate user
- `GET /api/users/active` - Get active users only

### Products
- `GET /api/products` - Get all products (with filtering)
- `GET /api/products/:id` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product
- `PATCH /api/products/:id/stock` - Update product stock
- `GET /api/products/category/:category` - Get products by category
- `GET /api/products/available` - Get available products
- `GET /api/products/search/:term` - Search products

### Orders
- `GET /api/orders` - Get all orders (with pagination)
- `GET /api/orders/:id` - Get order by ID
- `POST /api/orders` - Create new order
- `PUT /api/orders/:id` - Update order
- `DELETE /api/orders/:id` - Delete order
- `PATCH /api/orders/:id/status` - Update order status
- `PATCH /api/orders/:id/cancel` - Cancel order
- `GET /api/orders/user/:userId` - Get orders by user
- `GET /api/orders/status/:status` - Get orders by status
- `GET /api/orders/stats` - Get order statistics

### Health
- `GET /health` - Basic health check (includes Kafka status)
- `GET /api/health` - Detailed health check
- `GET /api/health/detailed` - Comprehensive health check with DB test

## 📨 Kafka Integration

### Topics
- **user-events**: User lifecycle events (created, updated, deleted, deactivated)
- **product-events**: Product lifecycle events (created, updated, deleted, stock updated)
- **order-events**: Order lifecycle events (created, updated, cancelled, status changed)
- **api-events**: API request/response events and errors
- **audit-logs**: System audit logs and security events

### Event Types
- `user.created`, `user.updated`, `user.deleted`, `user.deactivated`
- `product.created`, `product.updated`, `product.deleted`, `product.stock.updated`
- `order.created`, `order.updated`, `order.cancelled`, `order.status.changed`
- `api.request`, `api.response`, `api.error`
- `audit.log`

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- MongoDB (or use the provided K8s manifests)
- Kafka (or use the provided K8s manifests)
- Docker (optional)
- Kubernetes cluster (optional)

### Local Development with Minikube
For local development and testing, use Minikube:

```bash
# Start the complete stack locally
./run-local-minikube.sh

# Stop the local environment
./stop-local-minikube.sh
```

This will:
- Start Minikube with 4GB RAM and 2 CPUs
- Build Docker images for all services
- Deploy the complete stack with monitoring
- Provide access URLs for all services

**Access URLs:**
- Frontend: `http://192.168.49.2:30080`
- API Server: `http://192.168.49.2:30080/api`
- Health Check: `http://192.168.49.2:30080/health`
- Prometheus: `http://192.168.49.2:30090`
- Minikube Dashboard: `minikube dashboard`

See [README-LOCAL.md](README-LOCAL.md) for detailed local development instructions.

### Local Development

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up environment variables:**
   ```bash
   cp env.example .env
   # Edit .env with your MongoDB connection details
   ```

3. **Start MongoDB (if not using K8s):**
   ```bash
   # Using Docker
   docker run -d --name mongodb -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=admin123 mongo:7.0
   ```

4. **Start the development server:**
   ```bash
   npm run dev
   ```

5. **Build and start production:**
   ```bash
   npm run build
   npm start
   ```

### Docker Deployment

1. **Build the image:**
   ```bash
   docker build -t api-server:latest .
   ```

2. **Run the container:**
   ```bash
   docker run -d -p 3000:3000 --name api-server api-server:latest
   ```

### Kubernetes Deployment

#### Option 1: Deploy Complete Stack (Recommended)
```bash
./deploy-all.sh
```

#### Option 2: Deploy Components Individually

1. **Deploy MongoDB:**
   ```bash
   ./deploy-mongodb.sh
   ```

2. **Deploy Kafka:**
   ```bash
   ./deploy-kafka.sh
   ```

3. **Deploy the API server:**
   ```bash
   ./deploy-api-server.sh
   ```

#### Access Information
- **API Server**: `http://<node-ip>:30080`
- **Health Check**: `http://<node-ip>:30080/health`
- **API Documentation**: `http://<node-ip>:30080/api`
- **Kafka**: `<node-ip>:30092`
- **MongoDB**: `<node-ip>:30017`

## 🔧 Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MONGODB_URI` | `mongodb://admin:admin123@mongodb-service:27017/admin?authSource=admin` | MongoDB connection string |
| `MONGODB_DATABASE` | `api_db` | Database name |
| `KAFKA_BROKERS` | `kafka-service:9092` | Kafka broker addresses |
| `KAFKA_CLIENT_ID` | `api-server` | Kafka client identifier |
| `PORT` | `3000` | Server port |
| `NODE_ENV` | `development` | Environment mode |
| `CORS_ORIGIN` | `*` | CORS allowed origins |
| `API_RATE_LIMIT_WINDOW_MS` | `900000` | Rate limit window (15 min) |
| `API_RATE_LIMIT_MAX_REQUESTS` | `100` | Max requests per window |

### MongoDB Configuration

The API server connects to MongoDB using the credentials from your Kubernetes secret:
- Username: `admin`
- Password: `admin123`
- Database: `api_db`

### Kafka Configuration

The API server connects to Kafka using the following configuration:
- **Broker**: `kafka-service:9092`
- **Client ID**: `api-server`
- **Consumer Groups**: 
  - `api-server-user-events`
  - `api-server-product-events`
  - `api-server-order-events`
  - `api-server-api-events`
  - `api-server-audit-logs`

## 📊 Data Models

### User
```typescript
{
  name: string;
  email: string;
  age?: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}
```

### Product
```typescript
{
  name: string;
  description: string;
  price: number;
  category: 'electronics' | 'clothing' | 'books' | 'home' | 'sports' | 'beauty' | 'food' | 'other';
  inStock: boolean;
  quantity: number;
  createdAt: Date;
  updatedAt: Date;
}
```

### Order
```typescript
{
  userId: string;
  products: Array<{
    productId: string;
    quantity: number;
    price: number;
  }>;
  totalAmount: number;
  status: 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  shippingAddress: {
    street: string;
    city: string;
    state: string;
    zipCode: string;
    country: string;
  };
  createdAt: Date;
  updatedAt: Date;
}
```

## 🧪 Testing the API

### Using curl

1. **Health check:**
   ```bash
   curl http://localhost:3000/health
   ```

2. **Create a user:**
   ```bash
   curl -X POST http://localhost:3000/api/users \
     -H "Content-Type: application/json" \
     -d '{"name": "John Doe", "email": "john@example.com", "age": 30}'
   ```

3. **Get all users:**
   ```bash
   curl http://localhost:3000/api/users
   ```

4. **Create a product:**
   ```bash
   curl -X POST http://localhost:3000/api/products \
     -H "Content-Type: application/json" \
     -d '{"name": "Laptop", "description": "High-performance laptop", "price": 999.99, "category": "electronics", "quantity": 10}'
   ```

### Using the API Documentation

Visit `http://localhost:3000/api` for complete API documentation with all available endpoints.

## 🔍 Monitoring and Logs

### Health Checks
- Basic: `GET /health`
- Detailed: `GET /api/health/detailed`

### Kubernetes Logs
```bash
# View API server logs
kubectl logs -l app=api-server -f

# View MongoDB logs
kubectl logs -l app=mongodb -f

# View Kafka logs
kubectl logs -l app=kafka -f
```

### Pod Status
```bash
# Check API server pods
kubectl get pods -l app=api-server

# Check MongoDB pods
kubectl get pods -l app=mongodb

# Check Kafka pods
kubectl get pods -l app=kafka
```

### Kafka Topics
```bash
# List all topics
kubectl run kafka-topics --image=confluentinc/cp-kafka:7.4.0 --rm -it --restart=Never -- kafka-topics --bootstrap-server kafka-service:9092 --list

# Describe a topic
kubectl run kafka-topics --image=confluentinc/cp-kafka:7.4.0 --rm -it --restart=Never -- kafka-topics --bootstrap-server kafka-service:9092 --describe --topic user-events
```

## 🛡️ Security Features

- **Rate Limiting**: 100 requests per 15 minutes per IP
- **Security Headers**: Helmet.js protection
- **CORS**: Configurable cross-origin resource sharing
- **Input Validation**: Request validation and sanitization
- **Error Handling**: Secure error responses without sensitive data exposure

## 📈 Performance Features

- **Connection Pooling**: MongoDB connection optimization
- **Compression**: Response compression with gzip
- **Indexing**: Database indexes for optimal query performance
- **Pagination**: Efficient data pagination
- **Caching**: HTTP caching headers

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Troubleshooting

### Common Issues

1. **MongoDB Connection Failed**
   - Check if MongoDB is running
   - Verify connection string in environment variables
   - Check network connectivity

2. **Port Already in Use**
   - Change the PORT environment variable
   - Kill the process using the port: `lsof -ti:3000 | xargs kill`

3. **Kubernetes Deployment Issues**
   - Check pod logs: `kubectl logs -l app=api-server`
   - Verify MongoDB is running: `kubectl get pods -l app=mongodb`
   - Verify Kafka is running: `kubectl get pods -l app=kafka`
   - Check service connectivity

4. **Kafka Connection Issues**
   - Verify Kafka is running: `kubectl get pods -l app=kafka`
   - Check Kafka logs: `kubectl logs -l app=kafka`
   - Test Kafka connectivity: `kubectl run kafka-test --image=confluentinc/cp-kafka:7.4.0 --rm -it --restart=Never -- kafka-topics --bootstrap-server kafka-service:9092 --list`

### Getting Help

- Check the logs for detailed error messages
- Verify all environment variables are set correctly
- Ensure MongoDB is accessible from the API server
- Ensure Kafka is accessible from the API server
- Check Kubernetes resource limits and requests
- Verify all services are running in the same namespace

---

## 📋 MongoDB Kubernetes Deployment

This directory also contains a complete Kubernetes deployment for MongoDB with persistent storage, authentication, and monitoring capabilities.

### MongoDB Files Overview

- **`mongodb-configmap.yaml`** - MongoDB configuration settings
- **`mongodb-secret.yaml`** - Authentication credentials (base64 encoded)
- **`mongodb-pvc.yaml`** - Persistent volume claim for data storage
- **`mongodb-deployment.yaml`** - Main MongoDB deployment with health checks
- **`mongodb-service.yaml`** - Services to expose MongoDB (ClusterIP and NodePort)
- **`mongodb-test-pod.yaml`** - Test pod for connectivity verification
- **`deploy-mongodb.sh`** - Automated deployment script

### MongoDB Quick Start

1. **Automated deployment** (recommended):
   ```bash
   chmod +x deploy-mongodb.sh
   ./deploy-mongodb.sh
   ```

2. **Manual deployment**:
   ```bash
   kubectl apply -f mongodb-configmap.yaml
   kubectl apply -f mongodb-secret.yaml
   kubectl apply -f mongodb-pvc.yaml
   kubectl apply -f mongodb-deployment.yaml
   kubectl apply -f mongodb-service.yaml
   kubectl apply -f mongodb-test-pod.yaml
   ```

### MongoDB Configuration Details

- **Root Username**: `admin`
- **Root Password**: `admin123`
- **Database**: `admin`
- **Storage Size**: 10Gi
- **Internal Access**: `mongodb-service:27017`
- **External Access**: `<node-ip>:30017` (NodePort)

⚠️ **Security Note**: Change these default credentials in production!