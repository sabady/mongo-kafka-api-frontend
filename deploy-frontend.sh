#!/bin/bash

# Deploy Frontend Service to Kubernetes
echo "🚀 Deploying Customer Frontend Service to Kubernetes..."

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
    echo "🔨 Building Docker image for frontend..."
    cd frontend
    docker build -t customer-frontend:latest .
    if [ $? -eq 0 ]; then
        echo "✅ Docker image built successfully"
    else
        echo "⚠️ Docker build failed, continuing with deployment..."
    fi
    cd ..
else
    echo "⚠️ Docker not available, skipping image build"
fi

# Apply Kubernetes manifests
echo "📦 Applying Kubernetes manifests..."

# Deploy the frontend
kubectl apply -f frontend-deployment.yaml
if [ $? -eq 0 ]; then
    echo "✅ Frontend deployment applied"
else
    echo "❌ Failed to apply frontend deployment"
    exit 1
fi

# Deploy the service
kubectl apply -f frontend-service.yaml
if [ $? -eq 0 ]; then
    echo "✅ Frontend service applied"
else
    echo "❌ Failed to apply frontend service"
    exit 1
fi

# Deploy the ingress (optional)
if [ -f "frontend-ingress.yaml" ]; then
    kubectl apply -f frontend-ingress.yaml
    if [ $? -eq 0 ]; then
        echo "✅ Frontend ingress applied"
    else
        echo "⚠️ Failed to apply frontend ingress (this is optional)"
    fi
fi

# Wait for deployment to be ready
echo "⏳ Waiting for frontend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend

if [ $? -eq 0 ]; then
    echo "✅ Frontend is ready!"
else
    echo "❌ Frontend failed to become ready within 5 minutes"
    echo "📋 Checking pod status..."
    kubectl get pods -l app=frontend
    exit 1
fi

# Get service information
echo "📋 Service Information:"
kubectl get services -l app=frontend

# Get pod information
echo "📋 Pod Information:"
kubectl get pods -l app=frontend

# Get ingress information (if available)
if kubectl get ingress frontend-ingress &> /dev/null; then
    echo "📋 Ingress Information:"
    kubectl get ingress frontend-ingress
fi

echo ""
echo "🎉 Frontend deployment completed successfully!"
echo ""
echo "📡 Access Information:"
echo "  - ClusterIP Service: frontend-service:80"
echo "  - NodePort Service: <node-ip>:30080"
echo "  - Health Check: http://<node-ip>:30080/health"
echo "  - Frontend Application: http://<node-ip>:30080"
echo ""
echo "🔍 To check logs:"
echo "  kubectl logs -l app=frontend -f"
echo ""
echo "🔍 To check status:"
echo "  kubectl get pods -l app=frontend"
echo "  kubectl get services -l app=frontend"
echo ""
echo "🧪 To test the frontend:"
echo "  1. Open browser: http://<node-ip>:30080"
echo "  2. Enter your name"
echo "  3. Click 'Add Random Item' to add items to your list"
echo "  4. Click 'Get Products from MongoDB' to fetch products from the database"
