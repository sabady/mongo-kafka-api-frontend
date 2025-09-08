#!/bin/bash

# Verify Deployments and Image Pulls
echo "🔍 Verifying Deployments and Image Pulls"
echo "========================================"
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

echo ""
echo "🚀 Deploying applications..."

# Deploy API Server
echo "📦 Deploying API Server..."
if kubectl apply -f api-server-deployment.yaml; then
    echo "✅ API Server deployment applied"
else
    echo "❌ Failed to apply API Server deployment"
    exit 1
fi

# Deploy Frontend
echo "📦 Deploying Frontend..."
if kubectl apply -f frontend-deployment.yaml; then
    echo "✅ Frontend deployment applied"
else
    echo "❌ Failed to apply Frontend deployment"
    exit 1
fi

echo ""
echo "⏳ Waiting for deployments to be ready..."
sleep 15

echo ""
echo "🔍 Checking deployment status..."

# Check API Server deployment
echo "📋 API Server Deployment:"
kubectl get deployment api-server

# Check Frontend deployment
echo ""
echo "📋 Frontend Deployment:"
kubectl get deployment frontend

echo ""
echo "🔍 Checking pod status..."

# Check all pods
kubectl get pods -l app=api-server
kubectl get pods -l app=frontend

echo ""
echo "🔍 Checking pod details..."

# Get detailed pod information
API_POD=$(kubectl get pods -l app=api-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
FRONTEND_POD=$(kubectl get pods -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$API_POD" ]; then
    echo "📋 API Server Pod ($API_POD):"
    kubectl describe pod $API_POD | grep -A 5 -B 5 "Image:"
    echo ""
    echo "📋 API Server Pod Status:"
    kubectl get pod $API_POD -o wide
else
    echo "❌ No API Server pod found"
fi

if [ -n "$FRONTEND_POD" ]; then
    echo ""
    echo "📋 Frontend Pod ($FRONTEND_POD):"
    kubectl describe pod $FRONTEND_POD | grep -A 5 -B 5 "Image:"
    echo ""
    echo "📋 Frontend Pod Status:"
    kubectl get pod $FRONTEND_POD -o wide
else
    echo "❌ No Frontend pod found"
fi

echo ""
echo "🔍 Checking for any issues..."

# Check for ImagePullBackOff or other issues
echo "📋 Pods with issues:"
kubectl get pods --field-selector=status.phase!=Running,status.phase!=Succeeded

echo ""
echo "📋 Recent events:"
kubectl get events --sort-by='.lastTimestamp' | tail -10

echo ""
echo "🎯 Summary:"
echo "==========="

# Count running pods
API_RUNNING=$(kubectl get pods -l app=api-server --field-selector=status.phase=Running --no-headers | wc -l)
FRONTEND_RUNNING=$(kubectl get pods -l app=frontend --field-selector=status.phase=Running --no-headers | wc -l)

echo "📊 API Server pods running: $API_RUNNING"
echo "📊 Frontend pods running: $FRONTEND_RUNNING"

if [ "$API_RUNNING" -gt 0 ] && [ "$FRONTEND_RUNNING" -gt 0 ]; then
    echo "✅ Both applications are running successfully!"
    echo ""
    echo "🔍 View logs:"
    echo "  kubectl logs -l app=api-server"
    echo "  kubectl logs -l app=frontend"
    echo ""
    echo "🌐 Access services:"
    echo "  kubectl port-forward service/api-server-service 3000:3000"
    echo "  kubectl port-forward service/frontend-service 8080:80"
else
    echo "⚠️ Some applications may not be running properly"
    echo "💡 Check the pod status and events above"
fi
