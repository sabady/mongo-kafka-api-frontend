#!/bin/bash

# Check if Images Exist in GitHub Container Registry
echo "🔍 Checking if Images Exist in GitHub Container Registry"
echo "======================================================="
echo ""

# Configuration
REGISTRY="ghcr.io"
REPOSITORY="sabady/mongo-kafka-api-frontend"
API_IMAGE="api-server"
FRONTEND_IMAGE="customer-frontend"
VERSION="latest"

API_FULL_NAME="$REGISTRY/$REPOSITORY/$API_IMAGE:$VERSION"
FRONTEND_FULL_NAME="$REGISTRY/$REPOSITORY/$FRONTEND_IMAGE:$VERSION"

echo "📋 Checking Images:"
echo "  🔌 API Server: $API_FULL_NAME"
echo "  🎨 Frontend:   $FRONTEND_FULL_NAME"
echo ""

# Load token
if [ -f ".docker-hub-token" ]; then
    export DOCKER_HUB_TOKEN=$(cat .docker-hub-token)
    echo "✅ Loaded GitHub token"
else
    echo "❌ No .docker-hub-token file found"
    exit 1
fi

# Login to GHCR
echo "🔐 Logging in to GitHub Container Registry..."
if echo $DOCKER_HUB_TOKEN | docker login ghcr.io -u sabady --password-stdin; then
    echo "✅ Successfully logged in to GHCR"
else
    echo "❌ Failed to login to GHCR"
    exit 1
fi

echo ""
echo "🔍 Checking if images exist in registry..."

# Check API Server image
echo "📋 Checking API Server image..."
if docker manifest inspect $API_FULL_NAME >/dev/null 2>&1; then
    echo "✅ API Server image exists in registry"
else
    echo "❌ API Server image not found in registry"
    echo "💡 You may need to push the image first:"
    echo "   ./run-local-minikube.sh --push-github --github-user sabady"
fi

# Check Frontend image
echo "📋 Checking Frontend image..."
if docker manifest inspect $FRONTEND_FULL_NAME >/dev/null 2>&1; then
    echo "✅ Frontend image exists in registry"
else
    echo "❌ Frontend image not found in registry"
    echo "💡 You may need to push the image first:"
    echo "   ./run-local-minikube.sh --push-github --github-user sabady"
fi

echo ""
echo "🔍 Testing local image pulls..."

# Test local pull of API Server
echo "📋 Testing local pull of API Server..."
if docker pull $API_FULL_NAME >/dev/null 2>&1; then
    echo "✅ API Server image pulled successfully"
    docker rmi $API_FULL_NAME >/dev/null 2>&1
    echo "✅ API Server image cleaned up"
else
    echo "❌ Failed to pull API Server image locally"
fi

# Test local pull of Frontend
echo "📋 Testing local pull of Frontend..."
if docker pull $FRONTEND_FULL_NAME >/dev/null 2>&1; then
    echo "✅ Frontend image pulled successfully"
    docker rmi $FRONTEND_FULL_NAME >/dev/null 2>&1
    echo "✅ Frontend image cleaned up"
else
    echo "❌ Failed to pull Frontend image locally"
fi

echo ""
echo "🎯 Summary:"
echo "==========="
echo "If all checks passed, your images are ready for Kubernetes deployment!"
echo ""
echo "📋 Next steps:"
echo "  1. Test image pulls in Kubernetes: ./test-image-pull.sh"
echo "  2. Deploy and verify: ./verify-deployments.sh"
