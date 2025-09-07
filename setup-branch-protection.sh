#!/bin/bash

# Branch Protection Setup Script for GitHub
# This script sets up branch protection rules for the main branch

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository information
REPO_OWNER="sabady"
REPO_NAME="mongo-kafka-api-frontend"
BRANCH="main"

echo -e "${BLUE}🔒 Setting up branch protection for ${REPO_OWNER}/${REPO_NAME}${NC}"

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed.${NC}"
    echo -e "${YELLOW}Please install it first:${NC}"
    echo "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
    echo "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
    echo "sudo apt update && sudo apt install gh"
    echo "gh auth login"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ Not authenticated with GitHub CLI.${NC}"
    echo -e "${YELLOW}Please run: gh auth login${NC}"
    exit 1
fi

# Check if repository exists and user has access
if ! gh repo view "${REPO_OWNER}/${REPO_NAME}" &> /dev/null; then
    echo -e "${RED}❌ Repository ${REPO_OWNER}/${REPO_NAME} not found or no access.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Repository access confirmed${NC}"

# Create branch protection rule
echo -e "${BLUE}🔧 Creating branch protection rule...${NC}"

# Set up branch protection with comprehensive rules
gh api repos/${REPO_OWNER}/${REPO_NAME}/branches/${BRANCH}/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["CI","Security","Performance"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_code_owner_reviews":false}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false \
  --field required_conversation_resolution=true \
  --field require_signed_commits=true \
  --field require_linear_history=true \
  --field allow_squash_merge=true \
  --field allow_merge_commit=false \
  --field allow_rebase_merge=true \
  --field allow_auto_merge=false \
  --field delete_branch_on_merge=true

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Branch protection rule created successfully!${NC}"
else
    echo -e "${RED}❌ Failed to create branch protection rule${NC}"
    exit 1
fi

# Display current protection status
echo -e "${BLUE}📋 Current branch protection status:${NC}"
gh api repos/${REPO_OWNER}/${REPO_NAME}/branches/${BRANCH}/protection | jq '{
  required_status_checks: .required_status_checks,
  enforce_admins: .enforce_admins.enabled,
  required_pull_request_reviews: .required_pull_request_reviews,
  restrictions: .restrictions,
  allow_force_pushes: .allow_force_pushes.enabled,
  allow_deletions: .allow_deletions.enabled,
  required_conversation_resolution: .required_conversation_resolution.enabled,
  require_signed_commits: .require_signed_commits.enabled,
  require_linear_history: .require_linear_history.enabled
}'

echo -e "${GREEN}🎉 Branch protection setup complete!${NC}"
echo -e "${YELLOW}Note: Some status checks (CI, Security, Performance) will be available after the first workflow runs.${NC}"
echo -e "${BLUE}You can now only merge changes via pull requests with proper reviews and passing tests.${NC}"
