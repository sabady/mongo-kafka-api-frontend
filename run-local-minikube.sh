#!/bin/bash

# Local Development Setup with Minikube
echo "🚀 Setting up Unity Stack for Local Development with Minikube..."

# Configuration
STATIC_IP="192.168.49.100"

# Parse command line arguments
PUSH_TO_GITHUB=false
GITHUB_USERNAME=""
VERSION="latest"

# Load Docker Hub token from file if it exists
if [ -f ".docker-hub-token" ]; then
    export DOCKER_HUB_TOKEN=$(cat .docker-hub-token)
    echo "🔑 Loaded Docker Hub token from .docker-hub-token"
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    --push-github)
      PUSH_TO_GITHUB=true
      shift
      ;;
    --github-user)
      GITHUB_USERNAME="$2"
      shift 2
      ;;
    --version)
      VERSION="$2"
      shift 2
      ;;
    --static-ip)
      STATIC_IP="$2"
      shift 2
      ;;
    --restore-deployments)
      echo "🔄 Restoring deployment files to use local images..."
      if [ -f "k8s/api-server/api-server-deployment.yaml.bak" ]; then
          mv k8s/api-server/api-server-deployment.yaml.bak k8s/api-server/api-server-deployment.yaml
          echo "✅ Restored api-server-deployment.yaml"
      fi
      if [ -f "k8s/frontend/frontend-deployment.yaml.bak" ]; then
          mv k8s/frontend/frontend-deployment.yaml.bak k8s/frontend/frontend-deployment.yaml
          echo "✅ Restored frontend-deployment.yaml"
      fi
      echo "📋 Deployment files restored to use local images"
      exit 0
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --push-github         Push images to GitHub Container Registry"
      echo "  --github-user         GitHub username (required with --push-github)"
      echo "  --version             Image version tag (default: latest)"
      echo "  --static-ip           Static IP for Minikube (default: 192.168.49.100)"
      echo "  --restore-deployments Restore deployment files to use local images"
      echo "  -h, --help            Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                                    # Local development only"
      echo "  $0 --push-github --github-user sabady # Push to GitHub Container Registry"
      echo "  $0 --push-github --github-user sabady --version v1.0.0"
      echo "  $0 --restore-deployments              # Restore local image references"
      echo ""
      echo "Notes:"
      echo "  - When using --push-github, deployment files are updated to use GitHub Container Registry images"
      echo "  - Use --restore-deployments to revert back to local images"
      echo "  - Backup files (.bak) are created when updating deployments"
      echo "  - Authentication: Uses .docker-hub-token file, existing Docker credentials, or DOCKER_HUB_TOKEN"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      echo "Use -h or --help for usage information"
      exit 1
      ;;
  esac
done

echo "📋 Using static IP: $STATIC_IP"

# Validate Docker Hub push parameters
if [ "$PUSH_TO_GITHUB" = true ]; then
    if [ -z "$GITHUB_USERNAME" ]; then
        echo "❌ GitHub username is required when using --push-github"
        echo "💡 Use: $0 --push-github --github-user YOUR_GITHUB_USERNAME"
        exit 1
    fi
    
    # Check if Docker config exists or token is provided
    if [ ! -f "$HOME/.docker/config.json" ] && [ -z "$DOCKER_HUB_TOKEN" ]; then
        echo "❌ No Docker authentication found"
        echo "💡 Option 1: Run 'docker login -u $GITHUB_USERNAME' to use existing credentials"
        echo "💡 Option 2: Set DOCKER_HUB_TOKEN environment variable"
        echo "💡 Option 3: Create .docker-hub-token file with your token"
        echo "💡 Create a Docker Hub Access Token with 'Read, Write, Delete' permission"
        exit 1
    fi
    
    echo "📋 GitHub Container Registry push enabled for user: $GITHUB_USERNAME"
    echo "📋 Image version: $VERSION"
fi

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

# Check if Docker is available and accessible
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

# Check if Minikube is already running
if minikube status | grep -q "Running"; then
    echo "✅ Minikube is already running"
    echo "📋 Current Minikube status:"
    minikube status
else
    # Function to start Minikube with retries
    start_minikube() {
        local max_attempts=3
        local attempt=1
        
        while [ $attempt -le $max_attempts ]; do
            echo "🚀 Starting Minikube (attempt $attempt/$max_attempts)..."
            
            if minikube start --memory=4096 --cpus=2 --driver=docker --static-ip=$STATIC_IP; then
                echo "✅ Minikube started successfully"
                return 0
            else
                echo "❌ Minikube start failed (attempt $attempt/$max_attempts)"
                if [ $attempt -lt $max_attempts ]; then
                    echo "🔄 Retrying in 10 seconds..."
                    sleep 10
                fi
                attempt=$((attempt + 1))
            fi
        done
        
        echo "❌ Failed to start Minikube after $max_attempts attempts"
        return 1
    }
    
    # Start Minikube
    start_minikube
    if [ $? -ne 0 ]; then
        exit 1
    fi
fi

# Wait for Minikube to be ready
echo "⏳ Waiting for Minikube to be ready..."
minikube status

# Check if Minikube is running
if ! minikube status | grep -q "Running"; then
    echo "❌ Minikube failed to start properly"
    echo "📋 Minikube status:"
    minikube status
    exit 1
fi

echo "✅ Minikube is running"

# Wait for cluster to be ready
echo "⏳ Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s
if [ $? -eq 0 ]; then
    echo "✅ Cluster is ready"
else
    echo "⚠️ Cluster readiness check timed out, but continuing..."
fi

# Enable required addons
echo "🔧 Enabling Minikube addons..."
minikube addons enable metrics-server
minikube addons enable ingress
minikube addons enable dashboard
minikube addons enable storage-provisioner

# Wait for addons to be ready
echo "⏳ Waiting for addons to be ready..."
sleep 10

# Set up Docker environment for Minikube
echo "🐳 Setting up Docker environment for Minikube..."
eval $(minikube docker-env)

# Copy Docker credentials to Minikube if they exist
if [ -f "$HOME/.docker/config.json" ]; then
    echo "📋 Copying Docker credentials to Minikube..."
    MINIKUBE_DOCKER_CONFIG=$(minikube ssh "echo \$HOME/.docker" 2>/dev/null || echo "/home/docker/.docker")
    
    # Create .docker directory in Minikube if it doesn't exist
    minikube ssh "mkdir -p $MINIKUBE_DOCKER_CONFIG" 2>/dev/null || true
    
    # Copy the config file to Minikube
    minikube cp "$HOME/.docker/config.json" "$MINIKUBE_DOCKER_CONFIG/config.json" 2>/dev/null || {
        echo "⚠️ Could not copy Docker config to Minikube"
        echo "💡 You may need to login to Docker Hub from within Minikube"
    }
    
    echo "✅ Docker credentials copied to Minikube"
else
    echo "⚠️ No Docker config found at $HOME/.docker/config.json"
    echo "💡 You may need to login to Docker Hub from within Minikube"
fi

# Verify Docker environment is set correctly
echo "🔍 Verifying Docker environment..."
if ! docker info | grep -q "minikube"; then
    echo "⚠️ Docker environment may not be set correctly for Minikube"
    echo "💡 Make sure you're using Minikube's Docker daemon"
fi

# Verify kubectl can connect to the cluster
echo "🔍 Verifying kubectl connection..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ kubectl cannot connect to the cluster"
    echo "📋 Cluster info:"
    kubectl cluster-info
    exit 1
fi

echo "✅ kubectl is connected to the cluster"

# Verify storage class is available
echo "💾 Verifying storage class..."
kubectl get storageclass
if ! kubectl get storageclass local-path &> /dev/null; then
    echo "⚠️ local-path storage class not found, but continuing..."
else
    echo "✅ local-path storage class is available"
fi

# Build Docker images
echo "🔨 Building Docker images..."

# Build API Server image
echo "📦 Building API Server image..."
if docker build -t api-server:latest .; then
    echo "✅ API Server image built successfully"
else
    echo "❌ Failed to build API Server image"
    exit 1
fi

# Verify API Server image is available
if docker images | grep -q "api-server"; then
    echo "✅ API Server image is available in Minikube's Docker registry"
else
    echo "❌ API Server image not found in Minikube's Docker registry"
    exit 1
fi

# Build Frontend image
echo "📦 Building Frontend image..."
cd frontend
if docker build -t customer-frontend:latest .; then
    echo "✅ Frontend image built successfully"
else
    echo "❌ Failed to build Frontend image"
    exit 1
fi
cd ..

# Verify Frontend image is available
if docker images | grep -q "customer-frontend"; then
    echo "✅ Frontend image is available in Minikube's Docker registry"
else
    echo "❌ Frontend image not found in Minikube's Docker registry"
    exit 1
fi

# Push to GitHub Container Registry if requested
if [ "$PUSH_TO_GITHUB" = true ]; then
    echo ""
    echo "📤 Pushing images to GitHub Container Registry..."
    
    # Create GitHub Container Registry secret for Kubernetes
    echo "🔐 Creating GitHub Container Registry secret for Kubernetes..."
    if [ -f ".docker-hub-token" ]; then
        GITHUB_TOKEN=$(cat .docker-hub-token)
        REGISTRY="ghcr.io"
        
        # Create Docker config JSON
        DOCKER_CONFIG=$(cat <<EOF
{
  "auths": {
    "$REGISTRY": {
      "username": "$GITHUB_USERNAME",
      "password": "$GITHUB_TOKEN",
      "auth": "$(echo -n "$GITHUB_USERNAME:$GITHUB_TOKEN" | base64 -w 0)"
    }
  }
}
EOF
        )
        
        # Encode and create secret
        DOCKER_CONFIG_B64=$(echo "$DOCKER_CONFIG" | base64 -w 0)
        
        cat > k8s/secrets/ghcr-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ghcr-secret
  namespace: default
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: $DOCKER_CONFIG_B64
EOF
        
        # Apply the secret
        kubectl apply -f k8s/secrets/ghcr-secret.yaml
        echo "✅ GitHub Container Registry secret created"
    else
        echo "⚠️ No .docker-hub-token file found, skipping secret creation"
    fi
    
    # Configuration
    REGISTRY="ghcr.io"
    REPOSITORY="$GITHUB_USERNAME/mongo-kafka-api-frontend"
    API_IMAGE_NAME="api-server"
    FRONTEND_IMAGE_NAME="customer-frontend"
    
    # Tag images for GitHub Container Registry
    echo "🏷️ Tagging images for GitHub Container Registry repository: $REPOSITORY..."
    docker tag $API_IMAGE_NAME:$VERSION $REGISTRY/$REPOSITORY/$API_IMAGE_NAME:$VERSION
    docker tag $FRONTEND_IMAGE_NAME:$VERSION $REGISTRY/$REPOSITORY/$FRONTEND_IMAGE_NAME:$VERSION
    
    # Check if already logged in to GitHub Container Registry
    echo "🔐 Checking GitHub Container Registry authentication..."
    if docker info | grep -q "Username: $GITHUB_USERNAME"; then
        echo "✅ Already logged in to GitHub Container Registry as $GITHUB_USERNAME"
    else
        echo "🔐 Attempting to login to GitHub Container Registry..."
        
        # Try using token first if provided
        if [ -n "$DOCKER_HUB_TOKEN" ]; then
            echo "🔑 Using GitHub token for authentication to GHCR..."
            echo $DOCKER_HUB_TOKEN | docker login $REGISTRY -u $GITHUB_USERNAME --password-stdin
            
            if [ $? -eq 0 ]; then
                echo "✅ Successfully logged in to GitHub Container Registry using token"
            else
                echo "❌ Failed to login to GitHub Container Registry using token"
                echo "💡 Trying alternative login method..."
                
                # Alternative: Login from within Minikube
                if minikube ssh "echo '$DOCKER_HUB_TOKEN' | docker login $REGISTRY -u $GITHUB_USERNAME --password-stdin" 2>/dev/null; then
                    echo "✅ Successfully logged in to GitHub Container Registry from within Minikube"
                else
                    echo "❌ Failed to login to GitHub Container Registry from within Minikube"
                    exit 1
                fi
            fi
        # Try to use existing Docker credentials
        elif [ -f "$HOME/.docker/config.json" ]; then
            echo "📋 Found existing Docker config at $HOME/.docker/config.json"
            echo "🔍 Testing existing credentials in Minikube..."
            
            # Test if credentials work by trying a dry-run push
            if timeout 10 docker push $GITHUB_USERNAME/$API_IMAGE_NAME:$VERSION --dry-run 2>/dev/null; then
                echo "✅ Docker credentials are valid for pushing"
            else
                echo "⚠️ Docker credentials may be expired or invalid in Minikube"
                echo "🔐 Attempting to login from within Minikube..."
                
                # Try to login from within Minikube using the copied credentials
                if minikube ssh "docker login -u $GITHUB_USERNAME" < /dev/null 2>/dev/null; then
                    echo "✅ Successfully logged in to Docker Hub from Minikube"
                else
                    echo "❌ Failed to login to Docker Hub from Minikube"
                    echo "💡 Please run: minikube ssh 'docker login -u $GITHUB_USERNAME'"
                    echo "💡 Or set DOCKER_HUB_TOKEN and run the script again"
                    exit 1
                fi
            fi
        else
            echo "❌ No Docker config found at $HOME/.docker/config.json"
            echo "💡 Please run: docker login -u $GITHUB_USERNAME"
            echo "💡 Or set DOCKER_HUB_TOKEN and run the script again"
            exit 1
        fi
    fi
    
    # Push API Server image
    echo "📤 Pushing API Server image..."
    if docker push $REGISTRY/$REPOSITORY/$API_IMAGE_NAME:$VERSION; then
        echo "✅ API Server image pushed successfully"
    else
        echo "❌ Failed to push API Server image"
        exit 1
    fi
    
    # Push Frontend image
    echo "📤 Pushing Frontend image..."
    if docker push $REGISTRY/$REPOSITORY/$FRONTEND_IMAGE_NAME:$VERSION; then
        echo "✅ Frontend image pushed successfully"
    else
        echo "❌ Failed to push Frontend image"
        exit 1
    fi
    
    echo ""
    echo "🎉 All images pushed successfully to GitHub Container Registry!"
    echo "📋 Image URLs:"
    echo "  🔌 API Server: $REGISTRY/$REPOSITORY/$API_IMAGE_NAME:$VERSION"
    echo "  🎨 Frontend:   $REGISTRY/$REPOSITORY/$FRONTEND_IMAGE_NAME:$VERSION"
    echo ""
    echo "🔍 View your packages: https://github.com/$GITHUB_USERNAME?tab=packages"
    echo ""
    
    # Update deployment files to use GitHub Container Registry images
    echo "📝 Updating deployment files to use GitHub Container Registry images..."
    
    # Update API Server deployment
    if [ -f "k8s/api-server/api-server-deployment.yaml" ]; then
        sed -i.bak "s|image: api-server:latest|image: $REGISTRY/$REPOSITORY/$API_IMAGE_NAME:$VERSION|g" k8s/api-server/api-server-deployment.yaml
        echo "✅ Updated api-server-deployment.yaml"
    fi
    
    # Update Frontend deployment
    if [ -f "k8s/frontend/frontend-deployment.yaml" ]; then
        sed -i.bak "s|image: customer-frontend:latest|image: $REGISTRY/$REPOSITORY/$FRONTEND_IMAGE_NAME:$VERSION|g" k8s/frontend/frontend-deployment.yaml
        echo "✅ Updated frontend-deployment.yaml"
    fi
    
    echo "📋 Deployment files updated to use GitHub Container Registry images"
    echo ""
fi

# Deploy MongoDB
echo "📊 Deploying MongoDB..."
kubectl apply -f k8s/mongodb/mongodb-configmap.yaml
kubectl apply -f k8s/mongodb/mongodb-secret.yaml
kubectl apply -f k8s/mongodb/mongodb-pvc.yaml
kubectl apply -f k8s/mongodb/mongodb-deployment.yaml
kubectl apply -f k8s/mongodb/mongodb-service.yaml

# Wait for MongoDB to be ready
echo "⏳ Waiting for MongoDB to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/mongodb

# Deploy Kafka
echo "📨 Deploying Kafka..."
kubectl apply -f k8s/kafka/kafka-configmap.yaml
kubectl apply -f k8s/kafka/kafka-pvc.yaml
kubectl apply -f k8s/kafka/kafka-deployment.yaml
kubectl apply -f k8s/kafka/kafka-service.yaml

# Wait for Kafka to be ready
echo "⏳ Waiting for Kafka to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/kafka

# Create Kafka topics
echo "📋 Creating Kafka topics..."
kubectl apply -f k8s/kafka/kafka-topics.yaml
kubectl apply -f k8s/kafka/kafka-topic-creator.yaml
kubectl wait --for=condition=complete --timeout=120s job/kafka-topic-creator

# Deploy API Server
echo "🔌 Deploying API Server..."
kubectl apply -f k8s/api-server/api-server-deployment.yaml
kubectl apply -f k8s/api-server/api-server-service.yaml

# Wait for API Server to be ready
echo "⏳ Waiting for API Server to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/api-server

# Deploy Frontend
echo "🎨 Deploying Frontend..."
kubectl apply -f k8s/frontend/frontend-deployment.yaml
kubectl apply -f k8s/frontend/frontend-service.yaml

# Wait for Frontend to be ready
echo "⏳ Waiting for Frontend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend

# Deploy Metrics Server
echo "📈 Deploying Metrics Server..."
kubectl apply -f k8s/monitoring/metrics-server.yaml

# Wait for metrics server to be ready
echo "⏳ Waiting for metrics server to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system

# Deploy Autoscaling
echo "📊 Deploying Autoscaling..."
kubectl apply -f k8s/api-server/api-server-hpa.yaml
kubectl apply -f k8s/frontend/frontend-hpa.yaml
kubectl apply -f k8s/kafka/kafka-hpa.yaml
kubectl apply -f k8s/mongodb/mongodb-hpa.yaml

# Get service URLs
echo "🔗 Getting service URLs..."
API_URL=$(minikube service api-server-service-nodeport --url)
FRONTEND_URL=$(minikube service frontend-service-nodeport --url)

# Display status
echo ""
echo "🎉 Unity Stack is running on Minikube!"
echo ""
echo "📡 Access Information:"
echo "  🌐 Frontend:           $FRONTEND_URL"
echo "  🔌 API Server:         $API_URL"
echo "  📊 Health Check:       $API_URL/health"
echo "  📊 Minikube Dashboard: minikube dashboard"

if [ "$PUSH_TO_GITHUB" = true ]; then
    echo ""
    echo "📦 GitHub Container Registry Images:"
    echo "  🔌 API Server:       ghcr.io/$GITHUB_USERNAME/api-server:$VERSION"
    echo "  🎨 Frontend:         ghcr.io/$GITHUB_USERNAME/customer-frontend:$VERSION"
    echo "  🔍 View Packages:    https://github.com/$GITHUB_USERNAME?tab=packages"
    echo ""
    echo "📝 Note: Deployment files have been updated to use GitHub Container Registry images"
    echo "   To restore local images: $0 --restore-deployments"
fi
echo ""
echo "📋 Service Status:"
kubectl get pods
kubectl get services
echo ""
echo "🔍 Useful Commands:"
echo "  View logs:            kubectl logs -f deployment/[service-name]"
echo "  Stop Minikube:        minikube stop"
echo "  Delete Minikube:      minikube delete"
echo "  Open dashboard:       minikube dashboard"
echo "  Get service URL:      minikube service [service-name] --url"
echo ""
echo "🧪 Test the Stack:"
echo "  1. Open browser: $FRONTEND_URL"
echo "  2. Enter your name and test the interface"
echo "  3. Check API: curl $API_URL/health"
echo "  4. View logs: kubectl logs -f deployment/api-server"
echo ""
echo "✨ Your local Minikube development environment is ready!"
