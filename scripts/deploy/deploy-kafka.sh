#!/bin/bash

# Deploy Kafka Cluster to Kubernetes
echo "🚀 Deploying Kafka Cluster to Kubernetes..."

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

# Apply Kafka manifests
echo "📦 Applying Kafka manifests..."

# Deploy Kafka configuration
kubectl apply -f k8s/kafka/kafka-configmap.yaml
if [ $? -eq 0 ]; then
    echo "✅ Kafka configuration applied"
else
    echo "❌ Failed to apply Kafka configuration"
    exit 1
fi

# Deploy Kafka PVC
kubectl apply -f k8s/kafka/kafka-pvc.yaml
if [ $? -eq 0 ]; then
    echo "✅ Kafka PVC applied"
else
    echo "❌ Failed to apply Kafka PVC"
    exit 1
fi

# Deploy Kafka
kubectl apply -f k8s/kafka/kafka-deployment.yaml
if [ $? -eq 0 ]; then
    echo "✅ Kafka deployment applied"
else
    echo "❌ Failed to apply Kafka deployment"
    exit 1
fi

# Deploy Kafka services
kubectl apply -f k8s/kafka/kafka-service.yaml
if [ $? -eq 0 ]; then
    echo "✅ Kafka services applied"
else
    echo "❌ Failed to apply Kafka services"
    exit 1
fi

# Wait for Kafka to be ready
echo "⏳ Waiting for Kafka to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/kafka

if [ $? -eq 0 ]; then
    echo "✅ Kafka is ready!"
else
    echo "❌ Kafka failed to become ready within 5 minutes"
    echo "📋 Checking pod status..."
    kubectl get pods -l app=kafka
    exit 1
fi

# Deploy Kafka topics
echo "📋 Creating Kafka topics..."
kubectl apply -f k8s/kafka/kafka-topics.yaml
kubectl apply -f k8s/kafka/kafka-topic-creator.yaml

# Wait for topic creation job to complete
echo "⏳ Waiting for Kafka topics to be created..."
kubectl wait --for=condition=complete --timeout=120s job/k8s/kafka/kafka-topic-creator

if [ $? -eq 0 ]; then
    echo "✅ Kafka topics created successfully!"
else
    echo "⚠️ Kafka topic creation may have failed, but continuing..."
fi

# Get service information
echo "📋 Kafka Service Information:"
kubectl get services -l app=kafka

# Get pod information
echo "📋 Kafka Pod Information:"
kubectl get pods -l app=kafka

# List created topics
echo "📋 Created Kafka Topics:"
kubectl logs job/k8s/kafka/kafka-topic-creator

echo ""
echo "🎉 Kafka Cluster deployment completed successfully!"
echo ""
echo "📡 Kafka Access Information:"
echo "  - ClusterIP Service: k8s/kafka/kafka-service:9092"
echo "  - NodePort Service: <node-ip>:30092"
echo "  - JMX Port: <node-ip>:30101"
echo ""
echo "📨 Available Topics:"
echo "  - user-events"
echo "  - product-events"
echo "  - order-events"
echo "  - api-events"
echo "  - audit-logs"
echo ""
echo "🔍 To check Kafka logs:"
echo "  kubectl logs -l app=kafka -f"
echo ""
echo "🔍 To check Kafka status:"
echo "  kubectl get pods -l app=kafka"
echo "  kubectl get services -l app=kafka"
echo ""
echo "🧪 To test Kafka connectivity:"
echo "  kubectl run k8s/kafka/kafka-test --image=confluentinc/cp-kafka:7.4.0 --rm -it --restart=Never -- k8s/kafka/kafka-topics --bootstrap-server k8s/kafka/kafka-service:9092 --list"
