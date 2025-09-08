#!/bin/bash

# Docker Hub Commands for API Server and Frontend
# This script provides commands to push and pull images to/from Docker Hub

REPOSITORY="ghcr.io/sabady/mongo-kafka-api-frontend"
API_IMAGE="api-server"
FRONTEND_IMAGE="customer-frontend"
VERSION="latest"

echo "🐳 GitHub Container Registry Commands for Unity Microservices"
echo "============================================================="
echo ""

echo "📋 Image Information:"
echo "  Repository: $REPOSITORY"
echo "  API Server: $REPOSITORY/$API_IMAGE:$VERSION"
echo "  Frontend: $REPOSITORY/$FRONTEND_IMAGE:$VERSION"
echo ""

echo "🔐 Authentication:"
echo "  Set your GitHub token:"
echo "  export DOCKER_HUB_TOKEN=your_token_here"
echo ""
echo "  Login to GitHub Container Registry:"
echo "  echo \$DOCKER_HUB_TOKEN | docker login ghcr.io -u sabady --password-stdin"
echo ""

echo "📤 Push Commands (after building locally):"
echo "  # Tag images for GitHub Container Registry"
echo "  docker tag $API_IMAGE:$VERSION $REPOSITORY/$API_IMAGE:$VERSION"
echo "  docker tag $FRONTEND_IMAGE:$VERSION $REPOSITORY/$FRONTEND_IMAGE:$VERSION"
echo ""
echo "  # Push to GitHub Container Registry"
echo "  docker push $REPOSITORY/$API_IMAGE:$VERSION"
echo "  docker push $REPOSITORY/$FRONTEND_IMAGE:$VERSION"
echo ""

echo "📥 Pull Commands:"
echo "  # Pull from GitHub Container Registry"
echo "  docker pull $REPOSITORY/$API_IMAGE:$VERSION"
echo "  docker pull $REPOSITORY/$FRONTEND_IMAGE:$VERSION"
echo ""

echo "🚀 Quick Deploy Commands:"
echo "  # Deploy with GitHub Container Registry images"
echo "  kubectl apply -f api-server-deployment.yaml"
echo "  kubectl apply -f frontend-deployment.yaml"
echo ""

echo "🔍 View Images:"
echo "  # List local images"
echo "  docker images | grep $REPOSITORY"
echo ""
echo "  # View on GitHub Container Registry"
echo "  https://github.com/sabady?tab=packages"
echo ""

echo "💡 Usage Examples:"
echo "  # Build and push using the main script"
echo "  ./run-local-minikube.sh --push-github --github-user sabady"
echo ""
echo "  # Pull and run locally"
echo "  docker pull $REPOSITORY/$API_IMAGE:$VERSION"
echo "  docker run -p 3000:3000 $REPOSITORY/$API_IMAGE:$VERSION"
