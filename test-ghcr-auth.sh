#!/bin/bash

# Test GitHub Container Registry Authentication
echo "🔐 Testing GitHub Container Registry Authentication"
echo "=================================================="
echo ""

# Load token from file if it exists
if [ -f ".docker-hub-token" ]; then
    export DOCKER_HUB_TOKEN=$(cat .docker-hub-token)
    echo "✅ Loaded GitHub token from .docker-hub-token"
    echo "🔍 Token preview: ${DOCKER_HUB_TOKEN:0:10}..."
else
    echo "❌ No .docker-hub-token file found"
    exit 1
fi

echo ""
echo "🔍 Testing authentication to GitHub Container Registry..."

# Test login to GitHub Container Registry
if echo $DOCKER_HUB_TOKEN | docker login ghcr.io -u sabady --password-stdin; then
    echo "✅ Successfully logged in to GitHub Container Registry as 'sabady'"
else
    echo "❌ Failed to login to GitHub Container Registry"
    echo "💡 Check your token and try again"
    exit 1
fi

echo ""
echo "🔍 Testing Minikube authentication..."

# Set up Minikube Docker environment
eval $(minikube docker-env)

# Test login from within Minikube
if echo $DOCKER_HUB_TOKEN | docker login ghcr.io -u sabady --password-stdin; then
    echo "✅ Successfully logged in to GitHub Container Registry from Minikube"
else
    echo "❌ Failed to login to GitHub Container Registry from Minikube"
    exit 1
fi

echo ""
echo "🔍 Testing repository access..."

# Test if we can access the repository
REPOSITORY="ghcr.io/sabady/mongo-kafka-api-frontend"
echo "📋 Testing repository: $REPOSITORY"

# Try to pull a non-existent image to test repository access
if docker pull $REPOSITORY/nonexistent:latest 2>&1 | grep -q "not found"; then
    echo "✅ Repository access confirmed (got 'not found' as expected)"
elif docker pull $REPOSITORY/nonexistent:latest 2>&1 | grep -q "unauthorized"; then
    echo "❌ Unauthorized access to repository"
    echo "💡 Check if the repository exists and you have push permissions"
    exit 1
else
    echo "⚠️ Unexpected response, but continuing..."
fi

echo ""
echo "🔍 Testing image tagging..."

# Test if we can tag an image
if docker images | grep -q "api-server"; then
    echo "✅ Found local api-server image"
    docker tag api-server:latest $REPOSITORY/api-server:test
    echo "✅ Successfully tagged image for GHCR"
    
    # Clean up test tag
    docker rmi $REPOSITORY/api-server:test 2>/dev/null || true
    echo "✅ Cleaned up test tag"
else
    echo "⚠️ No local api-server image found"
    echo "💡 Build the image first: docker build -t api-server:latest ."
fi

echo ""
echo "🎉 GitHub Container Registry authentication is working!"
echo "📋 You can now run:"
echo "   ./run-local-minikube.sh --push-github --github-user sabady"
echo ""
echo "🔍 If you still get push errors, check:"
echo "   1. Repository exists: https://github.com/sabady/mongo-kafka-api-frontend"
echo "   2. You have write permissions to the repository"
echo "   3. Token has 'write:packages' permission"
