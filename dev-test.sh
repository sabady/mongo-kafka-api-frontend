#!/bin/bash

# Quick Development Testing Script
echo "🧪 Unity Stack Development Testing..."

# Check if Minikube is running
if ! minikube status &> /dev/null; then
    echo "❌ Minikube is not running. Please run ./run-local-minikube.sh first"
    exit 1
fi

# Get service URLs
API_URL=$(minikube service api-server-service-nodeport --url)
FRONTEND_URL=$(minikube service frontend-service-nodeport --url)

echo "📡 Service URLs:"
echo "  API Server: $API_URL"
echo "  Frontend: $FRONTEND_URL"
echo ""

# Test API Health
echo "🔍 Testing API Health..."
if curl -f -s "$API_URL/health" > /dev/null; then
    echo "✅ API Server is healthy"
else
    echo "❌ API Server health check failed"
fi

# Test API Endpoints
echo "🔍 Testing API Endpoints..."

# Test GET /api/users
echo "  Testing GET /api/users..."
if curl -f -s "$API_URL/api/users" > /dev/null; then
    echo "  ✅ GET /api/users works"
else
    echo "  ❌ GET /api/users failed"
fi

# Test POST /api/users
echo "  Testing POST /api/users..."
USER_RESPONSE=$(curl -s -X POST "$API_URL/api/users" \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test User","email":"test@example.com"}')
if echo "$USER_RESPONSE" | grep -q "success"; then
    echo "  ✅ POST /api/users works"
else
    echo "  ❌ POST /api/users failed"
fi

# Test GET /api/products
echo "  Testing GET /api/products..."
if curl -f -s "$API_URL/api/products" > /dev/null; then
    echo "  ✅ GET /api/products works"
else
    echo "  ❌ GET /api/products failed"
fi

# Test Frontend
echo "🔍 Testing Frontend..."
if curl -f -s "$FRONTEND_URL" > /dev/null; then
    echo "✅ Frontend is accessible"
else
    echo "❌ Frontend is not accessible"
fi

# Test Kafka Topics
echo "🔍 Testing Kafka Topics..."
TOPICS=$(kubectl exec -it deployment/kafka -- kafka-topics --bootstrap-server localhost:9092 --list 2>/dev/null)
if echo "$TOPICS" | grep -q "user-events"; then
    echo "✅ Kafka topics are created"
else
    echo "❌ Kafka topics are not created"
fi

# Test MongoDB Connection
echo "🔍 Testing MongoDB Connection..."
if kubectl exec -it deployment/mongodb -- mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    echo "✅ MongoDB is accessible"
else
    echo "❌ MongoDB is not accessible"
fi

# Show Pod Status
echo ""
echo "📋 Pod Status:"
kubectl get pods

echo ""
echo "📋 Service Status:"
kubectl get services

echo ""
echo "📋 HPA Status:"
kubectl get hpa

echo ""
echo "🎉 Development testing completed!"
echo ""
echo "💡 Quick Commands:"
echo "  View logs: kubectl logs -f deployment/api-server"
echo "  Scale API: kubectl scale deployment api-server --replicas=3"
echo "  Open dashboard: minikube dashboard"
echo "  Port forward: kubectl port-forward service/api-server-service 3000:3000"
