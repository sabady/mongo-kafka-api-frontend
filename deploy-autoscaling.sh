#!/bin/bash

# Deploy Autoscaling Components to Kubernetes
echo "🚀 Deploying Autoscaling Components to Kubernetes..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we can connect to Kubernetes cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

echo "✅ Kubernetes cluster connection verified"

# Deploy Metrics Server
echo "📊 Deploying Metrics Server..."
kubectl apply -f metrics-server.yaml
if [ $? -eq 0 ]; then
    echo "✅ Metrics Server deployed"
else
    echo "❌ Failed to deploy Metrics Server"
    exit 1
fi

# Wait for metrics server to be ready
echo "⏳ Waiting for Metrics Server to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system

if [ $? -eq 0 ]; then
    echo "✅ Metrics Server is ready!"
else
    echo "❌ Metrics Server failed to become ready within 5 minutes"
    exit 1
fi

# Deploy Prometheus
echo "📈 Deploying Prometheus..."
kubectl apply -f prometheus-server.yaml
if [ $? -eq 0 ]; then
    echo "✅ Prometheus deployed"
else
    echo "❌ Failed to deploy Prometheus"
    exit 1
fi

# Wait for Prometheus to be ready
echo "⏳ Waiting for Prometheus to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus

if [ $? -eq 0 ]; then
    echo "✅ Prometheus is ready!"
else
    echo "❌ Prometheus failed to become ready within 5 minutes"
    exit 1
fi

# Deploy Custom Metrics Server
echo "📊 Deploying Custom Metrics Server..."
kubectl apply -f custom-metrics-server.yaml
if [ $? -eq 0 ]; then
    echo "✅ Custom Metrics Server deployed"
else
    echo "❌ Failed to deploy Custom Metrics Server"
    exit 1
fi

# Wait for custom metrics server to be ready
echo "⏳ Waiting for Custom Metrics Server to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/custom-metrics-server

if [ $? -eq 0 ]; then
    echo "✅ Custom Metrics Server is ready!"
else
    echo "❌ Custom Metrics Server failed to become ready within 5 minutes"
    exit 1
fi

# Deploy Horizontal Pod Autoscalers
echo "📈 Deploying Horizontal Pod Autoscalers..."

kubectl apply -f api-server-hpa.yaml
if [ $? -eq 0 ]; then
    echo "✅ API Server HPA deployed"
else
    echo "❌ Failed to deploy API Server HPA"
    exit 1
fi

kubectl apply -f frontend-hpa.yaml
if [ $? -eq 0 ]; then
    echo "✅ Frontend HPA deployed"
else
    echo "❌ Failed to deploy Frontend HPA"
    exit 1
fi

kubectl apply -f kafka-hpa.yaml
if [ $? -eq 0 ]; then
    echo "✅ Kafka HPA deployed"
else
    echo "❌ Failed to deploy Kafka HPA"
    exit 1
fi

kubectl apply -f mongodb-hpa.yaml
if [ $? -eq 0 ]; then
    echo "✅ MongoDB HPA deployed"
else
    echo "❌ Failed to deploy MongoDB HPA"
    exit 1
fi

# Deploy Vertical Pod Autoscalers (if VPA is installed)
echo "📊 Checking for VPA installation..."
if kubectl get crd verticalpodautoscalers.autoscaling.k8s.io &> /dev/null; then
    echo "✅ VPA is installed, deploying VPA resources..."
    
    kubectl apply -f api-server-hpa.yaml
    kubectl apply -f frontend-hpa.yaml
    kubectl apply -f kafka-hpa.yaml
    kubectl apply -f mongodb-hpa.yaml
    
    echo "✅ VPA resources deployed"
else
    echo "⚠️ VPA is not installed, skipping VPA deployment"
    echo "   To install VPA, run: kubectl apply -f https://github.com/kubernetes/autoscaler/releases/download/vertical-pod-autoscaler-0.13.0/vpa-release.yaml"
fi

# Get status information
echo "📋 Autoscaling Status:"
kubectl get hpa
kubectl get vpa 2>/dev/null || echo "VPA not available"

echo "📋 Metrics Server Status:"
kubectl get pods -n kube-system -l k8s-app=metrics-server

echo "📋 Prometheus Status:"
kubectl get pods -l app=prometheus

echo "📋 Custom Metrics Server Status:"
kubectl get pods -l app=custom-metrics-server

echo ""
echo "🎉 Autoscaling deployment completed successfully!"
echo ""
echo "📡 Access Information:"
echo "  - Prometheus: http://<node-ip>:30090"
echo "  - Metrics API: kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes"
echo "  - Custom Metrics API: kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1"
echo ""
echo "🔍 To check autoscaling status:"
echo "  kubectl get hpa"
echo "  kubectl describe hpa <hpa-name>"
echo "  kubectl get vpa"
echo ""
echo "📊 To check metrics:"
echo "  kubectl top nodes"
echo "  kubectl top pods"
echo "  kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods"
echo ""
echo "🧪 To test autoscaling:"
echo "  1. Generate load on your services"
echo "  2. Monitor HPA status: kubectl get hpa -w"
echo "  3. Check pod scaling: kubectl get pods -w"
echo "  4. View metrics in Prometheus: http://<node-ip>:30090"
