#!/bin/bash

# Deploy API Server to Kubernetes
echo "🚀 Deploying MongoDB API Server with Kafka Consumer to Kubernetes..."

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

# Build Docker image (if Docker is available)
if command -v docker &> /dev/null; then
    echo "🔨 Building Docker image..."
    docker build -t api-server:latest .
    if [ $? -eq 0 ]; then
        echo "✅ Docker image built successfully"
    else
        echo "⚠️ Docker build failed, continuing with deployment..."
    fi
else
    echo "⚠️ Docker not available, skipping image build"
fi

# Apply Kubernetes manifests
echo "📦 Applying Kubernetes manifests..."

# Deploy the API server
kubectl apply -f api-server-deployment.yaml
if [ $? -eq 0 ]; then
    echo "✅ API server deployment applied"
else
    echo "❌ Failed to apply API server deployment"
    exit 1
fi

# Deploy the service
kubectl apply -f api-server-service.yaml
if [ $? -eq 0 ]; then
    echo "✅ API server service applied"
else
    echo "❌ Failed to apply API server service"
    exit 1
fi

# Deploy the ingress (optional)
if [ -f "api-server-ingress.yaml" ]; then
    kubectl apply -f api-server-ingress.yaml
    if [ $? -eq 0 ]; then
        echo "✅ API server ingress applied"
    else
        echo "⚠️ Failed to apply API server ingress (this is optional)"
    fi
fi

# Wait for deployment to be ready
echo "⏳ Waiting for API server to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/api-server

if [ $? -eq 0 ]; then
    echo "✅ API server is ready!"
else
    echo "❌ API server failed to become ready within 5 minutes"
    echo "📋 Checking pod status..."
    kubectl get pods -l app=api-server
    exit 1
fi

# Get service information
echo "📋 Service Information:"
kubectl get services -l app=api-server

# Get pod information
echo "📋 Pod Information:"
kubectl get pods -l app=api-server

# Get ingress information (if available)
if kubectl get ingress api-server-ingress &> /dev/null; then
    echo "📋 Ingress Information:"
    kubectl get ingress api-server-ingress
fi

echo ""
echo "🎉 API Server with Kafka Consumer deployment completed successfully!"
echo ""
echo "📡 Access Information:"
echo "  - ClusterIP Service: api-server-service:3000"
echo "  - NodePort Service: <node-ip>:30080"
echo "  - Health Check: http://<node-ip>:30080/health"
echo "  - API Documentation: http://<node-ip>:30080/api"
echo ""
echo "📨 Kafka Integration:"
echo "  - Kafka Service: kafka-service:9092"
echo "  - Kafka NodePort: <node-ip>:30092"
echo "  - Consuming from topics: user-events, product-events, order-events, api-events, audit-logs"
echo ""
echo "🔍 To check logs:"
echo "  kubectl logs -l app=api-server -f"
echo ""
echo "🔍 To check status:"
echo "  kubectl get pods -l app=api-server"
echo "  kubectl get services -l app=api-server"
echo ""
echo "🧪 To test Kafka message consumption:"
echo "  kubectl run kafka-producer --image=confluentinc/cp-kafka:7.4.0 --rm -it --restart=Never -- kafka-console-producer --bootstrap-server kafka-service:9092 --topic user-events"
