#!/bin/bash

# Local Development Setup with Minikube
echo "🚀 Setting up Unity Stack for Local Development with Minikube..."

# Check if minikube is available
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube is not installed or not in PATH"
    echo "Please install Minikube: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    echo "Please install kubectl: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

echo "✅ Minikube and kubectl are available"

# Start Minikube
echo "🚀 Starting Minikube..."
minikube start --memory=4096 --cpus=2 --driver=docker

# Enable required addons
echo "🔧 Enabling Minikube addons..."
minikube addons enable metrics-server
minikube addons enable ingress
minikube addons enable dashboard

# Set up Docker environment for Minikube
echo "🐳 Setting up Docker environment for Minikube..."
eval $(minikube docker-env)

# Build Docker images
echo "🔨 Building Docker images..."

# Build API Server image
echo "📦 Building API Server image..."
docker build -t api-server:latest .

# Build Frontend image
echo "📦 Building Frontend image..."
cd frontend
docker build -t customer-frontend:latest .
cd ..

# Deploy MongoDB
echo "📊 Deploying MongoDB..."
kubectl apply -f mongodb-configmap.yaml
kubectl apply -f mongodb-secret.yaml
kubectl apply -f mongodb-pvc.yaml
kubectl apply -f mongodb-deployment.yaml
kubectl apply -f mongodb-service.yaml

# Wait for MongoDB to be ready
echo "⏳ Waiting for MongoDB to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/mongodb

# Deploy Kafka
echo "📨 Deploying Kafka..."
kubectl apply -f kafka-configmap.yaml
kubectl apply -f kafka-pvc.yaml
kubectl apply -f kafka-deployment.yaml
kubectl apply -f kafka-service.yaml

# Wait for Kafka to be ready
echo "⏳ Waiting for Kafka to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/kafka

# Create Kafka topics
echo "📋 Creating Kafka topics..."
kubectl apply -f kafka-topics.yaml
kubectl apply -f kafka-topic-creator.yaml
kubectl wait --for=condition=complete --timeout=120s job/kafka-topic-creator

# Deploy API Server
echo "🔌 Deploying API Server..."
kubectl apply -f api-server-deployment.yaml
kubectl apply -f api-server-service.yaml

# Wait for API Server to be ready
echo "⏳ Waiting for API Server to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/api-server

# Deploy Frontend
echo "🎨 Deploying Frontend..."
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

# Wait for Frontend to be ready
echo "⏳ Waiting for Frontend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend

# Deploy Monitoring
echo "📈 Deploying Monitoring..."
kubectl apply -f prometheus-server.yaml
kubectl apply -f metrics-server.yaml

# Wait for monitoring to be ready
echo "⏳ Waiting for monitoring to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus

# Deploy Autoscaling
echo "📊 Deploying Autoscaling..."
kubectl apply -f api-server-hpa.yaml
kubectl apply -f frontend-hpa.yaml
kubectl apply -f kafka-hpa.yaml
kubectl apply -f mongodb-hpa.yaml

# Get service URLs
echo "🔗 Getting service URLs..."
API_URL=$(minikube service api-server-service-nodeport --url)
FRONTEND_URL=$(minikube service frontend-service-nodeport --url)
PROMETHEUS_URL=$(minikube service prometheus-nodeport --url)

# Display status
echo ""
echo "🎉 Unity Stack is running on Minikube!"
echo ""
echo "📡 Access Information:"
echo "  🌐 Frontend:           $FRONTEND_URL"
echo "  🔌 API Server:         $API_URL"
echo "  📊 Health Check:       $API_URL/health"
echo "  📈 Prometheus:         $PROMETHEUS_URL"
echo "  📊 Minikube Dashboard: minikube dashboard"
echo ""
echo "📋 Service Status:"
kubectl get pods
kubectl get services
echo ""
echo "🔍 Useful Commands:"
echo "  View logs:            kubectl logs -f deployment/[service-name]"
echo "  Stop Minikube:        minikube stop"
echo "  Delete Minikube:      minikube delete"
echo "  Open dashboard:       minikube dashboard"
echo "  Get service URL:      minikube service [service-name] --url"
echo ""
echo "🧪 Test the Stack:"
echo "  1. Open browser: $FRONTEND_URL"
echo "  2. Enter your name and test the interface"
echo "  3. Check API: curl $API_URL/health"
echo "  4. View metrics: $PROMETHEUS_URL"
echo ""
echo "✨ Your local Minikube development environment is ready!"
