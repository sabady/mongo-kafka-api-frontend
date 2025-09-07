#!/bin/bash

# Stop Local Minikube Development Environment
echo "🛑 Stopping Unity Stack on Minikube..."

# Check if minikube is available
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube is not installed or not in PATH"
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Stop Minikube
echo "🛑 Stopping Minikube..."
minikube stop

echo "✅ Minikube stopped successfully!"
echo ""
echo "💡 To completely remove Minikube and all data:"
echo "   minikube delete"
echo ""
echo "💡 To start again:"
echo "   ./run-local-minikube.sh"
