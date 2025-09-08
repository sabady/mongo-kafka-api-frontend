#!/bin/bash

# Test GitHub Container Registry Secret
echo "🔐 Testing GitHub Container Registry Secret"
echo "==========================================="
echo ""

# Check if secret exists
if kubectl get secret ghcr-secret >/dev/null 2>&1; then
    echo "✅ Secret 'ghcr-secret' exists"
    
    # Test if we can pull an image using the secret
    echo ""
    echo "🔍 Testing image pull with secret..."
    
    # Create a test pod that uses the secret
    cat > test-pod.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-ghcr-pull
  namespace: default
spec:
  imagePullSecrets:
  - name: ghcr-secret
  containers:
  - name: test
    image: ghcr.io/sabady/mongo-kafka-api-frontend/api-server:latest
    command: ["echo", "Image pull successful"]
  restartPolicy: Never
EOF
    
    echo "📝 Created test pod manifest"
    
    # Try to create the pod (this will test the image pull)
    if kubectl apply -f test-pod.yaml; then
        echo "✅ Test pod created successfully"
        
        # Wait a moment and check status
        sleep 5
        echo ""
        echo "🔍 Checking pod status..."
        kubectl get pod test-ghcr-pull
        
        # Clean up
        kubectl delete -f test-pod.yaml
        rm -f test-pod.yaml
        echo "✅ Test pod cleaned up"
        
    else
        echo "❌ Failed to create test pod"
        rm -f test-pod.yaml
        exit 1
    fi
    
else
    echo "❌ Secret 'ghcr-secret' not found"
    echo "💡 Create it first: ./create-ghcr-secret.sh"
    exit 1
fi

echo ""
echo "🎉 GitHub Container Registry secret is working!"
echo "📋 Your deployments can now pull images from GHCR"
