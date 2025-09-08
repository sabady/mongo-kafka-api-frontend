#!/bin/bash

# Check GitHub Token Format and Permissions
echo "🔍 Checking GitHub Token"
echo "========================"
echo ""

# Load token from file
if [ -f ".docker-hub-token" ]; then
    TOKEN=$(cat .docker-hub-token)
    echo "✅ Token loaded from .docker-hub-token"
    echo "📏 Token length: ${#TOKEN} characters"
    echo "🔍 Token preview: ${TOKEN:0:10}..."
    
    # Check token format
    if [[ $TOKEN =~ ^ghp_ ]]; then
        echo "✅ Token format: GitHub Personal Access Token (ghp_)"
    elif [[ $TOKEN =~ ^gho_ ]]; then
        echo "✅ Token format: GitHub OAuth Token (gho_)"
    elif [[ $TOKEN =~ ^ghu_ ]]; then
        echo "✅ Token format: GitHub User Token (ghu_)"
    elif [[ $TOKEN =~ ^ghs_ ]]; then
        echo "✅ Token format: GitHub Server Token (ghs_)"
    elif [[ $TOKEN =~ ^ghr_ ]]; then
        echo "✅ Token format: GitHub Refresh Token (ghr_)"
    else
        echo "⚠️ Unknown token format - should start with ghp_, gho_, ghu_, ghs_, or ghr_"
    fi
    
    echo ""
    echo "🔍 Testing token with GitHub API..."
    
    # Test token with GitHub API
    RESPONSE=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/user)
    
    if echo "$RESPONSE" | grep -q '"login"'; then
        USERNAME=$(echo "$RESPONSE" | grep '"login"' | cut -d'"' -f4)
        echo "✅ Token is valid for user: $USERNAME"
    else
        echo "❌ Token is invalid or expired"
        echo "💡 Response: $RESPONSE"
        exit 1
    fi
    
    echo ""
    echo "🔍 Checking package permissions..."
    
    # Check if user can access packages
    PACKAGES_RESPONSE=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/user/packages)
    
    if echo "$PACKAGES_RESPONSE" | grep -q '"name"'; then
        echo "✅ Token has package access permissions"
    else
        echo "⚠️ Token may not have package permissions"
        echo "💡 Make sure token has 'write:packages' scope"
    fi
    
else
    echo "❌ No .docker-hub-token file found"
    exit 1
fi

echo ""
echo "🎯 Next steps:"
echo "   1. Run: ./test-ghcr-auth.sh"
echo "   2. If successful, run: ./run-local-minikube.sh --push-github --github-user sabady"
