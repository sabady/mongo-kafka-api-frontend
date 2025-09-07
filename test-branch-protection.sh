#!/bin/bash

# Test script to verify branch protection is working
# This script attempts to push directly to main and should fail

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing branch protection for main branch...${NC}"

# Create a test branch
TEST_BRANCH="test-branch-protection-$(date +%s)"
echo -e "${YELLOW}Creating test branch: ${TEST_BRANCH}${NC}"

git checkout -b "$TEST_BRANCH"

# Create a test file
echo "This is a test file to verify branch protection" > test-branch-protection.txt
git add test-branch-protection.txt
git commit -m "test: verify branch protection is working"

echo -e "${YELLOW}Attempting to push directly to main (this should fail)...${NC}"

# Try to push directly to main - this should fail
if git push origin "$TEST_BRANCH:main" 2>&1 | grep -q "remote: error: GH006: Protected branch update failed"; then
    echo -e "${GREEN}✅ Branch protection is working! Direct push to main was blocked.${NC}"
    PROTECTION_WORKING=true
else
    echo -e "${RED}❌ Branch protection may not be working. Direct push to main was allowed.${NC}"
    PROTECTION_WORKING=false
fi

# Clean up test branch
echo -e "${YELLOW}Cleaning up test branch...${NC}"
git checkout main
git branch -D "$TEST_BRANCH"

# Test creating a proper pull request
echo -e "${YELLOW}Testing proper pull request workflow...${NC}"
git checkout -b "$TEST_BRANCH"
echo "This is a test file for proper PR workflow" > test-pr-workflow.txt
git add test-pr-workflow.txt
git commit -m "test: proper PR workflow"
git push origin "$TEST_BRANCH"

echo -e "${GREEN}✅ Test branch pushed successfully: ${TEST_BRANCH}${NC}"
echo -e "${BLUE}📋 Next steps:${NC}"
echo -e "1. Go to: https://github.com/sabady/mongo-kafka-api-frontend/compare/main...$TEST_BRANCH"
echo -e "2. Create a pull request"
echo -e "3. Verify that the PR requires review and status checks"

# Clean up
git checkout main
git branch -D "$TEST_BRANCH"
git push origin --delete "$TEST_BRANCH" 2>/dev/null || true

if [ "$PROTECTION_WORKING" = true ]; then
    echo -e "${GREEN}🎉 Branch protection test completed successfully!${NC}"
    echo -e "${BLUE}Your main branch is now protected and requires pull requests for changes.${NC}"
else
    echo -e "${RED}⚠️  Branch protection test failed. Please check your GitHub repository settings.${NC}"
    echo -e "${YELLOW}Make sure you've set up branch protection rules in GitHub.${NC}"
fi
