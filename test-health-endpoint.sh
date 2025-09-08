#!/bin/bash

# Test Health Endpoint
echo "🔍 Testing Health Endpoint"
echo "=========================="
echo ""

# Test local health endpoint if API server is running locally
echo "📋 Testing local health endpoint..."
if curl -s http://localhost:3000/health >/dev/null 2>&1; then
    echo "✅ Local health endpoint is responding"
    curl -s http://localhost:3000/health | jq .
else
    echo "⚠️ Local health endpoint is not responding (this is expected if not running locally)"
fi

echo ""
echo "📋 Testing health endpoint in Kubernetes..."

# Get API server pod
API_POD=$(kubectl get pods -l app=api-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$API_POD" ]; then
    echo "📋 Pod: $API_POD"
    
    # Check if pod is running
    POD_STATUS=$(kubectl get pod $API_POD -o jsonpath='{.status.phase}')
    echo "📋 Pod Status: $POD_STATUS"
    
    if [ "$POD_STATUS" = "Running" ]; then
        echo "✅ Pod is running, testing health endpoint..."
        
        # Port forward to test the health endpoint
        echo "🔗 Setting up port forward..."
        kubectl port-forward pod/$API_POD 3001:3000 &
        PORT_FORWARD_PID=$!
        
        # Wait for port forward to be ready
        sleep 5
        
        # Test the health endpoint
        if curl -s http://localhost:3001/health >/dev/null 2>&1; then
            echo "✅ Health endpoint is responding in Kubernetes!"
            curl -s http://localhost:3001/health | jq .
        else
            echo "❌ Health endpoint is not responding in Kubernetes"
            echo "📋 Testing with verbose output:"
            curl -v http://localhost:3001/health
        fi
        
        # Clean up port forward
        kill $PORT_FORWARD_PID 2>/dev/null
        
    else
        echo "❌ Pod is not running (Status: $POD_STATUS)"
        echo "📋 Pod Details:"
        kubectl describe pod $API_POD
    fi
    
else
    echo "❌ No API Server pod found"
fi

echo ""
echo "📋 Alternative: Test via service"
API_SERVICE=$(kubectl get service api-server-service -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
if [ -n "$API_SERVICE" ]; then
    echo "📋 Service IP: $API_SERVICE"
    echo "📋 Testing health endpoint via service..."
    
    # Create a test pod to test the service
    kubectl run test-health --image=curlimages/curl --rm -i --restart=Never -- curl -s http://api-server-service:3000/health
else
    echo "❌ API Server service not found"
fi

echo ""
echo "💡 Troubleshooting Tips:"
echo "   1. Check if the API server is starting properly in the logs"
echo "   2. Verify the health endpoint is implemented correctly"
echo "   3. Check if the server is listening on port 3000"
echo "   4. Verify the image was built correctly"
echo "   5. Check resource constraints"
