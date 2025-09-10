#!/bin/bash

# MongoDB Kubernetes Deployment Script
# This script deploys MongoDB to your Kubernetes cluster

set -e

echo "🚀 Starting MongoDB deployment to Kubernetes..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

echo "✅ Kubernetes cluster is accessible"

# Apply configurations in order
echo "📝 Creating ConfigMap..."
kubectl apply -f k8s/mongodb/mongodb-configmap.yaml

echo "🔐 Creating Secret..."
kubectl apply -f k8s/mongodb/mongodb-secret.yaml

echo "💾 Creating PersistentVolumeClaim..."
kubectl apply -f k8s/mongodb/mongodb-pvc.yaml

echo "🚀 Deploying MongoDB..."
kubectl apply -f k8s/mongodb/mongodb-deployment.yaml

echo "🌐 Creating Services..."
kubectl apply -f k8s/mongodb/mongodb-service.yaml

echo "⏳ Waiting for MongoDB to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/mongodb

echo "🧪 Creating test pod..."
kubectl apply -f k8s/mongodb/mongodb-test-pod.yaml

echo "✅ MongoDB deployment completed successfully!"
echo ""
echo "📊 Deployment Status:"
kubectl get pods -l app=mongodb
kubectl get services -l app=mongodb
kubectl get pvc

echo ""
echo "🔗 Connection Information:"
echo "Internal cluster access: k8s/mongodb/mongodb-service:27017"
echo "External access (NodePort): <node-ip>:30017"
echo ""
echo "🧪 To test the connection:"
echo "kubectl exec -it k8s/mongodb/mongodb-test -- mongosh mongodb://admin:admin123@k8s/mongodb/mongodb-service:27017/admin"
echo ""
echo "📋 To view logs:"
echo "kubectl logs -l app=mongodb"
