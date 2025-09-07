#!/bin/bash

# Test Minikube Setup
echo "🧪 Testing Minikube Setup..."

# Check if minikube is available
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube is not installed or not in PATH"
    echo "Please install Minikube: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    echo "Please install kubectl: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check Docker permissions
if ! docker ps &> /dev/null; then
    echo "❌ Docker permissions issue detected"
    echo "💡 Run the following to fix Docker permissions:"
    echo "   ./fix-docker-permissions.sh"
    echo ""
    echo "Or manually:"
    echo "   sudo usermod -aG docker \$USER"
    echo "   # Then log out and log back in"
    exit 1
fi

echo "✅ Minikube, kubectl, and Docker are available"

# Check Minikube status
echo "📋 Minikube Status:"
minikube status

# Check if Minikube is running
if minikube status | grep -q "Running"; then
    echo "✅ Minikube is running"
else
    echo "❌ Minikube is not running"
    echo "💡 To start Minikube:"
    echo "   minikube start --memory=4096 --cpus=2 --driver=docker"
    exit 1
fi

# Check cluster connectivity
echo "🔍 Testing cluster connectivity..."
if kubectl cluster-info &> /dev/null; then
    echo "✅ kubectl can connect to the cluster"
else
    echo "❌ kubectl cannot connect to the cluster"
    exit 1
fi

# Check nodes
echo "📋 Cluster Nodes:"
kubectl get nodes

# Check storage classes
echo "📋 Storage Classes:"
kubectl get storageclass

# Check addons
echo "📋 Minikube Addons:"
minikube addons list | grep -E "(metrics-server|ingress|dashboard|storage-provisioner)"

# Check Docker environment
echo "🐳 Docker Environment:"
eval $(minikube docker-env)
echo "DOCKER_HOST: $DOCKER_HOST"
echo "DOCKER_CERT_PATH: $DOCKER_CERT_PATH"
echo "DOCKER_TLS_VERIFY: $DOCKER_TLS_VERIFY"

echo ""
echo "🎉 Minikube setup test completed successfully!"
echo ""
echo "💡 Next steps:"
echo "   ./run-local-minikube.sh  # Start the complete stack"
echo "   ./dev-test.sh           # Test the deployed services"
