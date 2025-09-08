#!/bin/bash

# Fix API Server Startup Issues
echo "🔧 Fixing API Server Startup Issues"
echo "==================================="
echo ""

# First, let's check the current status
echo "📋 Current API Server Status:"
kubectl get pods -l app=api-server

echo ""
echo "🔍 Diagnosing the issue..."

# Get the API server pod
API_POD=$(kubectl get pods -l app=api-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$API_POD" ]; then
    echo "📋 Pod: $API_POD"
    
    # Check pod status
    POD_STATUS=$(kubectl get pod $API_POD -o jsonpath='{.status.phase}')
    echo "📋 Pod Status: $POD_STATUS"
    
    # Check container status
    CONTAINER_STATUS=$(kubectl get pod $API_POD -o jsonpath='{.status.containerStatuses[0].state}')
    echo "📋 Container Status: $CONTAINER_STATUS"
    
    # Check if container is waiting
    WAITING_REASON=$(kubectl get pod $API_POD -o jsonpath='{.status.containerStatuses[0].state.waiting.reason}' 2>/dev/null)
    if [ -n "$WAITING_REASON" ]; then
        echo "📋 Waiting Reason: $WAITING_REASON"
    fi
    
    # Check if container failed
    FAILED_REASON=$(kubectl get pod $API_POD -o jsonpath='{.status.containerStatuses[0].state.terminated.reason}' 2>/dev/null)
    if [ -n "$FAILED_REASON" ]; then
        echo "📋 Failed Reason: $FAILED_REASON"
    fi
    
    echo ""
    echo "📋 Recent Logs:"
    kubectl logs $API_POD --tail=20
    
    echo ""
    echo "📋 Pod Events:"
    kubectl get events --field-selector involvedObject.name=$API_POD --sort-by='.lastTimestamp' | tail -5
    
else
    echo "❌ No API Server pod found"
fi

echo ""
echo "🔧 Attempting to fix the issue..."

# Option 1: Restart the deployment
echo "🔄 Restarting API Server deployment..."
kubectl rollout restart deployment/api-server

echo "⏳ Waiting for rollout to complete..."
kubectl rollout status deployment/api-server --timeout=120s

echo ""
echo "📋 New Pod Status:"
kubectl get pods -l app=api-server

# Check if the new pod is running
NEW_API_POD=$(kubectl get pods -l app=api-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$NEW_API_POD" ]; then
    echo ""
    echo "📋 New Pod Logs:"
    kubectl logs $NEW_API_POD --tail=20
    
    # Wait a bit and check status again
    echo ""
    echo "⏳ Waiting for pod to stabilize..."
    sleep 30
    
    NEW_POD_STATUS=$(kubectl get pod $NEW_API_POD -o jsonpath='{.status.phase}')
    echo "📋 Final Pod Status: $NEW_POD_STATUS"
    
    if [ "$NEW_POD_STATUS" = "Running" ]; then
        echo "✅ API Server is now running successfully!"
    else
        echo "⚠️ API Server is still not running properly"
        echo "📋 Final Pod Details:"
        kubectl describe pod $NEW_API_POD
    fi
fi

echo ""
echo "💡 If the issue persists, try:"
echo "   1. Check if the image exists: ./check-images-exist.sh"
echo "   2. Rebuild and push the image: ./run-local-minikube.sh --push-github --github-user sabady"
echo "   3. Check resource constraints in the deployment"
echo "   4. Verify the health endpoint is working in the image"
