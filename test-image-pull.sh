#!/bin/bash

# Test Image Pull from GitHub Container Registry
echo "🔍 Testing Image Pull from GitHub Container Registry"
echo "=================================================="
echo ""

# Configuration
REGISTRY="ghcr.io"
REPOSITORY="sabady/mongo-kafka-api-frontend"
API_IMAGE="api-server"
FRONTEND_IMAGE="customer-frontend"
VERSION="latest"

API_FULL_NAME="$REGISTRY/$REPOSITORY/$API_IMAGE:$VERSION"
FRONTEND_FULL_NAME="$REGISTRY/$REPOSITORY/$FRONTEND_IMAGE:$VERSION"

echo "📋 Testing Images:"
echo "  🔌 API Server: $API_FULL_NAME"
echo "  🎨 Frontend:   $FRONTEND_FULL_NAME"
echo ""

# Check if secret exists
echo "🔐 Checking Kubernetes secret..."
if kubectl get secret ghcr-secret >/dev/null 2>&1; then
    echo "✅ Secret 'ghcr-secret' exists"
else
    echo "❌ Secret 'ghcr-secret' not found"
    echo "💡 Create it first: ./create-ghcr-secret.sh"
    exit 1
fi

# Test API Server image pull
echo ""
echo "🔍 Testing API Server image pull..."

# Create a test pod for API Server
cat > test-api-pod.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-api-pull
  namespace: default
spec:
  imagePullSecrets:
  - name: ghcr-secret
  containers:
  - name: test-api
    image: $API_FULL_NAME
    command: ["echo", "API Server image pull successful"]
  restartPolicy: Never
EOF

echo "📝 Created test pod for API Server"

# Try to create the pod (this will test the image pull)
if kubectl apply -f test-api-pod.yaml; then
    echo "✅ API Server test pod created successfully"
    
    # Wait and check status
    echo "⏳ Waiting for pod to start..."
    sleep 10
    
    echo "🔍 Checking API Server pod status..."
    kubectl get pod test-api-pull
    
    # Check if pod is running or completed
    POD_STATUS=$(kubectl get pod test-api-pull -o jsonpath='{.status.phase}')
    if [ "$POD_STATUS" = "Succeeded" ] || [ "$POD_STATUS" = "Running" ]; then
        echo "✅ API Server image pull successful!"
    else
        echo "⚠️ API Server pod status: $POD_STATUS"
        echo "🔍 Pod events:"
        kubectl describe pod test-api-pull | grep -A 10 "Events:"
    fi
    
    # Clean up
    kubectl delete -f test-api-pod.yaml
    rm -f test-api-pod.yaml
    echo "✅ API Server test pod cleaned up"
    
else
    echo "❌ Failed to create API Server test pod"
    rm -f test-api-pod.yaml
    exit 1
fi

# Test Frontend image pull
echo ""
echo "🔍 Testing Frontend image pull..."

# Create a test pod for Frontend
cat > test-frontend-pod.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-frontend-pull
  namespace: default
spec:
  imagePullSecrets:
  - name: ghcr-secret
  containers:
  - name: test-frontend
    image: $FRONTEND_FULL_NAME
    command: ["echo", "Frontend image pull successful"]
  restartPolicy: Never
EOF

echo "📝 Created test pod for Frontend"

# Try to create the pod (this will test the image pull)
if kubectl apply -f test-frontend-pod.yaml; then
    echo "✅ Frontend test pod created successfully"
    
    # Wait and check status
    echo "⏳ Waiting for pod to start..."
    sleep 10
    
    echo "🔍 Checking Frontend pod status..."
    kubectl get pod test-frontend-pull
    
    # Check if pod is running or completed
    POD_STATUS=$(kubectl get pod test-frontend-pull -o jsonpath='{.status.phase}')
    if [ "$POD_STATUS" = "Succeeded" ] || [ "$POD_STATUS" = "Running" ]; then
        echo "✅ Frontend image pull successful!"
    else
        echo "⚠️ Frontend pod status: $POD_STATUS"
        echo "🔍 Pod events:"
        kubectl describe pod test-frontend-pull | grep -A 10 "Events:"
    fi
    
    # Clean up
    kubectl delete -f test-frontend-pod.yaml
    rm -f test-frontend-pod.yaml
    echo "✅ Frontend test pod cleaned up"
    
else
    echo "❌ Failed to create Frontend test pod"
    rm -f test-frontend-pod.yaml
    exit 1
fi

echo ""
echo "🎉 Image pull tests completed!"
echo ""
echo "📋 Next steps:"
echo "  1. Deploy the applications:"
echo "     kubectl apply -f api-server-deployment.yaml"
echo "     kubectl apply -f frontend-deployment.yaml"
echo ""
echo "  2. Check deployment status:"
echo "     kubectl get pods"
echo "     kubectl get deployments"
echo ""
echo "  3. View logs if needed:"
echo "     kubectl logs -l app=api-server"
echo "     kubectl logs -l app=frontend"
