#!/bin/bash

# Rebuild and Push API Server with MongoDB Fix
echo "🔧 Rebuilding API Server with MongoDB Fix"
echo "========================================="
echo ""

echo "📋 Issue: MongoDB connection error - 'buffermaxentries' option not supported"
echo "✅ Fix: Removed deprecated bufferMaxEntries option from database config"
echo ""

# Check if we're in the right directory
if [ ! -f "src/config/database.ts" ]; then
    echo "❌ Not in the correct directory. Please run from project root."
    exit 1
fi

echo "🔍 Verifying the fix..."
if grep -q "bufferMaxEntries" src/config/database.ts; then
    echo "❌ bufferMaxEntries still found in database.ts"
    exit 1
else
    echo "✅ bufferMaxEntries removed from database.ts"
fi

echo ""
echo "🚀 Rebuilding and pushing API Server image..."

# Run the main script to rebuild and push
if ./run-local-minikube.sh --push-github --github-user sabady; then
    echo ""
    echo "✅ API Server image rebuilt and pushed successfully!"
    echo ""
    echo "🔄 Restarting API Server deployment..."
    
    # Restart the deployment to use the new image
    kubectl rollout restart deployment/api-server
    
    echo "⏳ Waiting for rollout to complete..."
    kubectl rollout status deployment/api-server --timeout=120s
    
    echo ""
    echo "📋 Checking new pod status..."
    kubectl get pods -l app=api-server
    
    # Wait a bit for the pod to start
    echo ""
    echo "⏳ Waiting for pod to start..."
    sleep 30
    
    # Check pod logs
    API_POD=$(kubectl get pods -l app=api-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ -n "$API_POD" ]; then
        echo ""
        echo "📋 New pod logs:"
        kubectl logs $API_POD --tail=20
        
        # Check if the pod is running
        POD_STATUS=$(kubectl get pod $API_POD -o jsonpath='{.status.phase}')
        if [ "$POD_STATUS" = "Running" ]; then
            echo ""
            echo "🎉 API Server is now running successfully!"
            echo "✅ MongoDB connection issue fixed!"
        else
            echo ""
            echo "⚠️ Pod status: $POD_STATUS"
            echo "📋 Check logs above for any remaining issues"
        fi
    fi
    
else
    echo "❌ Failed to rebuild and push API Server image"
    exit 1
fi

echo ""
echo "💡 Next steps:"
echo "   1. Check pod status: kubectl get pods -l app=api-server"
echo "   2. View logs: kubectl logs -l app=api-server"
echo "   3. Test health endpoint: ./test-health-endpoint.sh"
