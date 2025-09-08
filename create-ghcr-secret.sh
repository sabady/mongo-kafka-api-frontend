#!/bin/bash

# Create GitHub Container Registry Secret for Kubernetes
echo "🔐 Creating GitHub Container Registry Secret"
echo "============================================="
echo ""

# Check if token file exists
if [ ! -f ".docker-hub-token" ]; then
    echo "❌ No .docker-hub-token file found"
    echo "💡 Create the file with your GitHub token"
    exit 1
fi

# Load token
GITHUB_TOKEN=$(cat .docker-hub-token)
GITHUB_USERNAME="sabady"
REGISTRY="ghcr.io"

echo "✅ Loaded GitHub token for user: $GITHUB_USERNAME"
echo "🔍 Token preview: ${GITHUB_TOKEN:0:10}..."

# Create Docker config JSON
echo ""
echo "📝 Creating Docker config JSON..."

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

# Encode the Docker config
DOCKER_CONFIG_B64=$(echo "$DOCKER_CONFIG" | base64 -w 0)

echo "✅ Docker config created and encoded"

# Create the secret YAML
cat > ghcr-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ghcr-secret
  namespace: default
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: $DOCKER_CONFIG_B64
EOF

echo "✅ Created ghcr-secret.yaml"

# Apply the secret to Kubernetes
echo ""
echo "🚀 Applying secret to Kubernetes..."

if kubectl apply -f ghcr-secret.yaml; then
    echo "✅ GitHub Container Registry secret created successfully"
else
    echo "❌ Failed to create secret"
    exit 1
fi

# Verify the secret
echo ""
echo "🔍 Verifying secret..."

if kubectl get secret ghcr-secret; then
    echo "✅ Secret exists in Kubernetes"
else
    echo "❌ Secret not found"
    exit 1
fi

echo ""
echo "🎉 GitHub Container Registry secret is ready!"
echo ""
echo "📋 Usage in deployments:"
echo "  Add this to your pod spec:"
echo "  imagePullSecrets:"
echo "  - name: ghcr-secret"
echo ""
echo "📋 Usage for image pulls:"
echo "  kubectl create secret docker-registry ghcr-secret \\"
echo "    --docker-server=ghcr.io \\"
echo "    --docker-username=sabady \\"
echo "    --docker-password=\$GITHUB_TOKEN \\"
echo "    --docker-email=your-email@example.com"
