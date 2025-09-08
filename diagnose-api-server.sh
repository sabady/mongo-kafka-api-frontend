#!/bin/bash

# Diagnose API Server Startup Issues
echo "🔍 Diagnosing API Server Startup Issues"
echo "======================================="
echo ""

# Get API Server pods
echo "📋 API Server Pods:"
kubectl get pods -l app=api-server

echo ""
echo "📋 API Server Pod Details:"
API_POD=$(kubectl get pods -l app=api-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$API_POD" ]; then
    echo "🔍 Pod: $API_POD"
    kubectl describe pod $API_POD
    
    echo ""
    echo "📋 Pod Status:"
    kubectl get pod $API_POD -o wide
    
    echo ""
    echo "📋 Pod Logs:"
    kubectl logs $API_POD --tail=50
    
    echo ""
    echo "📋 Pod Events:"
    kubectl get events --field-selector involvedObject.name=$API_POD --sort-by='.lastTimestamp'
    
    echo ""
    echo "🔍 Container Status:"
    kubectl get pod $API_POD -o jsonpath='{.status.containerStatuses[*].state}' | jq .
    
else
    echo "❌ No API Server pod found"
fi

echo ""
echo "📋 API Server Deployment:"
kubectl get deployment api-server

echo ""
echo "📋 API Server Service:"
kubectl get service api-server-service

echo ""
echo "🔍 Common Issues and Solutions:"
echo "==============================="
echo ""
echo "1. Image Pull Issues:"
echo "   - Check if image exists: ./check-images-exist.sh"
echo "   - Verify secret: kubectl get secret ghcr-secret"
echo ""
echo "2. Health Endpoint Issues:"
echo "   - Check if /health endpoint is implemented"
echo "   - Verify the server is listening on port 3000"
echo "   - Check if the server is starting properly"
echo ""
echo "3. Resource Issues:"
echo "   - Check if pod has enough resources"
echo "   - Verify resource limits and requests"
echo ""
echo "4. Network Issues:"
echo "   - Check if port 3000 is exposed correctly"
echo "   - Verify service configuration"
echo ""
echo "💡 Next Steps:"
echo "   1. Check the pod logs above for startup errors"
echo "   2. Verify the image was built correctly"
echo "   3. Test the health endpoint manually"
echo "   4. Check resource constraints"
