#!/bin/bash

# Setup Local Path Storage Class for Minikube
echo "💾 Setting up Local Path Storage Class for Minikube..."

# Check if minikube is running
if ! minikube status &> /dev/null; then
    echo "❌ Minikube is not running. Please start Minikube first:"
    echo "   minikube start"
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

echo "✅ Minikube is running"

# Check current storage classes
echo "📋 Current storage classes:"
kubectl get storageclass

# Check if local-path storage class exists
if kubectl get storageclass local-path &> /dev/null; then
    echo "✅ local-path storage class already exists"
else
    echo "⚠️ local-path storage class not found"
    echo "🔧 Installing local-path provisioner..."
    
    # Install local-path provisioner
    kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml
    
    # Wait for the provisioner to be ready
    echo "⏳ Waiting for local-path provisioner to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/local-path-provisioner -n local-path-storage
    
    if [ $? -eq 0 ]; then
        echo "✅ local-path provisioner is ready"
    else
        echo "❌ local-path provisioner failed to start"
        exit 1
    fi
fi

# Set local-path as default storage class
echo "🔧 Setting local-path as default storage class..."
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Remove default annotation from other storage classes
echo "🧹 Removing default annotation from other storage classes..."
kubectl get storageclass -o name | grep -v local-path | xargs -I {} kubectl patch {} -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# Verify the setup
echo "📋 Updated storage classes:"
kubectl get storageclass

echo ""
echo "✅ Local path storage class setup completed!"
echo ""
echo "💡 Storage class details:"
echo "  - Name: local-path"
echo "  - Provisioner: rancher.io/local-path"
echo "  - Default: Yes"
echo "  - Access Mode: ReadWriteOnce"
echo ""
echo "🧪 Test the storage class:"
echo "  kubectl apply -f mongodb-pvc.yaml"
echo "  kubectl get pvc"
echo "  kubectl describe pvc mongodb-pvc"
