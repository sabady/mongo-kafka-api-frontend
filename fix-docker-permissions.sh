#!/bin/bash

# Fix Docker Permissions for Minikube
echo "🔧 Fixing Docker permissions for Minikube..."

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root"
    echo "Run it as your regular user: ./fix-docker-permissions.sh"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

echo "✅ Docker is installed"

# Check if user is already in docker group
if groups $USER | grep -q '\bdocker\b'; then
    echo "✅ User $USER is already in the docker group"
else
    echo "🔧 Adding user $USER to docker group..."
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    if [ $? -eq 0 ]; then
        echo "✅ User $USER added to docker group"
        echo ""
        echo "⚠️ IMPORTANT: You need to log out and log back in for the changes to take effect!"
        echo "Alternatively, you can run: newgrp docker"
        echo ""
        echo "After logging back in, test with: docker ps"
    else
        echo "❌ Failed to add user to docker group"
        exit 1
    fi
fi

# Check if Docker daemon is running
echo "🔍 Checking Docker daemon status..."
if sudo systemctl is-active --quiet docker; then
    echo "✅ Docker daemon is running"
else
    echo "⚠️ Docker daemon is not running"
    echo "🔧 Starting Docker daemon..."
    sudo systemctl start docker
    sudo systemctl enable docker
    
    if [ $? -eq 0 ]; then
        echo "✅ Docker daemon started and enabled"
    else
        echo "❌ Failed to start Docker daemon"
        exit 1
    fi
fi

# Test Docker permissions
echo "🧪 Testing Docker permissions..."
if docker ps &> /dev/null; then
    echo "✅ Docker permissions are working correctly"
else
    echo "❌ Docker permissions are not working"
    echo "💡 Try one of these solutions:"
    echo "   1. Log out and log back in"
    echo "   2. Run: newgrp docker"
    echo "   3. Restart your terminal session"
    echo "   4. Check if Docker daemon is running: sudo systemctl status docker"
fi

# Check Minikube Docker driver
echo "🔍 Checking Minikube Docker driver..."
if docker info &> /dev/null; then
    echo "✅ Docker is accessible to Minikube"
else
    echo "❌ Docker is not accessible to Minikube"
    echo "💡 Make sure Docker is running and accessible"
fi

echo ""
echo "🎉 Docker permissions setup completed!"
echo ""
echo "📋 Next steps:"
echo "   1. If you were added to docker group, log out and log back in"
echo "   2. Test Docker: docker ps"
echo "   3. Test Minikube: minikube start --driver=docker"
echo "   4. Run the stack: ./run-local-minikube.sh"
echo ""
echo "💡 If you still have issues:"
echo "   - Check Docker status: sudo systemctl status docker"
echo "   - Check your groups: groups"
echo "   - Restart Docker: sudo systemctl restart docker"
