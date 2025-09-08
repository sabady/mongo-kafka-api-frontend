#!/bin/bash

# Login to Docker Hub from within Minikube
# This script helps you login to Docker Hub from Minikube's Docker daemon

echo "🐳 Docker Hub Login for Minikube"
echo "================================"
echo ""

# Check if minikube is running
if ! minikube status | grep -q "Running"; then
    echo "❌ Minikube is not running"
    echo "💡 Start Minikube first: minikube start"
    exit 1
fi

echo "✅ Minikube is running"
echo ""

# Get username
read -p "Enter your Docker Hub username: " DOCKERHUB_USERNAME

if [ -z "$DOCKERHUB_USERNAME" ]; then
    echo "❌ Username cannot be empty"
    exit 1
fi

echo ""
echo "🔐 Logging in to Docker Hub from within Minikube..."
echo "💡 You'll be prompted for your Docker Hub password or access token"
echo ""

# Login from within Minikube
if minikube ssh "docker login -u $DOCKERHUB_USERNAME"; then
    echo ""
    echo "✅ Successfully logged in to Docker Hub from Minikube!"
    echo "📋 You can now push images using the main script:"
    echo "   ./run-local-minikube.sh --push-github --github-user $DOCKERHUB_USERNAME"
else
    echo ""
    echo "❌ Failed to login to Docker Hub from Minikube"
    echo "💡 Make sure your credentials are correct"
    echo "💡 You can also use a Docker Hub Access Token instead of password"
fi
