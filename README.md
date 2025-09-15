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
├── src/                 # Source code
│   ├── config/          # Database and Kafka configuration
│   ├── models/          # Mongoose models (User, Product, Order)
│   ├── routes/          # Express routes and API endpoints
│   ├── middleware/      # Custom middleware (error handling, validation)
│   ├── services/        # Kafka consumer service
│   ├── utils/           # Kafka producer utilities
│   ├── types/           # TypeScript interfaces and types
│   └── server.ts        # Main application entry point
├── k8s/                 # Kubernetes manifests organized by service
│   ├── mongodb/         # MongoDB deployment files
│   ├── kafka/           # Kafka deployment files
│   ├── api-server/      # API server deployment files
│   ├── frontend/        # Frontend deployment files
│   ├── monitoring/      # Monitoring and metrics files
│   └── secrets/         # Secret management files
├── scripts/             # Shell scripts organized by purpose
│   ├── deploy/          # Deployment scripts
│   ├── dev/             # Development and debugging scripts
│   ├── test/            # Testing and verification scripts
│   └── setup/           # Setup and configuration scripts
├── docs/                # Documentation organized by purpose
│   ├── setup/           # Setup and configuration documentation
│   ├── deployment/      # Deployment and operations documentation
│   └── development/     # Development and local setup documentation
├── config/              # Configuration files organized by purpose
│   ├── build/           # Build configuration files
│   │   ├── tsconfig.json # TypeScript configuration
│   │   └── jest.config.js # Jest testing configuration
│   ├── docker/          # Docker configuration
│   │   └── Dockerfile   # Container configuration
│   ├── ci/              # CI/CD configuration
│   │   └── CODEOWNERS   # Code ownership rules
│   ├── env.example      # Environment variables template
│   └── load-test.yml    # Load testing configuration
├── tests/               # Test files organized by type
│   ├── unit/            # Unit tests
│   └── integration/     # Integration tests
├── frontend/            # Frontend application code
├── run-local-minikube.sh # Main deployment script
├── stop-local-minikube.sh # Cleanup script
├── package.json         # Dependencies and scripts
└── README.md            # Main project documentation
```

### 📂 File Organization Guide

- **Kubernetes Manifests**: All `.yaml` files are in `k8s/` organized by service
- **Shell Scripts**: All `.sh` files are in `scripts/` organized by purpose
- **Documentation**: All `.md` files are in `docs/` organized by topic
- **Configuration**: Environment and config files are in `config/`
- **Tests**: Test files are in `tests/` organized by type
- **Source Code**: Application code remains in `src/` and `frontend/`

### 🔍 Quick File Finder

- **Deploy MongoDB**: `scripts/deploy/deploy-mongodb.sh`
- **Kafka Config**: `k8s/kafka/kafka-configmap.yaml`
- **API Server**: `k8s/api-server/api-server-deployment.yaml`
- **Environment Setup**: `config/env.example`
- **Load Testing**: `config/load-test.yml`
- **TypeScript Config**: `config/build/tsconfig.json`
- **Jest Config**: `config/build/jest.config.js`
- **Dockerfile**: `config/docker/Dockerfile`
- **Code Owners**: `config/ci/CODEOWNERS`
- **Setup Docs**: `docs/setup/`
- **Deployment Docs**: `docs/deployment/`

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
- Frontend: `http://192.168.49.2:30081`
- API Server: `http://192.168.49.2:30080/api`
- Health Check: `http://192.168.49.2:30080/health`
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
./scripts/deploy/deploy-all.sh
```

#### Option 2: Deploy Components Individually

1. **Deploy MongoDB:**
   ```bash
   ./scripts/deploy/deploy-mongodb.sh
   ```

2. **Deploy Kafka:**
   ```bash
   ./scripts/deploy/deploy-kafka.sh
   ```

3. **Deploy the API server:**
   ```bash
   ./scripts/deploy/deploy-api-server.sh
   ```

#### Access Information
- **Frontend**: `http://<node-ip>:30081`
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

th## 🛒 Core API Examples

### Essential User-Product Operations

The API provides three core functions for managing users and their product purchases:

#### 1. **Add User**
Create a new user in the system:

```bash
curl -X POST http://192.168.49.100:30080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Demo User", "email": "demo@example.com", "age": 28}'
```

**Response:**
```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "name": "Demo User",
    "email": "demo@example.com",
    "age": 28,
    "isActive": true,
    "_id": "68c056c332840da5acefde7f",
    "createdAt": "2025-09-09T16:33:07.552Z",
    "updatedAt": "2025-09-09T16:33:07.552Z",
    "__v": 0,
    "fullInfo": "Demo User (demo@example.com) - Active",
    "id": "68c056c332840da5acefde7f"
  }
}
```

#### 2. **Add Product to User (Buy)**
Associate a product with a user by creating an order:

```bash
curl -X POST http://192.168.49.100:30080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "68c056c332840da5acefde7f",
    "products": [{"productId": "68c0554632840da5acefde73", "quantity": 1, "price": 1299.99}],
    "totalAmount": 1299.99,
    "shippingAddress": {
      "street": "456 Demo St",
      "city": "Demo City",
      "state": "DC",
      "zipCode": "54321",
      "country": "USA"
    }
  }'
```

**What happens:**
- Creates an order for the user
- Associates the product with the user
- Tracks quantity and price
- Stores shipping information
- Updates product stock automatically

#### 3. **List User Products**
Get all products purchased by a specific user:

```bash
curl "http://192.168.49.100:30080/api/orders?userId=68c056c332840da5acefde7f"
```

**Response:**
```json
{
  "success": true,
  "message": "Orders retrieved successfully",
  "data": [
    {
      "_id": "68c056d432840da5acefde82",
      "userId": {
        "_id": "68c056c332840da5acefde7f",
        "name": "Demo User",
        "email": "demo@example.com"
      },
      "products": [
        {
          "productId": {
            "_id": "68c0554632840da5acefde73",
            "name": "MacBook Air",
            "price": 1299.99
          },
          "quantity": 1,
          "price": 1299.99
        }
      ],
      "totalAmount": 1299.99,
      "status": "pending",
      "createdAt": "2025-09-09T16:33:24.176Z"
    }
  ],
  "pagination": {
    "total": 1,
    "totalPages": null
  }
}
```

### Complete Example Flow

Here's a complete example showing all three operations:

```bash
# 1. Create a user
USER_RESPONSE=$(curl -s -X POST http://192.168.49.100:30080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Smith", "email": "john@example.com", "age": 35}')

# Extract user ID from response
USER_ID=$(echo $USER_RESPONSE | jq -r '.data._id')

# 2. Add a product to the user (buy)
curl -X POST http://192.168.49.100:30080/api/orders \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": \"$USER_ID\",
    \"products\": [{\"productId\": \"68c0553832840da5acefde71\", \"quantity\": 2, \"price\": 999.99}],
    \"totalAmount\": 1999.98,
    \"shippingAddress\": {
      \"street\": \"123 Main St\",
      \"city\": \"Anytown\",
      \"state\": \"CA\",
      \"zipCode\": \"12345\",
      \"country\": \"USA\"
    }
  }"

# 3. List all products for this user
curl "http://192.168.49.100:30080/api/orders?userId=$USER_ID"
```

### Key Features

- **JSON Format**: All requests and responses use JSON
- **Automatic Validation**: Input validation and error handling
- **Stock Management**: Product quantities are automatically updated
- **Complete History**: Full purchase history with timestamps
- **Flexible Queries**: Support for pagination and filtering
- **Real-time Updates**: Changes are immediately reflected in the database

## 🧪 Kafka Integration Testing

### Testing Kafka Connectivity

1. **Check Kafka Topics:**
   ```bash
   # List all available topics
   kubectl exec -it kafka-58b74bd6b-k62ph -- kafka-topics --bootstrap-server localhost:9092 --list
   ```

2. **Test Kafka Producer (from API):**
   ```bash
   # Create a user to trigger Kafka message
   curl -X POST http://192.168.49.100:30080/api/users \
     -H "Content-Type: application/json" \
     -d '{"name": "Kafka Test User", "email": "kafka@test.com", "age": 25}'
   ```

3. **Test Kafka Consumer (view messages):**
   ```bash
   # View user-events messages
   kubectl exec -it kafka-58b74bd6b-k62ph -- kafka-console-consumer \
     --bootstrap-server localhost:9092 \
     --topic user-events \
     --from-beginning \
     --max-messages 5
   ```

4. **Test Product Events:**
   ```bash
   # Create a product to trigger Kafka message
   curl -X POST http://192.168.49.100:30080/api/products \
     -H "Content-Type: application/json" \
     -d '{"name": "Test Product", "description": "Kafka test product", "price": 99.99, "category": "electronics", "quantity": 5}'
   
   # View product-events messages
   kubectl exec -it kafka-58b74bd6b-k62ph -- kafka-console-consumer \
     --bootstrap-server localhost:9092 \
     --topic product-events \
     --from-beginning \
     --max-messages 5
   ```

5. **Test Order Events:**
   ```bash
   # Create an order to trigger Kafka message
   curl -X POST http://192.168.49.100:30080/api/orders \
     -H "Content-Type: application/json" \
     -d '{
       "userId": "68c0520a32840da5acefde60",
       "products": [{"productId": "product-id", "quantity": 2, "price": 99.99}],
       "totalAmount": 199.98,
       "shippingAddress": {
         "street": "123 Test St",
         "city": "Test City",
         "state": "TS",
         "zipCode": "12345",
         "country": "USA"
       }
     }'
   
   # View order-events messages
   kubectl exec -it kafka-58b74bd6b-k62ph -- kafka-console-consumer \
     --bootstrap-server localhost:9092 \
     --topic order-events \
     --from-beginning \
     --max-messages 5
   ```

### Kafka Health Verification

1. **Check API Server Kafka Status:**
   ```bash
   curl -s http://192.168.49.100:30080/health | jq .kafka
   ```

2. **Expected Response:**
   ```json
   {
     "connected": true,
     "consumerRunning": true
   }
   ```

3. **Test Kafka Connection from Frontend:**
   ```bash
   # Check if frontend can reach Kafka NodePort
   nc -zv 192.168.49.100 30092
   ```

### Kafka Topic Management

1. **Describe Topic Details:**
   ```bash
   kubectl exec -it kafka-58b74bd6b-k62ph -- kafka-topics \
     --bootstrap-server localhost:9092 \
     --describe \
     --topic user-events
   ```

2. **Check Topic Partitions:**
   ```bash
   kubectl exec -it kafka-58b74bd6b-k62ph -- kafka-topics \
     --bootstrap-server localhost:9092 \
     --describe \
     --topic user-events \
     --partitions
   ```

3. **Monitor Consumer Groups:**
   ```bash
   kubectl exec -it kafka-58b74bd6b-k62ph -- kafka-consumer-groups \
     --bootstrap-server localhost:9092 \
     --list
   ```

### Frontend Kafka Integration Test

1. **Access Frontend:**
   - URL: `http://192.168.49.100:30081`
   - Check Kafka connection status in the UI

2. **Test Kafka Producer from Frontend:**
   - Use the frontend interface to send messages
   - Verify messages appear in Kafka topics

3. **Clear Browser Cache (if needed):**
   - Hard refresh: `Ctrl+F5` or `Cmd+Shift+R`
   - Clear cache in browser settings
   - Check if Kafka connection status updates

### Troubleshooting Kafka Issues

1. **Kafka Pod Not Running:**
   ```bash
   kubectl get pods -l app=kafka
   kubectl describe pod -l app=kafka
   ```

2. **Kafka Service Issues:**
   ```bash
   kubectl get services | grep kafka
   kubectl describe service kafka-service
   ```

3. **Network Connectivity:**
   ```bash
   # Test internal connection
   kubectl exec -it kafka-58b74bd6b-k62ph -- nc -zv kafka-service 9092
   
   # Test external connection
   nc -zv 192.168.49.100 30092
   ```

4. **Check Kafka Logs:**
   ```bash
   kubectl logs -l app=kafka --tail=50
   ```

5. **API Server Kafka Connection:**
   ```bash
   kubectl logs -l app=api-server | grep -i kafka
   ```

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
   chmod +x scripts/deploy/deploy-mongodb.sh
   ./scripts/deploy/deploy-mongodb.sh
   ```

2. **Manual deployment**:
   ```bash
   kubectl apply -f k8s/mongodb/mongodb-configmap.yaml
   kubectl apply -f k8s/mongodb/mongodb-secret.yaml
   kubectl apply -f k8s/mongodb/mongodb-pvc.yaml
   kubectl apply -f k8s/mongodb/mongodb-deployment.yaml
   kubectl apply -f k8s/mongodb/mongodb-service.yaml
   kubectl apply -f k8s/mongodb/mongodb-test-pod.yaml
   ```

### MongoDB Configuration Details

- **Root Username**: `admin`
- **Root Password**: `admin123`
- **Database**: `admin`
- **Storage Size**: 10Gi
- **Internal Access**: `mongodb-service:27017`
- **External Access**: `<node-ip>:30017` (NodePort)

⚠️ **Security Note**: Change these default credentials in production!