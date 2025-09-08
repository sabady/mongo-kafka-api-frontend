#!/bin/bash

# Push Docker Images to GitHub Container Registry
echo "🚀 Building and pushing Docker images to GitHub Container Registry..."

# Configuration
GITHUB_USERNAME="sabady"  # Update this to your GitHub username
REGISTRY="ghcr.io"
API_IMAGE_NAME="api-server"
FRONTEND_IMAGE_NAME="customer-frontend"
VERSION="latest"

# Check if GitHub CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo "💡 Install it from: https://cli.github.com/"
    exit 1
fi

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    exit 1
fi

# Check if user is logged in to GitHub CLI
if ! gh auth status &> /dev/null; then
    echo "❌ Not logged in to GitHub CLI"
    echo "💡 Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI and Docker are available"

# Get GitHub username from CLI
GITHUB_USERNAME=$(gh api user --jq .login)
echo "📋 Using GitHub username: $GITHUB_USERNAME"

# Build API Server image
echo "🔨 Building API Server image..."
if docker build -t $API_IMAGE_NAME:$VERSION .; then
    echo "✅ API Server image built successfully"
else
    echo "❌ Failed to build API Server image"
    exit 1
fi

# Build Frontend image
echo "🔨 Building Frontend image..."
cd frontend
if docker build -t $FRONTEND_IMAGE_NAME:$VERSION .; then
    echo "✅ Frontend image built successfully"
else
    echo "❌ Failed to build Frontend image"
    exit 1
fi
cd ..

# Tag images for GitHub Container Registry
echo "🏷️ Tagging images for GitHub Container Registry..."
docker tag $API_IMAGE_NAME:$VERSION $REGISTRY/$GITHUB_USERNAME/$API_IMAGE_NAME:$VERSION
docker tag $FRONTEND_IMAGE_NAME:$VERSION $REGISTRY/$GITHUB_USERNAME/$FRONTEND_IMAGE_NAME:$VERSION

# Login to GitHub Container Registry
echo "🔐 Logging in to GitHub Container Registry..."
echo $GITHUB_TOKEN | docker login $REGISTRY -u $GITHUB_USERNAME --password-stdin

if [ $? -eq 0 ]; then
    echo "✅ Successfully logged in to GitHub Container Registry"
else
    echo "❌ Failed to login to GitHub Container Registry"
    echo "💡 Make sure you have a GitHub Personal Access Token with 'write:packages' permission"
    echo "💡 Set it as GITHUB_TOKEN environment variable"
    exit 1
fi

# Push API Server image
echo "📤 Pushing API Server image..."
if docker push $REGISTRY/$GITHUB_USERNAME/$API_IMAGE_NAME:$VERSION; then
    echo "✅ API Server image pushed successfully"
else
    echo "❌ Failed to push API Server image"
    exit 1
fi

# Push Frontend image
echo "📤 Pushing Frontend image..."
if docker push $REGISTRY/$GITHUB_USERNAME/$FRONTEND_IMAGE_NAME:$VERSION; then
    echo "✅ Frontend image pushed successfully"
else
    echo "❌ Failed to push Frontend image"
    exit 1
fi

echo ""
echo "🎉 All images pushed successfully to GitHub Container Registry!"
echo ""
echo "📋 Image URLs:"
echo "  🔌 API Server: $REGISTRY/$GITHUB_USERNAME/$API_IMAGE_NAME:$VERSION"
echo "  🎨 Frontend:   $REGISTRY/$GITHUB_USERNAME/$FRONTEND_IMAGE_NAME:$VERSION"
echo ""
echo "📋 Next steps:"
echo "  1. Update your Kubernetes deployments to use these images"
echo "  2. Make sure the images are public or your cluster has access"
echo "  3. Deploy your services"
echo ""
echo "🔍 To view your packages:"
echo "  https://github.com/$GITHUB_USERNAME?tab=packages"
