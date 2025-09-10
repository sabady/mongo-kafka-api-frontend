# 🚀 Running Unity Stack Locally with Minikube

This guide shows you how to run the complete Unity microservices stack locally using Minikube for development and testing.

## 📋 Prerequisites

Before running the stack locally, ensure you have the following installed:

### Required Software
- **Minikube**: Kubernetes cluster for local development
- **kubectl**: Kubernetes command-line tool
- **Docker**: Container runtime (Minikube will use this)

### Installation Commands

#### Ubuntu/Debian
```bash
# Install Docker
sudo apt update
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

#### macOS
```bash
# Install using Homebrew
brew install minikube kubectl docker
```

#### Windows
```bash
# Install using Chocolatey
choco install minikube kubectl docker-desktop
```

## 🚀 Quick Start

### 1. Fix Docker Permissions (If Needed)
```bash
./fix-docker-permissions.sh
```

### 2. Test Minikube Setup (Optional)
```bash
./test-minikube.sh
```

### 3. Start the Complete Stack
```bash
./run-local-minikube.sh
```

**Note**: The script automatically configures the `local-path` storage class for persistent volumes. If you encounter storage issues, you can manually set it up:

```bash
./setup-storage.sh
```

This script will:
- Start Minikube with 4GB RAM and 2 CPUs
- Enable required addons (metrics-server, ingress, dashboard)
- Build Docker images for API server and frontend
- Deploy all services in the correct order
- Wait for all services to be ready
- Display access URLs

### 2. Access Your Services

After the script completes, you'll see URLs like:
```
📡 Access Information:
  🌐 Frontend:           http://192.168.49.2:30080
  🔌 API Server:         http://192.168.49.2:30080
  📊 Health Check:       http://192.168.49.2:30080/health
  📈 Prometheus:         http://192.168.49.2:30090
  📊 Minikube Dashboard: minikube dashboard
```

### 3. Test the Stack

#### Frontend Interface
1. Open your browser to the Frontend URL
2. Enter your name
3. Click "Add Random Item" to add items to your list
4. Click "Get Products from MongoDB" to fetch products

#### API Testing
```bash
# Health check
curl http://192.168.49.2:30080/health

# Create a user
curl -X POST http://192.168.49.2:30080/api/users \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test User","email":"test@example.com"}'

# Get users
curl http://192.168.49.2:30080/api/users
```

#### Kafka Testing
```bash
# List Kafka topics
kubectl exec -it deployment/kafka -- kafka-topics --bootstrap-server localhost:9092 --list

# Send a test message
kubectl exec -it deployment/kafka -- kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic user-events
```

## 🔧 Development Workflow

### Hot Reloading
The Docker images are built with volume mounts for development:

```bash
# API Server development
# Edit files in src/ directory
# Changes will be reflected after container restart

# Frontend development
# Edit files in frontend/src/ directory
# Changes will be reflected after container restart
```

### Viewing Logs
```bash
# API Server logs
kubectl logs -f deployment/api-server

# Frontend logs
kubectl logs -f deployment/frontend

# Kafka logs
kubectl logs -f deployment/kafka

# MongoDB logs
kubectl logs -f deployment/mongodb
```

### Scaling Services
```bash
# Scale API Server
kubectl scale deployment api-server --replicas=3

# Scale Frontend
kubectl scale deployment frontend --replicas=2

# Check autoscaling
kubectl get hpa
```

## 📊 Monitoring

### Prometheus Metrics
- **URL**: `http://192.168.49.2:30090`
- **API Server Metrics**: `/metrics` endpoint
- **Custom Metrics**: Business-specific metrics

### Minikube Dashboard
```bash
minikube dashboard
```
This opens the Kubernetes dashboard in your browser.

### Resource Usage
```bash
# View resource usage
kubectl top nodes
kubectl top pods

# View autoscaling status
kubectl get hpa
kubectl describe hpa api-server-hpa
```

## 🛠️ Troubleshooting

### Common Issues

#### Docker Permissions Issues
```bash
# Fix Docker permissions
./fix-docker-permissions.sh

# Or manually:
sudo usermod -aG docker $USER
# Then log out and log back in

# Test Docker permissions
docker ps

# Check if user is in docker group
groups $USER
```

#### Minikube Won't Start
```bash
# Test Minikube setup
./test-minikube.sh

# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Start Minikube with more resources
minikube start --memory=6144 --cpus=3

# Check Minikube logs
minikube logs

# Delete and recreate Minikube
minikube delete
minikube start --memory=4096 --cpus=2 --driver=docker
```

#### Services Not Ready
```bash
# Check pod status
kubectl get pods

# Check pod logs
kubectl logs deployment/[service-name]

# Check service endpoints
kubectl get endpoints
```

#### Port Access Issues
```bash
# Get service URLs
minikube service api-server-service-nodeport --url
minikube service frontend-service-nodeport --url

# Port forward for direct access
kubectl port-forward service/api-server-service 3000:3000
kubectl port-forward service/frontend-service 3001:80
```

#### Storage Issues
```bash
# Check storage classes
kubectl get storageclass

# Check PVC status
kubectl get pvc

# Check PV status
kubectl get pv

# Setup local-path storage class
./setup-storage.sh

# Check PVC details
kubectl describe pvc mongodb-pvc
kubectl describe pvc kafka-pvc
```

### Reset Everything
```bash
# Stop and delete Minikube
minikube stop
minikube delete

# Start fresh
./run-local-minikube.sh
```

## 🧪 Testing

### Run Tests
```bash
# Backend tests
npm test

# Frontend tests
cd frontend
npm test

# Integration tests
npm run test:integration
```

### Load Testing
```bash
# Install Artillery
npm install -g artillery

# Run load test
artillery run load-test.yml
```

## 📁 Project Structure

```
Unity/
├── run-local-minikube.sh      # Start local development
├── stop-local-minikube.sh     # Stop local development
├── docker-compose.yml         # Alternative Docker Compose setup
├── src/                       # API Server source code
├── frontend/                  # React frontend
├── tests/                     # Test suites
├── *.yaml                     # Kubernetes manifests
└── README-LOCAL.md           # This file
```

## 🔄 Development Commands

### Quick Commands
```bash
# Start everything
./run-local-minikube.sh

# Stop everything
./stop-local-minikube.sh

# View logs
kubectl logs -f deployment/api-server

# Restart a service
kubectl rollout restart deployment/api-server

# Check status
kubectl get pods
kubectl get services
kubectl get hpa
```

### Database Access
```bash
# Connect to MongoDB
kubectl exec -it deployment/mongodb -- mongosh mongodb://admin:admin123@localhost:27017/admin

# List databases
kubectl exec -it deployment/mongodb -- mongosh --eval "show dbs"
```

### Kafka Management
```bash
# List topics
kubectl exec -it deployment/kafka -- kafka-topics --bootstrap-server localhost:9092 --list

# Create topic
kubectl exec -it deployment/kafka -- kafka-topics --bootstrap-server localhost:9092 --create --topic test-topic

# Consume messages
kubectl exec -it deployment/kafka -- kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --from-beginning
```

## 🎯 Next Steps

1. **Explore the Frontend**: Test the customer interface
2. **Monitor Metrics**: Check Prometheus for system metrics
3. **Test Autoscaling**: Generate load to see HPA in action
4. **Develop Features**: Make changes and see them reflected
5. **Run Tests**: Ensure your changes don't break anything

## 📚 Additional Resources

- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Kafka Documentation](https://kafka.apache.org/documentation/)

---

**Happy coding! 🚀**
