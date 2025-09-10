#!/bin/bash

# Deploy Complete Stack: MongoDB + Kafka + API Server
echo "🚀 Deploying Complete Stack: MongoDB + Kafka + API Server..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we can connect to Kubernetes cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

echo "✅ Kubernetes cluster connection verified"

# Deploy MongoDB first
echo ""
echo "📊 Step 1: Deploying MongoDB..."
./deploy-mongodb.sh
if [ $? -ne 0 ]; then
    echo "❌ MongoDB deployment failed"
    exit 1
fi

# Wait a bit for MongoDB to be fully ready
echo "⏳ Waiting for MongoDB to be fully ready..."
sleep 30

# Deploy Kafka
echo ""
echo "📨 Step 2: Deploying Kafka..."
./deploy-kafka.sh
if [ $? -ne 0 ]; then
    echo "❌ Kafka deployment failed"
    exit 1
fi

# Wait a bit for Kafka to be fully ready
echo "⏳ Waiting for Kafka to be fully ready..."
sleep 30

# Deploy API Server
echo ""
echo "🔌 Step 3: Deploying API Server with Kafka Consumer..."
./deploy-api-server.sh
if [ $? -ne 0 ]; then
    echo "❌ API Server deployment failed"
    exit 1
fi

# Deploy Frontend
echo ""
echo "🎨 Step 4: Deploying Frontend Service..."
./deploy-frontend.sh
if [ $? -ne 0 ]; then
    echo "❌ Frontend deployment failed"
    exit 1
fi

# Deploy Autoscaling Components
echo ""
echo "📈 Step 5: Deploying Autoscaling Components..."
./deploy-autoscaling.sh
if [ $? -ne 0 ]; then
    echo "❌ Autoscaling deployment failed"
    exit 1
fi

echo ""
echo "🎉 Complete Stack Deployment Successful!"
echo ""
echo "📋 Deployed Components:"
echo "  ✅ MongoDB Database"
echo "  ✅ Kafka Message Broker"
echo "  ✅ API Server with Kafka Consumer"
echo "  ✅ Frontend Service with Kafka Producer"
echo "  ✅ Autoscaling Components (HPA, VPA, Metrics)"
echo ""
echo "📡 Access Information:"
echo "  - Frontend: http://<node-ip>:30080"
echo "  - API Server: http://<node-ip>:30080/api"
echo "  - Health Check: http://<node-ip>:30080/health"
echo "  - Prometheus: http://<node-ip>:30090"
echo "  - Kafka: <node-ip>:30092"
echo "  - MongoDB: <node-ip>:30017"
echo ""
echo "📨 Kafka Topics:"
echo "  - user-events"
echo "  - product-events"
echo "  - order-events"
echo "  - api-events"
echo "  - audit-logs"
echo ""
echo "🔍 To check all services:"
echo "  kubectl get pods"
echo "  kubectl get services"
echo "  kubectl get hpa"
echo ""
echo "🔍 To check logs:"
echo "  kubectl logs -l app=api-server -f"
echo "  kubectl logs -l app=frontend -f"
echo "  kubectl logs -l app=kafka -f"
echo "  kubectl logs -l app=mongodb -f"
echo ""
echo "📊 To check autoscaling:"
echo "  kubectl get hpa -w"
echo "  kubectl top pods"
echo "  kubectl top nodes"
echo ""
echo "🧪 To test the complete stack:"
echo "  1. Create a user: curl -X POST http://<node-ip>:30080/api/users -H 'Content-Type: application/json' -d '{\"name\":\"Test User\",\"email\":\"test@example.com\"}'"
echo "  2. Check health: curl http://<node-ip>:30080/health"
echo "  3. Send Kafka message: kubectl run k8s/kafka/kafka-producer --image=confluentinc/cp-kafka:7.4.0 --rm -it --restart=Never -- k8s/kafka/kafka-console-producer --bootstrap-server k8s/kafka/kafka-service:9092 --topic user-events"
echo ""
echo "✨ Your complete microservices stack is ready!"
